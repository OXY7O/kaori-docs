---
id: kubernetes-inventory-and-dashboard
title: Kubernetes Inventory and Dashboard
description: Understand the permission-scoped KAORI Kubernetes workspace, committed inventory, dashboard evidence, and safe read-only investigation.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished, source-reviewed operator guide under
> Docs #138. The names and behavior described here were read from KAORI
> Application staging source, not verified in a live deployment or against
> a stable product release. Actual menus, configured clusters and data
> availability depend on permissions and the accepted Application candidate.

## Purpose and audience

The **Kubernetes** workspace combines operational overview, inventory,
operations, governance, tenant and analytics capabilities in one
domain-oriented navigation family. This guide covers only the
**read-only Operational Dashboard and committed Inventory views**.

It is intended for authorized infrastructure operators and observers
who need to identify assets, investigate workload relationships and
interpret the age and completeness of collected evidence. It does not
grant permission to change a cluster or expose Kubernetes Secrets.

### Before you begin

- Your KAORI account must be authorized to view the relevant capability
  and selected cluster. The source catalog labels Kubernetes Overview
  with `dashboard.view` and Inventory with `inventory.view`. Those
  navigation permissions do **not** bypass route, resource-scope or
  integration validation checks.
- The cluster must be registered through its owning Kubernetes
  integration and have collected inventory evidence. A registration
  record alone does not prove that a current snapshot exists.
- Source-derived visibility and usability must be confirmed with a
  permitted account during candidate browser UAT. No real cluster,
  namespace or provider endpoint is assumed in this example.

## Workspace navigation at a glance

The source-defined Kubernetes top-level capability tabs are
**Overview**, **Inventory**, **Operations**, **Governance**,
**Tenant** and **Analytics**. Some require distinct permissions and
may not appear for every account.

From **Kubernetes → Inventory**, the source catalog declares these
nested views:

- **Overview:** Inventory assets, multi-cluster scope and last collection context.
- **Topology:** Recorded resource relationships and cluster/namespace boundaries.
- **Nodes:** Node identity, readiness and reported capacity.
- **Namespaces:** Namespace identity and resource controls.
- **Workloads:** Workload identity, desired/runtime posture and available Pod template evidence.
- **Pods:** Pod readiness, phase and cumulative restart counts.
- **Services:** Service identity and configured exposure.
- **Ingresses:** Recorded ingress rules and relationships.
- **Storage:** Persistent volumes, claims and source-backed relationships.
- **Configuration:** ConfigMaps and other collected configuration evidence where supported.

## Read-only workflow: review a cluster inventory

1. Sign in with an account granted the applicable Inventory access.
   Open **Kubernetes → Inventory** in the workspace navigation.
2. Select the desired cluster or authorized all-cluster scope when
   that option is available to the account. Inspect the collection
   timestamp and evidence scope before using totals as current facts.
3. Review **Inventory Overview** for asset counts and collection
   context. A missing or partial collection must not be described as
   an empty or healthy cluster.
4. Choose **Nodes**, **Workloads** or **Pods** according to the
   investigation. Narrow the available cluster, namespace, state or
   other resource-specific filters as appropriate.
5. Inspect the visible records. The established KAORI inventory
   tables default to **5 rows per page**, with 5/10/25/50 page-size
   options. Filter changes update the scope-aware summary and
   dependent options; pagination changes the visible rows.
6. Open a permitted resource detail when offered. Compare the
   object's recorded identity, namespace, status and related
   resources with the collection context. Do not infer a workload
   Pod template from observed Pods if the authoritative template
   was not collected.
7. Open **Topology** to examine source-supported relationships.
   Matching names alone do not prove a dependency. Avoid mixing
   resources from different clusters or superseded inventory
   generations when interpreting a visual relationship.

**Expected outcome:** you can describe which resources were
**observed in a specific committed inventory generation**, the
selected scope, and what data was missing or uncertain. No provider
mutation should occur during this workflow.

### Reading health and status without overclaiming

- **Inventory freshness:** the cluster's `ClusterInventory.collected_at`
  value identifies the committed generation marker. List rows,
  summaries, dependent filters, details and topology should read the
  same current generation rather than mixing old and incomplete
  observations.
- **Pod readiness versus phase:** Ready, Starting, Not Ready, Failed,
  Completed and Unknown convey distinct operational evidence.
  A Pod restart count is cumulative unless its time window is
  explicitly known.
- **Capacity:** Kubernetes object capacity metadata and metrics
  utilization represent different sources and timestamps.
  A resource's configured limits or requests are not automatically
  its observed utilization.
- **Unknown does not mean healthy:** absent certificate, image,
  topology, runtime or policy evidence must not silently become a
  passing compliance posture.

## Read-only workflow: interpret the dashboard

The source catalog exposes the operational dashboard at
**Kubernetes → Overview**, which is permission-scoped under
`dashboard.view`. The dashboard uses committed KAORI data rather
than calling Kubernetes, Metrics Source or Alertmanager synchronously
on a normal web request.

1. Open **Kubernetes → Overview** and confirm the selected cluster
   scope and timestamp context.
2. Read **Operations Overview** for Cluster Health, Inventory
   Snapshot and Data Freshness. These are committed projections;
   a successful page load alone cannot prove every source is ready.
3. Inspect **Capacity & Demand** for capacity, Top Consumers and
   forecast only when the corresponding worker evidence exists.
   A forecast is a model output—not a measured future utilization.
4. Review **Signals & Actions** for source-qualified alerts and
   recommendations. Verify the signal source and available
   evidence; a recommendation is not approval to execute remediation.
5. Use **Reporting** for reported results when authorized and
   available. A queued report or missing worker result must not be
   represented as a completed report.

**Expected outcome:** a read-only, evidence-limited view of
current *committed* operational posture. Missing, stale, pending,
expired or failed worker data must remain distinguishable.

## When data does not look right

- **Cluster missing from scope:** Check account scope and the owning Kubernetes integration; do not bypass RBAC or add a cluster as a workaround.
- **Empty table but source expected:** Inspect the last committed collection, source/binding and applied filters before concluding there are no resources.
- **Totals and records appear inconsistent:** Compare selected cluster/namespace filters and generation timestamp; record the discrepancy for the owning inventory workflow.
- **Topology has missing edges:** Confirm both endpoints and their source-supported identity/binding; do not draw a dependency from matching labels.
- **Dashboard analytics are stale or unavailable:** Check evidence age, Metrics Source/Alertmanager configuration and owning worker/job outcome through authorized views.
- **Action is unavailable or disabled:** Confirm role permissions, resource scope and owning workflow maturity; viewing the dashboard does not grant execution rights.

Do not restart a cluster, delete inventory, reset persistent storage
or mutate external providers solely because a dashboard looks stale.
Escalate with sanitized source, selected scope, collection timestamp,
job status and a reproducible UI navigation path.

## Related workflows and current limits

**Operations** (including ConfigMaps and Secrets), **Governance**
(certificates), **Tenant** (resource profiles and namespace
provisioning), and **Analytics** each have their own permission and
potential mutation or sensitive-data contracts. They need separate
guides and UAT; the read-only Inventory permission does **not**
authorize those actions.

No specific Kubernetes distribution, cluster, observability
provider, alert source or production deployment is claimed
configured by this documentation. All examples are conceptual.

## Source and release applicability

Source reviewed: KAORI Application
`app/common/workspace_navigation_catalog.py`,
`app/common/workspace_navigation.py`,
`app/kubernetes/inventory/README.md`,
`app/kubernetes/dashboard/README.md`, and
`app/dashboards/README.md` on
`kaori/staging@197a7f7e598c111592a8ae36388865cd3aacf541`.

**Remaining acceptance:** verify every named menu and link against
real role-scoped browser UAT; capture evidence for normal/empty/stale
and partial cases; validate applicable Application candidate
tag/SHA, provider readiness, rights/sanitization and reviewer
decisions. This article remains `draft: true` and is **not** a
stable product guide or part of the current public Docs RC.
