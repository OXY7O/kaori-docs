---
id: object-storage-inventory-and-analytics
title: Object Storage Inventory and Analytics
description: Review committed object storage inventory, metrics-source analytics, incomplete evidence, and permission-scoped read-only workflows.
draft: true
sidebar_position: 3
---

> **Editorial status:** Unpublished, source-reviewed operator draft for
> Docs #139. Navigation labels and data contracts come from KAORI
> Application staging source; the workflow has **not** been verified in
> a live role-scoped browser UAT or mapped to an accepted stable release.

## Purpose and scope

**Object Storage** is a provider-neutral KAORI infrastructure
capability. It brings together committed records of managed systems
and buckets/containers with separately collected operational
analytics. MinIO is an existing provider implementation, **not**
the definition of Object Storage or a guarantee that MinIO (or any
other provider) is connected in your environment.

The external provider is authoritative for its own buckets,
configuration and operations. KAORI normalizes and commits
source-qualified observations, then presents authorized views and
time-windowed analytics. A browser page displaying an old snapshot
does not mean it has queried the provider just now.

This guide covers **read-only** navigation, inspection and
interpretation, not provider changes, bucket deletion, credential
management or forced inventory reconciliation.

## Audience and prerequisites

The canonical catalog declares three primary Object Storage
capabilities with separate permissions:

- **Overview:** `dashboard.view`, for the read-only operational
  dashboard.
- **Inventory:** `object_storage_inventory.view`, for the
  normalized inventory.
- **Analytics:** `object_storage_analytics.view`, for
  committed time-series-derived operational analysis.

These are navigation permission indicators, not a complete
description of route, tenant, instance or resource-scope policy.
Your account must also be authorized for the selected systems and
the appropriate integration must have been registered, validated
and collected. No such connection is presumed by this article.

## Product navigation

**Object Storage → Inventory** contains:

- **Overview** — source-qualified fleet posture, registered
  systems, collection coverage and inventory context.
- **Systems** — committed managed-system identity and provider
  information, with scoped record details.
- **Buckets & Containers** — recorded bucket/container identity,
  ownership, available quota and protection metadata.

**Object Storage → Analytics** contains:

- **Overview**
- **Capacity & Usage**
- **Performance**
- **Forecast**
- **Top Consumers**
- **Alerts & Anomalies**

These labels describe source-declared views. Which ones a given
person can use depends on authorization, configured provider
capabilities and accepted application maturity. A missing time
series or optional alert source must not be fabricated.

## Workflow 1: inspect recorded systems and buckets

1. Sign in with the applicable Inventory permission and open
   **Object Storage → Inventory**.
2. In **Overview**, review the registered-system coverage,
   selected scope and snapshot context. An unobserved system
   must remain unknown even if other systems are healthy.
3. Open **Systems**. Use the supported system/provider or search
   controls to narrow the visible list. Inspect the system's
   source identity, reported provider information, and
   observation status.
4. Open **Buckets & Containers**. Apply **System**, **Provider**,
   **Type**, **Environment** or **Search** filters as relevant.
   The Environment filter reflects **committed system metadata**,
   not a live provider look-up.
5. Review the visible rows and inspect permitted details.
   The canonical inventory list defaults to **5 rows per page**
   and supports 5/10/25/50 page sizes. Changing a filter should
   keep both summary context and row data aligned; pagination
   should not trigger a full provider collection.
6. Check reported usage, quota, encryption, immutability,
   versioning and exposure **only where assessed evidence
   exists**. A missing protection value must not be displayed
   or interpreted as compliance or non-exposure.

**Expected result:** a scoped view of what KAORI actually
collected, including coverage and the last known evidence
state. This read path does not mutate provider objects.

### Interpreting an empty bucket table

The source contract distinguishes several materially different
situations:

- **Collection Pending:** no successful observation is yet
  available for the selected scope.
- **Partial Inventory:** some systems have observed results,
  while others remain unobserved.
- **Observed Empty:** all relevant systems completed the
  collection successfully and no buckets were observed.
- **No Matches:** records exist, but the current filters
  return no visible rows.

These states are not interchangeable. In particular,
a previous nonempty collection followed by an unexpected
zero-result provider response must not silently erase
last-good assets. The owning synchronization workflow has
special safeguards for that scenario.

Do not invoke a force-empty reconciliation or destructive
provider operation as a solution to a confusing empty table.
Such actions have separate **`jobs.execute` and
`storage.sync`** authorities and require validated provider
evidence; they are outside this read-only guide.

## Workflow 2: review analytics and data readiness

1. Open **Object Storage → Analytics** with authorized access
   to the target system.
2. Use the domain-owned **System**, **Time Range**, **Forecast
   History Window** and, for alerts, **Alert Source** controls
   only where shown by the selected view.
3. Review **Metrics Source Status**. This is the committed
   **metrics contract at collection** and identifies source,
   selected provider instance and available inventory context.
   It is **not** an active network check from the browser.
4. Review **Latest Analytics Data Snapshot** for the
   `generated_at` observation, `expires_at` or Refresh Due,
   and `last_attempt_at` worker attempt. Stale, missing and
   failed worker data must remain explicit.
5. Move through **Capacity & Usage**, **Performance**, **Forecast**
   and **Top Consumers** to investigate available committed
   metrics snapshots. Forecast is model output—not a guarantee
   of future consumption.
6. For **Alerts & Anomalies**, inspect the committed selected
   alert source. An eligible Alertmanager consumer binding is
   preferred where available; the owning adapter may use
   metrics-derived alert state as a fallback. The UI must show
   which source actually supplied evidence and whether it
   was unavailable or stale.

**Expected result:** an interpretation of source-qualified,
time-bounded data and its readiness/age. Analytics does not
read MinIO credentials, create provider clients or issue
a new Metrics Source request merely because someone opens
a page.

The **Applying Filter** indicator tracks a UI filter refresh;
it is not equivalent to Job Execution progress or a
successful new collection. Worker states are independently
recorded under the appropriate job/evidence contract.

## How to handle incomplete or surprising results

- **System missing:** check your resource scope, selected filters
  and registered integration/binding rather than assuming
  the provider contains no systems.
- **Bucket list empty:** distinguish Collection Pending, Partial
  Inventory, Observed Empty and No Matches. Preserve last-good
  committed data until authoritative evidence explains a change.
- **Protection posture appears clean:** verify assessed coverage.
  Missing encryption/immutability/versioning or exposure evidence
  cannot be counted as compliant.
- **Analytics missing:** check selected Metrics Source,
  source/consumer binding, snapshot expiration and worker
  outcome. Inventory records do not prove time-series coverage.
- **Alerts missing:** distinguish Alertmanager unavailable,
  metrics-derived fallback, no assessed data and a genuine
  observed absence of alerts.
- **Access denied:** verify role and system scope with an
  authorized administrator; do not use a broader credential
  or hidden URL to bypass permission checks.

For escalation, capture only sanitized information: selected
domain and filters, source category/provider, collection time,
job state, visible status and exact reproduction steps.
Avoid leaking object names, endpoints, credentials or
internal system identifiers.

## Source and release applicability

Reviewed Application source:
`app/common/workspace_navigation_catalog.py`,
`app/storage/object_storage/inventory/README.md`,
`app/storage/object_storage/analytics/README.md` and
domain-owned navigation/route contracts at
`kaori/staging@197a7f7e598c111592a8ae36388865cd3aacf541`.

Still required before candidate publication: real browser evidence
for the authorized workspace, every named tab, source/permissions,
normal and incomplete inventory, applied filters, metrics
readiness, alert-source fallback, visual accessibility and
a signed accepted KAORI Application prerelease. This article
remains `draft: true` and has **no stable version claim**.
