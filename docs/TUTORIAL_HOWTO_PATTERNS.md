# Tutorials and How-to editorial patterns — Docs #6

**Status:** Internal source-reviewed editorial draft; not public Docusaurus content. **Owner:** Docs #6. **Publication dependencies:** native article shell #2, release/version mapping #15, accepted KAORI Application release, and role-scoped browser UAT.

## Tutorial — progressive learning

Use a tutorial when the reader needs to **learn a mental model** while exploring safe, pre-existing evidence.

1. State the learning outcome and approved demonstration scope.
2. Identify prerequisites and read-only permissions.
3. Provide an accessible, clearly conceptual source-to-evidence flow.
4. Guide the reader through small observations; avoid guessing UI labels before browser UAT.
5. Add a learning checkpoint: source, scope, generation, and uncertainty.
6. Explain unavailable, empty, stale, and permission-denied outcomes without inventing live data.
7. Record the source SHA, owner, release applicability, browser evidence, and acceptance status.

**Current unpublished example:** `content/tutorials/explore-first-inventory-snapshot.md`.

## How-to — goal-oriented verification

Use a how-to when the reader already knows the domain and needs to **verify a specific outcome**.

1. State a measurable read-only goal, prerequisites, and permission.
2. Separate collection **request/queue** from **committed generation** and current source truth.
3. Use only source-reviewed contracts; add exact UI click paths only after observed release-specific UAT.
4. Specify what to inspect: source, cluster/scope, generation time, freshness, and missing/partial exceptions.
5. Describe expected evidence, bounded conclusion, and safe escalation.
6. Do not include state-changing retries, provider administration, secret disclosure, or privileged access instructions without separate authority.
7. Record source/Docs revision, exact App release manifest, test role, sanitized screenshots, and human acceptance.

**Current unpublished example:** `content/how-to/verify-inventory-refresh-evidence.md`.

## Inspected application implementation

Pinned `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`:

- `app/kubernetes/inventory/routes.py`: `GET /inventory/`, resource views, and topology require `inventory.view`; `POST /inventory/<cluster_id>/sync` requires `clusters.sync` and queues a job. The blueprint's mounting context and final browser URL require verification; route paths here are code-level, not promised public links.
- `app/kubernetes/inventory/README.md`: `ClusterInventory.collected_at` identifies the committed generation; summary, filters, table, detail, and topology read that generation. All-cluster views are database-backed snapshots, not live Kubernetes queries.
- `app/kubernetes/inventory/synchronization.py`: synchronization commits an inventory generation atomically and rolls back on exceptions. Request accepted/queued is not committed evidence.
- `docs/product/README.md`: capability-first language, source authority, honest stale/partial/unknown states, and visibility-before-mutation.

## Evidence and publication checklist

- [x] Two separate editorial patterns, without custom navigation, components, or a second tutorial application.
- [x] Two substantive English `draft: true` articles grounded in inspected staging contracts.
- [x] Explicit source-reviewed vs UAT vs accepted release distinctions and read-only boundaries.
- [ ] Exact accepted KAORI Application release manifest, tag/SHA/digest, and Docs #15 mapping.
- [ ] Permissioned browser UAT of the real labels, navigation, empty/error states, and user task.
- [ ] Six viewport widths (360/390/768/1024/1280/1440), light/dark, keyboard, 200% zoom, focus, and accessibility.
- [ ] Reviewed staging merge, Full Admission, source owner and human acceptance, signed Docs RC and deployment evidence.

These drafts must remain outside public Docusaurus routes and local search. Developer Check PASS alone cannot authorize publication.
