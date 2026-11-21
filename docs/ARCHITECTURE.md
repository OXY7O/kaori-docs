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

| Path                                            | Role                                                         | Public build               |
| ----------------------------------------------- | ------------------------------------------------------------ | -------------------------- |
| `src/pages/`                                    | Documentation Home under issue #1 (review candidate)         | Yes                        |
| `static/`                                       | Reviewed public assets; logo and restrictive robots policy   | Yes                        |
| `content/`                                      | Native Docusaurus article/version content after #15 approval | **Disabled** for bootstrap |
| `docs/`                                         | Internal engineering, authoring and governance material      | **No**                     |
| `.github/`, `.devcontainer/`, `compose.dev.yml` | Development and CI metadata                                  | **No**                     |

The root Home has an unversioned, product-direction editorial scope, with only real same-page or external links. Its category cards are non-clickable pending release qualification. The Docusaurus classic preset explicitly uses `content/` for opt-in local editorial review and never mounts internal `docs/`. Issue #15 adds a strict, currently **empty** internal `docs/PUBLISHED_VERSIONS.json` and native `versions.json`. Production therefore continues with `docs: false` and `blog: false` until release-qualified, reviewed native `versioned_docs/` snapshots are admitted. When mapped lines exist, `includeCurrentVersion: false` keeps unpublished `content/` drafts out of public routes, and the native version selector only lists approved lines. See [Version Routing](VERSION_ROUTING.md). Local search remains a separate #16 gate.

## Capability and design boundaries

Capability/domain first, provider second, instance third. External providers remain authoritative. KAORI adds normalization, committed evidence, correlation, governance and operational workflow. Public product claims require exact release verification. Mark roadmap direction as Planned/Future rather than Available unless accepted implementation proves otherwise.

Reuse the approved KAORI logo, Inter and Violet design tokens through native Docusaurus/Infima. Avoid cloning authenticated KAORI Jinja/HTMX/Tailwind UI components in Docs or inventing a second shared design taxonomy.

## Release isolation

Docs repository artifact SemVer, KAORI Application Major.Minor documentation applicability and exact application patch release notes are different identities. They are not interchangeable. Until #15 verifies the accepted application release and Docs SHA mapping, **do not display a version selector, search index or application-version documentation route**.

Runtime Docker, release signing, shared VPS deployment and public Host/SNI/DNS/TLS work are separately owned by #13/#14/#10. No development build deploys anything to `/opt/kaori`, `/opt/kaori-website`, `/opt/shared-edge` or public domains.
