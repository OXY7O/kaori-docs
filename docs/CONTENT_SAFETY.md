# Public documentation authoring and security

## Release and authority

Public product documentation is English and **release-qualified**, not a mirror of all internal KAORI files. The application product README, module documentation and accepted release manifest govern claims. Authors must record applicable application release line, source issue/commit, content owner and review outcome before publishing an article. A development VERSION is not evidence of a released product.

## Source placement

- Internal engineering, CI, delivery, security operations, private implementation evidence and instructions stay in repository docs/; the Docusaurus docs plugin **must never use this path**.
- Public drafts are not served from src/pages/, static/ or an enabled plugin. A content/ article is eligible only after #15 validates publication/version isolation and a reviewer authorizes the exact source.
- The Docs Home under #1 is a **public-safe product-direction landing page**, not an unpublished product guide: its topic cards are deliberately non-clickable while release-qualified articles are absent. The on-page Get Started and Explore Capabilities links navigate to real Home sections, not invented documentation routes.
- Do not add placeholder URLs, fictional version menus or a search bar that appears functional without a real eligible public index.
- Diagrams must be conceptual and source-attributed; screenshots must be sanitized and approved. No credentials, hostnames, personal data, provider secrets, infrastructure identifiers or private operational state.

## Editorial checks

Check capability maturity (Available/In progress/Planned/Future), provider authority, safe examples and cross-domain evidence language. Changes to application functionality, security, release mapping or architecture must update the owning canonical application docs and link issue/PR work across repositories. Docs does not add an independent release engine or replicate the live provider.

Docs Major.Minor applicability and exact patch release notes follow #15 and #9. Local-first version-isolated search is a separate #16 gate. Public DNS/TLS/routing and host deployment remain separate infrastructure approvals.

## Home content registry — issue #1

| Surface | Content authority | Editorial owner | Applicability | Publication state |
| --- | --- | --- | --- | --- |
| Home introduction and operational model | KAORI docs/product/README.md | KAORI Docs #1 | Version-neutral product positioning | Review candidate; not yet accepted |
| Eight category descriptions | KAORI Docs #1 and approved website #108 | KAORI Docs #1 | Discoverability only, not feature availability | Review candidate; links withheld |
| Conceptual authority/evidence flow | KAORI docs/product/README.md | KAORI Docs #1 | Concept, no instance/provider claims | Review candidate; not a product screenshot |
| Version selector and search | KAORI Docs #15/#16 | Separate owning issues | Only accepted application releases | Intentionally unavailable |

A work-branch review candidate is **not** an accepted public release. Record the final source SHA, actual product release mapping (if applicable), exact Full Admission, stage/browser evidence, human acceptance, and deployment receipt only when those events occur. Do not retroactively treat this matrix as approval.

## Public release process

An accepted Docs release requires source SHA, version/applicability evidence, public-content isolation, QA/browser accessibility, immutable static OCI digest and signed provenance, approved staging UAT and explicit human acceptance. A green static build alone does not permit public deployment.
