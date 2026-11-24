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

## Public analytics

Umami is an independent, self-hosted provider at
`https://analytics.kaori.cloud` (KAORI #5190, #5191; consumer #163).
The Docusaurus static build remains immutable; no application
credential, public Website ID, or enablement flag is embedded in the image.
The host-owned read-only `/.well-known/kaori-analytics/config.json` projection
is separate from release receipts and defaults to disabled when absent,
malformed, or explicitly off. Its schema requires the canonical HTTPS host,
exact provider script URL, UUIDv4, and explicit enablement.

The browser never loads the provider until the visitor explicitly allows
analytics using the footer privacy disclosure and the runtime config is valid.
DNT, Global Privacy Control, blocked storage and explicit opt-out fail closed.
Umami automatic pageview and click handling are disabled; the native Docusaurus route lifecycle sends one manual
pageview per pathname and bounded approved outbound CTA events without
preventing navigation. Query strings, fragments, referrer paths, custom
identities, event data, error/performance capture and session replay are
excluded. The loader sends only the canonical host, pathname, page title,
referring origin, language, screen dimensions and approved event name.
The provider processes network metadata; the authenticated application is
excluded. Local development and real CI traffic are excluded by exact
canonical origin; browser tests intercept all requests with local mocks.
Editorial, candidate full-manual review, and search routes are excluded. The change does not enable any unpublished documentation or stable version.

No analytics provider failure may block rendering or navigation. Runtime
authorization is cached for at most 60 seconds in an open tab; expiry or
invalid config blocks sending until revalidated. Changing a Website ID
requires a fresh page load, not a rebuilt image.
