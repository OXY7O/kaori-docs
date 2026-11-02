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

## Stable main identity — issue #39, production deployment pending #40

The **staging environment uses RC** (`vX.Y.Z-rc.N`) from an admitted
`kaori/staging` SHA. Staging/UAT may deploy the signed candidate only under
the existing guarded source/digest approval and isolated Docs runtime.
**Main uses stable** (`vX.Y.Z`) after Human Acceptance and a reviewed promotion
PR. Main stable publication must preserve the **exact same accepted RC OCI
digest** and must **not rebuild** Docusaurus/Nginx/OCI application bits.

Use the existing canonical `Full Admission` workflow on `main` with manual
`workflow_dispatch` inputs:

- `stable_version` — strict `vX.Y.Z`.
- `accepted_candidate_tag` — exact `vX.Y.Z-rc.N` prerelease previously
  signed and human accepted.
- `stable_approval_reference` — issue #39 maintainer comment URL containing
  `KAORI_DOCS_STABLE_APPROVED:<exact-main-SHA>:<exact-RC-tag>:<stable-tag>:<sha256-digest>`.

The stable publication job runs only after **same-run main Full Admission,
Container Admission and Browser Quality Evidence PASS**. It checks main source
identity, matching RC tag/SHA/digest and immutable build inputs, approver write
permission, uniqueness/no overwrite, then independently verifies Cosign image
signature and SPDX/SLSA attestations before publishing stable GitHub Release
metadata on main. It does not change any VPS container, public edge, DNS, TLS,
registry image digest, nor create a mutable alias.

**The previously proposed #33 successful-RC → public automatic deploy is
not production authority.** Leave its enable variable OFF and do not issue
its standing approval marker. Issue #40 will replace that auto trigger with
a **separate accepted-stable-main → production deployment** workflow. A single
existing public Docs VPS is not a true isolated staging/production environment;
do not claim two independent environments or deploy an unaccepted RC to public
production merely because it has passed Full Admission.

## Stable production automatic deployment — issue #40 (inactive until accepted)

**Only a stable `vX.Y.Z` published from `main` may trigger production
automation.** The earlier #33 RC publisher-completion → public production
route has been retired from the workflow and explicitly rejected by the
deployment adapter. RC `vX.Y.Z-rc.N` remains staging/UAT release identity,
not production authorization.

The canonical `Release Deployment` workflow listens for successful
`workflow_run: completed` of the `Full Admission` workflow on `main`
with upstream event `workflow_dispatch`. It rejects a validation-only run:
the upstream run must contain a successful **Publish Accepted Stable Release**
job. The stable publisher writes its exact run ID into the stable GitHub
Release; the orchestrator selects **exactly one** non-draft, non-prerelease
stable tag bound to that successful run and current main SHA.

**Disabled by default, independent activation gates:**

1. Repository Actions variable
   `KAORI_DOCS_STABLE_AUTO_DEPLOY_ENABLED=true`, only after signed RC/UAT,
   same-digest stable publisher and Docs-only rollback/cutover human
   acceptance. Leave the old `KAORI_DOCS_AUTO_DEPLOY_ENABLED` unset/false.
2. One **write-authorized** maintainer comment on
   [issue #40](https://github.com/OXY7O/kaori-docs/issues/40)
   with this standalone marker:

   ```text
   KAORI_DOCS_STABLE_AUTO_DEPLOY_APPROVED:docs.kaori.cloud:docker.io/lethisaputri/kaori-docs:main-stable-only
   ```

Neither activation gate is granted by creating or merging this PR. In
particular, the initial public bootstrap Human Acceptance for PR #37 does
**not** authorize automatic stable releases. Revocation is removing the
standing comment marker and/or setting the variable other than `true`.

With these gates present, the adapter checks current main SHA, stable Git
tag/source/release metadata, matching accepted RC tag and RC source SHA
ancestor, identical registry digest, accepted issue #39 per-release human
approval, exact successful main Full Admission/stable-publication run,
write-authorized approvers and admitted RC Full Admission. It then
independently verifies the **original RC digest** using Cosign image
signature and signed SPDX/SLSA attestations. Nothing rebuilds or retags
the original immutable image.

The release deployer reuses the existing pinned SSH host trust and Docker
Compose adapter, passing *stable public version* `vX.Y.Z` with original
*artifact version* `vX.Y.Z-rc.N`. Image metadata must match the RC.
The receipt stores `KAORI_DOCS_VERSION` (stable) and
`KAORI_DOCS_ARTIFACT_VERSION` (RC) alongside the original source and
digest so rollback can verify the genuine OCI label. Before replacing
the currently healthy public Docs frontend, it verifies the existing
`kaori-docs.env` route and `edge-public` alias; after committing the
new digest it reconnects **only** Docs and runs the canonical all-site
shared-edge verifier. A same-digest stable retry is an idempotent
verified no-op. Any post-commit public-edge failure stays a separate
incident; never silently roll back KAORI App/Website.

**Current infrastructure caveat:** a *single* `kaori-docs` Compose project
on the publicly routed VPS is not an isolated staging/UAT environment.
Do **not** call an RC deployed there an independently isolated staging
release; approved UAT is a release candidate on the existing public
Docs origin. True simultaneous staging/production separation needs
an explicit approved second runtime/namespace and private UAT ingress.
Existing manual RC `workflow_dispatch` remains per-digest approved
under issue #14; it defaults to private mode and fails closed rather
than detaching an attached public Docs frontend. That is intentional.

The historical one-time staging trigger #28 has been removed from the
deployment workflow. Issue #24 publisher-only RC bootstrap trigger is a
separate previously reviewed cleanup item; production must never rely
on it. GitHub `GITHUB_TOKEN` created releases do not fire downstream
`release.published`; the successful main `workflow_run` handoff is
the supported model. Actual stable publication, host cutover, rollback,
UAT and activation remain pending real evidence.

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

A separately approved manual rollback can use the previous trusted receipt.
The default private rollback **fails closed** if its current Docs frontend is already
publicly attached; it must not silently detach the existing Docs route.
After approved public publication, explicitly opt in to the same existing
Docs-only `edge-public` preflight/reattachment and full shared-edge verification:

```bash
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 KAORI_DOCS_ATTACH_EXISTING_EDGE=1 \
  bash /opt/kaori-docs/releases/<accepted-source-SHA>/server/rollback.sh
```

The existing signed/committed release receipt remains authoritative, and a
failed rollback/public reattachment is reported as failure/CRITICAL rather than
claiming successful service recovery.

A private-only rollback (when the current Docs web is **not** publicly attached) uses:

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

**Updated authority (2026-11-02):** first-public Docs DNS/TLS/shared-edge and bootstrap placeholder Human UAT were accepted by the maintainer; [KAORI#4196](https://github.com/OXY7O/KAORI/issues/4196) closed, retired n8n Certbot lineage [#4197](https://github.com/OXY7O/KAORI/issues/4197) operator-confirmed fixed. The full raw final Certbot transcript was not uploaded, and the evidence does not include a new digest-cutover/rollback test. Foundation [PR #37](https://github.com/OXY7O/kaori-docs/pull/37) merged into `main` at `6915fb97c5f53d8e5043876d51401d08bd683879`, post-main Full Admission [#41465358039](https://github.com/OXY7O/kaori-docs/actions/runs/41465358039) PASS 4/4. Stable publisher #39 and public auto-deploy #40 are separate follow-ons, inactive until approval. The previously deployed last evidenced artifact is signed RC `v0.1.0-rc.2` at digest `sha256:bc182315f2e638f81ea7f0b0d34b78c9d566831fd327e565528b1f3c4c16fa57`; **no stable tag or stable deployment evidence is claimed**.\n