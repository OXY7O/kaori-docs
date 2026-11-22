---
id: kubernetes-inventory-and-dashboard
title: Kubernetes Inventory and Dashboard
description: Read committed Kubernetes inventory and dashboard evidence with source, scope, and permission awareness.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished source-reviewed draft for Docs #138.
> Application staging source was inspected, but real role-scoped browser
> UAT and stable-release applicability have not been accepted.

## What this workspace provides

The **Kubernetes** workspace groups Overview, Inventory, Operations,
Governance, Tenant and Analytics capabilities. Each may have
different permissions and data readiness. This guide describes
the **read-only Dashboard and Inventory** workflows only.

Kubernetes remains authoritative for its own cluster resources.
KAORI stores normalized inventory generations and presents
source-qualified evidence. A web request does not automatically
refresh a cluster, execute Kubernetes API calls or obtain
up-to-date metrics from an external monitoring service.

## Audience and access

- **Overview:** The navigation catalog lists `dashboard.view`.
- **Inventory:** The navigation catalog lists `inventory.view`.

These are **navigation** permission indicators, not blanket
authorization to inspect every cluster or change a workload.
An authorized account and a registered Kubernetes integration
are prerequisites. Provider readiness, selected cluster scope
and current committed collection status must be verified
separately.

## Inventory menu reference

The source-defined **Kubernetes → Inventory** workspace
includes these nested views:

- **Overview:** Fleet inventory, coverage and snapshot context.
- **Topology:** Recorded resource identities and relationships.
- **Nodes:** Node identity, state and capacity metadata.
- **Namespaces:** Namespaces and resource controls.
- **Workloads:** Workload ownership and reported Pod templates.
- **Pods:** Pod phase, readiness and restart evidence.
- **Services:** Service identity and exposure configuration.
- **Ingresses:** Recorded ingress routing and references.
- **Storage:** Persistent storage resources and associations.
- **Configuration:** Collected configuration records.

The user-visible menu may be filtered by role and feature
readiness. These source entries do not prove that every tab
is accessible or populated in a given environment.

## Task: review an inventory snapshot

1. Sign in with the required Inventory authorization and open
   **Kubernetes → Inventory**.
2. Select the relevant cluster or permitted all-cluster scope.
   Inspect the collection timestamp before trusting totals.
3. Review **Overview** to understand the asset coverage. A
   pending or incomplete collection is not evidence of an
   empty cluster.
4. Open **Nodes**, **Workloads** or **Pods**, as needed, and
   apply the available cluster, namespace or status filters.
5. Inspect a permitted resource detail and compare its
   identity, reported state and related objects against
   the selected snapshot.
6. Open **Topology** to inspect source-supported relations
   without inferring a connection from identical names.

**Expected result:** a scoped list of assets and relationships
observed in one committed inventory generation. This is
a read-only investigation, not an operation on the cluster.

Tables use canonical KAORI pagination, defaulting to
**5 records per page**, with 5/10/25/50 options. Filter
changes refresh the scope-dependent workspace context,
while pagination changes only the visible records.

### How to interpret inventory correctly

The source contract uses
`ClusterInventory.collected_at` as the committed generation
marker. Summaries, filters, detail views and topology must
not silently combine new and superseded generations.

- **Ready and phase are distinct:** a Pod's Ready state
  cannot be inferred solely from its phase.
- **Restart counts are cumulative:** a time-windowed
  restart rate requires separate time-qualified evidence.
- **Pod template details are source-owned:** do not infer
  workload configuration from existing Pods when the
  authoritative collected template is missing.
- **Unknown remains unknown:** missing conditions or
  relationships are not a clean bill of health.

## Task: interpret the operational dashboard

The source-defined **Kubernetes → Overview** page reads
committed KAORI projections, with `dashboard.view`
navigation permission. It does not directly query
Kubernetes, Metrics Source or Alertmanager during
normal page GET requests.

1. Open **Kubernetes → Overview** with a permitted cluster
   scope and review **Operations Overview**.
2. Read Cluster Health, Inventory Snapshot and Data
   Freshness before interpreting operational summaries.
3. Inspect **Capacity & Demand** for committed metrics,
   Top Consumers and available forecast results.
4. Review **Signals & Actions** for qualified alert
   and recommendation evidence. A recommendation is
   not permission to execute remediation.
5. Review **Reporting** only when its source and worker
   evidence are available to your account.

**Expected result:** a read-only explanation of the
last committed operational posture. Missing, stale,
expired or failed worker data must be shown as such.
A forecast is model output, not a verified future state.

## Troubleshooting and limitations

- If a cluster is missing, check permitted scope and
  integration registration before assuming deletion.
- If rows are empty, verify filters, collection outcome,
  generation timestamp and available provider evidence.
- If data conflicts across pages, compare source scope,
  current generation and the relevant worker result.
- If topology edges are missing, verify actual source
  identities and bindings, not merely matching labels.
- If analytics are stale, review the owning Metrics Source
  or Alertmanager binding and the committed worker state.
- If an action is unavailable, check the actual
  permission and the owning workflow maturity.

Do not restart a cluster or delete inventory to resolve
a stale dashboard without separate evidence and change
authorization. Kubernetes Operations, Governance, Tenant
and other mutating workflows require their own guide
and action-specific UAT.

## Source and acceptance

This draft reflects KAORI Application
`app/common/workspace_navigation_catalog.py`,
`app/common/workspace_navigation.py`,
`app/kubernetes/inventory/README.md`,
`app/kubernetes/dashboard/README.md` and
`app/dashboards/README.md` at source revision
`197a7f7e598c111592a8ae36388865cd3aacf541`.

Before acceptance, verify real menus, permissions and
data states on an admitted application candidate;
capture sanitized normal, empty, stale and partial
browser evidence; and obtain an independent content
review. This article remains `draft: true` and
is not published in the current Docs RC.
