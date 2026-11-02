#!/usr/bin/env bash
set -Eeuo pipefail

fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 3 ]] || fail 'usage: deploy.sh IMAGE@sha256:<digest> SOURCE_SHA RELEASE_VERSION'
image="$1"; source_sha="$2"; release_version="$3"
[[ "$image" =~ ^[^[:space:]]+@sha256:[a-f0-9]{64}$ ]] || fail 'image must use exact OCI digest'
[[ "$source_sha" =~ ^[a-f0-9]{40}$ ]] || fail 'source SHA must be a 40-character lowercase Git SHA'
[[ "$release_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$ ]] || fail 'release version must be governed SemVer'
# The stable public version is a metadata promotion of an accepted RC image.
# Retain RC as the OCI build version; stable tag/approval is checked upstream.
artifact_version="${KAORI_DOCS_ARTIFACT_VERSION:-$release_version}"
[[ "$artifact_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc\.[1-9][0-9]*$ || "$artifact_version" == "$release_version" ]] ||
    fail 'invalid original immutable image version'
if [[ "$artifact_version" != "$release_version" ]]; then
    [[ "$release_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ &&
       "${artifact_version%-rc.*}" == "$release_version" &&
       "${KAORI_DOCS_STABLE_RELEASE_CONFIRMED:-0}" == 1 &&
       "${KAORI_DOCS_RELEASE_LOCAL_ONLY:-0}" == 1 ]] ||
        fail 'stable identity cannot reuse an unapproved or unrelated RC image'
fi
command -v docker >/dev/null || fail 'Docker is not available'
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
compose_file="${KAORI_DOCS_COMPOSE_FILE:-$script_dir/compose.docs.yml}"
runtime_env="${KAORI_DOCS_RUNTIME_ENV:-production}"
[[ "$runtime_env" == production || "$runtime_env" == staging ]] || fail 'unknown Docs runtime environment'
# One existing Docs deployment root and state directory on ONE VPS.
# Independent environment-scoped receipt FILENAMES (not separate directories)
# protect production rollback from staging mutations.
if [[ "$runtime_env" == staging ]]; then
    [[ "${KAORI_DOCS_STATE_DIR:-}" == /var/lib/kaori-docs/deploy-state ]] ||
        fail 'staging must use the existing canonical Docs state directory'
    [[ "${COMPOSE_PROJECT_NAME:-}" == kaori-docs-staging ]] ||
        fail 'staging must use independent Compose project'
    state_dir=/var/lib/kaori-docs/deploy-state
    receipt_name=release-staging.env
    previous_name=previous-release-staging.env
else
    [[ "${COMPOSE_PROJECT_NAME:-kaori-docs}" == kaori-docs ]] ||
        fail 'production must retain canonical Docs Compose project'
    state_dir="${KAORI_DOCS_STATE_DIR:-/var/lib/kaori-docs/deploy-state}"
    [[ "$state_dir" == /var/lib/kaori-docs/deploy-state ]] ||
        fail 'production must use the existing canonical Docs state directory'
    receipt_name=release.env
    previous_name=previous-release.env
fi
[[ -f "$compose_file" && ! -L "$compose_file" ]] || fail 'compose file missing or symlinked'
[[ -d "$state_dir" && ! -L "$state_dir" && -w "$state_dir" ]] || fail 'docs release state directory must be prepared and writable by deployment identity'
docker info >/dev/null || fail 'Docker daemon unavailable'
compose_args=(-f "$compose_file")
if [[ "${KAORI_DOCS_RELEASE_LOCAL_ONLY:-}" == 1 ]]; then
    if [[ "$runtime_env" == staging ]]; then
        override="$script_dir/compose.staging.yml"
    else
        override="$script_dir/compose.release.yml"
    fi
    [[ -f "$override" && ! -L "$override" ]] || { echo 'BLOCK: missing trusted loopback override' >&2; exit 1; }
    compose_args+=(-f "$override")
fi
[[ "${KAORI_DOCS_RELEASE_LOCAL_ONLY:-}" == 1 ]] || fail 'Docs release deployment requires explicit private loopback mode; public edge is separate authority'
umask 077

# Image pull, metadata validation, and container reconciliation occur without touching KAORI app.
docker pull "$image"
revision="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$image")"
[[ "$revision" == "$source_sha" ]] || fail "OCI revision $revision differs from admitted source $source_sha"
configured_version="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.version"}}' "$image")"
[[ "$configured_version" == "${artifact_version#v}" ]] || fail 'OCI version differs from accepted RC artifact identity'
export KAORI_DOCS_IMAGE="$image"
docker compose "${compose_args[@]}" config --quiet || fail 'Compose validation failed'

candidate="$(mktemp "$state_dir/.release-${runtime_env}-candidate.XXXXXXXX")"
cleanup() { rm -f -- "$candidate"; }
trap cleanup EXIT
printf 'KAORI_DOCS_IMAGE=%s\nKAORI_DOCS_SOURCE_SHA=%s\nKAORI_DOCS_VERSION=%s\nKAORI_DOCS_ARTIFACT_VERSION=%s\n' \
    "$image" "$source_sha" "$release_version" "$artifact_version" > "$candidate"

# Keep the prior immutable identity separate; failed candidate must not advance state.
previous_image=''
if [[ -f "$state_dir/$receipt_name" && ! -L "$state_dir/$receipt_name" ]]; then
    # The release receipt is private to the approved docs deployment identity.
    # shellcheck source=/dev/null
    source "$state_dir/$receipt_name"
    if [[ "${KAORI_DOCS_IMAGE:-}" =~ @sha256:[a-f0-9]{64}$ ]]; then
        previous_image="$KAORI_DOCS_IMAGE"
    fi
fi
export KAORI_DOCS_IMAGE="$image"

if ! docker compose "${compose_args[@]}" up -d --pull never --no-build web || ! bash "$script_dir/verify.sh"; then
    echo 'FAIL: candidate unhealthy; current release receipt is NOT changed' >&2
    if [[ -n "$previous_image" && "$previous_image" != "$image" ]]; then
        echo 'Attempting recovery of last committed docs digest' >&2
        export KAORI_DOCS_IMAGE="$previous_image"
        if docker compose "${compose_args[@]}" up -d --no-build web && bash "$script_dir/verify.sh"; then
            echo 'RECOVERED: previous docs digest is healthy; release receipt unchanged' >&2
        else
            echo 'CRITICAL: previous docs recovery failed; manual intervention required' >&2
        fi
    fi
    fail 'candidate deployment rejected'
fi

if [[ -f "$state_dir/$receipt_name" && ! -L "$state_dir/$receipt_name" ]]; then
    cp -- "$state_dir/$receipt_name" "$state_dir/$previous_name"
fi
mv -- "$candidate" "$state_dir/$receipt_name"
trap - EXIT
printf 'PASS: docs release committed: %s / %s\n' "$release_version" "$source_sha"
printf 'Existing shared-edge Nginx/Certbot publication requires separately approved authority; no public routing changed.\n'
