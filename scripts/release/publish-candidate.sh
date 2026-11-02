#!/usr/bin/env bash
set -Eeuo pipefail

mode="${1:?expected preflight or publish or resume}"
[[ "$mode" == preflight || "$mode" == publish || "$mode" == resume ]] || { echo 'BLOCK: invalid RC operation' >&2; exit 1; }
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
repo="${GITHUB_REPOSITORY:?}"
sha="${ACCEPTED_SHA:?}"
tag="${RC_TAG:?}"
host="${REGISTRY_HOST:-}"
image="${REGISTRY_IMAGE:-}"
api="https://api.github.com/repos/$repo"
headers=(-H "Authorization: Bearer ${GH_TOKEN:?}" -H 'Accept: application/vnd.github+json')
[[ "$repo" == "OXY7O/kaori-docs" ]] || fail 'wrong repository authority'
[[ "$GITHUB_REF" == refs/heads/kaori/staging ]] || fail 'RC dispatch must use kaori/staging'
[[ "$(git rev-parse HEAD)" == "$sha" ]] || fail 'source mismatch'
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc\.[1-9][0-9]*$ ]] || fail 'candidate must use vX.Y.Z-rc.N'
[[ -n "$host" && "$image" == "$host/"* && "$host" != *://* ]] || fail 'registry variables missing or inconsistent'
[[ "$image" == */kaori-docs ]] || fail 'docs image must use dedicated /kaori-docs repository, never KAORI Application image'
[[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]] || fail 'registry credentials missing'
[[ "${APP_LICENSE:-}" =~ ^[A-Za-z0-9._-]+$ && "$APP_LICENSE" != NOASSERTION ]] || fail 'reviewed SPDX license identifier required'
[[ "${APPROVAL_REF:-}" =~ ^https://github[.]com/OXY7O/kaori-docs/issues/13#issuecomment-([0-9]+)$ ]] || fail 'exact issue #13 approval comment URL required'
approval_id="${BASH_REMATCH[1]}"
approval="$(curl -fsS "${headers[@]}" "$api/issues/comments/$approval_id")" || fail 'approval inaccessible'
[[ "$(jq -r '.issue_url' <<< "$approval")" == "$api/issues/13" ]] || fail 'approval must belong to issue #13'
grep -Fxq "KAORI_DOCS_RC_APPROVED:$sha:$tag" <<< "$(jq -r '.body // ""' <<< "$approval")" || fail 'approval marker SHA/tag mismatch'
approval_user="$(jq -r '.user.login // ""' <<< "$approval")"
[[ "$approval_user" =~ ^[A-Za-z0-9-]+$ ]] || fail 'invalid approval author'
approval_permission="$(curl -fsS "${headers[@]}" "$api/collaborators/$approval_user/permission" | jq -r '.permission')" || fail 'cannot verify approver authority'
case "$approval_permission" in admin|maintain|write) ;; *) fail 'approval author lacks write authority' ;; esac

command -v jq >/dev/null && command -v curl >/dev/null && docker info >/dev/null || fail 'runner prerequisites unavailable'
current="$(curl -fsS "${headers[@]}" "$api/git/ref/heads/kaori/staging" | jq -r '.object.sha')"
[[ "$current" == "$sha" ]] || fail 'staging source changed'
runs="$(curl -fsS "${headers[@]}" "$api/actions/workflows/quality.yml/runs?branch=kaori%2Fstaging&event=push&per_page=100")"
matched="$(jq -c --arg sha "$sha" '[.workflow_runs[] | select(.head_sha==$sha)] | sort_by(.run_number) | last // empty' <<< "$runs")"
[[ -n "$matched" ]] || fail 'missing Full Admission run for exact staging SHA'
[[ "$(jq -r '.status' <<< "$matched")" == completed && "$(jq -r '.conclusion' <<< "$matched")" == success ]] || fail 'Full Admission not PASS'
echo "Full Admission: $(jq -r '.html_url' <<< "$matched")"
if [[ "$mode" == preflight ]]; then
  # Private repositories use an API-authenticated lookup; checkout intentionally does
  # not persist write-capable credentials into Git configuration.
  tag_status="$(curl -sS -o /dev/null -w '%{http_code}' "${headers[@]}" "$api/git/ref/tags/$tag")"
  case "$tag_status" in
    404) ;; # Partial candidate may have a verified registry digest but no Git tag yet.
    200) [[ "${RESUME_EXISTING:-false}" == true ]] || fail 'candidate tag already reserved' ;;
    *) fail "GitHub tag authority check failed (HTTP $tag_status)" ;;
  esac
  if [[ "${RESUME_EXISTING:-false}" == true ]]; then
    [[ "${EXPECTED_DIGEST:-}" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'resume digest invalid'
  fi
  printf 'PASS: RC config and admitted source validated (%s)\n' "$sha"
  exit 0
fi

created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s' "$REGISTRY_PASSWORD" | docker login "$host" --username "$REGISTRY_USER" --password-stdin
if [[ "$mode" == publish ]]; then
  [[ "${RESUME_EXISTING:-false}" != true ]] || fail 'resume cannot build'
  git_status="$(curl -sS -o /dev/null -w '%{http_code}' "${headers[@]}" "$api/git/ref/tags/$tag")"
  [[ "$git_status" == 404 ]] || fail 'Git tag already exists or lookup failed'
  error="$(mktemp)"
  trap 'rm -f "$error"' EXIT
  if docker manifest inspect "$image:$tag" >/dev/null 2>"$error"; then fail 'registry tag exists: rebuilding forbidden'; fi
  grep -Eqi 'manifest unknown|no such manifest|not found' "$error" || fail 'registry lookup inconclusive'
  docker build --platform linux/amd64 --target production \
    --build-arg APP_BUILD_SHA="$sha" --build-arg APP_VERSION="${tag#v}" \
    --build-arg APP_BUILD_DATE="$created" --build-arg APP_LICENSE="$APP_LICENSE" --tag "$image:$tag" .
  docker run --rm --network none --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --entrypoint /bin/sh "$image:$tag" -ec 'test "$(id -u)" != 0; nginx -t; test -s /usr/share/nginx/html/index.html'
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    -v kaori-docs-trivy-cache:/root/.cache/trivy aquasec/trivy:0.74.0 \
    image --cache-dir /root/.cache/trivy --exit-code 1 --ignore-unfixed \
    --scanners vuln --severity HIGH,CRITICAL "$image:$tag"
  docker push "$image:$tag"
else
  [[ "$mode" == resume ]] || fail 'invalid publishing mode'
  [[ "${RESUME_EXISTING:-false}" == true && "${EXPECTED_DIGEST:-}" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'resume requires exact previously committed digest'
fi
docker pull "$image:$tag"
qualified="$(docker image inspect --format '{{index .RepoDigests 0}}' "$image:$tag")"
digest="${qualified#*@}"
[[ "$qualified" == "$image@$digest" && "$digest" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'qualified image digest unavailable'
if [[ "$mode" == resume ]]; then
  [[ "$digest" == "$EXPECTED_DIGEST" ]] || fail 'registry tag digest changed: reject retry'
fi
ref="$image@$digest"
revision="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$ref")"
version="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.version"}}' "$ref")"
license="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.licenses"}}' "$ref")"
source="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.source"}}' "$ref")"
[[ "$revision" == "$sha" && "$version" == "${tag#v}" && "$license" == "$APP_LICENSE" && "$source" == "https://github.com/OXY7O/kaori-docs" ]] || fail 'OCI identity mismatch'
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v kaori-docs-trivy-cache:/root/.cache/trivy aquasec/trivy:0.74.0 \
  image --cache-dir /root/.cache/trivy --exit-code 1 --ignore-unfixed --scanners vuln --severity HIGH,CRITICAL "$ref"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v kaori-docs-trivy-cache:/root/.cache/trivy -v "$PWD:/workspace" \
  aquasec/trivy:0.74.0 image --cache-dir /root/.cache/trivy \
  --format spdx-json --output /workspace/docs-sbom.spdx.json "$ref"
test -s docs-sbom.spdx.json
jq -n --arg src "$repo" --arg source_sha "$sha" --arg run "$GITHUB_RUN_ID" \
  '{buildDefinition:{buildType:"https://slsa.dev/provenance/v1",
     resolvedDependencies:[{uri:("https://github.com/"+$src),digest:{gitCommit:$source_sha}}]},
    runDetails:{builder:{id:("https://github.com/"+$src+"/actions/runs/"+$run)},
      metadata:{invocationId:$run}}}' > docs-provenance.json
identity="https://github.com/$GITHUB_WORKFLOW_REF"
# Sign the immutable image itself before independently attesting its evidence.
docker run --rm --user 0:0 \
  -e ACTIONS_ID_TOKEN_REQUEST_TOKEN -e ACTIONS_ID_TOKEN_REQUEST_URL \
  -e DOCKER_CONFIG=/root/.docker \
  -v "$HOME/.docker:/root/.docker:ro" \
  ghcr.io/sigstore/cosign/cosign:v3.1.3 sign --yes "$ref"
# Registry OCI referrers may propagate after sign returns. Preserve every trust
# requirement; retry only the mandatory cryptographic verification, never skip it.
signature_verified=false
for attempt in $(seq 1 8); do
  if docker run --rm --user 0:0 -e DOCKER_CONFIG=/root/.docker \
    -v "$HOME/.docker:/root/.docker:ro" \
    ghcr.io/sigstore/cosign/cosign:v3.1.3 verify \
    --certificate-identity "$identity" \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com "$ref" > docs-signature-verification.json; then
    signature_verified=true
    break
  fi
  printf 'Signature not yet verifiable (attempt %s/8); preserving fail-closed policy\n' "$attempt" >&2
  if (( attempt < 8 )); then sleep 15; fi
done
[[ "$signature_verified" == true ]] || fail 'mandatory signature verification exhausted bounded registry retries'
test -s docs-signature-verification.json
for entry in 'docs-sbom.spdx.json:spdxjson' 'docs-provenance.json:slsaprovenance1'; do
  predicate="${entry%%:*}"
  kind="${entry#*:}"
  docker run --rm --user 0:0 \
    -e ACTIONS_ID_TOKEN_REQUEST_TOKEN -e ACTIONS_ID_TOKEN_REQUEST_URL \
    -e DOCKER_CONFIG=/root/.docker \
    -v "$HOME/.docker:/root/.docker:ro" -v "$PWD:/workspace:ro" \
    ghcr.io/sigstore/cosign/cosign:v3.1.3 attest --yes \
    --predicate "/workspace/$predicate" --type "$kind" "$ref"
done
for kind in spdxjson slsaprovenance1; do
  attestation_verified=false
  for attempt in $(seq 1 8); do
    if docker run --rm --user 0:0 -e DOCKER_CONFIG=/root/.docker \
      -v "$HOME/.docker:/root/.docker:ro" \
      ghcr.io/sigstore/cosign/cosign:v3.1.3 verify-attestation \
      --certificate-identity "$identity" \
      --certificate-oidc-issuer https://token.actions.githubusercontent.com \
      --type "$kind" "$ref" > "verification-$kind.json"; then
      attestation_verified=true
      break
    fi
    printf 'Attestation %s not yet verifiable (attempt %s/8)\n' "$kind" "$attempt" >&2
    if (( attempt < 8 )); then sleep 15; fi
  done
  [[ "$attestation_verified" == true ]] || fail "mandatory $kind attestation verification exhausted bounded registry retries"
  test -s "verification-$kind.json"
done
sbom_sha="sha256:$(sha256sum docs-sbom.spdx.json | awk '{print $1}')"
# Git tag/release are registered only after digest, scanning, signature and attestations verify.
tag_status="$(curl -sS -o /dev/null -w '%{http_code}' "${headers[@]}" "$api/git/ref/tags/$tag")"
case "$tag_status" in
  404)
    jq -nc --arg ref "refs/tags/$tag" --arg object "$sha" '{ref:$ref,sha:$object}' | curl -fsS "${headers[@]}" -H 'Content-Type: application/json' -X POST --data-binary @- "$api/git/refs" >/dev/null ;;
  200)
    [[ "$mode" == resume ]] || fail 'unexpected existing tag'
    tag_sha="$(curl -fsS "${headers[@]}" "$api/git/ref/tags/$tag" | jq -r '.object.sha')"
    [[ "$tag_sha" == "$sha" ]] || fail 'existing Git tag points to different source' ;;
  *) fail 'Git tag lookup failed' ;;
esac
release_status="$(curl -sS -o /dev/null -w '%{http_code}' "${headers[@]}" "$api/releases/tags/$tag")"
case "$release_status" in
  404) ;;
  200)
    [[ "$mode" == resume ]] || fail 'release unexpectedly exists'
    existing="$(curl -fsS "${headers[@]}" "$api/releases/tags/$tag")"
    [[ "$(jq -r '.target_commitish' <<< "$existing")" == "$sha" && "$(jq -r '.prerelease' <<< "$existing")" == true ]] || fail 'existing release source mismatch'
    grep -Fq "$digest" <<< "$(jq -r '.body // ""' <<< "$existing")" || fail 'existing release digest mismatch'
    printf 'PASS: resumed identical candidate at %s\n' "$ref"
    exit 0 ;;
  *) fail 'release metadata state unknown' ;;
esac

jq -n --arg tag "$tag" --arg sha "$sha" --arg digest "$digest" \
  --arg image "$ref" --arg sbom "$sbom_sha" \
  '{tag_name:$tag,target_commitish:$sha,name:("KAORI Docs "+$tag),
    body:("Docs artifact only; no KAORI Application version applicability asserted.\nStaging source SHA: "+$sha+"\nImmutable digest: "+$digest+
    "\nDeployment authority: "+$image+"\nSPDX SBOM SHA256: "+$sbom+
    "\nTrivy security and signed SBOM/provenance: PASS\nRelease verification: PENDING; human acceptance required."),
    draft:false,prerelease:true,make_latest:"false"}' |
  curl -fsS "${headers[@]}" -H 'Content-Type: application/json' \
    -X POST --data-binary @- "$api/releases" >/dev/null
printf 'PASS: candidate %s built from %s and published at %s; release verification pending\n' "$tag" "$sha" "$ref"
