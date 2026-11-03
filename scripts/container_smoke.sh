#!/usr/bin/env bash
set -Eeuo pipefail
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
[[ "${1:-}" =~ ^[a-f0-9]{40}$ ]] || fail 'exact source SHA required'
sha="$1"
[[ "$(git rev-parse HEAD)" == "$sha" ]] || fail 'source SHA mismatch'
command -v docker >/dev/null && docker info >/dev/null || fail 'Docker unavailable'
bash -n scripts/release/publish-candidate.sh
image="kaori-docs-smoke:${sha:0:12}"
docker build --platform linux/amd64 --target production --build-arg APP_BUILD_SHA="$sha" --build-arg APP_VERSION=0.1.0-rc.1 --build-arg APP_BUILD_DATE=2026-01-01T00:00:00Z --build-arg APP_LICENSE=NOASSERTION --tag "$image" .
revision="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$image")"
[[ "$revision" == "$sha" ]] || fail 'image revision mismatch'
docker run --rm --network none --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m --entrypoint /bin/sh "$image" -ec '
    test "$(id -u)" != 0
    nginx -t
    nginx -g "daemon off;" &
    pid="$!"
    trap "kill $pid 2>/dev/null || true" EXIT
    count=0
    until wget -q -O - http://127.0.0.1:8080/healthz | grep -Fxq healthy; do
      count=$((count + 1))
      [ "$count" -lt 20 ] || exit 1
      sleep 1
    done
    wget -q -O - http://127.0.0.1:8080/ | grep -Fq "KAORI Documentation"
  '
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v kaori-docs-trivy-cache:/root/.cache/trivy aquasec/trivy:0.74.0 image --cache-dir /root/.cache/trivy --exit-code 1 --ignore-unfixed --scanners vuln --severity HIGH,CRITICAL "$image"
printf 'PASS: isolated static nonroot Docs runtime verified without host deployment\n'
