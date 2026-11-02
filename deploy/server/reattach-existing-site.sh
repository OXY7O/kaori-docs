#!/usr/bin/env bash
set -Eeuo pipefail

mode="${1:-}"
[[ "$mode" == preflight || "$mode" == attach ]] || {
    echo 'BLOCK: expected preflight or attach' >&2
    exit 1
}
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }

# Issue #32: reconcile only an independently published Docs site (#4196).
# This is not an alternative Nginx/Certbot/DNS publisher.
edge_root=/opt/shared-edge
site="$edge_root/config/sites/kaori-docs.env"
[[ -f "$site" && ! -L "$site" && -r "$site" ]] ||
    fail 'reviewed Docs shared-edge registration is absent or unreadable'

required=(
    'EDGE_DOMAIN=docs.kaori.cloud'
    'EDGE_UPSTREAM=kaori-docs-web'
    'EDGE_UPSTREAM_PORT=8080'
    'EDGE_HEALTH_PATH=/healthz'
    'EDGE_TLS=true'
    'EDGE_WEBSOCKET=false'
    'EDGE_CLIENT_MAX_BODY_SIZE=25m'
)
[[ "$(wc -l < "$site")" -eq "${#required[@]}" ]] ||
    fail 'Docs shared-edge registration includes unexpected fields'
for field in "${required[@]}"; do
    [[ "$(grep -Fxc "$field" "$site" || true)" -eq 1 ]] ||
        fail 'Docs shared-edge registration differs from approved host/domain contract'
done

docker network inspect edge-public >/dev/null 2>&1 ||
    fail 'standalone edge-public network not present'
[[ -f "$edge_root/runtime/verify.sh" && ! -L "$edge_root/runtime/verify.sh" && -r "$edge_root/runtime/verify.sh" ]] ||
    fail 'standalone shared-edge verifier is not installed'
command -v curl >/dev/null || fail 'curl is required for public readiness'

mapfile -t containers < <(
    docker ps --filter label=com.docker.compose.project=kaori-docs \
        --filter label=com.docker.compose.service=web --format '{{.ID}}'
)
[[ "${#containers[@]}" -eq 1 ]] || fail 'expected exactly one Docs frontend'
container="${containers[0]}"
health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' "$container")"
[[ "$health" == healthy ]] || fail "Docs frontend unhealthy: $health"

if [[ "$mode" == preflight ]]; then
    # Existing registration must work prior to replacing the public frontend.
    attached="$(docker inspect --format '{{if index .NetworkSettings.Networks "edge-public"}}true{{else}}false{{end}}' "$container")"
    [[ "$attached" == true ]] || fail 'current Docs frontend is not attached to public edge'
    aliases="$(docker inspect --format '{{json (index .NetworkSettings.Networks "edge-public").Aliases}}' "$container")"
    [[ "$aliases" == *'"kaori-docs-web"'* ]] || fail 'existing Docs frontend has unexpected edge alias'
    [[ "$(curl -fsS --max-time 10 https://docs.kaori.cloud/healthz)" == healthy ]] ||
        fail 'existing public Docs HTTPS health is not ready'
    printf 'PASS: existing Docs-only published registration and HTTPS readiness verified\n'
    exit 0
fi

# Reattaching after a successful release may only expose the already committed
# immutable digest. Never attach a still-uncommitted candidate or another app.
receipt=/var/lib/kaori-docs/deploy-state/release.env
[[ -f "$receipt" && ! -L "$receipt" && -r "$receipt" ]] ||
    fail 'committed Docs release receipt missing'
mapfile -t images < <(grep '^KAORI_DOCS_IMAGE=' "$receipt" || true)
[[ "${#images[@]}" -eq 1 ]] || fail 'invalid Docs release receipt'
expected_image="${images[0]#KAORI_DOCS_IMAGE=}"
[[ "$expected_image" =~ ^docker[.]io/[A-Za-z0-9._-]+/kaori-docs@sha256:[a-f0-9]{64}$ ]] ||
    fail 'receipt is not a dedicated immutable Docs image'
actual_image="$(docker inspect --format '{{.Config.Image}}' "$container")"
[[ "$actual_image" == "$expected_image" ]] ||
    fail 'healthy Docs frontend does not match committed release digest'

attached="$(docker inspect --format '{{if index .NetworkSettings.Networks "edge-public"}}true{{else}}false{{end}}' "$container")"
if [[ "$attached" == true ]]; then
    aliases="$(docker inspect --format '{{json (index .NetworkSettings.Networks "edge-public").Aliases}}' "$container")"
    [[ "$aliases" == *'"kaori-docs-web"'* ]] ||
        fail 'Docs container already attached with conflicting edge alias'
else
    docker network connect --alias kaori-docs-web edge-public "$container" ||
        fail 'Docs-only edge-public reattachment failed'
fi

ready=false
for attempt in $(seq 1 20); do
    if [[ "$(curl -fsS --max-time 7 https://docs.kaori.cloud/healthz 2>/dev/null || true)" == healthy ]]; then
        ready=true
        break
    fi
    sleep 3
done
[[ "$ready" == true ]] ||
    fail 'Docs public HTTPS not ready after reattachment; use existing edge recovery authority'

# Verify every registered site, cert SAN/HSTS and unknown Host/SNI using the
# canonical edge owner. Normal release reconciliation does not renew certificates.
bash "$edge_root/runtime/verify.sh" --wait-seconds 120 ||
    fail 'shared-edge regression verification failed; Docs release receipt remains committed'
printf 'PASS: committed Docs digest reattached; docs.kaori.cloud and all existing shared-edge sites verified\n'
