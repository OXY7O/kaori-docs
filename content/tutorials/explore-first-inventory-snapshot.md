---
id: explore-first-inventory-snapshot
title: Explore Your First Inventory Snapshot
description: Learn how a Kubernetes inventory snapshot, its source scope, and committed evidence relate in KAORI.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished learning draft for Docs #6. KAORI Application staging source was inspected at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. This is **not** a release-qualified, browser-tested walkthrough. Exact UI labels, navigation, screenshots, and applicability require acceptance before publication.

## What you will learn

This beginner tutorial teaches you to interpret a **committed Kubernetes inventory snapshot** without assuming it is a live query of the cluster. You will distinguish a cluster source from its inventory generation, narrow the resource scope, and recognize what a missing or older observation can—and cannot—tell you.

You will **not** initiate a collection, edit infrastructure, reveal credentials, or change access permissions.

## Before you begin

- Use a non-sensitive, approved demonstration cluster with an authorized KAORI account. The inspected Inventory GET routes require the server-side `inventory.view` permission.
- A registered Kubernetes connection and an existing committed snapshot are needed for meaningful records. Without them, treat the empty/onboarding state as a valid learning outcome rather than fabricating data.
- Ask the environment owner for an approved demonstration scope. Do not record real cluster identifiers, namespaces, hostnames, user identities, or workload details in documentation screenshots.
- This exercise describes a **source-reviewed staging contract**; it does not guarantee that a particular account, provider connection, or stable release exposes these pages.

## Learn the source-to-snapshot model

```text
Kubernetes API (external authority)
             |
             v
Authorized collection for one cluster
             |
             v
Atomic inventory generation committed by KAORI
             |
       +-----+------+
       |            |
       v            v
Resource tables    Topology / related records
       |            |
       +-----+------+
             |
             v
Scoped, timestamped operational interpretation
```

**Diagram description:** An external Kubernetes API supplies resource observations. KAORI collects and commits one cluster generation, which powers inventory tables and topology. The reader must preserve the cluster and timestamp scope. This is conceptual, not a live synchronization trace.

## Guided exploration

1. **Identify the source.** In a release-verified Inventory workspace, locate the cluster context and confirm which registered cluster is represented. The staging implementation defines an Inventory Overview, resource lists, and topology; the final browser navigation path must be confirmed during UAT.
2. **Read the snapshot context first.** Look for the inventory source, selected scope, observation time, committed coverage, and stale/missing exceptions. If the page has no committed snapshot, stop here and explain the missing prerequisite; do not infer an empty cluster.
3. **Choose one resource family.** The inspected source supports Nodes, Namespaces, Workloads, Pods, Services, Ingresses, Storage, and Configuration inventory. Pick a resource family that the demonstration cluster is authorized to expose.
4. **Narrow the scope.** Select a cluster and, where applicable, a namespace or resource filter. Observe that the summary, dependent filters, and table should represent the same committed generation. A filter returning zero records means no matching records **in that committed scope**, not proof that the external source has no such resources.
5. **Inspect one record if available.** Compare identity, operational state, and metadata without treating labels or configuration as policy violations. In particular, Kubernetes Pod phase and readiness are separate observations; a restart count is cumulative unless a time window is explicitly provided.
6. **Return to the overview.** Explain which cluster, snapshot generation, resource family, and filter scope support your observation. If topology is available, treat its relationships as source-derived observations, not a complete service dependency map.

### Learning checkpoint

You should be able to answer: **Which source and cluster does this record belong to? When was the committed generation observed? Which filters changed the view? What remains unknown?**

A useful conclusion is: “This demonstration view shows records in the selected committed cluster snapshot; it does not establish the live state of every Kubernetes resource.” Do not substitute a made-up asset count, collection time, or success badge.

## When the exercise cannot proceed

- **No registered cluster or snapshot:** the environment may require onboarding or an authorized collection. Do not trigger it as part of this read-only tutorial.
- **Permission denied:** `inventory.view` is a distinct server-side permission. Ask the administrator to review access; do not recommend a role change or bypass.
- **Stale or partial context:** preserve the last committed observation and report the limitation. A previous successful collection does not prove present-day source health.
- **No matching rows:** recheck filters and scope before interpreting absence; do not equate an empty result with a healthy or empty cluster.

## Editorial source and publication gate

- **Owner:** Docs #6; tutorial content pattern in `docs/TUTORIAL_HOWTO_PATTERNS.md`.
- **Application evidence:** `app/kubernetes/inventory/README.md`, `app/kubernetes/inventory/routes.py`, and `app/kubernetes/inventory/synchronization.py` at the pinned staging SHA.
- **Source-reviewed:** inventory GET routes require `inventory.view`; synchronization is a separate POST guarded by `clusters.sync`; committed generation is the read boundary. These are implementation observations, **not executed UAT**.
- **Pending:** accepted application release manifest and Docs #15 version mapping; actual role-scoped browser steps, accessible navigation, mobile/light-dark/200%-zoom checks, sanitized screenshots, staging Full Admission, and human acceptance.

Until publication is separately authorized, keep `draft: true`; do not add this page to public navigation or search.
