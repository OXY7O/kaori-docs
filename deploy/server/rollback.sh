#!/usr/bin/env bash
set -Eeuo pipefail
runtime_env="${KAORI_DOCS_RUNTIME_ENV:-production}"
[[ "$runtime_env" == production || "$runtime_env" == staging ]] ||
  { echo 'BLOCK: unknown Docs rollback environment' >&2; exit 1; }
if [[ "$runtime_env" == staging ]]; then
  [[ "${COMPOSE_PROJECT_NAME:-}" == kaori-docs-staging &&
     "${KAORI_DOCS_STATE_DIR:-}" == /var/lib/kaori-docs-staging/deploy-state &&
     "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 0 ]] ||
    { echo 'BLOCK: staging rollback must use only its private project and receipt' >&2; exit 1; }
  compose_project=kaori-docs-staging
  state_dir=/var/lib/kaori-docs-staging/deploy-state
else
  [[ "${COMPOSE_PROJECT_NAME:-kaori-docs}" == kaori-docs ]] ||
    { echo 'BLOCK: production rollback project mismatch' >&2; exit 1; }
  compose_project=kaori-docs
  state_dir="${KAORI_DOCS_STATE_DIR:-/var/lib/kaori-docs/deploy-state}"
fi
previous="$state_dir/previous-release.env"
[[ -f "$previous" && ! -L "$previous" && -r "$previous" ]] || { echo 'BLOCK: reviewed previous release state unavailable' >&2; exit 1; }
# shellcheck source=/dev/null
source "$previous"
[[ "${KAORI_DOCS_IMAGE:-}" =~ @sha256:[a-f0-9]{64}$ ]] || { echo 'BLOCK: previous image is not immutable' >&2; exit 1; }
[[ "${KAORI_DOCS_SOURCE_SHA:-}" =~ ^[a-f0-9]{40}$ ]] || { echo 'BLOCK: previous source SHA invalid' >&2; exit 1; }
[[ "${KAORI_DOCS_VERSION:-}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$ ]] || { echo 'BLOCK: previous release version invalid' >&2; exit 1; }
if [[ "${KAORI_DOCS_ARTIFACT_VERSION:-${KAORI_DOCS_VERSION}}" != "${KAORI_DOCS_VERSION}" ]]; then
  [[ "${KAORI_DOCS_ARTIFACT_VERSION:-}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc\.[1-9][0-9]*$ &&
     "${KAORI_DOCS_ARTIFACT_VERSION%-rc.*}" == "${KAORI_DOCS_VERSION}" &&
     "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 1 ]] ||
    { echo 'BLOCK: prior stable receipt requires approved public RC-identity recovery' >&2; exit 1; }
  export KAORI_DOCS_STABLE_RELEASE_CONFIRMED=1
fi
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" =~ ^[01]$ ]] || { echo 'BLOCK: invalid public rollback option' >&2; exit 1; }
if [[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 1 ]]; then
  # A public rollback may never create its own edge registration or rewrite
  # KAORI App/Website routes. Verify existing Docs public authority first.
  bash "$script_dir/reattach-existing-site.sh" preflight
else
  # Never replace a publicly attached Docs container during private rollback.
  mapfile -t containers < <(docker ps --filter label=com.docker.compose.project="$compose_project" \
    --filter label=com.docker.compose.service=web --format '{{.ID}}')
  if [[ "${#containers[@]}" -eq 1 ]]; then
    attached="$(docker inspect --format '{{if index .NetworkSettings.Networks "edge-public"}}true{{else}}false{{end}}' "${containers[0]}")"
    [[ "$attached" != true ]] || { echo 'BLOCK: public Docs rollback requires explicit public reconciliation' >&2; exit 1; }
  fi
fi
if ! bash "$script_dir/deploy.sh" "$KAORI_DOCS_IMAGE" "$KAORI_DOCS_SOURCE_SHA" "$KAORI_DOCS_VERSION"; then
  if [[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 1 ]]; then
    bash "$script_dir/reattach-existing-site.sh" attach ||
      echo 'CRITICAL: Docs public edge recovery failed during rollback' >&2
  fi
  exit 1
fi
if [[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 1 ]]; then
  bash "$script_dir/reattach-existing-site.sh" attach
fi
echo 'PASS: reviewed Docs rollback completed; public reconciliation applied only when explicitly authorized'
