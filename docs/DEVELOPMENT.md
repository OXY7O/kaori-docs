# Development and Dev Container

## Local baseline

Mirror KAORI Website's isolated Compose Dev Container, but use **Docusaurus** on loopback port `3000` and repository-scoped `docs_node_modules`. The container is Node.js `22.23.2` and npm `10.9.9`, user `node`. No application Postgres/Redis/Celery, infrastructure credentials or hosted search are used.

1. Open the repository with VS Code.
2. Run **Dev Containers: Reopen in Container**.
3. Run `npm run dev` from `/workspace/kaori-docs`.
4. Open `http://localhost:3000` and check both native theme modes.

Alternatively:

```bash
docker compose -f compose.dev.yml up -d --build
docker compose -f compose.dev.yml exec workspace npm ci
docker compose -f compose.dev.yml exec workspace npm run dev
```

Stop with `docker compose -f compose.dev.yml down`. Do not remove the named volume unless intentionally discarding local dependencies.

## Local editorial article preview (issue #2)

The Introduction is an unpublished `draft: true` document. It is deliberately
absent from the normal public `npm run build` and static release image.
To review the native Docusaurus article/sidebar/breadcrumb/table-of-contents
layout **locally only**, opt in during the development command:

```bash
KAORI_DOCS_EDITORIAL_PREVIEW=1 npm run dev
```

Browse `http://localhost:3000/editorial-preview/getting-started/introduction`.
This **editorial-preview** path is a development-only route and is **not** the
future public version path `/v0.3/getting-started/introduction`. It must not
be linked from the public Home, uploaded to a public search index, or deployed
as a substitute for the signed release flow. Normal `npm run dev` shows the
approved Home without enabling articles.

Run existing Playwright checks against that opt-in preview, including the
article's six viewports, both themes, accessibility and screenshot evidence:

```bash
KAORI_DOCS_EDITORIAL_PREVIEW=1 npm run test:browser
```

Both `npm run build` and the self-hosted CI workflows keep the docs plugin
disabled, including if `KAORI_DOCS_EDITORIAL_PREVIEW` is accidentally present
during a build. Issue #15 owns real Docusaurus `/vX.Y/` routing, release
mapping, version selector and publication. There is no accepted stable
application `v0.3.0` claim in this preview.

## Reproducible install and real CI evidence

The original authoring environment could not resolve `registry.npmjs.org`. The approved `platform-ci` self-hosted runner resolved the pinned Docusaurus dependencies, and `package-lock.json` is now committed in the combined #11/#12 review branch.

The [Developer Check #41396567726](https://github.com/OXY7O/kaori-docs/actions/runs/41396567726) passed on exact SHA `f2e13e631c71fa416c6c2f1f95b2b3cea43f7e4c` using Node `22.23.2`; its executed checks include `npm ci`, Prettier, `npm audit --audit-level=high`, TypeScript and Docusaurus production build. This is **source/build acceptance only**, not browser, runtime-image, staging deployment or public release acceptance. New commits require new exact-head results.

To reproduce in an approved network-enabled environment:

```bash
node --version
npm --version
npm ci
npm run check-format
npm audit --audit-level=high
npm run check
npm run build
```

Do not regenerate or edit the lockfile without a reviewed dependency-authority change. Preserve issue-branch and exact-head provenance; an uncommitted dependency graph is never a passing gate.

## Public-output review

After building, inspect `build/` for any leakage of internal `docs/`, `.github/`, `.devcontainer/`, private metadata or unpublished content. Validate the root page and that there is **no public version selector, search control or draft documentation article**. `static/robots.txt` disallows indexing until explicit public publication. Use Docusaurus native link checking and broken-link build failure; do not add custom checks while #12 governs CI/quality.

## Evidence to collect

Record exact Node/npm versions, pinned lockfile hash, build SHA and command exit codes. Run responsive light/dark/keyboard/focus/200% zoom checks at 360, 390, 768, 1024, 1280 and 1440 px. Dev Container smoke, staging Full Admission, published asset verification, browser accessibility/visual QA and human UAT are separate gates; do not treat locally valid JSON/TypeScript as acceptance.
