# KAORI staging implementation → Docs content coverage register

**Editorial owner:** Docs #36. **Application source pinned:** `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91` (branch `kaori/staging`, observed 2026-11-03). **Docs scope:** source-reviewed draft planning, not public release readiness.

**Release qualification:** the KAORI Application has no verified first stable `v0.3.0` release manifest at this checkpoint. Docs artifact `v0.3.0-rc.7` is independently signed, but proves only the Docs image identity. **Implemented source paths** below mean a route/contract exists in the inspected staging repository, _not_ observed live UAT, accessible permission for every account, complete data coverage, or accepted product GA status. This register is internal (`docs/`) and excluded from the static website and search.

## Current RC content checkpoint — 2026-11-22

This checkpoint **updates the current work status** without rewriting the dated
2026-11-03 source review or treating the older SHA as current Application
authority. The matrix below is a historical source-reviewed scope snapshot;
its route and permission claims must be reconciled against the **accepted**
Application source and actual browser UAT before any product guide is enabled.

### Verified repository and release observations

- **Application source head observed:** `OXY7O/KAORI` `kaori/staging@197a7f7e598c111592a8ae36388865cd3aacf541`. This is a branch-head observation, **not** a fresh domain-by-domain capability audit or a production release.
- **Docs source head observed before this change:** `OXY7O/kaori-docs` `kaori/staging@269c12b6d747a9888d43a31a15446cdc2b3c5ed8`.
- **Independent prerelease records:** GitHub Releases lists KAORI Application `v0.3.0-rc.3` (2026-11-22) and KAORI Docs `v0.3.0-rc.9` (2026-11-21). The check did not independently attest their signatures, immutable runtime digests, deployed state or Human Acceptance. No `v0.3.0` stable GitHub Release appeared in the inspected Application releases.
- **Published documentation:** `docs/PUBLISHED_VERSIONS.json` still declares `publication_state: awaiting-release` and an empty `published` list; `versioned_docs/` contains only `.gitkeep`. There is **no approved published Application version line** or stable guide route to expose.
- **Source promotion is not release:** Docs [promotion PR #95](https://github.com/OXY7O/kaori-docs/pull/95) already merged source to `main`; this does not publish accepted product guides, request a host deployment or establish a Docs stable artifact.
- **Rights/deployment gate:** Docs [#74](https://github.com/OXY7O/kaori-docs/issues/74) is still open. The standing publication guard described in [DELIVERY.md](DELIVERY.md) therefore remains a separate blocker for any opt-in automatic RC publication. Do not enable auto-publication or public-edge mutation through this content workstream.

### Existing editorial inventory (source checked on staging)

All **15** existing product articles below retain `draft: true` and are intentionally excluded from public versioned navigation and search:

- **#2 — Getting Started (1):** `content/getting-started/introduction.md`.
- **#3 — Core Concepts (5):** capability/provider/instance model, external authority, committed evidence, cross-domain correlation and governed workflows.
- **#4 — Product Guides (1):** Registry overview.
- **#5 — Integrations (2):** integration catalog and Harbor Registry provider guide.
- **#6 — Tutorials and How-to (2):** first inventory snapshot and refresh-evidence verification.
- **#7 — Administration and Security (2):** overview and roles/permissions.
- **#8 — Troubleshooting (2):** overview and outdated inventory evidence.

This counts **review drafts**, not fifteen verified or release-qualified guides.
Do not infer feature readiness from an article's existence. Source control,
security, operational mutation, compatibility and release-note behavior must
follow the current authoritative KAORI contracts, not the November 3 content
matrix.

### Corrected provenance and next editorial acceptance

The older handoff table below lists PR #53 and #66–#71 as pending integration,
which was accurate **when that handoff was written**. GitHub now confirms
[#53](https://github.com/OXY7O/kaori-docs/pull/53),
[#66](https://github.com/OXY7O/kaori-docs/pull/66),
[#67](https://github.com/OXY7O/kaori-docs/pull/67) through
[#71](https://github.com/OXY7O/kaori-docs/pull/71) **merged to
`kaori/staging` on 2026-11-04**. They are not outstanding open PRs. Historical
Developer Check links in that table remain tied to their old exact heads,
not proof of current release qualification.

1. **Revalidate product wording:** use the current
   [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/kaori/staging/docs/product/README.md)
   and domain-owned documentation against an accepted Application RC/UAT
   source. Confirm capability maturity, per-domain permissions, committed
   evidence, freshness/partial scope and provider-vs-KAORI execution boundary.
   New source head alone is not evidence of working UI.
2. **Review issue-owned articles:** #2–#8 retain separate implementation
   authority. Confirm actual UI steps, roles, expected outcome, unknown and
   failure states, safe conceptual illustrations, accessibility, and release
   applicability. Record accepted issue/PR/SHA and sanitized browser evidence
   before changing any `draft: true`.
3. **Keep version gates separate:** #15 owns native `/v0.3/` mapping; #9
   owns exact `/releases/v0.3.0/` notes; #16 owns published-version-only local
   search. A Docs `v0.3.0-rc.N` artifact is **not** evidence that the
   Application `v0.3.0` is stable.
4. **Review an RC safely:** use the existing local editorial preview and
   governed Docs release/admission flow. Any signed RC publication, single-slot
   deployment, shared-edge change and real browser/Human UAT require their
   own existing approvals and receipts. A content-only staging merge must
   **not** trigger publication or deployment.
5. **Stable HOLD:** only after accepted KAORI Application `v0.3.0` release
   identity, reviewed content/version map, signed Docs artifact, actual
   accessibility/browser UAT, Human Acceptance and separately approved
   Docs stable promotion may public product guides be described as stable.

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

## Editorial engineering handoff (2026-11-03)

This is a **source-reviewed editorial snapshot**, not a release or UAT acceptance ledger. The KAORI Application `kaori/staging` head was rechecked at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`; the Docs `kaori/staging` head was `e94725f276fccdf7cd197857c54c146564905c2a` when this handoff was recorded. Issue-owned drafts remain separate branches; none of the PRs below has been merged into Docs staging.

| Docs issue | Editorial deliverable                            | PR / exact head                                                              | Developer Check                                                                                   | Remaining acceptance                                       |
| ---------- | ------------------------------------------------ | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| #3         | Five Core Concepts drafts                        | [#53](https://github.com/OXY7O/kaori-docs/pull/53) `835cbfe`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41649453960)                              | Independent content review; staging admission; release/UAT |
| #36        | This internal coverage register                  | [#66](https://github.com/OXY7O/kaori-docs/pull/66) `260e09d` (previous head) | [PASS, route-only](https://github.com/OXY7O/kaori-docs/actions/runs/41649342174) on previous head | Recheck this updated head; staging admission; release/UAT  |
| #4         | Registry overview and guide patterns             | [#67](https://github.com/OXY7O/kaori-docs/pull/67) `b5a8b43`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41649485660)                              | Review; staging admission; release/UAT                     |
| #5         | Integration catalog and Harbor guide             | [#68](https://github.com/OXY7O/kaori-docs/pull/68) `8ab3be2`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41659821969)                              | Review; staging admission; release/UAT                     |
| #6         | Inventory tutorial and refresh-evidence how-to   | [#69](https://github.com/OXY7O/kaori-docs/pull/69) `e84f5f3`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41669225465)                              | Review; staging admission; release/UAT                     |
| #7         | Access administration and RBAC drafts            | [#70](https://github.com/OXY7O/kaori-docs/pull/70) `c0051fd`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41669488000)                              | Security-owner review; staging admission; release/UAT      |
| #8         | Inventory troubleshooting and reference patterns | [#71](https://github.com/OXY7O/kaori-docs/pull/71) `f7dad5d`                 | [PASS](https://github.com/OXY7O/kaori-docs/actions/runs/41669878015)                              | Review; staging admission; release/UAT                     |

All PASS entries refer to **exact PR heads at the time checked**, not merged-SHA Full Admission. The #66 entry is explicitly historical because this register update changes its head; never reuse its previous PASS for the new commit. `#2` Introduction already exists as a draft on Docs staging, so this coordination issue must **not** duplicate its article or create another Introduction PR. Docs #1/#2/#15 and the accepted KAORI Application release remain publication dependencies. The next safe batch is editorial/security review and coordinated staging integration, followed by a single Full Admission on the final merged SHA; this table is not permission to bypass required per-PR checks.

## Evidence classification used by every article

| State                         | Meaning                                                                                                                          |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Source-reviewed               | The implementation contract and route have been read at the pinned staging commit. This is **not** executed UAT.                 |
| Draft                         | English product article written under its own Docs issue, unpublished via `draft: true`.                                         |
| Browser UAT pending           | Exact source, permission, navigation, light/dark, narrow/zoom, keyboard and safe screenshots still require observed tests.       |
| Release qualification pending | Accepted App stable tag, SHA, immutable image/manifest, documented product applicability and Docs snapshot approval are missing. |
| Published                     | **Not assigned** to any application-versioned guide in this register.                                                            |

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
