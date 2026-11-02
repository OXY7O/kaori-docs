# KAORI Docs — single-slot signed image deployment

**Authorities:** [#14](https://github.com/OXY7O/kaori-docs/issues/14) (deployment and rollback), [#43](https://github.com/OXY7O/kaori-docs/issues/43) (maintainer-approved single-slot runtime), [#13](https://github.com/OXY7O/kaori-docs/issues/13) (signed RC), [#39](https://github.com/OXY7O/kaori-docs/issues/39) (stable acceptance), [#40](https://github.com/OXY7O/kaori-docs/issues/40) (stable deployment policy), and [KAORI shared-edge operations](https://github.com/OXY7O/KAORI/blob/main/docs/deployment/SHARED_EDGE_OPERATIONS.md).

## Deployment model

One existing KAORI VPS hosts **one active Docs image**: either an approved RC or an accepted stable. Selecting the next signed digest **replaces** the current Docs container. The maintainer has explicitly accepted a brief service interruption during this development-phase replacement. The release engine does not create concurrent staging/production Docs instances.

| Setting                     | Single existing deployment slot                                         |
| --------------------------- | ----------------------------------------------------------------------- |
| Release root                | `/opt/kaori-docs/releases/<source-SHA>/server`                          |
| Compose                     | `kaori-docs` / `web`                                                    |
| Loopback                    | `127.0.0.1:18081:8080`                                                  |
| Public edge                 | Previously approved `docs.kaori.cloud` → `kaori-docs-web:8080`          |
| Current / previous receipts | `/var/lib/kaori-docs/deploy-state/release.env` / `previous-release.env` |
| Selected image              | `docker.io/<approved-account>/kaori-docs@sha256:<64-hex>`               |
| Existing deploy identity    | `kaori-deploy`                                                          |

No second Docs Compose project, port 18082, staging directory, OS account, proxy, TLS certificate or DNS registration. Deployment may momentarily interrupt the public Docs site, **never** intentionally the KAORI Application or Website.

The container remains unprivileged, read-only with no-new-privileges, bounded memory/CPU/PIDs/logs, a restricted tmpfs, immutable image and internal `/healthz` check. Resource limits are configuration, not proof that the host has enough capacity. The remote adapter must use the pinned SSH host key and existing Docs-only credentials.

## Release authority and approval

An **RC** is built and signed once from the exact admitted `kaori/staging` SHA. Publication requires issue #13 approval, successful Full Admission and the existing Trivy, Cosign, SPDX/SLSA, OCI version/revision and immutable digest gates. The candidate is not a stable product release.

Deploying that RC into the **one existing public Docs slot** requires a separate issue #14 comment from a write-authorized maintainer containing **both** exact markers:

```text
KAORI_DOCS_DEPLOY_APPROVED:<source-SHA>:<RC-tag>:<sha256-digest>
KAORI_DOCS_RC_PUBLIC_SWAP_APPROVED:<source-SHA>:<RC-tag>:<sha256-digest>
```

The second marker is mandatory because the previous issue #14 approval authorized **private-only staging**, not replacement of the publicly served image. Never reinterpret that earlier comment as permission for public substitution.

**Stable** publication occurs only after actual UAT, explicit Human Acceptance, reviewed promotion PR to `main`, main Full Admission and the issue #39 approved stable manifest. The accepted stable release reuses the **same verified immutable RC image digest** (no rebuild). Stable deployment uses the existing issue #40 policy and exact acceptance evidence. An RC visible at `docs.kaori.cloud` remains an RC; it is never implicitly promoted to stable.

## Operational selection

The existing canonical `Release Deployment` workflow offers an explicit `candidate_tag` for RC or `stable_tag` for a governed main stable release.

- For RC: dispatch from `kaori/staging`, supply the signed `vX.Y.Z-rc.N`, issue #14 **public swap** approval URL, leave `stable_tag` blank, `publish_existing_edge=true`.
- For stable: use the separately admitted main-stable release workflow/trigger and its issue #40 approval. Do not supply an RC tag as a stable tag.

The workflow validates the current release's SHA, GitHub Release and immutable digest, explicit authorization, source admission, exact registry metadata, Cosign image signature and SPDX/SLSA attestations, then SSH host trust **before** host mutation. Existing shared-edge registration is preflighted; if absent/unhealthy, **fail closed** rather than creating it. Do not use unreviewed direct Docker commands to bypass the adapter.

The host pulls the approved digest and reconciles the same `kaori-docs` Compose `web` service. Image identity, non-root readiness, port 18081, internal/host `/healthz` and root page must PASS before the receipt advances. A failed candidate attempts automatic previous-digest recovery. The existing edge adapter may reattach **only** the Docs frontend after a successful receipt and must run the original all-site shared-edge verifier; it must not rewrite DNS, Nginx/Certbot or App/Website registrations.

A public-edge reconciliation failure is **not** a successful deployment even when the container itself is healthy. Collect its error and the actual last-known-good/receipt state; do not report production or UAT PASS until the public site and rollback evidence are verified.

## Governed request branch triggers

Issue [#51](https://github.com/OXY7O/kaori-docs/issues/51) adds optional `push` request signals: `kaori/rc-request` selects the exact admitted staging SHA and a uniquely approved RC publication; `kaori/uat-request` selects the uniquely signed RC for that exact SHA and the issue #14 **public swap** approval. Both use the existing canonical workflows, same Compose project `kaori-docs`, loopback 18081, and one release receipt. No alternate staging target is created.

Manual `workflow_dispatch` remains a governed fallback. Request branch events do **not** mean preapproved Human UAT, stable release, main promotion or public deployment without the issue #14 exact-digest consent and all cryptographic/edge checks.

## Existing VPS preflight

```bash
docker compose ls --all
docker stats --no-stream
docker system df
ss -lnt | grep -E ':(18081|18080|80|443)\b' || true
ls -ld /opt/kaori-docs /var/lib/kaori-docs/deploy-state
```

**STOP** if the shared VPS cannot safely replace its existing Docs container or App/Website/shared-edge is unhealthy. The directories above already belong to the existing Docs deployment; do **not** create separate staging directories or use global Docker cleanup.

## Single previous-release rollback

For a separately approved rollback, the existing adapter reads `previous-release.env` and returns the _same project_ to its previous digest. The public edge is reconciled only for the existing Docs hostname, using the same shared-edge verification:

```bash
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 \
KAORI_DOCS_ATTACH_EXISTING_EDGE=1 \
bash /opt/kaori-docs/releases/<accepted-source-SHA>/server/rollback.sh
```

Preserve exact run URL, digest and source, before/after image, current/previous receipt, health, and all-site verification. A failed rollback must be explicitly marked critical; CI PASS is not Human Acceptance.

## UAT and promotion

Because the deployment slot is shared, the selected RC is visible on **https://docs.kaori.cloud/** and the previous Docs image is no longer running. Human UAT covers six viewports (360/390/768/1024/1280/1440), light/dark, keyboard, accessible navigation, links, source accuracy, and App/Website non-regression. This is an intentionally **non-isolated** UAT topology accepted by the maintainer.

After explicit acceptance, promote using `kaori/staging → main`, verify the same signed digest, publish stable under `vX.Y.Z` and select its stable release for **this same slot**. RC-only acceptance is not an automatic main promotion.

**Historical evidence:** prior `v0.1.0-rc.2` private/bootstrap deployment and current signed `v0.3.0-rc.1` remain auditable. The new single-slot behavior is **not** active until its PR merges, a fresh exact-SHA Full Admission and new RC approval/deployment prove it. The old separate-runtime design is superseded, not evidence that a new swap already occurred.
