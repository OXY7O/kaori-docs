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

## Documentation Home visual parity — issue #57

- **Authority:** Docs #1 (Home foundation) and bounded #57 (editorial layout), approved KAORI Application Design System and KAORI Website `HOMEPAGE_REVIEW.md`, `global.css`, `Icon.astro` and native website/footer presentation.
- **Content:** Short, conceptual English summaries; no public product documentation release is asserted. The eight existing topic categories are intentionally informational and non-clickable until release-qualified guides, version routes and search are separately accepted under #2–#9, #15 and #16.
- **Navigation:** Native Docusaurus navbar and footer own the public header/theme/mobile and footer structure. Overview, Catalog and How to Use point to real root/section anchors; external Website and Application destinations remain accurate. Contact owner uses the already approved KAORI Website public contact address.
- **Design:** Inter and the neutral-first KAORI Website Violet token family; reusable Lucide-outline icon vocabulary shared by Docs Home topics, process steps and conceptual context diagram. Light/dark parity and screen-reader text remain mandatory; no operational health is represented by violet styling.
- **Attribution and availability:** The diagram describes authority → normalization and committed evidence → cross-domain context, never live provider data. `In preparation` is a neutral publication label, not a claim that guides are published or that a specific KAORI Application release is available.
- **Validation:** Existing six-viewport/two-theme Playwright/axe, keyboard/focus, no-overflow and CTA/anchor/footers; new exact-merge SHA Full Admission, signed candidate and live public-edge verification are independently required. Human Visual UAT, rollback drill, main and stable promotion remain separately controlled.

## Documentation Home UAT refinement — issue #57, navbar and footer

- **Observed feedback:** The deployed RC.4 navbar/footer still used the abbreviation `KAORI Docs`, native boxed external-link icons, and a cramped theme toggle. The native footer placed the logo below link columns and did not show the official KAORI acronym.
- **Authority:** Approved KAORI Website `SiteFooter.astro`, `SiteHeader.astro` and `Icon.astro`; global KAORI Violet/Inter and neutral-first light/dark design system. The official acronym is **Knowledge, Automation, Operations, Resilience & Intelligence**.
- **Scoped presentation:** The site title, brand and page identity use **KAORI Documentation**. Existing Docusaurus navbar/mobile/theme operation is retained. Its external destinations display the same Lucide `arrow-up-right` stroke vocabulary without the bundled box glyph; the icon is decorative and does not change link semantics.
- **Footer:** A Docusaurus Footer theme wrapper renders the single existing footer navigation configuration, plus official logo, shortened brand explanation, KAORI acronym, approved Website contact identity and OXY7 ORBITAL attribution. Existing public links and version/public-corpus safety constraints remain unchanged.
- **Acceptance:** Use existing browser/axe tests to check desktop/mobile, light/dark, spacing, heading identity, links/icons, footer, navigation and no overflow. CI success is **not** proof of human visual acceptance or rollback validation. A new exact-SHA admission and signed, approved RC are required before a single-slot public swap.
