#!/usr/bin/env bash
set -Eeuo pipefail

mode="${1:?expected preflight or publish}"
[[ "$mode" == preflight || "$mode" == publish ]] || { echo 'BLOCK: unsupported stable operation' >&2; exit 1; }
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }

# Docs #39: stable publication is a metadata/identity promotion of an
# already signed, admitted, and human-accepted RC. Never rebuild application bits.
for required in GH_TOKEN GITHUB_REF GITHUB_SHA GITHUB_REPOSITORY STABLE_TAG ACCEPTED_RC_TAG APPROVAL_REF REGISTRY_HOST REGISTRY_IMAGE; do
  [[ -n "$(printenv "$required" || true)" ]] || fail "missing $required"
done
[[ "$GITHUB_REF" == refs/heads/main && "$GITHUB_REPOSITORY" == OXY7O/kaori-docs ]] ||
  fail 'stable publisher must execute on canonical Docs main'
[[ "$GITHUB_EVENT_NAME" == workflow_dispatch ]] || fail 'stable publication is intentional manual approval only'
[[ "$STABLE_TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] ||
  fail 'stable tag must be strict SemVer vX.Y.Z'
[[ "$ACCEPTED_RC_TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-rc\.[1-9][0-9]*$ &&
   "${ACCEPTED_RC_TAG%-rc.*}" == "$STABLE_TAG" ]] ||
  fail 'RC version and stable version differ'
[[ "$REGISTRY_IMAGE" == docker.io/lethisaputri/kaori-docs && "$REGISTRY_HOST" == docker.io ]] ||
  fail 'stable release registry authority differs from approved dedicated Docs image'
[[ "$APPROVAL_REF" =~ ^https://github[.]com/OXY7O/kaori-docs/issues/39#issuecomment-([0-9]+)$ ]] ||
  fail 'exact issue #39 stable approval comment required'
approval_id="${BASH_REMATCH[1]}"
[[ "$(git rev-parse HEAD)" == "$GITHUB_SHA" ]] || fail 'main checkout does not match release SHA'

api="https://api.github.com/repos/$GITHUB_REPOSITORY"
headers=(-H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')
api_get() { curl --fail-with-body -fsS "${headers[@]}" "$1"; }
api_status() { curl -sS -o /dev/null -w '%{http_code}' "${headers[@]}" "$1"; }
current_main="$(api_get "$api/git/ref/heads/main" | jq -r '.object.sha')"
[[ "$current_main" == "$GITHUB_SHA" ]] || fail 'main source changed after dispatch'
rc="$(api_get "$api/releases/tags/$ACCEPTED_RC_TAG")" || fail 'accepted RC release unavailable'
[[ "$(jq -r '.prerelease' <<< "$rc")" == true && "$(jq -r '.draft' <<< "$rc")" == false ]] ||
  fail 'accepted RC is not a finalized prerelease'
rc_sha="$(jq -r '.target_commitish' <<< "$rc")"
[[ "$rc_sha" =~ ^[a-f0-9]{40}$ ]] || fail 'invalid RC source SHA'
rc_ref="$(api_get "$api/git/ref/tags/$ACCEPTED_RC_TAG" | jq -r '.object.sha')"
[[ "$rc_ref" == "$rc_sha" ]] || fail 'RC tag source does not match signed release'
git merge-base --is-ancestor "$rc_sha" "$GITHUB_SHA" ||
  fail 'RC source must be an ancestor of accepted main promotion'
# A promotion may change release documentation or delivery policy but not the
# Docusaurus image source, its dependency inputs or actual host runtime bits.
for path in Dockerfile .dockerignore package.json package-lock.json docusaurus.config.ts docusaurus.config.js sidebars.ts tsconfig.json src static content deploy/server; do
  git diff --quiet "$rc_sha" "$GITHUB_SHA" -- "$path" ||
    fail "source or runtime drift since accepted RC: $path"
done
body="$(jq -r '.body // ""' <<< "$rc")"
[[ "$body" == *"Staging source SHA: $rc_sha"* ]] || fail 'RC source evidence missing'
digest="$(grep -oE 'Immutable digest: sha256:[a-f0-9]{64}' <<< "$body" | head -1 | awk '{print $3}')"
[[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'immutable RC digest missing'
image_ref="$REGISTRY_IMAGE@$digest"
[[ "$body" == *"Deployment authority: $image_ref"* &&
   "$body" == *'Trivy security and signed SBOM/provenance: PASS'* ]] ||
  fail 'RC is missing signed image/source security evidence'

approval="$(api_get "$api/issues/comments/$approval_id")" || fail 'stable approval unavailable'
[[ "$(jq -r '.issue_url' <<< "$approval")" == "$api/issues/39" ]] ||
  fail 'stable approval is not issue #39 authority'
grep -Fxq "KAORI_DOCS_STABLE_APPROVED:$GITHUB_SHA:$ACCEPTED_RC_TAG:$STABLE_TAG:$digest" <<< "$(jq -r '.body // ""' <<< "$approval")" ||
  fail 'human acceptance marker main/RC/stable/digest mismatch'
author="$(jq -r '.user.login // ""' <<< "$approval")"
[[ "$author" =~ ^[A-Za-z0-9-]+$ ]] || fail 'invalid approval author'
permission="$(api_get "$api/collaborators/$author/permission" | jq -r '.permission')"
case "$permission" in admin|maintain|write) ;; *) fail 'approver has no repository write authority' ;; esac

for endpoint in "$api/git/ref/tags/$STABLE_TAG" "$api/releases/tags/$STABLE_TAG"; do
  [[ "$(api_status "$endpoint")" == 404 ]] ||
    fail 'stable tag/release exists or status lookup was not definitively 404'
done

echo "PASS: approved main=$GITHUB_SHA stable=$STABLE_TAG RC=$ACCEPTED_RC_TAG digest=$digest; no rebuild"
if [[ "$mode" == preflight ]]; then
  echo 'PASS: main lineage, unchanged image inputs, exact approval and release uniqueness; no mutation'
  exit 0
fi

# Independently validate the same signed RC subject before publishing stable
# metadata. Never sign a freshly built stable image.
[[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]] ||
  fail 'registry verification credentials missing'
command -v docker >/dev/null || fail 'Docker required for cryptographic verification'
docker info >/dev/null || fail 'Docker runner unavailable'
umask 077
trust_dir="$(mktemp -d)"
trap 'rm -rf -- "$trust_dir"' EXIT
printf '%s' "$REGISTRY_PASSWORD" | DOCKER_CONFIG="$trust_dir" docker login "$REGISTRY_HOST"   --username "$REGISTRY_USER" --password-stdin >/dev/null
identity="https://github.com/OXY7O/kaori-docs/.github/workflows/publish-staging-image.yml@refs/heads/kaori/staging"
cosign=(docker run --rm --user 0:0 -e DOCKER_CONFIG=/root/.docker -v "$trust_dir:/root/.docker:ro" ghcr.io/sigstore/cosign/cosign:v3.1.3)
"${cosign[@]}" verify --certificate-identity "$identity"   --certificate-oidc-issuer https://token.actions.githubusercontent.com "$image_ref" > "$trust_dir/rc-signature.json" ||
  fail 'accepted RC image signature failed'
for attestation in spdxjson slsaprovenance1; do
  "${cosign[@]}" verify-attestation --type "$attestation"     --certificate-identity "$identity"     --certificate-oidc-issuer https://token.actions.githubusercontent.com "$image_ref" > "$trust_dir/$attestation.json" ||
    fail "accepted RC $attestation attestation failed"
done
echo 'PASS: accepted immutable RC image, SPDX and SLSA cryptography reverified'

stable_body="$(jq -n --arg tag "$STABLE_TAG" --arg main "$GITHUB_SHA"   --arg rc "$ACCEPTED_RC_TAG" --arg rcsha "$rc_sha" --arg digest "$digest"   --arg image "$image_ref" --arg acceptance "$APPROVAL_REF" '
  ["KAORI Docs stable artifact: " + $tag,
   "Accepted RC: " + $rc,
   "Accepted RC source SHA: " + $rcsha,
   "Stable main source SHA: " + $main,
   "Immutable digest: " + $digest,
   "Deployment authority: " + $image,
   "Cosign image signature + SPDX/SLSA verification: PASS",
   "Human acceptance authority: " + $acceptance,
   "No image rebuild or retag was performed; production host deployment requires a separate governed action."] | join("\n")')"
payload="$(jq -n --arg tag "$STABLE_TAG" --arg sha "$GITHUB_SHA" --arg body "$stable_body"   '{tag_name:$tag,target_commitish:$sha,name:("KAORI Docs "+$tag),body:$body,draft:false,prerelease:false,make_latest:"true"}')"
published="$(curl --fail-with-body -fsS "${headers[@]}" -H 'Content-Type: application/json'   -X POST --data "$payload" "$api/releases")" ||
  fail 'stable release creation failed; inspect whether API partially created a tag before retry'
[[ "$(jq -r '.tag_name' <<< "$published")" == "$STABLE_TAG" &&
   "$(jq -r '.prerelease' <<< "$published")" == false ]] ||
  fail 'unexpected stable release response'
stable_sha="$(api_get "$api/git/ref/tags/$STABLE_TAG" | jq -r '.object.sha')"
[[ "$stable_sha" == "$GITHUB_SHA" ]] || fail 'stable tag was not created on exact main source'
echo "PASS: stable $STABLE_TAG published from main=$GITHUB_SHA using signed RC digest=$digest (no host mutation)"
