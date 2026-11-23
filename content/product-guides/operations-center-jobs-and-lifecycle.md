---
id: operations-center-jobs-and-lifecycle
title: Operations Center Jobs and Data Lifecycle
description: Inspect source-qualified jobs, archive evidence and protected Kubernetes administration.
draft: true
sidebar_position: 9
---

> **Editorial status:** Unpublished draft for Docs #161.
> Reviewed Application source does not prove runtime UAT, production availability or release acceptance.

## Purpose and boundaries

**Operations Center** composes read-only operational posture from the canonical Jobs, Data Lifecycle and Kubernetes Administration domains. It is not another Celery scheduler, retention engine or Kubernetes provider. The owning domain controls every command, policy, execution record and permission.

The Application source declares four workspace capabilities:

- **Overview:** Permission-filtered summary, visible when at least one permitted Operations Center domain is available.
- **Jobs:** JobExecution and worker/queue context; navigation requires `jobs.view`.
- **Data Lifecycle:** Retention Policies, Archive History and Archive Storage; navigation requires `platform_operations.view_data_lifecycle`.
- **Kubernetes Admin:** Protected Secret Reveal administration; navigation requires `kubernetes_secrets.manage_reveal`.

Overview navigation can be admitted by any of `jobs.view`, `platform_operations.view_data_lifecycle` or `kubernetes_secrets.manage_reveal`. These are *navigation* permissions; actual route/asset/action authorization must be verified independently. A hidden card does not imply a domain or its data is absent.

## Task: inspect Operations Center Overview

1. Open **Operations Center → Overview** using an authorized account.
2. Review only the visible source-qualified Jobs, Data Lifecycle and Kubernetes Admin posture.
3. Inspect Jobs execution attention and persisted dispatch-policy attention separately. A failed policy may have no corresponding queued execution.
4. Compare Data Lifecycle **Policies Enabled**, **Active Archives / Jobs** and **Failed · 24H**. An archive and its creating job are not two independent business operations.
5. Follow the owning workspace to investigate warnings or blocked configuration.

**Expected result:** a permission-scoped summary of committed operational evidence. Overview does not call live Kubernetes, probe storage, inspect Celery topology, preview retention or create JobPolicies during GET. Unknown, missing or configuration-review state is not **Ready**.

## Task: investigate a canonical job

1. Open **Operations Center → Jobs** with `jobs.view`.
2. Select a registered JobDefinition and the exact permitted domain or infrastructure scope.
3. Inspect the canonical **JobExecution** record, queue, status, progress and final result.
4. Distinguish registration, dispatch, running, failure and completed **domain evidence**. Queued is not committed.
5. If recovery is needed, follow the owning domain's authorized Job Configuration and worker procedure.

The supported flow is **registered definition → domain authorization → JobExecution → Celery queue → domain executor → result/evidence**. Jobs owns policy, orchestration and lifecycle; Kubernetes, Object Storage, Registry, Reports and Analytics own their respective collectors and business actions. Manual or scheduled actions must not dispatch ad hoc Celery tasks or bypass resource permissions. A job's presence does not authorize schedule edits or manual execution.

## Task: interpret Data Lifecycle evidence

1. Open **Operations Center → Data Lifecycle** with the appropriate permission.
2. In **Retention Policies**, choose the registered domain and inspect the actual enabled/paused policy and **Preview**.
3. Read **Archive History** for artifact generation, checksum or manifest verification and any conditional cleanup outcome.
4. Review **Archive Storage** for verified profile-matching target evidence, not simply a reachable endpoint.
5. Inspect related JobExecution in **Jobs** if separately authorized; Data Lifecycle does not operate a second worker ledger.

The source declares nine registered archive adapters, but destructive source cleanup is separately admitted for each domain. Some are archive-only or manual-only; an enabled UI does not grant blanket deletion. Policy absence, paused state, an active conflicting execution, unverified archive or unknown storage must fail closed. **Reachable is not a verified archive**; a successful connection test does not prove retained data integrity or restore eligibility.

The legacy Settings Data Lifecycle route is redirect-only. The active retention and archive policy workspace belongs to Operations Center.

## Task: review Kubernetes Admin protection

1. Open **Operations Center → Kubernetes Admin** only with the required management permission.
2. Inspect the **Overview** and **Secret Reveal** policy tabs.
3. Check the global protection gate, eligible Kubernetes cluster, cluster credential readiness and namespace policy coverage.
4. Treat missing cluster credentials, disabled global gate or failed namespace retrieval as **Blocked**, not as empty or Ready.
5. Send an actual one-time Secret Reveal request through the owning protected Kubernetes workflow and its independent approval/audit gates.

**Expected result:** a review of setup and policy readiness, never a Secret value. Operations Center does not own Kubernetes Secret content or grant a viewer the ability to reveal it. Do not enable permissive policies or bypass approvals to make the status appear healthy.

## Troubleshooting and evidence interpretation

- **Overview unavailable:** Check the owning domain's permission, not just the sidebar.
- **Job pending or failed:** Inspect canonical queue/worker and domain result without dispatching directly from HTTP.
- **Unexpected execution count:** Check create-or-attach and deduplication before claiming a missing or duplicate job.
- **Storage reachable but not verified:** Confirm checksum and manifest evidence for the currently configured archive profile.
- **Retention blocked:** Check policy state, Preview, job concurrency, source-specific cleanup admission and history.
- **Secret Reveal blocked:** Verify eligible cluster credential, global gate and namespace policy, not Secret contents.
- **Unknown or stale:** Distinguish incomplete collection from a completed observed zero.

Use sanitized evidence timestamps and scoped job references in support channels. Never include private storage URLs, credentials, production target details, Secret identities or reveal results in public documentation.

## Source and publication applicability

Source authority: `app/platform_operations/README.md`, `app/platform_operations/jobs/README.md`, `app/platform_operations/data_lifecycle/README.md`, `app/common/workspace_navigation_catalog.py` and owning route permissions in Application `v0.3.0-rc.3@197a7f7e598c111592a8ae36388865cd3aacf541`.

The published Application RC.3 is **UAT pending**. This article requires independent source review, real role/cluster/job/archive/Secret positive and denied browser tests, license and sanitization checks, accepted Docs candidate applicability and Human Acceptance before publication. It remains `draft: true`, excluded from public Docs RC and stable `/v0.3/`.
