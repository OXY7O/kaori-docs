# Public documentation authoring and security

## Release and authority

Public product documentation is English and **release-qualified**, not a mirror of all internal KAORI files. The application product README, module documentation and accepted release manifest govern claims. Authors must record applicable application release line, source issue/commit, content owner and review outcome before publishing an article. A development `VERSION` is not evidence of a released product.

## Source placement

- Internal engineering, CI, delivery, security operations, private implementation evidence and instructions stay in repository `docs/`; the Docusaurus docs plugin **must never use this path**.
- Public drafts are not served from `src/pages/`, `static/` or an enabled plugin. A `content/` article is eligible only after #15 validates publication/version isolation and a reviewer authorizes the exact source.
- Do not add placeholder URLs, fictional version menus or a search bar that appears functional without a real eligible public index.
- Diagrams must be conceptual and source-attributed; screenshots must be sanitized and approved. No credentials, hostnames, personal data, provider secrets, infrastructure identifiers or private operational state.

## Editorial checks

Check capability maturity (Available/In progress/Planned/Future), provider authority, safe examples and cross-domain evidence language. Changes to application functionality, security, release mapping or architecture must update the owning canonical application docs and link issue/PR work across repositories. Docs does not add an independent release engine or replicate the live provider.

Docs Major.Minor applicability and exact patch release notes follow #15 and #9. Local-first version-isolated search is a separate #16 gate. Public DNS/TLS/routing and host deployment remain separate infrastructure approvals.

## Public release process

An accepted Docs release requires source SHA, version/applicability evidence, public-content isolation, QA/browser accessibility, immutable static OCI digest and signed provenance, approved staging UAT and explicit human acceptance. A green static build alone does not permit public deployment.

## Documentation Home content record — issue #1

- **Authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md), with approved Home scope in Docs #1 and Website #108.
- **Editorial owner:** Docs #1. The introduction, eight topic labels and conceptual flow are version-neutral, with no assertion that a product capability or provider is released.
- **Public readiness:** Work-branch review candidate only. Topic cards remain non-clickable; Get Started and Explore Capabilities are working same-page anchors.
- **Release applicability:** No application version is asserted. Publication of versioned guides is owned by #15 and source-released App evidence; local search by #16.
- **Acceptance evidence:** Exact-head Developer Check, merged-SHA Full Admission, six-viewport browser checks, operator UAT and Human Acceptance remain separate and must be recorded only after completion.
