# Review drafts for KAORI public product documentation

This internal editorial register is **not** part of the Docusaurus public output. The publication boundary is governed by [CONTENT_SAFETY.md](CONTENT_SAFETY.md), the native version-routing authority [Docs #15](https://github.com/OXY7O/kaori-docs/issues/15), and the application release authority.

## Getting Started — Introduction (issue #2)

- **Draft path:** `content/getting-started/introduction.md`.
- **Editorial owner:** KAORI Docs #2; Home #1 has operator visual acceptance as of 2026-11-03 but retains its separate release/UAT governance until evidence is complete.
- **Product authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md) and approved Docs #2.
- **Audience:** infrastructure operators, platform/reliability engineers, and operational governance readers.
- **Release applicability:** **not assigned**. First intended line is KAORI App `v0.3` with native route `/v0.3/`, but `v0.3.0` remains a _target_, not proof of a stable accepted application release. Docs RC versions do not qualify application content.
- **Article structure:** introduction → audience → capability/provider/instance → conceptual source-to-evidence flow → committed evidence → visibility versus authorization → links to actually published pages.
- **Native article presentation:** Docusaurus own sidebar, breadcrumb, on-page TOC, accessible anchors, and previous/next navigation. The draft frontmatter carries a title, sidebar label, ordering, description, and `draft: true`; it does not create a custom router or a visible version assertion.
- **Conceptual diagram:** text-first accessible flow; no real infrastructure state or claim of enabled providers.
- **Developer preview:** explicitly run `KAORI_DOCS_EDITORIAL_PREVIEW=1 npm run dev` and inspect `/editorial-preview/getting-started/introduction`; normal builds/CI do not enable the plugin. The slug `/getting-started/introduction` is stable within either preview or a future accepted native `/vX.Y/` line, but no public version route exists yet.
- **Article QA:** `KAORI_DOCS_EDITORIAL_PREVIEW=1 npm run test:browser` exercises the native sidebar/TOC, headings, keyboard, accessibility, responsive themes and screenshot. Execution/evidence remains pending until reported by a real environment.

## Proposed version placement — pending maintainer review and issue #15

Keep **product applicability** and **Docs artifact version** distinct:

1. **Article/sidebar version selector:** use Docusaurus native version navigation near the top of the article sidebar, listing only verified published KAORI Application Major.Minor lines; hide it when there is no accepted line to select.
2. **Article applicability:** directly beneath the article heading, show the matching app release line (for example, `Applies to KAORI v0.3.x`) only when the Docs #15 mapping has verified the accepted App stable release and Docs revision. Do not hardcode a future release line into draft markup or show a false stable badge.
3. **Documentation artifact identity:** an independently verifiable Docs release/build identity may be shown in the global footer or release details, clearly labeled **Docs release** (not KAORI application version), after its signed/accepted release identity is verified.
4. **Routes:** Documentation Home `/`; native Docusaurus guide line `/vX.Y/`; exact patch release notes `/releases/vX.Y.Z/` owned by #9. Stable canonical links and version-scoped search #16 remain separately gated.

The released application manifest/tag, accepted app SHA and immutable evidence, Docs revision/publication approval, and signed Docs artifact must all agree before presenting a published version. The KAORI App source `VERSION`, a Docs RC tag, or the Docusaurus package version alone cannot prove this.

## Publication and validation gates

- **Current status:** unpublished review content. `draft: true` is retained and the `docs` plugin remains disabled in the current public build; only explicit local development can show an `editorial-preview` article. No product version selector, public article or search route is enabled by this draft.
- **Verification:** perform locked-dependency formatting, TypeScript/build, public-scope assertions and relevant Developer Check on the **new exact head**. Previous successful checks on earlier commits are historical evidence only.
- **Activation blockers:** accept native release mapping #15 and actual KAORI application stable release evidence; review the article against that exact release; remove the draft boundary only in a subsequent reviewed publication change; verify route, six viewports, two themes, keyboard/200% zoom, TOC/sidebar/a11y, index isolation, Full Admission, UAT, and Human Acceptance.
- **Operations:** Do not merge directly to `main`, deploy, revise DNS/edge, or claim stable Docs publication based on source review alone.
