# Product Guides editorial patterns — Docs #4

**Status:** Internal editorial standard, source-reviewed draft; not part of the public Docusaurus corpus. **Owner:** Docs #4. **Depends on:** accepted native article shell (#2), publication/version authority (#15), and actual accepted KAORI Application release evidence. This does not create a new component library, navigation system, or release engine.

## Domain Overview pattern

A domain overview helps a reader understand the capability and interpret its evidence, without implying that every provider or workflow is available.

1. **Purpose and audience:** define the operator's question and domain boundary.
2. **Source authority:** name the external source class, KAORI normalization boundary, and committed evidence contract.
3. **Conceptual flow:** text-accessible source → collection → committed state → scoped operational context; mark as conceptual, never live telemetry.
4. **Source-reviewed surfaces:** list only inspected application routes/permissions and qualify these as source implementation, not release/UAT.
5. **Evidence interpretation:** identify source, scope, observation time, freshness, partial/unavailable states, and relationship strength.
6. **Limitations:** separate available from planned capabilities and visibility from mutation.
7. **Publication metadata:** owning issue, pinned application SHA, accepted application release manifest (when verified), Docs revision, reviewer, sanitized screenshots, and browser/UAT evidence.
8. **Navigation:** use native Docusaurus sidebar, TOC, breadcrumbs, previous/next; link only to published, release-qualified articles.

**Current example:** `content/product-guides/registry-overview.md` (unpublished `draft: true`).

## Feature Guide pattern

A feature guide describes a **specific, release-confirmed** task. Do not fill in UI click paths from route names or mockups alone.

1. **Goal and applicability:** exact supported application release line, capability maturity, and expected result.
2. **Prerequisites:** configured source, source scope, account permissions, and relevant evidence availability.
3. **Read-only or mutation boundary:** identify whether any step changes KAORI/provider state; separate `view` from `sync` or other write permissions.
4. **Verified procedure:** numbered, accessible, real browser-UAT steps with accepted screenshots; never infer controls or status labels.
5. **Expected committed evidence:** record the observed result, collection generation/timestamp, scope, freshness, and relationship confidence.
6. **Failure and partial states:** distinguish missing data, stale evidence, denied access, provider unavailability, queued work, and completed work without inventing an enum.
7. **Recovery and escalation:** offer safe read-only checks first; include privileged actions only with separate reviewed authorization and rollback contract.
8. **Evidence ledger:** application issue/commit, manifest/digest, test account role, UAT scenario/result, screenshot sanitation, Docs source SHA, and human acceptance.

## Registry-specific source review

Inspected at `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`:

- `app/artifact_registry/routes.py`: `/artifact-registry/inventory`, `/inventory/projects`, `/inventory/repositories`, `/inventory/artifacts`, `/runtime/overview`, `/runtime`, and `/security` are GET routes guarded by `artifact_registry.view`. Source filters and read-model outputs are not proof of connected instances.
- `app/artifact_registry/routes.py`: `POST /artifact-registry/security/sync` requires `artifact_registry.sync` and dispatches a background job; queued/accepted is not completed or scanned. No write procedure belongs in the Registry Overview.
- `app/security_posture/README.md`: cross-domain findings are source- and role-qualified, with immutable digest versus mutable-reference binding distinctions and last-good/stale evidence handling.
- `docs/product/README.md`: capability-first positioning, provider authority, honest partial/unknown state, and visibility-before-mutation remain the global wording contract.

**Not yet established:** exact first stable KAORI App release identity, browser-tested navigation and UI copy, source readiness, accepted user-role/UAT results, safe public screenshots, and final article version mapping. Keep the public plugin and search index isolated from drafts.

## Acceptance checklist

- [x] Two bounded editorial patterns defined without a duplicate design system.
- [x] First Registry Overview draft grounded in pinned staging routes and domain authority.
- [ ] Verify exact application release, UI behavior, permissions, and screenshots with real UAT.
- [ ] Validate native sidebar, links, six widths, two themes, 200% zoom, keyboard, and accessibility on accepted versioned pages.
- [ ] Obtain reviewed staging merge, Full Admission, human acceptance, signed release and deployment approval.

This file is an editorial planning artifact. A green Developer Check or a source-reviewed route is **not** publication authority.
