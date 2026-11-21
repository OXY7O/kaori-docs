# KAORI Docs — configured signed image deployment

**Authorities:** [#14](https://github.com/OXY7O/kaori-docs/issues/14) (deployment and rollback), [#43](https://github.com/OXY7O/kaori-docs/issues/43) (maintainer-approved single-slot runtime), [#13](https://github.com/OXY7O/kaori-docs/issues/13) (signed RC), [#39](https://github.com/OXY7O/kaori-docs/issues/39) (stable acceptance), [#40](https://github.com/OXY7O/kaori-docs/issues/40) (stable deployment policy), and [KAORI shared-edge operations](https://github.com/OXY7O/KAORI/blob/main/docs/deployment/SHARED_EDGE_OPERATIONS.md).

## Deployment model

GitHub `staging` and `production` Environments select **governance and target configuration**; they do not define the number of VMs or running slots. Accepted `kaori/staging` selects staging RC/UAT, while accepted `main` selects production stable authority. The **effective** Docs runtime is the selected host/SSH identity, Compose project, deploy root, state/receipt path, loopback port and independently approved shared-edge registration. Different Environments with identical target configuration refer to the same runtime. The same host may also contain distinct Docs projects when explicitly configured and independently provisioned.

**Current operator deployment** uses one existing shared KAORI VPS and one Docs container. An approved RC or stable selection on **that same configured runtime** replaces its selected image, and a brief Docs interruption is accepted during development. This is the current default topology, **not** a hardcoded release mode or a requirement that staging and production must share a server.

| Setting                     | Current configured Docs target (default)                                |
| --------------------------- | ----------------------------------------------------------------------- |
| Release root                | `/opt/kaori-docs/releases/<source-SHA>/server`                          |
| Compose                     | `kaori-docs` / `web`                                                    |
| Loopback                    | `127.0.0.1:18081:8080`                                                  |
| Public edge                 | Previously approved `docs.kaori.cloud` → `kaori-docs-web:8080`          |
| Current / previous receipts | `/var/lib/kaori-docs/deploy-state/release.env` / `previous-release.env` |
| Selected image              | `docker.io/<approved-account>/kaori-docs@sha256:<64-hex>`               |
| Existing deploy identity    | `kaori-deploy`                                                          |

The release adapter does **not** create an additional Docs project, directory, OS account, public registration, proxy, TLS certificate or DNS entry. An operator-selected alternative runtime must already have its own authorized root/state, healthy Compose/loopback and provider-owned ingress routing before release; otherwise the workflow fails closed. A public replacement may briefly interrupt Docs but must **never** intentionally interrupt the KAORI Application or Website.

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

The host pulls the approved digest and reconciles the selected Docs Compose `web` service. Image identity, non-root readiness, port 18081, internal/host `/healthz` and root page must PASS before the receipt advances. A failed candidate attempts automatic previous-digest recovery. The existing edge adapter may reattach **only** the Docs frontend after a successful receipt and must run the original all-site shared-edge verifier; it must not rewrite DNS, Nginx/Certbot or App/Website registrations.

A public-edge reconciliation failure is **not** a successful deployment even when the container itself is healthy. Collect its error and the actual last-known-good/receipt state; do not report production or UAT PASS until the public site and rollback evidence are verified.

### Shared-edge Compose scope isolation (Docs #32 / KAORI #4203)

The Docs release adapter intentionally exports `COMPOSE_PROJECT_NAME=kaori-docs`
for its **own** single-slot Compose service. The separately owned
`/opt/shared-edge/runtime/compose.yml` uses project `shared-edge-example`.
Do not carry the Docs project override into the canonical independent
`/opt/shared-edge/runtime/verify.sh`: its `docker compose ps -q nginx`
would otherwise look under the wrong project and falsely report that the
Nginx container is missing. The Docs-only reconciliation adapter therefore
invokes the **unchanged strict shared-edge verifier** with
`env -u COMPOSE_PROJECT_NAME`. This is a scoped process environment
boundary, not a new verifier, relaxed test, change to edge ownership or
change to the active application Compose project.

**Observed incident (2026-11-03):** [Release Deployment
#41556596818](https://github.com/OXY7O/kaori-docs/actions/runs/41556596818)
of signed `v0.3.0-rc.2` installed the approved immutable digest and
committed its receipt. DNS, redirects, TLS and HTTPS readiness for Docs,
Website and Application all passed, but the inherited Compose project
caused the final independent Nginx discovery check to fail. Operator's
read-only `docker compose ls --all`, Nginx/Certbot labels and correctly
scoped `docker compose ... ps -a` independently found both running
`shared-edge-example` containers. This is a release **final-gate FAIL**,
not evidence that the Nginx or Certbot containers stopped.

For read-only diagnostic reproduction under the existing authorized host
identity (never print the private `edge.env`), use:

```bash
docker compose ls --all
docker compose --env-file /opt/shared-edge/config/edge.env \
  --project-directory /opt/shared-edge/runtime \
  -f /opt/shared-edge/runtime/compose.yml ps -a
env -u COMPOSE_PROJECT_NAME \
  bash /opt/shared-edge/runtime/verify.sh --wait-seconds 120
```

After source fix admission, any newly published Docs RC requires a **new**
immutable tag, exact staging SHA approval and digest-bound public swap
authorization. Existing `v0.3.0-rc.2` remains historical evidence and
must not be retagged or claimed to originate from the new source. Verify
the actual receipt, Docs-only alias and all sites through the existing
canonical deployer; browser/rollback evidence and Human Acceptance remain
separate. Do not change the shared-edge project name, restart Nginx/Certbot,
modify DNS/TLS or bypass the strict verifier as a workaround.

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

## Accepted RC signer identities and opt-in publication

A signed candidate may originate from the existing manual/explicit-request
`publish-staging-image.yml` workflow, or from the separately admitted,
feature-flagged protected staging `quality.yml` publisher (issue #102).
The same existing `deploy-release.sh` verifies the **exact expected
Cosign workflow certificate identity and SPDX/SLSA attestations** at the
immutable OCI digest. Adding the quality-workflow signer identity does
not authorize an RC deployment: a unique issue #14 source/tag/digest
public-swap approval is still required, followed by existing host/edge
and rollback checks.

Issue #102 **does not enable auto host deployment**. `kaori/uat-request`
or governed manual release deployment remains the only RC replacement
signal. Never infer a new source/tag/digest swap permission from a
successful RC publication or the `KAORI_DOCS_AUTO_STAGING_ENABLED` flag.
Public single-slot UAT and eventual production approval remain separate.

## Environment-scoped runtime target (Docs #106 / Website #234)

The `Release Deployment` workflow selects GitHub Environment `staging` for
the exact approved RC source and `production` for accepted stable-main
publication. Environment-level variables/secrets take precedence over
repository defaults for the **same names**; operators may deliberately assign
identical values to both Environments. The working current target is the safe
fallback when the optional runtime variables are unset.

- `KAORI_DOCS_HOST`, `KAORI_DOCS_HOST_PORT`,
  `KAORI_DOCS_HOST_USER`: existing approved pinned SSH host identity,
  selected from the GitHub Environment.
- `KAORI_DOCS_HOST_DEPLOY_ROOT`: current `/opt/kaori-docs`, or an
  operator-prepared `/opt/<configured-project>` matching the runtime.
- `KAORI_DOCS_RUNTIME_PROJECT`: defaults to `kaori-docs`; a distinct
  runtime uses a validated `kaori-docs-<suffix>` namespace.
- `KAORI_DOCS_RUNTIME_STATE_DIR`: defaults to
  `/var/lib/<configured-project>/deploy-state` and must match the project.
- `KAORI_DOCS_RUNTIME_LOOPBACK_PORT`: defaults to `18081`; choose an
  available numeric port 1024–65535 for each separate runtime.
- `KAORI_DOCS_PUBLIC_DOMAIN`: remains the approved
  `docs.kaori.cloud` public hostname; no arbitrary new hostnames.

The matching `KAORI_DOCS_HOST_SSH_PRIVATE_KEY`,
`KAORI_DOCS_HOST_KNOWN_HOSTS`, registry secret names and approved native
Environment protection remain mandatory. **No** `single-slot`,
`multi-slot` or split-host mode switch exists. Runtime project, state and
loopback are passed to the existing deploy/verify/rollback/edge adapters. A
target directory/state must exist, be writable, nonsymlinked and prepared
before deployment. A different project must have its separately approved
Docs edge registration already pointing to exactly
`EDGE_UPSTREAM=<configured-project>-web`; it is **not** silently registered,
reconfigured or exposed by this code. The current alias remains
`kaori-docs-web`.

The same host address does not prove the same runtime, and two different
host addresses do not create a second release policy. Receipt and Compose
identity are operational evidence. Host migration, target-specific DNS/TLS,
provider ingress preparation, controlled production different-target deployment,
visual UAT and actual rollback **remain separately accepted work**. In
particular, source-level support for a configured target is not evidence
that stable-main already performs safe bootstrap of a fresh production
target. See Docs [#40](https://github.com/OXY7O/kaori-docs/issues/40) and
Website [#234](https://github.com/OXY7O/kaori-website/issues/234).

## Single previous-release rollback

For a separately approved rollback, the existing adapter reads `previous-release.env` and returns the _same project_ to its previous digest. The public edge is reconciled only for the existing Docs hostname, using the same shared-edge verification:

```bash
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 \
KAORI_DOCS_ATTACH_EXISTING_EDGE=1 \
bash /opt/kaori-docs/releases/<accepted-source-SHA>/server/rollback.sh
```

Preserve exact run URL, digest and source, before/after image, current/previous receipt, health, and all-site verification. A failed rollback must be explicitly marked critical; CI PASS is not Human Acceptance.

## UAT and promotion

With the **current** shared-target configuration, the selected RC is visible on **https://docs.kaori.cloud/** and the prior Docs image is no longer running. Alternate configured runtime identities require their own independently verified ingress and acceptance. Human UAT covers six viewports (360/390/768/1024/1280/1440), light/dark, keyboard, accessible navigation, links, source accuracy, and App/Website non-regression. This is an intentionally **non-isolated** UAT topology accepted by the maintainer.

After explicit acceptance, promote using `kaori/staging → main`, verify the same signed digest, publish stable under `vX.Y.Z` and select its stable release for **this same slot**. RC-only acceptance is not an automatic main promotion.

**Historical evidence:** prior `v0.1.0-rc.2` private/bootstrap deployment and current signed `v0.3.0-rc.1` remain auditable. The new single-slot behavior is **not** active until its PR merges, a fresh exact-SHA Full Admission and new RC approval/deployment prove it. The old separate-runtime design is superseded, not evidence that a new swap already occurred.

## GitHub Environment deployment approval — Docs #96

The existing signed RC publisher uses GitHub Environment `staging`. The accepted stable publisher on `main` uses `production`. The single-slot Docs deployment job selects `staging` for signed RC/UAT requests and `production` for approved stable-main publication or explicit main stable dispatch. This is an authorization boundary, not a new host, proxy, port or Compose project. Existing issue #13, #14, #39 and #40 approval references, SHA/digest, Cosign, Trivy, SPDX/SLSA, rollback and shared-edge checks remain mandatory.

**Administrator configuration:** In GitHub repository Settings → Environments, restrict `staging` to `kaori/staging`, `kaori/rc-request` and `kaori/uat-request`. Restrict `production` to `main` only; require independent `donibawono` approval, prevent self-review and disable administrator bypass. Check scoped credentials and variables without exposing values. The GitHub connector cannot verify or change these protection rules, so production activation remains HOLD until the administrator confirms them.

**Deployment review evidence:** Verify a real, separately authorized stable run is **Waiting for review** before the privileged runner starts. Confirm denied/unapproved and self-review cannot reach registry or host mutation. For an approved release, record the native `Review deployments → production → Approve and deploy` actor, accepted signed digest, current/previous host receipts, public HTTPS/shared-edge health and rollback readiness. Source CI PASS alone is not evidence of enforced Environment approval.

Docs first-main broad promotion [#95](https://github.com/OXY7O/kaori-docs/pull/95), public content publication, live DNS/TLS changes and automatic production deployment remain outside this issue.
