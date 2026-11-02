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

## Deterministic install blocker

The bootstrap authoring environment could not access `registry.npmjs.org`. Initial dependency versions are explicitly pinned against the Docusaurus 3.10.2 supported Node.js matrix, but no registry-resolved `package-lock.json` has been created. This is a **BLOCKER**, not a skipped PASS. Resolve the lock in an approved network-enabled environment:

```bash
node --version
npm --version
npm install --package-lock-only --ignore-scripts
npm ci
npm run check-format
npm run check
npm run build
```

Commit the generated `package-lock.json` to this #11 work branch; inspect the dependency tree, npm audit findings and source integrity before accepting it. Never hand-write an invented lockfile. Re-run the exact-head checks and verify native Docusaurus + pinned package compatibility. Until then `npm ci` and Dev Container post-create are expected to fail, and #11 must stay Draft/blocked.

## Public-output review

After building, inspect `build/` for any leakage of internal `docs/`, `.github/`, `.devcontainer/`, private metadata or unpublished content. Validate the root page and that there is **no public version selector, search control or draft documentation article**. `static/robots.txt` disallows indexing until explicit public publication. Use Docusaurus native link checking and broken-link build failure; do not add custom checks while #12 governs CI/quality.

## Evidence to collect

Record exact Node/npm versions, pinned lockfile hash, build SHA and command exit codes. Run responsive light/dark/keyboard/focus/200% zoom checks at 360, 390, 768, 1024, 1280 and 1440 px. Dev Container smoke, staging Full Admission, published asset verification, browser accessibility/visual QA and human UAT are separate gates; do not treat locally valid JSON/TypeScript as acceptance.
