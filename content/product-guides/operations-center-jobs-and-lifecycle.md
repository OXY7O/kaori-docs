---
id: operations-center-jobs-and-lifecycle
title: Operations Center Jobs and Data Lifecycle
description: Interpret canonical job execution, archive evidence and protected Kubernetes administration without bypassing operational controls.
draft: true
sidebar_position: 9
---

> **Editorial status:** Unpublished source-reviewed operator draft
> for Docs #161. Application RC.3 source does not establish
> live production worker, archive storage or Secret Reveal
> authorization; all real UAT and content-rights gates remain pending.

## What Operations Center owns

**Operations Center** is KAORI's cross-cutting
operational control-plane workspace. It combines
the *committed posture* of authorized operational
domains while leaving execution, retention and
Kubernetes Secret policy to their separate owners.

The Overview does not become a second job engine,
archive backend or Kubernetes API client. Actual
background work uses canonical JobExecution and
domain-owned workers. Archive verification belongs
to the Data Lifecycle contract. Secret contents
belong to protected Kubernetes Operations.

## Workspaces and permissions

The source navigation defines:

- **Operations Center → Overview:** A read-only
  cross-domain posture. Navigation may be visible
  with any of `jobs.view`,
  `platform_operations.view_data_lifecycle`,
  or `kubernetes_secrets.manage_reveal`.
  Each contributing card must be permission-scoped.
- **Operations Center → Jobs:** The registered
  Jobs & Executions workspace for permitted
  inspection under `jobs.view`.
- **Operations Center → Data Lifecycle:** Retention,
  archive history and storage readiness, with
  `platform_operations.view_data_lifecycle`.
- **Operations Center → Kubernetes Admin:**
  Protected Kubernetes administration setup,
  gated by `kubernetes_secrets.manage_reveal`.

These are source navigation labels, **not a
complete authorization proof** for a given
job command, archive action or Secret Reveal.
Owning route decorators, domain permissions,
policy and selected resource scope decide
whether a request is admitted.

## Task: inspect Overview without mutating state

1. Open **Operations Center → Overview** with
   a role authorized for the visible workspaces.
2. Check the status of each permitted domain
   without assuming that invisible controls
   exist or are Healthy.
3. Inspect Jobs execution attention and
   persisted JobPolicy dispatch attention
   as **separate** quantities.
4. For Data Lifecycle, read **Policies Enabled**,
   **Active Archives / Jobs** and **Failed · 24H**.
   Archive and job counts must remain separate:
   one lifecycle job may also have an archive.
5. Review Kubernetes Administration readiness
   from its owning domain state, not an
   inferred count of registered clusters.
6. Use the corresponding owning workspace
   to investigate or request a permitted action.

**Expected result:** a read-only cross-domain
posture summary qualified by source permissions.
The page must not trigger a Celery topology query,
live cluster call, archive probe or policy creation.

**Blocked, unknown and configuration review**
must not be painted as operational Ready. Critical
and warning evidence takes precedence in the
source-owned presentation.

## Jobs: authoritative execution lifecycle

The canonical background-work sequence is:

1. An authorized operator action or supported
   scheduler identifies a registered JobDefinition.
2. The owning dispatcher resolves current domain
   permission and exact asset scope.
3. KAORI creates or attaches to a canonical
   **JobExecution**, applying policy and
   deduplication boundaries.
4. The accepted task enters its permitted
   **Celery queue** and domain-owned worker.
5. Progress, result, failure and terminal state
   are committed to the execution registry.

The Jobs domain owns admission, registry,
schedule policy, execution lifecycle and queue
posture; collectors and report builders remain
in their respective operational domains.

### Task: examine a JobExecution

1. Open **Operations Center → Jobs**.
2. Filter or locate a committed execution for
   the exact registered job and domain.
3. Inspect creation time, queue, status,
   source scope, progress and final result.
4. Check whether the domain evidence was
   **committed**; a queued/dispatched task
   is not proof that a provider changed state.
5. For a failed or stale job, follow the owning
   domain's recovery procedure and current
   policy rather than directly enqueuing
   Celery or editing database rows.

**Expected result:** an auditable job lifecycle
without bypassing server-side scope and worker
admission.

The Configuration workspace and schedule
controls have their **own** permissions and
validation. A visible job definition does
not grant schedule editing or manual dispatch.
Manual-only jobs must not imply an automated
scheduler switch. Do not infer a healthy
worker from a static badge.

## Data Lifecycle: archive first, verified evidence

**Operations Center → Data Lifecycle** provides
three source-owned workspaces:

- **Retention Policies:** A policy view with
  source-qualified retention/archive intent,
  preview and guarded execution controls.
- **Archive History:** Committed archive artifacts,
  verification state and cleanup evidence;
  underlying JobExecution remains in Jobs.
- **Archive Storage:** Configured storage target
  posture, verification and dependency checks.

The current source catalog contains **nine
registered Data Lifecycle adapters**, with
domain-specific capabilities. A shared
retention interface is not blanket permission
to delete all corresponding source records.

### Task: assess an archive or retention policy

1. Open the permitted **Retention Policies**
   workspace and select the registered domain.
2. Check whether the policy is configured,
   enabled or paused, and which archive
   or cleanup actions are actually admitted.
3. Examine the **Preview** before considering
   a lifecycle execution. An unconfigured
   or paused policy is a fail-closed blocker.
4. Review queue/worker and target-storage
   readiness in the owning views.
5. Inspect **Archive History** for a matching
   archive generation, checksum/manifest
   verification and cleanup outcome.
6. If evidence is missing or degraded,
   use the separately authorized operations
   process instead of treating an endpoint
   connectivity check as verification.

**Expected result:** an evidence-backed
assessment of archive eligibility and
retained artifacts, not a claim that
data has been safely removed.

**Reachable** only indicates a limited
connectivity fact. It is **not** verified
checksum integrity or complete artifact
recovery. The source requires matching
verified evidence for archive success.

Some registered domains are archive-only
or remain manually operated while their
destructive cleanup and delivery
contracts await separate admission.
The formerly used Settings Data Lifecycle
route is compatibility-only: do not
create a second policy editor in Settings.

## Kubernetes Admin: protected policy, not Secret values

**Operations Center → Kubernetes Admin**
owns high-privilege setup and namespace
policy for the protected Secret Reveal
workflow. Operational Secret values remain
owned by the Kubernetes Secrets domain,
not Operations Center.

Its workspace uses **Overview** and
**Secret Reveal** tabs with independent
eligibility and scoped authorization.

### Task: review Secret Reveal readiness

1. Open **Kubernetes Admin** only with
   authorization to manage reveal policy.
2. Inspect global gate status, eligible
   cluster credential and security posture.
3. Review per-cluster and namespace reveal
   policy coverage. A missing or failed
   namespace source is a blocker, not an
   empty inventory.
4. Treat a disabled global gate or
   incomplete policy as **not ready**.
5. Refer an actual one-time Secret Reveal
   request to the protected owner workflow,
   with its own permissions, approvals
   and audit requirements.

**Expected result:** qualified configuration
readiness without exposing a Kubernetes
Secret value, token, private key or
approval bypass.

A direct navigation link or configured
cluster does not grant reveal permission.
Do not add permissive namespace policy
or turn on global reveal merely to make
the page look Ready.

## Troubleshooting and escalation

- **Overview card unavailable:** Inspect the
  owning domain permission before assuming
  the domain is absent.
- **Jobs pending or failed:** Identify the
  canonical JobExecution, queue, worker and
  domain result; do not issue direct Celery
  tasks from the page.
- **Repeated job appears once:** Check
  deduplication/attach semantics before
  claiming a missing run.
- **Storage reachable but archive unverified:**
  Inspect target-profile-matched manifest
  and checksum evidence, not connectivity
  alone.
- **Retention execution blocked:** Review
  persisted policy, paused status, active
  execution and source-specific cleanup
  admission.
- **Kubernetes Admin blocked:** Check
  eligible credentials, global gate,
  cluster readiness and namespace policy.
- **Empty or stale counts:** Separate a
  completed true zero from missing,
  failed, partial or stale observations.

Use sanitized job IDs and evidence timestamps
in authorized support channels. Never put
production archive target details, tokens,
namespace Secret names or reveal payloads
in publicly tracked Docs source.

## Source and UAT applicability

This article reflects KAORI Application
`app/platform_operations/README.md`,
`app/platform_operations/jobs/README.md`,
`app/platform_operations/data_lifecycle/README.md`,
`app/common/workspace_navigation_catalog.py`,
and the relevant owning route contracts,
at `v0.3.0-rc.3@197a7f7e598c111592a8ae36388865cd3aacf541`.

The published App RC.3 still requires
runtime/permissions/UAT acceptance. Before
candidate Docs publication, verify real
role/cluster/source boundaries, worker,
archive-only and checksum outcomes,
protected reveal denials, responsive
browser behavior, attribution, rights
and Human Acceptance.

This chapter remains `draft: true`,
outside the current public Docs RC
and independent of stable `/v0.3/`.
