# Documentation RC article rights and applicability register

**Authority:** Docs [#150](https://github.com/OXY7O/kaori-docs/issues/150) (audit), [#74](https://github.com/OXY7O/kaori-docs/issues/74) (public rights), [#131](https://github.com/OXY7O/kaori-docs/issues/131) (candidate design), [#142](https://github.com/OXY7O/kaori-docs/issues/142) (eventual gated implementation), [#127](https://github.com/OXY7O/kaori-docs/issues/127) (completeness), [#15](https://github.com/OXY7O/kaori-docs/issues/15) (stable versions).

**Docs source:** `kaori/staging@c01ca5020f61b7d7c9aeda497271024a110493ba`, inspected 2026-11-23. This is an **initial inventory and HOLD register**, not an approved public candidate allowlist, publication manifest, screenshot/license clearance, or claim of Application UAT. Use `content/` only for individually reviewed authored public content; repository `docs/` is engineering reference, never the Docusaurus public article root.

**Potential Application candidate:** [KAORI `v0.3.0-rc.3`](https://github.com/OXY7O/KAORI/releases/tag/v0.3.0-rc.3), source `197a7f7e598c111592a8ae36388865cd3aacf541`, image digest `sha256:74d2bda52d9ba74c6a9a028c302a6459345031433a7f41391a39898bd9267e13`. This published prerelease explicitly states **UAT pending**. The candidate identity is useful for validating source applicability, but is **not approval** for provider/permission/deployment claims or Docs publication.

## Rules for admission

Every tracked or candidate article starts **HOLD**, regardless of its author, the GitHub PR outcome or its `draft` frontmatter. A candidate article requires all of these **separate** approvals before it may appear in the public signed Docs RC:

1. **Original rights and licensing:** First-party material owns its rights; approved authored public prose may use CC BY 4.0 subject to `CONTENT_LICENSE.md`, `LICENSE` and `NOTICE`. Images, fonts, Lucide icons, trademarks, code quotations, diagrams and third-party material need their own licenses, attribution and source rights.
2. **Public safety:** No credentials, live internal hostnames, real network addresses, real customer environment identifiers, private deployment receipts, auth keys, Secret metadata/paths, real security findings, proprietary diagrams or operational logs. Every tracked file in this publicly readable GitHub repository is already externally accessible, even when excluded from Docusaurus.
3. **Source applicability:** Document the owning App issue/route/behavior and exact candidate source/tag/digest; distinguish source-declared feature from actual deployed, authorized and UAT-accepted support.
4. **Chapter quality:** Author/reviewer, complete prerequisites, permission persona, menu path, safe steps, outcome, committed state/freshness, incomplete/error/denied behavior, rollback/escalation, source evidence and doc article review.
5. **Acceptance:** Exact-head Developer Check, independent editorial + rights approval, merged-SHA Full Admission, six-width/two-theme/a11y and role-scoped browser UAT for candidate workflows, source-safe screenshots where applicable and explicit Human Acceptance.
6. **Separate publication authority:** Even a fully accepted article cannot be exposed until native candidate `/review/` allowlist and public-output negative tests under #142 are accepted, a new Docs signed source/tag/immutable digest is approved under #13/#14 and the single public slot passes HTTPS/edge/UAT. Stable `/v0.3/` remains subject to accepted **stable** Application and #15.

## Current tracked chapter inventory — all HOLD

At the pinned Docs staging source there are **19** authored `content/**/*.md` files. All 19 use `draft: true`; none may be interpreted as a site-public product article. Each listing below is intentionally explicit; **ownership issue** is the content workstream, not an automatic clearance.

### Introduction and concepts

**Owning workstream:** #2 / #3. **Special safety review:** Conceptual source material. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/getting-started/introduction.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/core-concepts/capabilities-providers-instances.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/core-concepts/committed-evidence.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/core-concepts/cross-domain-correlation.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/core-concepts/external-source-authority.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/core-concepts/governed-operational-workflows.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Platform architecture

**Owning workstream:** #128. **Special safety review:** Conceptual system diagrams and asserted security/operational boundaries. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/core-concepts/platform-architecture.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Installation and runtime modes

**Owning workstream:** #129. **Special safety review:** Environment-sensitive commands, operator prerequisites and deployment assumptions. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/getting-started/installation-and-runtime-modes.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Product domain guides

**Owning workstream:** #4 / #138 / #139. **Special safety review:** Source and provider capability, role-scoped interface behavior, freshness and support maturity. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/product-guides/registry-overview.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/product-guides/kubernetes-inventory-and-dashboard.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/product-guides/object-storage-inventory-and-analytics.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Provider integration guides

**Owning workstream:** #5. **Special safety review:** Provider-specific configuration, credential/endpoint safety, lifecycle and rights. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/integrations/integration-catalog.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/integrations/harbor-provider-guide.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Tutorials and How-to

**Owning workstream:** #6. **Special safety review:** Task-specific screenshots/steps, real scope and mutation qualification. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/tutorials/explore-first-inventory-snapshot.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/how-to/verify-inventory-refresh-evidence.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Administration and security

**Owning workstream:** #7. **Special safety review:** Role scopes, access-denied evidence and security safety boundaries. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/administration-security/administration-security-overview.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/administration-security/understanding-roles-permissions.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

### Troubleshooting

**Owning workstream:** #8. **Special safety review:** Safe diagnosis, irreversible-action disclaimers and private logs/redaction. **Eligibility:** HOLD — no rights/App/browser/UAT acceptance record yet.

- `content/troubleshooting/troubleshooting-overview.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.
- `content/troubleshooting/inventory-data-appears-outdated.md` — draft, **HOLD**; check source rights, App RC applicability, reviewer and browser evidence.

## In-flight chapters not yet part of the 19-file staging inventory

- [Docs #144](https://github.com/OXY7O/kaori-docs/issues/144) / [PR #145](https://github.com/OXY7O/kaori-docs/pull/145): `content/product-guides/source-control-installations-and-repositories.md`. **HOLD** — current local-Super-Admin gate is not a supported production access policy; provider identities and repository examples require careful redaction.
- [Docs #146](https://github.com/OXY7O/kaori-docs/issues/146) / [PR #147](https://github.com/OXY7O/kaori-docs/pull/147): `content/product-guides/secrets-pki-evidence-and-readiness.md`. **HOLD** — Secret values/paths/key material are prohibited; public certificate-overlap evidence is not live endpoint assurance.
- [Docs #148](https://github.com/OXY7O/kaori-docs/issues/148) / [PR #149](https://github.com/OXY7O/kaori-docs/pull/149): `content/product-guides/security-posture-overview-and-findings.md`. **HOLD** — no real CVE/security finding, live Registry identity or permission bypass in examples; scanner freshness must be qualified.

These pending PRs have independent editorial/CI work. A draft's merge into staging would add it to the inventory, **not** approve public website publication or change `PUBLISHED_VERSIONS.json`.

## Candidate handoff fields for actual accepted articles

Use the existing approval/issue evidence rather than creating a parallel release registry. For every future allowlisted entry, record and independently confirm: **Docs file path; owning issue and PR; reviewed Docs source SHA; author; independent reviewer; rights and third-party asset clearance; sanitized screenshot/diagram reference; App RC tag/SHA/digest; permission persona and required provider/instance; positive/negative UAT receipt; scope/maturity and known limitations; explicit #74/#131 publication approval; accepted Docs source/tag/digest; rollback and Human Acceptance**.

The implementation owner #142 must **fail closed** on any missing or mismatched authority and prove every unapproved draft/private page absent from generated static output, sitemap and search.

## Coverage gaps before a complete software manual

The 19 existing files and three in-flight domain chapters do not cover all **12 workspaces / 54 capabilities / 56 nested views** indexed under #130. In particular, Reports, Intelligence, Operations Center, many Administration/Settings and provider/runtime-specific workflows remain incomplete. Assign those to existing owning workstreams or bounded child issues before claiming a complete manual. A summary of unresolved content is not a substitute for actual tested user steps.

**Decision:** all listed articles currently **HOLD**. No candidate inclusion, static-page exposure, signed Docs RC, production deployment, stable publication or human acceptance is authorized by this register.
