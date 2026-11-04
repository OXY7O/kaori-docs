---
id: verify-inventory-refresh-evidence
title: Verify Inventory Refresh Evidence
description: Check the committed Kubernetes inventory generation and distinguish collection requests from observed results.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished, read-only how-to draft for Docs #6. Source-reviewed against KAORI Application staging `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. UI instructions are intentionally limited until release-specific browser UAT confirms the exact controls and labels.

## Goal and scope

Determine whether the **currently displayed Kubernetes inventory** reflects a committed collection generation for the intended cluster, and document what that evidence supports. This guide does **not** start a refresh, establish a source-of-truth health verdict, or assert that the cluster is fully covered.

The staging Inventory GET routes use `inventory.view`. A synchronization request uses a different `clusters.sync` permission and can enqueue a background job; it is deliberately **outside** this read-only procedure.

## Prerequisites

You need an authorized KAORI session, `inventory.view`, a known demonstration cluster, and permission to inspect its existing committed inventory. For publication, an accepted application release, tested account/role, and real UI route evidence must be supplied. No private environment details should be copied into the guide.

## Read-only verification procedure

1. **Confirm cluster and filters.** In the release-verified Inventory Overview, identify the selected cluster and any namespace/resource filters. An all-cluster view aggregates committed database snapshots; it does not issue a hidden live Kubernetes API query.
2. **Inspect snapshot evidence.** Read the visible source, collection timestamp, active scope, coverage, and stale/missing exceptions from the snapshot context. Record only sanitized or conceptual values in review notes.
3. **Compare the intended generation.** The staging implementation uses `ClusterInventory.collected_at` as the committed-generation marker. Tables, summaries, dependent filters, details, and topology are expected to read the current committed generation, rather than mix rows from an in-progress replacement.
4. **Separate job state from data state.** A synchronization request may be queued or reuse an active job. An HTTP 202 or “in progress” notification is **not** a completed inventory generation. If an authorized operator has already initiated a refresh, wait for independently observed completion and a committed generation before interpreting the updated inventory.
5. **Check for exceptions.** If the source is unavailable, no snapshot exists, the observation is stale, or some scope is missing, report that limitation explicitly. An empty filtered table is not evidence of source-wide absence.
6. **Record a bounded conclusion.** State the inspected cluster/scope, committed observation time when present, any freshness/coverage limitation, and whether a refresh was merely requested or a new committed generation was actually observed.

### Expected result

The reader can distinguish a **requested**, **in-progress**, **failed**, or **committed** observation without treating those explanatory categories as an asserted exhaustive runtime enum. The evidence supports a claim only about the specific committed generation and filters inspected.

## If the evidence does not advance

The synchronization source writes the generation atomically and rolls back on exceptions. A failed or queued attempt should not be described as a new committed snapshot. The old snapshot may remain readable, but its age and coverage must be evaluated independently. A missing cluster, denied permission, or unavailable collector is not a reason to recommend privileged retries or infrastructure changes in a public how-to.

Escalate through the environment's approved support channel with sanitized scope, the observed timestamp or absence, and the distinction between job state and committed state. Do not include raw Kubernetes credentials, API responses, internal endpoints, or operational logs.

## Source and acceptance boundary

- **Owner:** Docs #6; this is a task-focused how-to, separate from the progressive learning tutorial.
- **Source-reviewed:** `app/kubernetes/inventory/routes.py` (`inventory.view` GET routes; `clusters.sync` POST), `app/kubernetes/inventory/README.md` (generation-scoped reads), and `app/kubernetes/inventory/synchronization.py` (atomic commit and rollback), pinned to `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`.
- **Not verified:** a live refresh, a specific job state, browser route/copy, exact UI click sequence, source coverage, user-role UAT, or a supported stable application version.
- **Publication gate:** accepted application manifest and Docs #15 mapping; exact browser steps and permissions; responsive/a11y checks; source-owner review; Full Admission and human acceptance.

This page stays `draft: true` and out of public routes, sidebar, and search.
