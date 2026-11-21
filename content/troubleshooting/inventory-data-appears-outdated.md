---
id: inventory-data-appears-outdated
title: Inventory Data Appears Outdated
description: Check a Kubernetes inventory snapshot's age, collection coverage, and source scope without triggering a refresh.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished, read-only troubleshooting draft for Docs #8. KAORI Application staging source reviewed at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. Exact UI text and release applicability still require browser and source-owner acceptance.

## Symptom

A Kubernetes inventory view appears older than the external cluster state, or expected resources are missing from a filtered list. The observation alone does **not** prove a collector failure, a live cluster outage, or an empty source.

## Check the committed snapshot

1. **Confirm access and scope.** The inspected Kubernetes Inventory GET routes require `inventory.view`. Verify the intended cluster, resource family and namespace/filter context. Do not use another account's identity or broaden access to bypass a denied view.
2. **Read the snapshot timestamp.** The staging source uses `ClusterInventory.collected_at` as the committed generation marker. The overview source currently treats a snapshot older than **24 hours** as stale; this is a **source-reviewed staging threshold**, not a promised stable-release policy.
3. **Inspect coverage and exceptions.** The overview checks per-resource-family collection evidence. A timestamp by itself does not establish complete collection; unreported or non-collected family evidence can produce an incomplete-coverage signal.
4. **Separate connection state.** The source distinguishes connected, failed and not-observed connection evidence. A previous snapshot can exist even when current connection readiness is uncertain.
5. **Distinguish queued from committed.** A synchronization POST is separately guarded by `clusters.sync` and can enqueue or reuse a background job. A queued response does not establish that the committed generation advanced. The collection implementation commits atomically and rolls back on failure.
6. **Recheck read-only filters.** A filtered zero-row result describes only the selected committed generation and filters; it cannot prove that the live provider has zero matching resources.

## Possible explanations

- The last committed snapshot predates the observation you expect.
- The source connection is failed, not observed, or otherwise unavailable.
- Collection coverage for a resource family is missing or incomplete.
- The selected cluster/namespace/resource filters exclude the expected record.
- A refresh request is still queued, in progress, or failed; no newer generation has been committed.
- The account lacks the permission needed to view the intended workspace.

Do not diagnose a specific root cause without corresponding evidence.

## Safe next action and verification

Document the inspected source/cluster scope, observation timestamp (or its absence), resource-family coverage, connection evidence, and any job-versus-commit distinction. If no newer committed generation is visible, report **“newer inventory not verified”** rather than declaring a successful refresh. Ask the authorized environment owner to investigate collection readiness or schedule a governed refresh; this public-facing draft does **not** instruct the reader to run synchronization or modify the cluster.

After an authorized operator completes a separately governed collection, verify the new committed timestamp and resource-family coverage from read-only views. Do not treat a success toast, an empty list, or a single healthy label as proof of global completeness.

## Escalation boundaries

Share only sanitized symptoms, source scope and timestamp evidence through the approved support channel. Do not include internal URLs, real infrastructure identifiers, credentials, raw provider payloads, or private incident logs. Do not assume permission to change provider connections or rerun jobs.

## Source and acceptance status

- **Owner:** Docs #8.
- **Reviewed source:** `app/kubernetes/inventory/overview.py` (freshness and coverage checks), `README.md` (committed generation), `routes.py` (read versus sync permissions), and `synchronization.py` (atomic commit/rollback), pinned to `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`.
- **Source-reviewed, not UAT:** current staging 24-hour threshold, snapshot marker, collection exceptions, read and sync guard distinction.
- **Pending:** accepted App release manifest, exact status labels and browser behavior, permissioned UAT, Docs #15 mapping, responsive/a11y evidence, security-owner review, Full Admission, and human acceptance.

Keep `draft: true`; do not publish an Evidence States Reference or add a public link until exact released semantics are verified.
