# Troubleshooting and Reference editorial patterns — Docs #8

**Status:** Internal editorial draft, source-reviewed against staging; not public content. **Owner:** Docs #8. **Publication dependencies:** Docs #2, Docs #15, accepted KAORI Application release and source/role-specific UAT.

## Troubleshooting pattern

Use **symptom → authorized scope → committed evidence → possible causes → safe read-only action → verification → escalation**.

- Begin with the reader's observation; do not invent a root cause or prescribe a privileged retry.
- Verify source/cluster, filters, account permission, collection timestamp, coverage and connection state.
- Separate queued/in-progress jobs from committed data and from current provider authority.
- Treat stale, unknown, missing, incomplete and empty filtered results as distinct evidentiary conditions.
- Require an actual committed-generation change before claiming refresh completion.
- Escalate with sanitized observations only; private production runbooks remain out of scope.

**Unpublished examples:** `content/troubleshooting/troubleshooting-overview.md` and `content/troubleshooting/inventory-data-appears-outdated.md`.

## Reference pattern — release-gated

A **Reference** page records exact public fields, labels, enum values, transitions, scope, and semantics **only when verified in an accepted KAORI Application release**. Do not copy labels from design mockups or infer a stable enum from explanatory prose. The proposed **Evidence States Reference** is deliberately **not created** as a publishable page until that contract is accepted.

Reference review must include the exact route/model/serializer, source authority, empty/error/partial behavior, permission boundary, accepted release manifest, test account/role, sanitized screenshots, Docs revision, and human acceptance.

## Source-review register

Pinned `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`:

- `app/kubernetes/inventory/overview.py`: current source threshold `INVENTORY_FRESHNESS_HOURS = 24`; connection not observed/failed, never collected, stale, incomplete resource-family evidence and scoped guidance.
- `app/kubernetes/inventory/README.md`: committed generation marker `ClusterInventory.collected_at` and generation-consistent lists, details and topology.
- `app/kubernetes/inventory/routes.py`: `inventory.view` GET and separately authorized `clusters.sync` POST; queued request is not committed result.
- `app/kubernetes/inventory/synchronization.py`: atomic commit/rollback of the inventory generation.
- `docs/product/README.md`: source authority, explicit stale/partial/unknown state and visibility-before-mutation.

## Publication checklist

- [x] Two bounded English troubleshooting drafts remain `draft: true` and read-only.
- [x] Separate Reference pattern, without prematurely publishing an exact Evidence States Reference.
- [x] Source-reviewed threshold and states explicitly distinguished from accepted stable-release contracts.
- [ ] Exact accepted App release and Docs #15 version mapping; source owner approves terminology.
- [ ] Permissioned browser UAT, real error/empty/freshness states, safe screenshots and public disclosure.
- [ ] Six widths (360/390/768/1024/1280/1440), light/dark, keyboard, 200% zoom and accessibility.
- [ ] Reviewed staging merge, Full Admission, human acceptance, signed Docs RC and deployment evidence.

No source-reviewed staging status should be presented as a universally supported stable-release API contract.
