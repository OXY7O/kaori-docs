# KAORI staging implementation → Docs content coverage register

**Editorial owner:** Docs #36. **Application source pinned:** `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91` (branch `kaori/staging`, observed 2026-11-03). **Docs scope:** source-reviewed draft planning, not public release readiness.

**Release qualification:** the KAORI Application has no verified first stable `v0.3.0` release manifest at this checkpoint. Docs artifact `v0.3.0-rc.7` is independently signed, but proves only the Docs image identity. **Implemented source paths** below mean a route/contract exists in the inspected staging repository, *not* observed live UAT, accessible permission for every account, complete data coverage, or accepted product GA status. This register is internal (`docs/`) and excluded from the static website and search.

## Source-reviewed coverage matrix

| Capability / scoped workflow    | Source-reviewed entry / permission                                                                    | KAORI staging authority                                               | Docs issue | Source state             | Acceptance gap                                                  |
| ------------------------------- | ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ---------- | ------------------------ | --------------------------------------------------------------- |
| Integrations — provider catalog | Integrations Overview; provider inventory/counts                                                      | app/integrations/README.md; docs/modules/integrations/UI_REFERENCE.md | #5         | Implemented source paths | Per-provider instance UI/UAT, screenshot sanitization           |
| Registry — inventory & security | /artifact-registry/inventory/{projects,repositories,artifacts}; artifact_registry.view                | app/artifact_registry/routes.py                                       | #4, #5     | Implemented source paths | Source availability; exact collection scope; browser UAT        |
| Registry → Runtime evidence     | /artifact-registry/runtime/overview; artifact_registry.view                                           | app/artifact_registry/routes.py                                       | #4         | Implemented source paths | Binding identity and freshness; UAT                             |
| Security Posture — findings     | /security/ and /security/findings; security_posture.view; source reads require artifact_registry.view | app/security_posture/README.md                                        | #4, #8     | Implemented review slice | Role-scoped source visibility, UAT; global coverage not claimed |
| Kubernetes — inventory          | Committed generation; filtered resource list and topology                                             | app/kubernetes/inventory/README.md                                    | #4, #6, #8 | Implemented source paths | Verified user navigation, granted cluster and UAT               |
| Kubernetes — dashboard          | /dashboards/kubernetes; dashboard.view; committed projections                                         | app/dashboards/README.md                                              | #4, #6     | Implemented source paths | Cluster-specific data and time scope; UAT                       |
| Access — roles and permissions  | /access/roles/ and /access/permissions/; roles.view / roles.manage                                    | app/access/README.md; docs/rbac/README.md                             | #7         | Implemented source paths | Protected-role and custom-role safety review, UAT               |
| Access — identity / audit       | /access/; /access/activity-audit/; permission-scoped                                                  | app/access/README.md                                                  | #7         | Implemented source paths | Identity provider maturity and audit coverage, UAT              |
| Settings — personal workspace   | /settings/general; time/region/system-info and compatibility                                          | app/settings/README.md                                                | #7         | Implemented source paths | Session, permission, and safe release identity verification     |
| Reports — export lifecycle      | Generated reports, templates, schedules, artifact storage                                             | app/reports/README.md                                                 | #4, #6     | Implemented source paths | Report formats, worker readiness, scope, scheduled UAT          |
| Platform Operations — control   | Overview, Jobs & Executions, Data Lifecycle, Kubernetes Administration                                | app/platform_operations/README.md                                     | #6, #7     | Implemented source paths | Mutation and permission review; source-owned workflow UAT       |
| Source Control — GitHub         | Taxonomy/foundation only, no available provider assertion                                             | app/source_control/README.md                                          | #5         | Planned / unadmitted     | SC-01–03 acceptance and provider readiness before public claim  |

**Source fingerprint:** The table's relative paths resolve under `https://github.com/OXY7O/KAORI/tree/7272c81e495ef8e4d590355f1d1e6c4dd785eb91/`. Where a source is a Markdown README, the authoritative code, route decorators and committed evidence contract still require final release review. This register intentionally contains no environment identifiers, private hosts, token examples or production screenshots.

## Documentation workstream ownership

- **Docs #2 — Introduction:** native article shell and capability-first overview are staged but remain `draft: true`; publish after accepted product applicability and browser UAT.
- **Docs #3 — Core Concepts:** five concept articles cover capability/provider/instance, provider authority, committed evidence, correlation and governed workflow. Add staging-source examples while preserving conceptual and draft boundaries.
- **Docs #4 — Product Guides:** Registry overview / user task pattern grounded in `app/artifact_registry/routes.py` and the domain-owned evidence model.
- **Docs #5 — Integrations:** capability-first provider catalog and Harbor Registry guide. Never claim every defined provider, source or connector is configured/ready.
- **Docs #6 — Tutorials/How-to:** Kubernetes inventory snapshot walkthrough and read-only evidence refresh verification; exact clickable steps remain pending browser UAT.
- **Docs #7 — Administration/Security:** Access Roles & Permissions and Settings boundaries; custom-role mutation requires role management privileges and explicit request authorization.
- **Docs #8 — Troubleshooting:** stale/partial inventory evidence, worker/collection availability and safe escalation. Never equate no findings with healthy state.
- **Docs #9 — Releases/Compatibility:** exact App patch notes and compatibility matrix cannot be published without accepted stable App manifests.
- **Docs #15/#16 — Versioning/Search:** native version map is currently empty; public guide navigation and search must not index these draft articles.

## Evidence classification used by every article

| State | Meaning |
| ----- | ------- |
| Source-reviewed | The implementation contract and route have been read at the pinned staging commit. This is **not** executed UAT. |
| Draft | English product article written under its own Docs issue, unpublished via `draft: true`. |
| Browser UAT pending | Exact source, permission, navigation, light/dark, narrow/zoom, keyboard and safe screenshots still require observed tests. |
| Release qualification pending | Accepted App stable tag, SHA, immutable image/manifest, documented product applicability and Docs snapshot approval are missing. |
| Published | **Not assigned** to any application-versioned guide in this register. |

## Article acceptance handoff

For each issue-owned guide, record the actual page and navigation shown in KAORI staging, permission/access profile, prerequisite integration/asset, observable committed evidence and its freshness/partial state, failure feedback, sanitized screenshots, exact Application PR/SHA and the human acceptance URL. Then review that article under its owning issue; do not convert this coordination register into a second article implementation authority.

For user-visible instructions, prefer a read-only verification path. A collector refresh or a lifecycle/role operation is state-changing and must reference the existing permission, CSRF, worker and audit contract before any public how-to suggests it. For a troubleshooting result, distinguish source unavailable from known-empty, stale from fresh, and requested/queued from completed.

## First-publication and release gates

- [ ] Verify a **stable KAORI Application** release tag and signed immutable source/digest/manifest at the documented authority; do not use `VERSION`, a candidate tag, or source README alone.
- [ ] Review each guide against the precise accepted feature surface, roles and UAT scenario. Confirm screenshots have no sensitive data and no invented source health.
- [ ] Freeze accepted native Docusaurus version snapshot under Docs #15; approve the release mapping with authenticated source and Docs revision; exclude `current` drafts.
- [ ] Complete Docs #9 patch notes and Docs #16 published-line-only search where applicable.
- [ ] Execute exact-head Developer Check, staging Full Admission, Browser Quality, signed Docs RC/digest verification, public edge/runtime checks, explicit human visual/rollback acceptance and governed stable promotion. CI PASS is not substitute for this approval.

**Blockers:** App stable release KAORI #4198 blocks final product mapping/publication; accepted article/screenshot evidence remains under Docs #2–#8. Source implementations can be documented in parallel as drafts.
