# KAORI Docs RC/UAT — one active deployment slot

**Authority:** [Issue #43](https://github.com/OXY7O/kaori-docs/issues/43) supersedes the previous parallel-runtime staging proposal, with [#14](https://github.com/OXY7O/kaori-docs/issues/14) governing signed release deployment.

## Operator contract

The development VPS runs **one** KAORI Docs deployment. A selected RC (`vX.Y.Z-rc.N`) **replaces** the currently running Docs image; a selected stable (`vX.Y.Z`) later **replaces** it in the same container. RC and stable are release identities, **not** different VMs, folders, ports, or simultaneous services. Brief replacement downtime is an explicitly accepted development tradeoff.

| Runtime setting           | Both RC and stable                                      |
| ------------------------- | ------------------------------------------------------- |
| VPS / SSH identity        | Existing KAORI shared VPS / approved `kaori-deploy`     |
| Deployment root           | `/opt/kaori-docs`                                       |
| Release checkout          | `/opt/kaori-docs/releases/<accepted-source-SHA>/server` |
| Compose project           | `kaori-docs` (one `web` service)                        |
| Loopback listener         | `127.0.0.1:18081:8080`                                  |
| Committed release pointer | `/var/lib/kaori-docs/deploy-state/release.env`          |
| Previous digest pointer   | `/var/lib/kaori-docs/deploy-state/previous-release.env` |
| Public site               | Existing approved `docs.kaori.cloud` registration       |

The RC can be visible on `docs.kaori.cloud` during UAT when **explicitly authorized**. It is still an RC and must not be represented as an accepted stable product release. No second staging Compose project/port/path, new proxy, DNS record, TLS certificate, or manual directory preparation is needed.

## Release selection

1. For an RC, publish a signed immutable candidate from the current exact admitted `kaori/staging` SHA with issue #13 approval. A signed RC publication does **not** automatically approve a server swap.
2. Approve the **exact RC SHA, tag and digest** on issue #14 with both markers `KAORI_DOCS_DEPLOY_APPROVED:<SHA>:<RC>:<digest>` and `KAORI_DOCS_RC_PUBLIC_SWAP_APPROVED:<SHA>:<RC>:<digest>` in the **same** write-authorized comment. Earlier private-only approvals are insufficient.
3. Run canonical `Release Deployment` against `kaori/staging` and select the approved RC tag, with `publish_existing_edge=true`. The workflow validates staging Full Admission, release source, digest, Cosign/SPDX/SLSA, permissions, SSH host trust and the already registered Docs-only public edge **before** replacing the single container.
4. For stable, obtain separate UAT Human Acceptance and promote through reviewed PR to `main`, publish stable using the **same immutable accepted RC digest**, then use the approved main stable deployment authority/trigger. No rebuild is required merely to label an accepted RC digest stable.

Both modes automatically select the same host root and Docker Compose project. The current receipt advances only after image/source/health verification succeeds. A failed candidate attempts recovery from the last committed digest and must report failure. The same existing-edge verifier checks `docs.kaori.cloud` and all other shared sites after successful reattachment.

## Request branch automation — #51

Once the request-trigger workflow change has passed its own Developer Check and exact staging Full Admission, `kaori/rc-request` and `kaori/uat-request` become **explicit events**, not deployments or environments. Both refs must point to the *exact current admitted* `kaori/staging` commit; ordinary staging pushes do not publish or deploy.

- `kaori/rc-request` resolves **one unique issue #13 source SHA and RC tag approval** and publishes the existing signed image through the canonical RC pipeline.
- `kaori/uat-request` resolves **one signed prerelease for the same staging SHA** and **one issue #14 approval comment containing both exact digest markers**, including `KAORI_DOCS_RC_PUBLIC_SWAP_APPROVED`; it replaces the **same existing** `kaori-docs` container only after existing-edge and supply-chain preflight.
- Manual governed dispatch remains available for operator recovery. Neither request ref can bypass Full Admission, release tag/digest immutability, approver permissions, Cosign/SPDX/SLSA, public-edge verification, rollback, or explicit Human Acceptance.

Do not create parallel Compose projects, a second port, new directories, or a second VPS. When staging SHA changes, request branches must be deliberately updated to the **new** exact admitted SHA; stale requests fail closed.

## Minimal host preflight

On the **existing** VPS, verify normal Docs/Website/App health and the current single Docs project:

```bash
docker compose ls --all
docker ps --filter label=com.docker.compose.project=kaori-docs
docker system df
ss -lnt | grep -E ':(18081|18080|80|443)\b' || true
ls -ld /opt/kaori-docs /var/lib/kaori-docs/deploy-state
```

**STOP** for unexpected ownership, insufficient capacity, missing existing Docs edge, unhealthy App/Website/Docs, or an unexpected listener. Do not prune Docker, create another runtime, or rewrite shared-edge/DNS/TLS. Only the existing Docs Compose project may be replaced.

## Review and rollback

After a successful deployment, inspect **https://docs.kaori.cloud/** directly: desktop/mobile, six breakpoints, real light/dark themes, keyboard/focus, links, and whether the chosen RC/stable is the exact digest in the committed receipt. Confirm `https://kaori.cloud` and `https://app.kaori.cloud` remain healthy. Record workflow run, exact tag, SHA, digest, receipt, container health and browser evidence. **An RC deployed publicly remains UAT pending** until the maintainer explicitly accepts it.

A separately approved rollback uses the _same_ project and previously committed image pointer:

```bash
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 \
KAORI_DOCS_ATTACH_EXISTING_EDGE=1 \
bash /opt/kaori-docs/releases/<accepted-source-SHA>/server/rollback.sh
```

A rollback is not an alternative release authorization; verify the prior receipt and the recovery outcome. Never report UAT completed merely because CI or HTTPS health passed.
