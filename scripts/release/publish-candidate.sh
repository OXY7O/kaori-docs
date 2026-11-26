#!/usr/bin/env bash
set -Eeuo pipefail

mode="${1:?expected rights, preflight, publish or resume}"
[[ "$mode" == rights || "$mode" == preflight || "$mode" == publish || "$mode" == resume ]] || { echo 'BLOCK: invalid RC operation' >&2; exit 1; }
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
repo="${GITHUB_REPOSITORY:?}"
sha="${ACCEPTED_SHA:?}"
tag="${RC_TAG:-}"
host="${REGISTRY_HOST:-}"
image="${REGISTRY_IMAGE:-}"
api="https://api.github.com/repos/$repo"
headers=(-H "Authorization: Bearer ${GH_TOKEN:?}" -H 'Accept: application/vnd.github+json')
[[ "$repo" == "OXY7O/kaori-docs" ]] || fail 'wrong repository authority'
# Issue #102: staging auto publication is a separate, default-disabled
# quality.yml caller, never an alternate signing engine or host deployment.
# Manual and request-branch release authority remains unchanged.
auto_staging=false
if [[ "$GITHUB_EVENT_NAME" == push && "$GITHUB_REF" == refs/heads/kaori/staging &&
      "${KAORI_DOCS_STAGING_AUTO:-0}" == 1 ]]; then
  [[ "$GITHUB_WORKFLOW_REF" == "$repo/.github/workflows/quality.yml@refs/heads/kaori/staging" &&
     "$GITHUB_SHA" == "$sha" ]] ||
    fail 'automatic RC requires canonical admitted staging workflow identity'
  auto_staging=true
elif [[ "$GITHUB_EVENT_NAME" == workflow_dispatch ]]; then
  [[ "$GITHUB_REF" == refs/heads/kaori/staging ]] ||
    fail 'manual RC must be dispatched from kaori/staging'
elif [[ "$GITHUB_EVENT_NAME" == push ]]; then
  [[ "$GITHUB_REF" == refs/heads/kaori/rc-request &&
     "$GITHUB_SHA" == "$sha" ]] ||
    fail 'RC request must point to the exact accepted staging SHA'
else
  fail 'RC event is neither governed request nor manual dispatch'
fi

# The existing Docs #74 rights authority is independent from Website #4939.
# No repo variable, matching license label or successfully built page alone
# grants permission for recurring public documentation distribution.
verify_recurring_publication_rights() {
  local authority issue comments closed_at count
  authority="$api/issues/74"
  issue="$(curl --fail-with-body -fsS "${headers[@]}" "$authority")" ||
    fail 'Docs #74 standing rights issue unavailable'
  jq -e '.state == "closed" and .state_reason == "completed" and
    (.closed_at | type == "string")' <<< "$issue" >/dev/null ||
    fail 'Docs #74 standing publication rights not accepted'
  closed_at="$(jq -r '.closed_at' <<< "$issue")"
  count="$(jq -r '.comments // -1' <<< "$issue")"
  [[ "$count" =~ ^[0-9]+$ && "$count" -le 100 ]] ||
    fail 'Docs rights comment pagination incomplete'
  comments="$(curl --fail-with-body -fsS "${headers[@]}" "$authority/comments?per_page=100")" ||
    fail 'Docs standing rights evidence unavailable'
  jq -e --arg cutoff "$closed_at" --argjson expected "$count" '
    type == "array" and length == $expected and
    ([.[] | select(
      .user.login == "lethisa" and
      ((.body // "" | split("\n") | index("KAORI_DOCS_PUBLICATION_GO:STANDING")) != null) and
      (.created_at | type == "string") and (.updated_at | type == "string") and
      .created_at <= $cutoff and .updated_at <= $cutoff
    )] | length == 1) and
    ([.[] | select(
      (.user.login == "lethisa" or .user.login == "donibawono") and
      ((.body // "" | split("\n") | index("KAORI_DOCS_PUBLICATION_REVOKED:STANDING")) != null)
    )] | length == 0)
  ' <<< "$comments" >/dev/null ||
    fail 'Docs standing rights missing, modified after acceptance or revoked'
  echo 'PASS: authenticated Docs #74 standing publication rights'
}

if [[ "$mode" == rights ]]; then
  [[ "$auto_staging" == true && "$sha" =~ ^[a-f0-9]{40}$ ]] ||
    fail 'rights mode is available only to canonical staging auto publication'
  verify_recurring_publication_rights
  exit 0
fi
[[ "$(git rev-parse HEAD)" == "$sha" ]] || fail 'source mismatch'
if [[ "$auto_staging" == true ]]; then verify_recurring_publication_rights; fi
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc\.[1-9][0-9]*$ ]] || fail 'candidate must use vX.Y.Z-rc.N'
[[ -n "$host" && "$image" == "$host/"* && "$host" != *://* ]] || fail 'registry variables missing or inconsistent'
[[ "$image" == */kaori-docs ]] || fail 'docs image must use dedicated /kaori-docs repository, never KAORI Application image'
[[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]] || fail 'registry credentials missing'
[[ "${APP_LICENSE:-}" =~ ^[A-Za-z0-9._-]+$ && "$APP_LICENSE" != NOASSERTION ]] || fail 'reviewed SPDX license identifier required'
[[ "${APP_LICENSE:-}" == Apache-2.0 ]] || fail 'KAORI-owned Docs code requires the approved Apache-2.0 SPDX identifier'
[[ -f LICENSE && ! -L LICENSE && -s LICENSE ]] || fail 'approved Apache-2.0 license source file absent'
grep -Fxq 'Apache License' LICENSE || fail 'unrecognized KAORI license authority'
grep -Fxq 'Version 2.0, January 2004' LICENSE || fail 'invalid Apache-2.0 license version'
if [[ "$auto_staging" != true ]]; then
  [[ "${APPROVAL_REF:-}" =~ ^https://github[.]com/OXY7O/kaori-docs/issues/13#issuecomment-([0-9]+)$ ]] || fail 'exact issue #13 approval comment URL required'
  approval_id="${BASH_REMATCH[1]}"
  approval="$(curl -fsS "${headers[@]}" "$api/issues/comments/$approval_id")" || fail 'approval inaccessible'
  [[ "$(jq -r '.issue_url' <<< "$approval")" == "$api/issues/13" ]] || fail 'approval must belong to issue #13'
  grep -Fxq "KAORI_DOCS_RC_APPROVED:$sha:$tag" <<< "$(jq -r '.body // ""' <<< "$approval")" || fail 'approval marker SHA/tag mismatch'
  approval_user="$(jq -r '.user.login // ""' <<< "$approval")"
  [[ "$approval_user" =~ ^[A-Za-z0-9-]+$ ]] || fail 'invalid approval author'
  approval_permission="$(curl -fsS "${headers[@]}" "$api/collaborators/$approval_user/permission" | jq -r '.permission')" || fail 'cannot verify approver authority'
  case "$approval_permission" in admin|maintain|write) ;; *) fail 'approval author lacks write authority' ;; esac
fi

command -v jq >/dev/null && command -v curl >/dev/null && docker info >/dev/null || fail 'runner prerequisites unavailable'
# Fail before any image build/push if registry-manifest tooling is absent.
docker buildx version >/dev/null || fail 'registry manifest inspection requires existing Docker buildx'
current="$(curl -fsS "${headers[@]}" "$api/git/ref/heads/kaori/staging" | jq -r '.object.sha')"
[[ "$current" == "$sha" ]] || fail 'staging source changed'
if [[ "$auto_staging" == true ]]; then
  # The calling quality.yml job needs ALL admission and evidence jobs to
  # succeed. The parent run is deliberately not yet complete while we sign.
  echo 'PASS: canonical staging Full Admission job dependencies succeeded'
else
  runs="$(curl -fsS "${headers[@]}" "$api/actions/workflows/quality.yml/runs?branch=kaori%2Fstaging&event=push&per_page=100")"
  matched="$(jq -c --arg sha "$sha" '[.workflow_runs[] | select(.head_sha==$sha)] | sort_by(.run_number) | last // empty' <<< "$runs")"
  [[ -n "$matched" ]] || fail 'missing Full Admission run for exact staging SHA'
  [[ "$(jq -r '.status' <<< "$matched")" == completed && "$(jq -r '.conclusion' <<< "$matched")" == success ]] || fail 'Full Admission not PASS'
  echo "Full Admission: $(jq -r '.html_url' <<< "$matched")"
fi
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
  if [[ "$auto_staging" == true ]]; then verify_recurring_publication_rights; fi
  docker push "$image:$tag"
else
  [[ "$mode" == resume ]] || fail 'invalid publishing mode'
  [[ "${RESUME_EXISTING:-false}" == true && "${EXPECTED_DIGEST:-}" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'resume requires exact previously committed digest'
fi
docker pull "$image:$tag"
# Registry manifests, not Docker's locally familiarized RepoDigests spelling,
# are authoritative for the digest that was actually pushed/pulled.
# Buildx preserves the multi-platform OCI index digest, including provenance.
manifest_json="$(docker buildx imagetools inspect "$image:$tag" --format '{{json .Manifest}}')" || fail 'registry manifest lookup failed'
digest="$(jq -er '.digest | strings | select(test("^sha256:[a-f0-9]{64}$"))' <<< "$manifest_json")" || fail 'registry manifest digest unavailable'
if [[ "$mode" == resume ]]; then
  [[ "$digest" == "$EXPECTED_DIGEST" ]] || fail 'registry tag digest changed: reject retry'
fi
ref="$image@$digest"
# Pin the content-addressable registry object explicitly before scanning and
# verifying OCI revision/version/license. Never sign an image ID or mutable tag.
docker pull "$ref" || fail 'immutable registry digest is not retrievable'
printf 'PASS: registry manifest digest resolved for Docs image: %s\n' "$digest"
revision="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$ref")"
version="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.version"}}' "$ref")"
license="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.licenses"}}' "$ref")"
source="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.source"}}' "$ref")"
[[ "$revision" == "$sha" && "$version" == "${tag#v}" && "$license" == "$APP_LICENSE" && "$source" == "https://github.com/OXY7O/kaori-docs" ]] || fail 'OCI identity mismatch'
# The static footer must agree with the exact pulled OCI identity before signing.
docker run --rm --network none --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --env EXPECTED_TAG="$tag" --env EXPECTED_SHA="$sha" --entrypoint /bin/sh "$ref" -ec '
    html=/usr/share/nginx/html/index.html
    grep -Fq "Docs build $EXPECTED_TAG" "$html"
    grep -Fq "data-docs-build-version=\"$EXPECTED_TAG\"" "$html"
    grep -Fq "data-docs-build-sha=\"$EXPECTED_SHA\"" "$html"
  ' || fail 'immutable Docs footer identity mismatch'
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v kaori-docs-trivy-cache:/root/.cache/trivy aquasec/trivy:0.74.0 \
  image --cache-dir /root/.cache/trivy --exit-code 1 --ignore-unfixed --scanners vuln --severity HIGH,CRITICAL "$ref"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v kaori-docs-trivy-cache:/root/.cache/trivy -v "$PWD:/workspace" \
  aquasec/trivy:0.74.0 image --cache-dir /root/.cache/trivy \
  --format spdx-json --output /workspace/docs-sbom.spdx.json "$ref"
test -s docs-sbom.spdx.json
# Declare the KAORI-authored source package under the standard SPDX Apache-2.0 ID.
# Preserve third-party package findings and SPDX relationships in the Trivy SBOM.
# Do not re-add the obsolete proprietary LicenseRef or replace upstream licenses.
sbom_tmp="$(mktemp)"
jq '
  .packages = (
    ((.packages // []) | map(select(.SPDXID != "SPDXRef-KAORI-Docs-Source")))
    + [{SPDXID:"SPDXRef-KAORI-Docs-Source",
        name:"kaori-docs-source",
        downloadLocation:"NOASSERTION",
        filesAnalyzed:false,
        licenseConcluded:"Apache-2.0",
        licenseDeclared:"Apache-2.0",
        copyrightText:"Copyright 2026 Lethisa"}]
  )
  | .relationships = (
    ((.relationships // []) | map(select(.relatedSpdxElement != "SPDXRef-KAORI-Docs-Source")))
    + [{spdxElementId:"SPDXRef-DOCUMENT",
        relatedSpdxElement:"SPDXRef-KAORI-Docs-Source",
        relationshipType:"DESCRIBES"}]
  )
  | .hasExtractedLicensingInfos = (
    (.hasExtractedLicensingInfos // [])
    | map(select(.licenseId != "LicenseRef-KAORI-Internal-Use"))
  )
' docs-sbom.spdx.json > "$sbom_tmp"
test -s "$sbom_tmp" || fail 'SPDX Apache-2.0 declaration missing'
mv -- "$sbom_tmp" docs-sbom.spdx.json
jq -e --arg expected "$APP_LICENSE" \
  '.packages | any(.SPDXID == "SPDXRef-KAORI-Docs-Source" and .licenseDeclared == $expected)' \
  docs-sbom.spdx.json >/dev/null || fail 'SPDX project source license unverified'
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
# Release source must still be current after the long-running build/sign process.
latest_sha="$(curl -fsS "${headers[@]}" "$api/git/ref/heads/kaori/staging" | jq -r '.object.sha')"
[[ "$latest_sha" == "$sha" ]] || fail 'staging advanced during candidate publication'
# Git tag/release are registered only after digest, scanning, signature and attestations verify.
if [[ "$auto_staging" == true ]]; then verify_recurring_publication_rights; fi
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
