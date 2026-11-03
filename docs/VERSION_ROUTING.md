# Native Docusaurus version routing and release mapping (#15)

## Scope and release authority

The Documentation Home is unversioned at `/`. Product guides use native
Docusaurus **Major.Minor** paths (`/vX.Y/`), while individual patch Release
Notes will use `/releases/vX.Y.Z/` under Docs #9. Docs artifact SemVer and
KAORI Application version applicability are different release authorities.

As of 2026-11-03, KAORI Application has **no accepted stable v0.3.0
release**. The signed Docs `v0.3.0-rc.7` does not authorize an application
guide line. Thus the internal `docs/PUBLISHED_VERSIONS.json` intentionally
has an empty `published` array, `versions.json` is `[]`, public Docs routing
is disabled, and no published version selector or search appears.

## Native snapshot contract

- `content/` is the unpublished Docusaurus **current** editorial tree.
  The existing opt-in article preview stays development-only.
- Approved frozen releases belong in
  `versioned_docs/version-vX.Y/` with a matching
  `versioned_sidebars/version-vX.Y-sidebars.json` and exactly one
  `versions.json` entry, newest first. Use Docusaurus native
  `docs:version vX.Y` during a reviewed release freeze rather than
  implementing a second version router.
- Production publication uses `routeBasePath: '/'` and
  `includeCurrentVersion: false`. It configures native
  `lastVersion`, `onlyIncludeVersions` and `versions[vX.Y].path` from
  the approved mapping, so every historical snapshot retains its
  matching Major.Minor path. No automatic redirect is added from Home
  or from an older version to the latest one.
- The Docusaurus `docsVersionDropdown` is hidden until at least one
  accepted application version is mapped. It uses the native navbar
  placement next to Overview and the built-in article/sidebar layout.
  Product applicability is displayed through the native version label.
  A separately accepted Docs artifact version may later be indicated
  explicitly as a Docs release, never as a product compatibility badge.
- Every frozen snapshot must exclude drafts, confidential information,
  unsupported product claims, unreviewed screenshots and dead links.
  The `content/` draft tree is **not** imported automatically.

## Publication-map fields

`docs/PUBLISHED_VERSIONS.json` is internal review metadata, **not**
proof of release authenticity by itself. A nonempty mapping can only
be submitted through a separately approved issue #15 publication
change. Each entry must bind:

| Field                         | Authority                                                                           |
| ----------------------------- | ----------------------------------------------------------------------------------- |
| `line`                        | Application Major.Minor, for example `v0.3`                                         |
| `application_release_tag`     | Real accepted stable `vX.Y.Z` GitHub Release, never RC or the source `VERSION` file |
| `application_release_url`     | Exact KAORI Application GitHub Release URL                                          |
| `application_source_sha`      | Accepted immutable source SHA                                                       |
| `application_image_digest`    | Signed immutable OCI application image digest                                       |
| `application_manifest_sha256` | Accepted signed release-manifest hash                                               |
| `docs_accepted_snapshot_sha`  | Exact reviewed Docs content/snapshot source                                         |
| `docs_approval_url`           | Write-authorized issue #15 acceptance comment with the release mapping              |

The existing Docusaurus production build rejects malformed or
inconsistent entries, absent native snapshots/sidebars, draft
articles in a published snapshot, duplicate names, and extra or
unmapped versions. An empty map must remain `awaiting-release` and
not contain historical snapshots.

**Static validation is not cryptographic or external release
verification.** Before a map changes from empty to published, verify
the stable KAORI GitHub Release, exact tag/source, manifest asset
hash, signed immutable OCI digest and provenance, Docs article
applicability, reviewed Docs source SHA, and the human acceptance
record under the existing KAORI release governance. Record
verification in issue #15; do not infer it from a source VERSION,
Docs RC tag, CI PASS or manually entered hash.

## Local-only native route test

The existing development-only Introduction review remains available
when `KAORI_DOCS_EDITORIAL_PREVIEW=1` is enabled at
`/editorial-preview/getting-started/introduction`.

For **native Docusaurus route mechanics only**, opt in to both
`KAORI_DOCS_EDITORIAL_PREVIEW=1` and
`KAORI_DOCS_VERSION_ROUTE_PREVIEW=1` with the existing
`npm run dev` command. The local development preview uses Docusaurus
`current` with the explicit path `/v0.3/` and an **Unreleased**
banner. This is not a frozen release snapshot, not reachable on the
production RC, and does not imply KAORI Application stable readiness.

The normal production `npm run build` does not use the preview
regardless of these flags; both require the Docusaurus dev lifecycle
and non-CI execution. No public article, search-index or version
routes are enabled with the currently empty publication map.

## Next approved handoff

The first stable product release (KAORI #4198), release manifest,
Docs #2 content acceptance, Docs #9 patch notes, native snapshot
freeze and issue #15 human acceptance are blockers for publishing
`/v0.3/`. Quality evidence must include existing formatting,
TypeScript and static build gates, exact-head Developer Check,
browser route/404/navigation/canonical checks, six viewport
light/dark keyboard/accessibility and an exact merged-SHA Full
Admission. Stage/UAT, Human Acceptance, promotion and an immutable
Docs publication are separate gates. Search remains under Docs #16;
no search index may include unapproved draft snapshots.

When an application patch release changes semantics, update the
approved Major.Minor snapshot content and patch notes in its owning
workstreams while preserving historical version URLs. A new
Major.Minor release requires its own signed product authority,
frozen native snapshot and separate approved mapping item. Do not
invent compatibility support/EOL dates or cross-version redirects.
