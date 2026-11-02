#!/usr/bin/env python3
"""KAORI Docs #45: fail-closed admission evidence reuse selector.

This selector never signs a release, writes a host receipt or makes release
decisions. A verified previous *full* staging admission may authorize only
the bounded fresh Fast Smoke profile; every ambiguity falls back to FULL.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
import zipfile
from datetime import UTC, datetime, timedelta
from typing import Any

REPO = "OXY7O/kaori-docs"
WORKFLOW = ".github/workflows/quality.yml"
VERSION = "KAORI_DOCS_ADMISSION_AUTHORITY_V1"
GATES = (
    "Promotion Policy",
    "Full Admission",
    "Container Admission",
    "Browser Quality Evidence",
    "Admission Evidence",
)
SHA = re.compile(r"^[a-f0-9]{40}$")
DIGEST = re.compile(r"^sha256:[a-f0-9]{64}$")
AUTHORITY_PATHS = (
    ".github/workflows", ".github/ci", "scripts", "tests",
    "package.json", "package-lock.json", ".npmrc", ".nvmrc",
    ".prettierrc.json", ".prettierignore", "playwright.config.ts",
    "docusaurus.config.ts", "tsconfig.json", "sidebars.ts",
    "Dockerfile", ".dockerignore", "deploy/server", "compose.dev.yml",
)


def git(*args: str) -> str:
    return subprocess.check_output(("git", *args), text=True).strip()


def authority() -> tuple[str, str, str]:
    source = git("rev-parse", "HEAD")
    tree = git("rev-parse", "HEAD^{tree}")
    if not SHA.fullmatch(source) or not SHA.fullmatch(tree):
        raise ValueError("invalid exact Git source/tree identity")
    listing = git("ls-tree", "-r", "HEAD", "--", *AUTHORITY_PATHS)
    if not listing:
        raise ValueError("empty validation authority")
    fingerprint = hashlib.sha256(
        (VERSION + "\n" + "\n".join(sorted(listing.splitlines())) + "\n").encode()
    ).hexdigest()
    return source, tree, "sha256:" + fingerprint


def iso(value: Any) -> datetime:
    if not isinstance(value, str):
        raise ValueError("missing evidence timestamp")
    dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        raise ValueError("naive evidence timestamp")
    return dt.astimezone(UTC)


def valid_evidence(
    evidence: dict[str, Any],
    *,
    source: str,
    tree: str,
    fingerprint: str,
    run_id: int,
    run_attempt: int,
    now: datetime,
) -> bool:
    """Pure validator; no trusted status is inferred from artifact alone."""
    try:
        created = iso(evidence.get("created_at"))
        if created > now + timedelta(minutes=5) or now - created > timedelta(days=30):
            return False
        gates = evidence.get("mandatory_gate_conclusions", {})
        return all((
            evidence.get("schema_version") == 2,
            evidence.get("profile") == "full",
            evidence.get("reuse_authorized") is True,
            evidence.get("repository") == REPO,
            evidence.get("canonical_workflow") == WORKFLOW,
            evidence.get("source_sha") == source,
            evidence.get("source_tree_sha") == tree,
            evidence.get("validation_authority_fingerprint") == fingerprint,
            evidence.get("evidence_run_id") == run_id,
            evidence.get("evidence_attempt") == run_attempt,
            evidence.get("source_event") == "push",
            evidence.get("source_ref") == "refs/heads/kaori/staging",
            evidence.get("executed_workflow_ref") ==
            f"{REPO}/{WORKFLOW}@refs/heads/kaori/staging",
            evidence.get("executed_workflow_sha") == source,
            isinstance(gates, dict),
            all(gates.get(gate) == "success" for gate in GATES if gate != "Admission Evidence"),
        ))
    except (ValueError, TypeError, OverflowError):
        return False


class SafeRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        target = urllib.parse.urlparse(newurl)
        if target.scheme != "https":
            raise ValueError("non-HTTPS GitHub artifact redirect")
        redirected = super().redirect_request(req, fp, code, msg, headers, newurl)
        if redirected is not None and target.hostname != urllib.parse.urlparse(req.full_url).hostname:
            redirected.remove_header("Authorization")
        return redirected


OPENER = urllib.request.build_opener(SafeRedirect())


def github(path: str, token: str, *, binary: bool = False) -> Any:
    parsed = urllib.parse.urlparse(path)
    if parsed.scheme != "https" or parsed.hostname != "api.github.com":
        raise ValueError("GitHub API authority changed")
    request = urllib.request.Request(
        path,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    with OPENER.open(request, timeout=15) as response:
        raw = response.read(1_000_000 if binary else 2_000_000)
    return raw if binary else json.loads(raw)


def ancestor(old: str, current: str) -> bool:
    try:
        subprocess.run(
            ("git", "merge-base", "--is-ancestor", old, current),
            check=True,
            capture_output=True,
            timeout=10,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return False
    return True


def choose(token: str) -> tuple[bool, str, str]:
    if os.environ.get("GITHUB_REPOSITORY") != REPO:
        return False, "", "wrong repository"
    source, tree, fingerprint = authority()
    if os.environ.get("KAORI_DOCS_SOURCE_SHA") != source:
        return False, "", "source checkout changed"
    if os.environ.get("GITHUB_EVENT_NAME") == "pull_request":
        if not (
            os.environ.get("GITHUB_HEAD_REF") == "kaori/staging"
            and os.environ.get("GITHUB_BASE_REF") == "main"
            and os.environ.get("ADMISSION_HEAD_REPO") == REPO
        ):
            return False, "", "untrusted promotion lineage"
    elif os.environ.get("GITHUB_REF") not in (
        "refs/heads/kaori/staging", "refs/heads/main"
    ):
        return False, "", "not a governed integration branch"
    if os.environ.get("GITHUB_EVENT_NAME") not in (
        "push", "pull_request", "workflow_dispatch"
    ):
        return False, "", "not a recognized admission event"
    current_run = os.environ.get("GITHUB_RUN_ID", "")
    if not current_run.isdigit() or not token:
        return False, "", "no trusted run identity"
    api = f"https://api.github.com/repos/{REPO}"
    runs = github(
        api + "/actions/workflows/quality.yml/runs?"
        + urllib.parse.urlencode({
            "branch": "kaori/staging",
            "event": "push",
            "status": "success",
            "per_page": 30,
        }), token
    ).get("workflow_runs", [])
    now = datetime.now(UTC)
    for run in runs:
        candidate = str(run.get("head_sha", ""))
        run_id = run.get("id")
        attempt = run.get("run_attempt")
        if not (
            SHA.fullmatch(candidate)
            and isinstance(run_id, int)
            and isinstance(attempt, int)
            and run_id != int(current_run)
            and run.get("path") == WORKFLOW
            and run.get("event") == "push"
            and run.get("head_branch") == "kaori/staging"
            and run.get("status") == "completed"
            and run.get("conclusion") == "success"
            and (run.get("head_repository") or {}).get("full_name") == REPO
            and ancestor(candidate, source)
        ):
            continue
        commit = github(api + "/git/commits/" + candidate, token)
        if (commit.get("tree") or {}).get("sha") != tree:
            continue
        artifacts = github(api + f"/actions/runs/{run_id}/artifacts?per_page=100", token)
        name = f"kaori-docs-admission-{candidate}-{run_id}-{attempt}"
        matching = [
            art for art in artifacts.get("artifacts", [])
            if art.get("name") == name
            and art.get("expired") is False
            and isinstance(art.get("digest"), str)
            and DIGEST.fullmatch(art["digest"])
            and isinstance(art.get("size_in_bytes"), int)
            and 0 < art["size_in_bytes"] < 100_000
        ]
        if len(matching) != 1:
            continue
        archive = github(matching[0]["archive_download_url"], token, binary=True)
        if hashlib.sha256(archive).hexdigest() != matching[0]["digest"][7:]:
            continue
        with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
            infos = bundle.infolist()
            if len(infos) != 1 or infos[0].filename != "admission-evidence.json":
                continue
            if infos[0].file_size > 100_000:
                continue
            evidence = json.loads(bundle.read("admission-evidence.json").decode("utf-8"))
        if not isinstance(evidence, dict) or not valid_evidence(
            evidence,
            source=candidate,
            tree=tree,
            fingerprint=fingerprint,
            run_id=run_id,
            run_attempt=attempt,
            now=now,
        ):
            continue
        jobs = github(api + f"/actions/runs/{run_id}/jobs?per_page=100", token)
        full_jobs = jobs.get("jobs", [])
        if not all(
            len([
                job for job in full_jobs
                if job.get("name") == gate and job.get("conclusion") == "success"
            ]) == 1
            for gate in GATES
        ):
            continue
        return True, str(run_id), "verified full staging evidence with identical source tree and authority"
    return False, "", "no trusted same-tree/full-authority evidence; fresh Full Admission required"


def emit(key: str, value: str) -> None:
    if "\n" in value or "\r" in value:
        raise ValueError("unsafe GitHub output value")
    line = f"{key}={value}\n"
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
            output.write(line)
    else:
        print(line, end="")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("resolve", "test"))
    args = parser.parse_args()
    if args.mode == "test":
        now = datetime.now(UTC)
        baseline = {
            "schema_version": 2, "profile": "full", "reuse_authorized": True,
            "repository": REPO, "canonical_workflow": WORKFLOW,
            "source_sha": "a" * 40, "source_tree_sha": "b" * 40,
            "validation_authority_fingerprint": "sha256:" + "c" * 64,
            "evidence_run_id": 10, "evidence_attempt": 1,
            "source_event": "push", "source_ref": "refs/heads/kaori/staging",
            "executed_workflow_sha": "a" * 40,
            "executed_workflow_ref": f"{REPO}/{WORKFLOW}@refs/heads/kaori/staging",
            "created_at": now.isoformat(),
            "mandatory_gate_conclusions": {gate: "success" for gate in GATES},
        }
        check = lambda obj: valid_evidence(
            obj, source="a" * 40, tree="b" * 40,
            fingerprint="sha256:" + "c" * 64,
            run_id=10, run_attempt=1, now=now,
        )
        assert check(baseline)
        for change in (
            {"source_tree_sha": "d" * 40},
            {"validation_authority_fingerprint": "sha256:" + "d" * 64},
            {"reuse_authorized": False},
            {"profile": "reused"},
            {"executed_workflow_ref": "untrusted"},
            {"evidence_run_id": 11},
            {"source_event": "pull_request"},
            {"created_at": (now - timedelta(days=40)).isoformat()},
            {"mandatory_gate_conclusions": {**baseline["mandatory_gate_conclusions"],
                                            "Browser Quality Evidence": "skipped"}},
        ):
            assert not check({**baseline, **change}), f"accepted unsafe evidence: {change}"
        print("PASS: exact tree/authority/source/run/age/full-gate evidence contract")
        return 0
    try:
        reusable, run_id, reason = choose(os.environ.get("GH_TOKEN", ""))
    except (
        OSError, ValueError, KeyError, TypeError, TimeoutError,
        subprocess.CalledProcessError, zipfile.BadZipFile, json.JSONDecodeError,
    ) as exc:
        reusable, run_id, reason = False, "", f"trusted evidence lookup failed closed: {type(exc).__name__}"
    emit("reuse", "true" if reusable else "false")
    emit("evidence_run_id", run_id)
    emit("reason", reason)
    print("REUSED" if reusable else "FALLBACK", reason)
    return 0


if __name__ == "__main__":
    sys.exit(main())
