# KAORI end-to-end software documentation coverage baseline

**Owner:** [Docs #127](https://github.com/OXY7O/kaori-docs/issues/127), coordinated by [Docs #36](https://github.com/OXY7O/kaori-docs/issues/36). **Checkpoint:** 2026-11-22. **Status:** source-reviewed planning inventory; **not a public release, feature acceptance, complete guide set, or UAT PASS**.

**Source baseline:** `OXY7O/KAORI` protected `kaori/staging@197a7f7e598c111592a8ae36388865cd3aacf541` observed on 2026-11-22. Actual product capability, routes, role visibility and configuration must be revalidated against the exact candidate selected for documentation review and browser UAT; this inventory is not stable-release evidence. Docs staging source prior to this audit included approved RC orientation [PR #126](https://github.com/OXY7O/kaori-docs/pull/126), but that conceptual page is not a substitute for the complete manual.

## Goal and release boundary

KAORI Docs should be a **professional, task-complete software manual**, suitable for a first-time user, operator, integrator, system administrator and technical reviewer. The intended first accepted stable publication remains aligned with KAORI Application `v0.3.0`, only after **both** application and documentation acceptance.

A **public signed Docs RC** is required for real browser/content UAT before stable; it must be possible to review more than a marketing-style Home page. However, today's [publication safety policy](CONTENT_SAFETY.md), [native version authority #15](https://github.com/OXY7O/kaori-docs/issues/15) and empty [publication map](PUBLISHED_VERSIONS.json) block release-qualified product guides before accepted application stable. [Docs #131](https://github.com/OXY7O/kaori-docs/issues/131) is the **separate change-authority gate** for a safe pre-stable, candidate-scoped full-content RC review path. Until admitted, **do not** activate unpublished `content/` drafts or serve them through `src/pages/` as a workaround. An RC artifact tag is not proof of application GA.

## Reader journeys and required documentation families

| Family | Expected user outcome | Content authority and workstream | Current acceptance |
| --- | --- | --- | --- |
| Documentation orientation | Understand KAORI, audience, navigation, first steps and terminology | #1, #2, #3 | Home / conceptual draft only; UAT pending |
| Architecture & design | Understand components, provider/source authority, evidence, workers, security and deployment boundaries | [#128](https://github.com/OXY7O/kaori-docs/issues/128), reuse #3 | Not documented as an accepted public chapter |
| Installation & prerequisites | Choose verified runtime mode and safely prepare required software/config | [#129](https://github.com/OXY7O/kaori-docs/issues/129), App `docs/RUNNING.md` | Public software installation manual missing |
| Initial configuration | Sign in, bootstrap only supported accounts, configure providers/instances and validate a source | #5, #7, #129 | Fragmentary drafts; release and role UAT pending |
| Product menu/reference | Find all permission-visible workspaces, submenus, UI actions and data limitations | [#130](https://github.com/OXY7O/kaori-docs/issues/130), #4–#7 | **12 top-level workspaces found; complete leaf-level guide absent** |
| Operational tutorials | Complete a task with prerequisites, numbered steps, expected outcome and safe validation | #6, #4–#7 | 2 example drafts only |
| Integrations | Understand capability→provider→instance, registration, validation, collection, health and limitations | #5, App integration contracts | Catalog/Harbor example drafts; provider-by-provider UAT pending |
| Identity, RBAC and security | Understand users, identity providers, policies, audit, sensitive action boundaries | #7, #128 | Two administration/security drafts only |
| Operations & maintenance | Read health/job state, backup, restore, migration, upgrade, rollback and safe recovery | #6, #7, #8, #129 | Not a reviewed public runbook |
| Troubleshooting & support | Diagnose stale, partial, unavailable, unauthorized and failing operations | #8 | Two inventory-troubleshooting drafts only |
| API/configuration/reference | Look up supported configuration knobs, permissions, errors, glossary, FAQ and compatibility | #7–#9, #129–#130 | Missing/partial; do not invent public API/support commitments |
| Release history | Identify accepted app patch, compatible docs line, upgrade notes, limitations and change history | #9, #15, #16 | No accepted stable application mapping or public search |

These are **required manual families**, not assertions of implementation/release readiness. Additional domain-specific documents are created only under small, source-owned child issues.

## Source-derived workspace and menu coverage baseline

**Authority:** Application `app/common/workspace_navigation_catalog.py` (`WORKSPACES`, `_CAPABILITY_VIEWS`) and `app/common/workspace_navigation.py` (permission-scoped navigation and active view behavior). Source-defined labels are not proof of route completion, production availability, configuration, or visibility for every user. Browser/source-owner review must record the exact accessible menu hierarchy per accepted role.

| Area / top-level workspace | Source-defined primary menu entries | Current Docs coverage | Next source-of-truth review |
| --- | --- | --- | --- |
| Infrastructure / **Kubernetes** | Overview, Inventory, Operations, Governance, Tenant, Analytics | Snapshot/refresh tutorial drafts (#6); no full UI menu guide | #130: Inventory views, topology, nodes, namespaces, workloads, pods, services, ingresses, storage and configuration; ConfigMaps, Secrets, certificates, Tenant and Analytics require separate permission/risk checks |
| Infrastructure / **Object Storage** | Overview, Inventory, Analytics | No dedicated published guide | #130: system/bucket inventory, dashboard, capacity/performance/forecast, source binding and freshness |
| Infrastructure / **Artifact Registry** | Overview, Inventory, Security, Runtime, Governance, Analytics | Registry overview draft (#4), Harbor integration draft (#5) | #4/#130: Projects, Repositories, Artifacts, vulnerability scope, digest evidence, Runtime Usage/Topology and analytics |
| Infrastructure / **Source Control** | Overview, Repositories | No approved public provider guide | #5/#130: GitHub App installation/identity, permission and collection/UAT; source catalog readiness does not establish live org installation |
| Infrastructure / **Secrets & PKI** | Overview, Inventory, Lifecycle & Assurance | No approved public guide | #7/#130: masking and secret/certificate lifecycle safety, source scope and real authorization |
| Assurance / **Security** | Overview, Findings | No dedicated public guide | #7/#130: sources, coverage/freshness, Registry/Kubernetes correlation and absence-of-evidence warning |
| Insights / **Intelligence** | Overview, Recommendations, Alert Intelligence, Rule Catalog, Automation Control | Conceptual correlation draft (#3) only | #4/#130: read model, recommendations, decisions, alert sources, authorization and planned vs accepted automation |
| Insights / **Reports** | Overview, Generate, Generated, Templates, Storage, Schedules | No dedicated guide | #4/#130: generation lifecycle, permission, storage, schedules, output/artifact and worker failure states |
| Platform / **Operations Center** | Overview, Jobs, Data Lifecycle, Kubernetes Admin | No dedicated guide | #6/#7/#130: job outcomes, retention/archive/recovery, approval and infrastructure mutation boundaries |
| Platform / **Integrations** | Overview, Orchestration, Observability, Storage, Registry, Secrets Management, Source Control, Notification Channels | Integration catalog and Harbor draft (#5) | #5/#130: provider/instance register/validation, health and feature maturity; do not imply all configured |
| Administration / **Access** | Overview, Users, Identity Providers, Authentication Security, Roles, Permissions, Activity Audit | Roles & Permissions draft (#7) | #7/#130: user/identity lifecycle, protected roles, permission visibility, SSO and audit evidence |
| Administration / **Settings** | General, Account | Administration overview only (#7) | #7/#130: personal account, system information, safe release identity and editable vs read-only settings |

`_CAPABILITY_VIEWS` defines additional nested tabs (not exhausted in this table), such as Kubernetes Inventory and Analytics, Artifact Registry Security/Runtime/Analytics, Object Storage Inventory/Analytics. [Docs #130](https://github.com/OXY7O/kaori-docs/issues/130) must produce the **complete leaf-level matrix**, including exact endpoint, required permission, supported role, data source, maturity and owning documentation article. Until completed, this baseline is **top-level coverage only**, not exhaustive UI acceptance.

### Critical implementation maturity boundaries

- A source-declared workspace or navigable endpoint does not imply every feature is enabled, integrated, licensed, production-ready or visible to a given user. Use canonical KAORI Available / In progress / Planned / Future maturity semantics.
- Kubernetes **Tenant** is a cluster/namespace governance capability, **not** multi-customer SaaS isolation. Planned customer-managed distribution, managed dedicated instances and shared SaaS must not appear as available products.
- Source Control GitHub has staging code and catalog evidence, but live installation, permissions and production UAT require separate proof. Do not repeat outdated 2026-11-03 planned-only statements as current fact without reconciling source and acceptance.
- Source systems execute their authoritative operations; KAORI normalizes, persists committed evidence, correlates, governs and audits. Last observed state may be stale, partial, unknown or unsupported.
- Normal user pages, mutating workflows and sensitive administrative actions require distinct guide prerequisites and role-specific browser testing. A view permission never grants mutation authority.

## Installation and lifecycle inventory

**Canonical App authority:** `docs/RUNNING.md`, `docs/DEVELOPMENT.md`, `docs/DEPLOYMENT.md`, `docs/deployment/RELEASE_GOVERNANCE.md`, `deploy/server/README.md`.

| Execution mode | Purpose | Authoring decision |
| --- | --- | --- |
| **VS Code Dev Container** | Local development from checked-out source, separated dev environment | Provide real prerequisites, setup, source/bootstrap/migrations, assets, verification and troubleshooting after reproduction. Never suggest copying root dev secrets into server config |
| **Standalone signed RC** | Disposable local trial using separately owned `example/kaori` stack and immutable candidate image | Document as candidate/evaluation mode, not a customer GA installer or operationally supported release |
| **Governed server UAT / release** | Controlled immutable image, environment split, backup/migrate/verify, workers, release receipt and recovery | Explain architecture and verified supported process; sensitive host procedures stay in internal operator docs. Do not equate merge to `main` with production deployment or imply stable acceptance |

Public installation chapters must include prerequisites, validated compatibility, roles/access, safe configuration and placeholder values, initial verification, upgrade/downgrade constraints, backup/restore, maintenance and recovery, plus explicit unsupported scenarios. `APP_VERSION`, source `VERSION`, an RC tag and a stable release manifest are distinct authorities.

## Article completeness contract

Each public **product task or menu guide** must be useful independently, with:

1. Purpose, audience and applicable **accepted** App RC/release and capability maturity.
2. Before-you-begin: supported deployment mode, role/permission, configured provider/instance, environment/scope, dependencies and safe prerequisites.
3. Where to navigate: exact **workspace → capability → view** labels confirmed against current permission-scoped navigation; no invented links/screens.
4. Steps: numbered read-only path first, then separately authorized mutation path when supported, with validation and impact warning.
5. Expected result: visible UI state, committed observation/provenance, freshness/partial/error/unavailable interpretation, and audit outcome where applicable.
6. Variants and limitations: provider/version constraints, supported scope, permissions, optional dependencies and negative cases.
7. Troubleshooting and recovery: minimal reproductions, safe evidence/log capture, rollback where applicable, escalation and known limitations.
8. Verified reference: owning App issue/PR/commit, Docs issue, reviewer, human browser/UAT evidence, approved screenshot/diagram/license and last reviewed date.

A **conceptual article** may omit UI steps if clearly labeled as conceptual; it still requires source, maturity, limitations and rights review.

## RC web-review and stable readiness gates

**Stage A — corpus:** Issue-owned articles and native sidebar are prepared, reviewed and tested as **drafts** against a pinned Application RC. No stable claim and no unapproved public build inclusion.

**Stage B — RC visibility design:** [#131](https://github.com/OXY7O/kaori-docs/issues/131) must reconcile pre-stable **full-content UAT visibility** with existing publication policy #15/#74; only an accepted, explicit, source-qualified RC scope/allowlist can serve those articles at an unmistakably prerelease route. Never activate `/v0.3/` stable or search just to make them visible.

**Stage C — public Docs RC:** Exact source → reviewed staging PR(s) → exact-head Developer Check → merged-SHA Full Admission (Container, Browser, security, public scope) → uniquely signed immutable Docs RC → new issue #14 public-swap approval **for that source/tag/digest** → single-slot deployment to existing Docs host → real trusted HTTPS/edge checks, browser 6 widths × light/dark × keyboard/200% zoom, link/navigation/role/content and rollback evidence → explicit Human Acceptance.

**Stage D — stable:** Independently accepted **KAORI Application** `v0.3.0` stable manifest/tag/SHA/digest and feature maturity; complete documented in-scope workflows; release-qualified native `/v0.3/` snapshot, exact patch release notes and search (#15/#9/#16); Docs exact signed artifact and independent public UAT/Human Acceptance; main promotion + stable publication and release-specific deployment approval. **Both** App and Docs acceptance must pass before stable.

Do not mark a family “complete” merely because a repository Markdown file exists, a route compiles, a CI badge turns green or a container answers `/healthz`.

## Next bounded workstreams

- [Docs #128](https://github.com/OXY7O/kaori-docs/issues/128): public-safe architecture, data/evidence and deployment overview; reuse existing Core Concepts #3.
- [Docs #129](https://github.com/OXY7O/kaori-docs/issues/129): verified setup/configuration and lifecycle chapters for the three documented running modes.
- [Docs #130](https://github.com/OXY7O/kaori-docs/issues/130): exhaustive source + role + UI menu catalog and missing-article issue breakdown.
- [Docs #131](https://github.com/OXY7O/kaori-docs/issues/131): policy/implementation authority for comprehensive pre-stable browser RC review without false stable versioned publication.
- Existing #2–#9: independently owned introductions, concepts, guides, integrations, how-to, administration, troubleshooting, releases and compatibility.
- Existing #15/#16: native stable version-line mapping and version-scoped search; they must not be bypassed.

## Next audit evidence to collect

- Complete leaf-level navigation inventory from `_CAPABILITY_VIEWS` and role-scoped **actual staging browser** with sanctioned user accounts.
- Installation mode reproduction with supported OS/tooling and **safe synthetic** configuration; negative fail/rollback paths.
- Per-domain page/workflow matrix with explicitly recorded **source, permission, provider/instance, observation freshness, UI navigation, unknown/error cases, UAT screenshot** and reviewer decisions.
- Content rights/sanitization review; original prose/image attribution and no disclosure of host/customer/internal details in public repo or static build.
- RC preview route/version decision reconciled with stable #15, automated public-output/canonical/search and private-data **negative tests**, and human visual acceptance on real HTTPS.

This file is a **scope and gap register**, not a stable compatibility promise, accepted source release, completed UAT or instruction to publish unreleased guides.
