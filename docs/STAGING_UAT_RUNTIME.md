# KAORI Docs RC/UAT staging runtime

**Authority:** [Docs #43](https://github.com/OXY7O/kaori-docs/issues/43), [Docs #14](https://github.com/OXY7O/kaori-docs/issues/14), [Docs #38](https://github.com/OXY7O/kaori-docs/issues/38), and the approved [KAORI delivery standard](https://github.com/OXY7O/KAORI/blob/main/docs/engineering/KAORI_DELIVERY_WORKFLOW.md).

Docs `vX.Y.Z-rc.N` is a staging/UAT artifact; Docs `vX.Y.Z` is a production release from `main` using the **same signed immutable RC image digest**. The first Docs bootstrap deployment used a single public `kaori-docs` Compose project. That single public container is **not** an independent staging/UAT environment.

## Isolation contract

**Production:** Compose project `kaori-docs`, release scripts under `/opt/kaori-docs/releases/<SHA>/server`, committed receipt under `/var/lib/kaori-docs/deploy-state`, and listener `127.0.0.1:18081` registered with the approved shared-edge site `docs.kaori.cloud`. The public release is stable `vX.Y.Z`.

**Staging/UAT:** Compose project `kaori-docs-staging`, release scripts under `/opt/kaori-docs-staging/releases/<SHA>/server`, committed receipt under `/var/lib/kaori-docs-staging/deploy-state`, and private loopback-only listener `127.0.0.1:18082`. This instance is **never** attached to the shared edge. The UAT release is the exact signed `vX.Y.Z-rc.N`.

Each Compose project owns its own bridge networks and `web` container. The staging overlay `deploy/server/compose.staging.yml` sets `name: kaori-docs-staging` and publishes only loopback port 18082. The remote adapter also exports and verifies the exact project identity; an environment name alone cannot silently redirect production.

## Operator-owned host preparation (not executed by CI)

Before creating any paths, inspect host availability and existing services as the privileged VPS operator:

```bash
docker compose ls --all
docker stats --no-stream
docker system df
ss -lnt | grep -E ':(18082|18081|18080|80|443)\b' || true
ls -ld /opt/kaori-docs /var/lib/kaori-docs /opt/kaori-docs-staging /var/lib/kaori-docs-staging 2>&1
```

**STOP** if 18082 is already occupied, the candidate staging project/path has unexpected ownership, the server lacks sufficient memory/disk/CPU, or any currently hosted App, Website or Docs production site is unhealthy. Do not prune Docker globally, stop a public container, change DNS/TLS or restart shared-edge as a staging preparation shortcut.

After authorized host review, create **only** the staging-owned paths:

```bash
sudo install -d -m 0750 -o kaori-deploy -g kaori-deploy /opt/kaori-docs-staging
sudo install -d -m 0700 -o kaori-deploy -g kaori-deploy /var/lib/kaori-docs-staging/deploy-state
sudo -u kaori-deploy test -w /opt/kaori-docs-staging
sudo -u kaori-deploy test -w /var/lib/kaori-docs-staging/deploy-state
```

Do not copy production release receipts/secrets to staging. Keep the previously pinned GitHub Actions SSH host-key and registry trust procedure. The `kaori-deploy` Docker group is a shared host authority; Compose separation is **not** equivalent to a separate OS security tenant.

## Governed RC/UAT deployment

Publish a new signed RC from the exact admitted `kaori/staging` SHA using the existing `Release Candidate` workflow and explicit issue #13 approval. When the canonical workflow definitions are on default `main`, use the existing manual `Release Deployment` workflow dispatched **from `kaori/staging`** with the exact candidate tag, independent issue #14 per-digest approval, and `publish_existing_edge=false`. The workflow sets `KAORI_DOCS_STAGING_UAT=1` automatically for manual RC dispatch. It must not deploy an RC to the already-public production Docs project or use the issue #40 stable-production approval.

The same existing deployer verifies signed RC release, exact source SHA/Full Admission, Cosign signature, SPDX/SLSA, pinned SSH trust and stage-owned host paths; then sets `COMPOSE_PROJECT_NAME=kaori-docs-staging`, stage receipt directory and `KAORI_DOCS_RUNTIME_ENV=staging`. The host runs the same immutable digest/nonroot/health/rollback contract, with loopback port 18082. No `edge-public` attachment is permitted.

Approved UAT operators may inspect private staged Docs using a temporary SSH tunnel with locally verified host identity:

```bash
ssh -N -L 18082:127.0.0.1:18082 -p <approved-port> <approved-user>@<approved-host>
```

Then inspect `http://127.0.0.1:18082/`, `/healthz`, desktop/mobile, light/dark, keyboard and navigation. Reconfirm that `https://docs.kaori.cloud`, `https://kaori.cloud` and `https://app.kaori.cloud` remain unchanged. Collect Docker project/port/receipt and SSH tunnel evidence without leaking credentials.

## Governed UAT request branch — Docs #51

After the [#51 request-branch change](https://github.com/OXY7O/kaori-docs/issues/51)
is independently admitted and a **new** signed candidate exists on its exact
staging SHA, the operator may request UAT by moving `kaori/uat-request` to
that same SHA. The existing `Release Deployment` workflow resolves **exactly
one** non-draft prerelease for that SHA, checks the Git tag and immutable image
digest, and requires **exactly one** issue #14 approval marker
`KAORI_DOCS_DEPLOY_APPROVED:<SHA>:<RC>:<sha256-digest>`.

Only after those checks can the canonical deploy adapter verify Cosign,
SPDX/SLSA, the pinned SSH host and private staging Compose. The request
branch **cannot** attach to `docs.kaori.cloud`, replace the production
`kaori-docs` container, or constitute Human UAT acceptance. Manual
`workflow_dispatch` against staging remains the reviewed recovery path.

The already signed `v0.3.0-rc.1` remains bound to source
`5c6987c32b344d926a151fee1fa6363ae7863fa3`; complete its separate
isolated UAT *before* integrating the source-changing #51 workflow PR. A
new staging source requires its own admission, tag and signed candidate.

## Rollback and acceptance

A separately approved staging-only recovery uses the previous staging receipt with explicit environment identity:

```bash
KAORI_DOCS_RUNTIME_ENV=staging \
COMPOSE_PROJECT_NAME=kaori-docs-staging \
KAORI_DOCS_STATE_DIR=/var/lib/kaori-docs-staging/deploy-state \
KAORI_DOCS_RELEASE_LOCAL_ONLY=1 \
bash /opt/kaori-docs-staging/releases/<accepted-source-SHA>/server/rollback.sh
```

Do not change production Docs receipts or Docker Compose project, and do not attach staging to the public edge. A failed staging RC deployment must leave the public production digest healthy and unchanged. Treat UAT as **pending** until a real admitted signed RC deploy, private browser review, stage rollback and explicit Human Acceptance are recorded on #43.

Only after a real RC/UAT acceptance and later reviewed promotion to `main` may the #39 stable publisher create `vX.Y.Z` from the same signed digest; #40 separately governs production cutover and standing auto-deploy activation.
