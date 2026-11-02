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

**Current status:** code candidate only. #10 credential scope/host key and #13 actual signed candidate remain unverified; no Docs host deployment, public site, UAT or release accepted.
