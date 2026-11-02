#!/usr/bin/env bash
# Issue #45: fresh bounded smoke, for use only AFTER authoritative evidence
# reuse is independently validated. Never a replacement for changed-source
# comprehensive Browser/Container/Security admission.
set -Eeuo pipefail
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
[[ "${1:-}" =~ ^[a-f0-9]{40}$ ]] || fail 'exact source SHA required'
[[ "$(git rev-parse HEAD)" == "$1" ]] || fail 'Fast Smoke checkout/source mismatch'
[[ -f package-lock.json ]] || fail 'locked dependency identity missing'
[[ -f playwright.config.ts && -f tests/browser/docs-foundation.spec.ts ]] ||
  fail 'fresh browser smoke contract missing'
command -v npm >/dev/null || fail 'npm unavailable'
npm run build
test -s build/index.html || fail 'static index missing'
test -s build/branding/kaori-logo.svg || fail 'approved logo missing'
grep -q 'KAORI Docs' build/index.html || fail 'Docs bootstrap identity absent'
for leaked in docs/ARCHITECTURE.md docs/CONTENT_SAFETY.md .github package.json package-lock.json content; do
  test ! -e "build/$leaked" || fail "private file leaked to static output: $leaked"
done
# One pinned viewport and keyboard/navigation smoke. The existing Full
# Admission retains all 12 viewport/theme and accessibility checks on any
# changed source/tree or validation authority.
npx playwright test tests/browser/docs-foundation.spec.ts \
  --project=desktop-light --grep 'tab focus and public version/search absence' \
  --workers=1 --retries=0
echo "PASS: fresh Docs Fast Smoke on $1 (not Human UAT)"
