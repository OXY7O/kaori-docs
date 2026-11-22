---
id: installation-and-runtime-modes
title: Installation and Runtime Modes
description: Choose the correct KAORI runtime mode and understand the source-reviewed setup, verification, and recovery boundaries.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished, source-reviewed installation draft.
> The steps below describe the current development and candidate-evaluation
> contracts, but they have **not** received this documentation release's
> independent hands-on UAT. A signed RC is not a stable application release,
> and these instructions do not advertise a supported customer installer.

## Choose the right way to run KAORI

KAORI currently documents three **different execution purposes**.
Choose one before editing configuration or starting containers.

| Mode | Intended use | What runs | Important boundary |
| --- | --- | --- | --- |
| Local Dev Container | Source development and debugging | Source checkout, Flask debug, PostgreSQL, Redis, workers, Beat and frontend tooling | Development credentials and bind-mounted source are **not** production isolation |
| Local standalone RC | Disposable candidate evaluation without a Dev Container | An accepted immutable candidate image and separate local PostgreSQL/Redis/worker/Beat stack | Not editable-source development and not a stable customer release |
| Governed server | Authorized UAT or release deployment | Accepted signed image, controlled configuration, migrations, workers, health and recovery | Requires separate approval and host/operator procedures; **not** a copy of local development |

The root `.env`, the standalone `example/kaori/.env`,
and governed server environment are **separate authorities**. Do not
reuse a development password, application secret, database volume or
runtime state across these modes.

## Path A — Develop with VS Code Dev Containers

### Prerequisites

Use a supported Docker host with running **Linux containers**, Git,
VS Code and the Dev Containers extension. The existing application
development documentation describes Docker Desktop + WSL2 on Windows
and Docker Desktop on macOS. A host-side Python virtual environment
is not required; the tooling runs in containers.

The following assumes you have the KAORI source repository and are
authorized to use its development mode.

### 1. Prepare a fresh checkout

Open the checkout in VS Code. On initial setup, the Dev Container
initializer prepares an ignored development `.env` and separately
ignored database-role credentials. You may inspect and edit the
repository's development-only `.env.example` and copy it before
opening the container if you need approved development settings:

```bash
# Optional; skip when using the normal initializer.
cp .env.example .env
```

Never commit generated `.env` or local development credentials.
Never substitute production secrets for placeholders. An initialized
PostgreSQL volume with unknown or mismatched credentials must cause
a stop and investigation, **not** volume deletion or silent credential
regeneration.

### 2. Open the supported container workspace

From the VS Code command palette, choose
**Dev Containers: Rebuild and Reopen in Container**.

The documented development stack starts PostgreSQL, Redis, the
workspace, dedicated Celery workers and Beat. For a Windows-host
checkout, a WSL Remote editor session is not required solely to open
this Dev Container.

The Compose lifecycle uses **both** development Compose files:

```bash
docker compose -f compose.yml -f .devcontainer/compose.devcontainer.yml ps
```

Do not use a plain `docker compose down` as a troubleshooting shortcut
or run `down -v` against persistent development data.

### 3. Verify database initialization

For a genuinely new development database, the guarded
`db-first-run` service handles the first schema/bootstrap. Existing
data is **not** automatically destroyed or migrated to recover a
failed initialization.

For an interrupted first install, review the job rather than
resetting persistent volumes:

```bash
docker compose -f compose.yml -f .devcontainer/compose.devcontainer.yml logs db-first-run
```

The current application runbook gives the explicit development-only
recovery command:

```bash
docker compose -f compose.yml -f .devcontainer/compose.devcontainer.yml run --rm db-bootstrap
```

After first setup, an **upgrade** remains a separately authorized
development migration, with a different guarded command. Do not
run arbitrary production migrations from a browser readiness screen.

### 4. Start the development web application

In VS Code select **F5 → KAORI: Flask Debug**, or use the supported
Dev Container terminal:

```bash
flask --app run:app run --host=0.0.0.0 --port=5000 --debug
```

The documented development address is
`http://localhost:5000/auth/login`. The development `ADMIN_*`
configuration identifies the bootstrap identity; do not reproduce
real passwords in troubleshooting tickets or screenshots.

If updating frontend templates or styles, the documented asset
workflow is **Terminal → Run Task → KAORI: Watch Tailwind CSS** after
Dev Container bootstrap is complete. The separate source build/CI
process validates static assets.

### 5. Check asynchronous workers

Before testing inventory sync, reports or other asynchronous features,
validate the registered workers and their canonical queues from the
authorized Dev Container terminal:

```bash
celery --app celery_worker:celery_app inspect ping
celery --app celery_worker:celery_app inspect active_queues
```

A browser request marked queued does not mean a task succeeded.
Check its committed job/outcome and owning domain before claiming
completion.

## Path B — Evaluate an admitted standalone RC

Use this mode when you want to run a specific **approved candidate
image on a disposable laptop**, without editing application source.

### 1. Obtain the correct release identity

An acceptable release record must identify its approved immutable
image digest, candidate tag, exact application source SHA, version
and build date. A mutable `:staging` tag or working-tree version is
not enough.

The application repository contains a separate
`example/kaori/` Compose example. From that folder:

```bash
cd example/kaori
cp .env.example .env
```

Before startup, review the local `.env` and set `KAORI_IMAGE`,
`APP_VERSION`, `APP_BUILD_SHA` and `APP_BUILD_DATE` to the
**same accepted release's values**. Use only disposable, local
credentials. Do not paste production database URLs, provider tokens
or enterprise configuration into this example.

### 2. Start and validate

Use the existing guarded launcher:

```bash
bash ./run.sh start
bash ./run.sh status
```

The documented local web address is `http://localhost:5000` on the
laptop loopback interface. PostgreSQL and Redis remain private to
the local Compose network; the web process, compact multi-queue worker
and Beat run from the selected admitted image.

If startup fails, review the existing wrapper output and logs:

```bash
bash ./run.sh logs
```

A source-code change in your checkout does **not** modify this
running image. Stop the local stack with `bash ./run.sh stop`.
The `reset` operation destroys its disposable volumes and is
**not** a routine stop, upgrade or problem-solving command.

## Path C — Governed server UAT or release

This path is **not a public self-service installation tutorial**.
It describes the documented operating boundary for an authorized
KAORI maintainer or infrastructure operator. It must not be used to
infer that customer-managed distribution or hosted subscription
deployment is generally available.

The current governed server process uses separately owned
application configuration, protected secrets, deployment adapter
configuration and generated immutable release identity. Its
canonical Compose deployment combines the base production definition
with the reviewed server overlay.

The operator-controlled process is:

1. Approve the target and operational impact, verify the applicable
   Environment and source/release authority.
2. Select the **exact signed immutable image digest**, rather than
   inferring a deployed version from a branch or development
   `VERSION` file.
3. Check isolated configuration, pinned host trust, database
   prerequisites and backup/recovery readiness.
4. Run the separately authorized deployment adapter, including
   **pre-migration backup → configuration checks → schema migration
   → web/workers/Beat startup → runtime verification**.
5. Verify the actual committed deployment receipt and external
   HTTPS/edge behavior where applicable. Maintain a recoverable
   previous-image baseline.
6. Obtain explicit user/operator UAT and release-bound Human
   Acceptance before treating the candidate as stable.

Do not start only the base production Compose file, use a
development `.env`, or manually bypass database migration or
release identity checks. The canonical server deployment and
recovery instructions stay with the authorized application
operations authority.

## Troubleshooting without data loss

Before attempting repair, determine which mode you are actually
running. For a development failure, use this source-verified order:

1. Capture the first Flask or Dev Container error and relevant
   service logs, with secrets removed.
2. Confirm schema/bootstrap state, never reset a populated
   PostgreSQL volume as a guess.
3. Check PostgreSQL and Redis connectivity within the correct
   Compose project.
4. Check application environment-contract validation.
5. Check worker and queue readiness for background functions.
6. Compare the failure with the exact source revision and supported
   runtime mode.

A failure is not resolved merely because a login page opens:
collection, workers, permission checks, and committed evidence
may still be incomplete. Server-side changes and rollback follow
the governed operator procedures, not these development commands.

## Source, applicability and review gaps

This draft follows the KAORI Application `docs/RUNNING.md`,
`docs/DEVELOPMENT.md`, `example/kaori/README.md`,
`docs/DEPLOYMENT.md` and `deploy/server/README.md` contracts
at the source-reviewed 2026-11-22 staging baseline.

Before acceptance for a Docs RC, verify prerequisites and commands
on each intended supported platform, read-only negative cases,
first-run and existing-database behavior, permission/access
configuration, screenshot sanitization, link accessibility and
the exact application candidate. Detailed installation/upgrade
and recovery procedures for unsupported customer distribution
must remain withheld until independently qualified.

This draft is **not assigned to any stable KAORI Application line**.
