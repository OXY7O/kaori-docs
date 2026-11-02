# KAORI Docs architecture

## Authority and scope

KAORI Docs is a standalone public static/read-only Docusaurus product-documentation site intended for `https://docs.kaori.cloud/`. It is not an authentication surface, external-provider API client, operational dashboard or source of truth for product behavior.

Authority order: the current approved KAORI Application product/design/release standards, then current governing Docs issues, then implemented verified releases, then older proposals. Refer to:

- [Canonical product direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md)
- [KAORI Design System](https://github.com/OXY7O/KAORI/blob/main/docs/design/KAORI_DESIGN_SYSTEM.md)
- [Engineering delivery workflow](https://github.com/OXY7O/KAORI/blob/main/docs/engineering/KAORI_DELIVERY_WORKFLOW.md)
- [Release governance](https://github.com/OXY7O/KAORI/blob/main/docs/deployment/RELEASE_GOVERNANCE.md)
- [Website delivery baseline](https://github.com/OXY7O/kaori-website/blob/main/docs/DELIVERY.md)

## Public vs internal

| Path | Role | Public build |
| --- | --- | --- |
| `src/pages/` | Approved static pages; initial preparation fixture | Yes |
| `static/` | Reviewed public assets; logo and restrictive robots policy | Yes |
| `content/` | Native Docusaurus article/version content after #15 approval | **Disabled** for bootstrap |
| `docs/` | Internal engineering, authoring and governance material | **No** |
| `.github/`, `.devcontainer/`, `compose.dev.yml` | Development and CI metadata | **No** |

The Docusaurus classic preset currently sets `docs: false` and `blog: false` explicitly. This avoids Docusaurus defaulting to repository `docs/` and mistakenly publishing internal engineering material. Do not enable a docs plugin until #15 implements a release-evidence-backed source path, routes and draft exclusion tests. Release-specific docs, the version selector and local search must remain absent until their respective issues and evidence gates are accepted.

## Capability and design boundaries

Capability/domain first, provider second, instance third. External providers remain authoritative. KAORI adds normalization, committed evidence, correlation, governance and operational workflow. Public product claims require exact release verification. Mark roadmap direction as Planned/Future rather than Available unless accepted implementation proves otherwise.

Reuse the approved KAORI logo, Inter and Violet design tokens through native Docusaurus/Infima. Avoid cloning authenticated KAORI Jinja/HTMX/Tailwind UI components in Docs or inventing a second shared design taxonomy.

## Release isolation

Docs repository artifact SemVer, KAORI Application Major.Minor documentation applicability and exact application patch release notes are different identities. They are not interchangeable. Until #15 verifies the accepted application release and Docs SHA mapping, **do not display a version selector, search index or application-version documentation route**.

Runtime Docker, release signing, shared VPS deployment and public Host/SNI/DNS/TLS work are separately owned by #13/#14/#10. No development build deploys anything to `/opt/kaori`, `/opt/kaori-website`, `/opt/shared-edge` or public domains.
