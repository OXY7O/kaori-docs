#!/usr/bin/env bash
set -Eeuo pipefail
state_dir="${KAORI_DOCS_STATE_DIR:-/var/lib/kaori-docs/deploy-state}"
previous="$state_dir/previous-release.env"
[[ -f "$previous" && ! -L "$previous" && -r "$previous" ]] || { echo 'BLOCK: reviewed previous release state unavailable' >&2; exit 1; }
# shellcheck source=/dev/null
source "$previous"
[[ "${KAORI_DOCS_IMAGE:-}" =~ @sha256:[a-f0-9]{64}$ ]] || { echo 'BLOCK: previous image is not immutable' >&2; exit 1; }
[[ "${KAORI_DOCS_SOURCE_SHA:-}" =~ ^[a-f0-9]{40}$ ]] || { echo 'BLOCK: previous source SHA invalid' >&2; exit 1; }
[[ "${KAORI_DOCS_VERSION:-}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$ ]] || { echo 'BLOCK: previous release version invalid' >&2; exit 1; }
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$script_dir/deploy.sh" "$KAORI_DOCS_IMAGE" "$KAORI_DOCS_SOURCE_SHA" "$KAORI_DOCS_VERSION"
