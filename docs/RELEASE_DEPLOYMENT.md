# KAORI Docs Private Release Deployment

**Authorities:** [#14](https://github.com/OXY7O/kaori-docs/issues/14) for the deployment adapter, [#13](https://github.com/OXY7O/kaori-docs/issues/13) for a signed immutable Release Candidate, and [#10](https://github.com/OXY7O/kaori-docs/issues/10) for repository credentials and host/registry trust. Use the existing [KAORI Website deployment standard](https://github.com/OXY7O/kaori-website/blob/main/docs/DEPLOYMENT.md) and [shared-edge operations](https://github.com/OXY7O/KAORI/blob/main/docs/deployment/SHARED_EDGE_OPERATIONS.md).

## Isolated runtime

The standalone Compose project is `kaori-docs`, with a static unprivileged read-only Nginx image listening internally on port 8080 and returning `healthy` at `/healthz`. Limits inherited from the Website pattern: 128 MiB memory, 0.50 CPU, 100 PIDs, 10 MiB × 3 logs, no-new-privileges, and a 64 MiB noexec tmpfs. These are **configured limits**, not proof of peak-capacity readiness. Unlike the Website release, Docs private staging UAT uses `127.0.0.1:18081:8080` on a separate non-public bridge; the base internal network remains private. The Website port 18080 and shared-edge public 80/443 are not owned by Docs.

All release scripts remain under `/opt/kaori-docs/releases/<accepted-SHA>/server/`, with an independent mode-restricted receipt under `/var/lib/kaori-docs/deploy-state/`. Application `/opt/kaori`, Website `/opt/kaori-website`, shared-edge `/opt/shared-edge`, databases, and all other Compose projects must remain unchanged. The approved `kaori-deploy` OS user is shared and in the Docker group: directory/Compose separation **does not provide OS-level tenant isolation**.

## Host preflight and provisioning

The operator previously confirmed Docker 29.9.0, Compose 5.6.0, successful n8n retirement via [Ops-Runbook #93](https://github.com/OXY7O/ops-runbooks/issues/93), and healthy Application/Website domains. Docs directories were **absent** during the prior inventory; they have not been provisioned by this repository. On the approved target VPS, a privileged operator must first inspect:

```bash
docker compose ls --all
docker stats --no-stream
docker system df
ss -lnt | grep -E ':(18081|18080|80|443)\b' || true
ls -ld /opt/kaori /opt/kaori-website /opt/shared-edge /opt/kaori-docs /var/lib/kaori-docs 2>&1
```

**STOP** if port 18081 is occupied, the Docs project/path already has an unexpected owner, capacity is inadequate, or other services are not healthy. Confirm the pinned Actions SSH host key **out of band**, Docs-only registry scope and the documented shared Docker authority.

Only after separate host-change review and operator acceptance, prepare exactly Docs-owned paths:

```bash
sudo install -d -m 0750 -o kaori-deploy -g kaori-deploy /opt/kaori-docs
sudo install -d -m 0700 -o kaori-deploy -g kaori-deploy /var/lib/kaori-docs/deploy-state
```

The deployment workflow will **refuse** missing or symlinked/wrong-root state instead of silently provisioning shared-host directories.

## Authorization and cryptographic gates

The canonical `.github/workflows/deploy-staging-host.yml` is manual-only. A successful [Full Admission](https://github.com/OXY7O/kaori-docs/actions/workflows/quality.yml) does not publish an image. Wait for an accepted #13 prerelease for the exact current staging SHA and the same immutable image digest. The required `approval_reference` is a permanent GitHub comment on [issue #14](https://github.com/OXY7O/kaori-docs/issues/14) containing **exactly one complete marker line**:

```text
KAORI_DOCS_DEPLOY_APPROVED:<40-character-current-staging-SHA>:<vX.Y.Z-rc.N>:sha256:<64-lowercase-hex>
```

The deploy adapter checks the issue number, approver repository write/maintain/admin permission, current staging SHA, exact successful Full Admission, prerelease identity and digest. It uses Cosign v3.1.3 to verify the immutable image's GitHub Actions signature and SPDX SBOM/SLSA provenance attestations against the #13 publisher certificate identity. Missing credentials, approval, digest, attestation or pinned SSH key **fail closed**. It does not trust mutable image tags or merely trust the release description text.

The workflow uses SSH with `StrictHostKeyChecking=yes`, exact known_hosts matching and an explicitly provided SSH key. The host pulls the accepted digest and verifies its OCI source SHA/version labels rather than rebuilding. **No runner-local Docker deployment shortcut** is allowed.

**GitHub default-branch limitation:** A `workflow_dispatch` workflow generally needs to exist on the default branch for its Run Workflow entry to appear. This branch does not activate the workflow. Promotion/activation must follow reviewed KAORI release governance; never push to `main` directly.

## Temporary staging-only activation — issue #28

Before Docs UAT and promotion to `main`, private GitHub default-branch rules prevent `workflow_dispatch` for the canonical deploy workflow. Issue #28 temporarily permits a one-time **push-triggered activation of the existing canonical workflow**, not a new deployment engine. This requires both a change to `.github/workflows/deploy-staging-host.yml` in an accepted **two-parent staging merge** and the exact merge-message marker `[KAORI_DOCS_DEPLOY_ISSUE_28]`. Ordinary pushes, forks and PRs do not deploy.

The initial bootstrap checks for exactly one issue #14 comment with the exact merged staging SHA, RC tag and immutable digest marker. Without it, the job must fail **before registry/SSH access**. After a signed #13 candidate exists for that exact SHA and its Full Admission is successful, the maintainer must give separate #14 authorization and explicitly rerun the failed job. The canonical `deploy-release.sh` revalidates release, digest, signature, SPDX/SLSA attestations, author permissions, host key and Docs-owned host prerequisites. It does not create missing privileged host directories or modify public DNS/TLS.

The same final staging merge must change the canonical RC workflow too, with the independently reviewed `[KAORI_DOCS_RC_ISSUE_24]` marker, to publish a **new** signed candidate for that SHA. Never deploy a candidate from an earlier commit. After private deployment evidence is accepted, remove both temporary triggers through reviewed issue-linked cleanup PRs and retain canonical manual workflows.

## Signed-release automatic deployment — issue #33

The canonical `Release Deployment` workflow can **optionally** run after a
**successfully completed canonical Release Candidate publisher workflow** through
GitHub Actions `workflow_run: completed`, **not** `release.published`.
The current publisher creates tags/prereleases with `GITHUB_TOKEN`, and GitHub
does not dispatch arbitrary new workflows for `release` events caused by that
token. `workflow_run` is an explicit supported handoff. It only becomes
operational after this workflow exists on the repository's **default `main`**
via an accepted `kaori/staging` promotion PR. Merely merging this change into
staging does **not** activate automatic deployment.

Automatic mode is **disabled by default** and requires both:

1. Repository Actions **Variable** `KAORI_DOCS_AUTO_DEPLOY_ENABLED=true`,
   intentionally enabled only after first public DNS/TLS readiness and
   maintainer Human Acceptance under
   [KAORI #4196](https://github.com/OXY7O/KAORI/issues/4196).
2. Exactly one **write-authorized maintainer** comment on
   [Docs issue #33](https://github.com/OXY7O/kaori-docs/issues/33)
   containing this standing policy marker verbatim:

   ```text
   KAORI_DOCS_AUTO_DEPLOY_POLICY_APPROVED:docs.kaori.cloud:docker.io/lethisaputri/kaori-docs:existing-public-only
   ```

Do **not** post the marker or enable the repository variable before the first
public Docs release has been accepted. The two controls are a reversible
standing release-to-deployment policy, **not a waiver of per-release signing**.
The publisher retains the separate exact-SHA/tag approval on #13. Revocation:
set the variable to any value other than `true` and/or edit the approval
comment to remove the marker.

Auto-deploy accepts only `workflow_run` completion of the **canonical,
successful, same-repository, manually dispatched** Release Candidate publisher
on `kaori/staging` with source equal to the current staging HEAD. It resolves
exactly one non-draft, properly tagged prerelease targeting that source and
verifies the exact Git tag. The existing deployment adapter independently
verifies publisher identity/run ID, issue #33 standing policy/author permission,
current admitted staging SHA, exact Full Admission, Docs registry identity and
OCI digest, then Cosign signature and signed SPDX/SLSA attestations. It deploys
through the same pinned SSH trust boundary and requires the **already approved**
Docs-only public edge preflight and reattachment from issue #32.

Automatic retries on an already deployed identical SHA/tag/digest are no-ops
after checking public Docs health; they do **not** overwrite the prior receipt.
Changed releases use the existing container health, committed receipt and
bounded runtime rollback before independent public-edge reconciliation. If
reconciliation fails after a healthy commit, the release remains committed and
publication is a separate failed incident; do not restart KAORI Application or
Website.

Normal `workflow_dispatch` retains its per-digest issue #14 authorization for
operator-controlled deploy/recovery. The temporary staging push routes #24/#28
are historical one-time activation paths, not recurrence triggers; retire them
through reviewed PRs once the main-branch workflow is operational.

**No automatic deployment or public staging mutation is claimed by merely
authoring this source.** Require a later admitted test RC, real public-edge
verification across all active sites and human release acceptance before
calling the recurring-release contract operational.

## Subsequent public release reconciliation — issue #32

First-time DNS, TLS and edge registration are **not** owned by the Docs release
adapter: [KAORI #4196](https://github.com/OXY7O/KAORI/issues/4196)
must separately provision and verify the existing `docs.kaori.cloud` site under
the standalone shared-edge. Do not set public mode when that issue is incomplete.

Only **after** public publication and operator acceptance, the canonical
`Release Deployment` workflow offers an explicit
`publish_existing_edge=true` switch. It exports
`KAORI_DOCS_ATTACH_EXISTING_EDGE=1` to the existing signed deployment adapter.
Default false retains private UAT and refuses to replace a Docs frontend already
attached to the public edge. No release push triggers public deployment.

The public switch reuses the existing Website pattern in
`deploy/server/reattach-existing-site.sh` with two modes:

- **preflight before container replacement:** require one healthy Docs frontend
  currently attached to `edge-public` with alias `kaori-docs-web`, a
  non-symlinked existing `/opt/shared-edge/config/sites/kaori-docs.env` with
  exact reviewed Docs-only domain/upstream/8080/`/healthz`/TLS fields,
  an existing independent edge verifier and healthy public HTTPS. No new
  registration, DNS record or certificate is created.
- **attach after committed release:** require one healthy Docs frontend whose
  immutable Docker image matches the committed Docs receipt. Reattach only
  that container to `edge-public` with the same alias. Verify the public Docs
  `/healthz`, then run the **existing** shared-edge `verify.sh` against
  **all** registered sites (DNS, trusted TLS/HSTS, redirect, unknown Host/SNI
  and immutable edge containers). Routine per-release verification does not
  run Certbot renewal dry-run; first publication and scheduled operator
  maintenance must still verify real renewal using the canonical
  `--renewal-dry-run` path.

If a candidate fails and the existing host adapter restores the previous
committed digest, the orchestration attempts to reconnect **only** the recovered
Docs frontend, but retains a failed release result. If the new runtime is
healthy/committed but edge reconciliation fails, **do not rewrite the Docs
receipt or redeploy unrelated services**: this is a separately failed public
publication phase requiring the existing edge recovery procedure.

The shared edge is a separate lifecycle authority: it does not belong in the
Docs Compose network declaration, and this public option never edits app/website
registrations, Nginx-generated vhosts, DNS or TLS configuration. Current
temporary staging activation #24/#28 must be retired through a reviewed PR
after governed promotion, not converted into automatic push-to-deploy.

## Verification, receipt and rollback

The host adapter requires exact non-root image identity, healthy Docker healthcheck, internal `/healthz` and root HTTP, effective loopback mapping `127.0.0.1:18081` **and a successful loopback curl**. Only after these checks does it commit a receipt and preserve the previous release pointer. If candidate deployment fails, the previous digest is restored, its health is checked, and the candidate receipt remains uncommitted. Failed rollback is **CRITICAL**.

A separately approved manual rollback can use the previous trusted receipt:

```bash
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 bash /opt/kaori-docs/releases/<accepted-source-SHA>/server/rollback.sh
```

Retain exact source/tag/digest, receipt, previous digest, SSH trust check, run URL and before/after container health as evidence. No application/database migration occurs.

## UAT and public edge handoff

After successful private deployment, an approved reviewer may establish a pinned/trusted SSH tunnel:

```bash
ssh -N -L 18081:127.0.0.1:18081 -p 22 <approved-user>@<approved-vps>
```

Visit `http://127.0.0.1:18081/` for responsive viewport, light/dark, accessibility, keyboard and manual browser acceptance. **Private UAT and CI do not constitute public DNS/TLS or human acceptance.**

Only a separate approved public-edge workstream may register `docs.kaori.cloud` using the **existing** `/opt/shared-edge/runtime/publish-container.sh`, `apply.sh` and `verify.sh` and DNS-provider records. The Docs deployment workflow itself does not modify Nginx, Certbot, ports 80/443, existing `kaori.cloud` / `app.kaori.cloud` registrations or `edge-public`. It refuses to replace an already publicly attached Docs frontend because an unreviewed recreate would detach its edge alias.

**Runtime evidence as of 2026-11-02:** signed Docs prerelease `v0.1.0-rc.2` from admitted staging SHA `fb2cb80cc1d9a9fb8a134d5e780ef6a8f1cb5603` deployed privately with digest `sha256:bc182315f2e638f81ea7f0b0d34b78c9d566831fd327e565528b1f3c4c16fa57`; [Release Deployment run #41450139227 attempt 3](https://github.com/OXY7O/kaori-docs/actions/runs/41450139227) succeeded with committed receipt, non-root health and localhost port 18081. A desktop dark screenshot was operator-supplied; full Human UAT and rollback drill remain pending. The shared Docker Hub credential is a documented scope exception, not a dedicated robot. Public `docs.kaori.cloud` DNS/TLS/shared-edge publication is **not verified**, and `main` remains unchanged. Issue #32's recurrence adapter is implementation-only until its issue-owned PR passes Developer Check, Full Admission and later public UAT.
