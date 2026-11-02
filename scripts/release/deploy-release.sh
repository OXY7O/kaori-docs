#!/usr/bin/env bash
set -Eeuo pipefail
mode="${1:?expected preflight or deploy}"
[[ "$mode" == preflight || "$mode" == deploy ]] || { echo 'BLOCK: unsupported operation' >&2; exit 1; }
fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
[[ "$GITHUB_REF" == refs/heads/kaori/staging ]] || fail 'dispatch from staging only'
[[ "$(git rev-parse HEAD)" == "$ACCEPTED_SHA" ]] || fail 'staged source SHA mismatch'
[[ "$RC_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc\.[1-9][0-9]*$ ]] || fail 'invalid prerelease tag'
[[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" =~ ^[01]$ ]] || fail 'public edge option must be 0 or 1'
[[ "$APPROVAL_REF" =~ ^https://github[.]com/OXY7O/kaori-docs/issues/14#issuecomment-([0-9]+)$ ]] || fail 'exact issue #14 approval comment URL required'
approval_id="${BASH_REMATCH[1]}"
[[ "${DOCS_PUBLIC_DOMAIN:-}" == docs.kaori.cloud ]] || fail 'Docs domain variable must be docs.kaori.cloud'
[[ -n "${REGISTRY_HOST:-}" && "$REGISTRY_IMAGE" == "$REGISTRY_HOST/"* ]] || fail 'docs registry variables missing or inconsistent'
[[ "$REGISTRY_IMAGE" == */kaori-docs ]] || fail 'docs image namespace is not dedicated; deployment blocked'
[[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]] || fail 'registry credentials missing'
[[ -n "${DOCS_HOST:-}" && -n "${DOCS_SSH_USER:-}" ]] || fail 'docs deployment host/user missing'
[[ "$DOCS_HOST" =~ ^[a-zA-Z0-9._-]+$ && "$DOCS_SSH_USER" =~ ^[a-zA-Z0-9._-]+$ ]] || fail 'invalid SSH host or username'
port="${DOCS_SSH_PORT:-22}"
[[ "$port" =~ ^[0-9]{1,5}$ ]] && (( port >= 1 && port <= 65535 )) || fail 'invalid SSH port'
[[ "$DOCS_DEPLOY_ROOT" == /opt/kaori-docs ]] || fail 'docs release root must be /opt/kaori-docs'
[[ -n "${DOCS_SSH_KEY:-}" && -n "${DOCS_KNOWN_HOSTS:-}" ]] || fail 'SSH private key/known_hosts missing'
command -v ssh-keygen >/dev/null && command -v ssh >/dev/null && command -v scp >/dev/null || fail 'SSH runner dependencies missing'
api="https://api.github.com/repos/$GITHUB_REPOSITORY"
headers=(-H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/vnd.github+json')
current="$(curl -fsS "${headers[@]}" "$api/git/ref/heads/kaori/staging" | jq -r '.object.sha')"
[[ "$current" == "$ACCEPTED_SHA" ]] || fail 'staging changed since dispatch'
release="$(curl -fsS "${headers[@]}" "$api/releases/tags/$RC_TAG")"
[[ "$(jq -r '.prerelease' <<<"$release")" == true ]] || fail 'candidate is not an intentional prerelease'
[[ "$(jq -r '.target_commitish' <<<"$release")" == "$ACCEPTED_SHA" ]] || fail 'RC release targets different source SHA'
body="$(jq -r '.body // empty' <<<"$release")"
[[ "$body" == *"Staging source SHA: $ACCEPTED_SHA"* ]] || fail 'RC release evidence SHA missing'
digest="$(grep -oE 'Immutable digest: sha256:[a-f0-9]{64}' <<<"$body" | head -n1 | awk '{print $3}')"
[[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'RC release has no immutable digest'
image_ref="$REGISTRY_IMAGE@$digest"
[[ "$body" == *"Deployment authority: $image_ref"* ]] || fail 'RC registry identity does not match Docs configuration'
[[ "$body" == *'Trivy security and signed SBOM/provenance: PASS'* ]] || fail 'RC publication security evidence missing'
approval="$(curl -fsS "${headers[@]}" "$api/issues/comments/$approval_id")" || fail 'approval inaccessible'
[[ "$(jq -r '.issue_url' <<< "$approval")" == "$api/issues/14" ]] || fail 'deployment approval does not belong to issue #14'
grep -Fxq "KAORI_DOCS_DEPLOY_APPROVED:$ACCEPTED_SHA:$RC_TAG:$digest" <<< "$(jq -r '.body // ""' <<< "$approval")" || fail 'deployment approval marker SHA/tag/digest mismatch'
approval_user="$(jq -r '.user.login // ""' <<< "$approval")"
[[ "$approval_user" =~ ^[A-Za-z0-9-]+$ ]] || fail 'invalid approval author'
approval_permission="$(curl -fsS "${headers[@]}" "$api/collaborators/$approval_user/permission" | jq -r '.permission')" || fail 'cannot verify approval authority'
case "$approval_permission" in admin|maintain|write) ;; *) fail 'deployment approver lacks write permission' ;; esac
runs="$(curl -fsS "${headers[@]}" "$api/actions/workflows/quality.yml/runs?branch=kaori%2Fstaging&event=push&per_page=100")"
matched="$(jq -c --arg sha "$ACCEPTED_SHA" '[.workflow_runs[] | select(.head_sha==$sha)] | sort_by(.run_number) | last // empty' <<< "$runs")"
[[ -n "$matched" && "$(jq -r '.status' <<<"$matched")" == completed && "$(jq -r '.conclusion' <<<"$matched")" == success ]] || fail 'exact-staging Full Admission not PASS'
echo "Accepted RC $RC_TAG: source $ACCEPTED_SHA; digest $digest"
if [[ "$mode" == preflight ]]; then
  echo 'PASS: source, immutable prerelease evidence and required credential names are present'
  echo 'PASS: issue #14 deployment approval marker and exact Full Admission verified; no registry access or host mutation performed'
  exit 0
fi
umask 077
# Verify publisher cryptography against the immutable digest, not the mutable RC tag.
command -v docker >/dev/null || fail 'Docker not available on release runner'
docker info >/dev/null || fail 'Docker daemon unavailable'
trust_dir="$(mktemp -d)"
chmod 700 "$trust_dir"
cleanup_trust() { rm -rf -- "$trust_dir"; }
trap cleanup_trust EXIT
printf '%s' "$REGISTRY_PASSWORD" | DOCKER_CONFIG="$trust_dir" docker login "$REGISTRY_HOST" --username "$REGISTRY_USER" --password-stdin >/dev/null
identity="https://github.com/OXY7O/kaori-docs/.github/workflows/publish-staging-image.yml@refs/heads/kaori/staging"
cosign=(docker run --rm --user 0:0 -e DOCKER_CONFIG=/root/.docker -v "$trust_dir:/root/.docker:ro" ghcr.io/sigstore/cosign/cosign:v3.1.3)
"${cosign[@]}" verify --certificate-identity "$identity" --certificate-oidc-issuer https://token.actions.githubusercontent.com "$image_ref" > "$trust_dir/signature-verification.json" || fail 'RC signature verification failed'
test -s "$trust_dir/signature-verification.json" || fail 'RC signature evidence empty'
for kind in spdxjson slsaprovenance1; do
  "${cosign[@]}" verify-attestation --certificate-identity "$identity" --certificate-oidc-issuer https://token.actions.githubusercontent.com --type "$kind" "$image_ref" > "$trust_dir/attestation-$kind.json" || fail "RC $kind attestation verification failed"
  test -s "$trust_dir/attestation-$kind.json" || fail "RC $kind evidence empty"
done
echo 'PASS: immutable signed image, SPDX SBOM and SLSA provenance attestations verified'
cleanup_trust
trap - EXIT

key_file="$(mktemp)"
known_hosts="$(mktemp)"
askpass="$(mktemp)"
agent_started=false
cleanup() {
  if [[ "$agent_started" == true ]]; then ssh-agent -k >/dev/null 2>&1 || true; fi
  rm -f -- "$key_file" "$known_hosts" "$askpass"
}
trap cleanup EXIT INT TERM
printf '%s\n' "$DOCS_SSH_KEY" > "$key_file"
printf '%s\n' "$DOCS_KNOWN_HOSTS" > "$known_hosts"
chmod 600 "$key_file" "$known_hosts"
identity="$DOCS_HOST"
if [[ "$port" != 22 ]]; then identity="[$DOCS_HOST]:$port"; fi
ssh-keygen -F "$identity" -f "$known_hosts" >/dev/null || fail 'configured host key does not match SSH target'
cat > "$askpass" <<'ASKPASS'
#!/usr/bin/env bash
printf '%s\n' "$DOCS_SSH_PASSPHRASE"
ASKPASS
chmod 700 "$askpass"
eval "$(ssh-agent -s)" >/dev/null
agent_started=true
export SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=force DISPLAY=:0
setsid -w ssh-add "$key_file" </dev/null >/dev/null
target="$DOCS_SSH_USER@$DOCS_HOST"
ssh_opts=(-p "$port" -i "$key_file" -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile="$known_hosts")
scp_opts=(-P "$port" -i "$key_file" -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile="$known_hosts")
remote_release="$DOCS_DEPLOY_ROOT/releases/$ACCEPTED_SHA"
{
  printf 'set -Eeuo pipefail\n'
  printf 'deploy_root=%q\nremote_release=%q\n' "$DOCS_DEPLOY_ROOT" "$remote_release"
  cat <<'REMOTE_PREPARE'
[[ -d "$deploy_root" && ! -L "$deploy_root" && -w "$deploy_root" ]] || { echo 'BLOCK: docs root not provisioned' >&2; exit 1; }
mkdir -p -- "$remote_release"
REMOTE_PREPARE
} | ssh "${ssh_opts[@]}" "$target" 'bash -se'
scp "${scp_opts[@]}" -r deploy/server "$target:$remote_release/"
{
  printf 'set -Eeuo pipefail\n'
  printf 'deploy_root=%q\nremote_release=%q\n' "$DOCS_DEPLOY_ROOT" "$remote_release"
  printf 'registry_host=%q\nregistry_user=%q\nregistry_pass=%q\n' "$REGISTRY_HOST" "$REGISTRY_USER" "$REGISTRY_PASSWORD"
  printf 'image_ref=%q\nsource_sha=%q\nrelease_tag=%q\n' "$image_ref" "$ACCEPTED_SHA" "$RC_TAG"
  printf 'attach_existing_edge=%q\n' "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}"
  cat <<'REMOTE_DEPLOY'
docker_config="$(mktemp -d)"
chmod 700 "$docker_config"
cleanup_remote() { rm -rf -- "$docker_config"; }
trap cleanup_remote EXIT
export DOCKER_CONFIG="$docker_config"
printf '%s' "$registry_pass" | docker login "$registry_host" --username "$registry_user" --password-stdin >/dev/null
test -s "$remote_release/server/deploy.sh"
if [[ "$attach_existing_edge" == 1 ]]; then
  test -s "$remote_release/server/reattach-existing-site.sh"
  # Fail before replacing public Docs unless its existing independent edge is
  # approved, healthy, and unambiguous. Never alter other edge registrations.
  bash "$remote_release/server/reattach-existing-site.sh" preflight
else
  existing_web="$(docker ps --filter label=com.docker.compose.project=kaori-docs \
    --filter label=com.docker.compose.service=web --format '{{.ID}}')"
  if [[ -n "$existing_web" ]]; then
    while IFS= read -r existing_id; do
      [[ -n "$existing_id" ]] || continue
      published="$(docker inspect --format '{{if index .NetworkSettings.Networks "edge-public"}}true{{else}}false{{end}}' "$existing_id")"
      [[ "$published" != true ]] || { echo 'BLOCK: public Docs requires explicit edge reconciliation before container replacement' >&2; exit 1; }
    done <<< "$existing_web"
  fi
fi
# The release keeps its private loopback; public reattachment is separate.
export KAORI_DOCS_RELEASE_LOCAL_ONLY=1
if ! bash "$remote_release/server/deploy.sh" "$image_ref" "$source_sha" "$release_tag"; then
  # If the runtime adapter recovered the previous committed digest, reconnect
  # only that Docs frontend; do not mask the original failed deployment.
  if [[ "$attach_existing_edge" == 1 ]]; then
    bash "$remote_release/server/reattach-existing-site.sh" attach ||
      echo 'CRITICAL: Docs rollback public edge reconciliation failed' >&2
  fi
  exit 1
fi
if [[ "$attach_existing_edge" == 1 ]]; then
  # Post-deploy publication failure is independently recoverable; do not change
  # the already committed runtime receipt or restart unrelated applications.
  bash "$remote_release/server/reattach-existing-site.sh" attach
fi
docker logout "$registry_host" >/dev/null 2>&1 || true
REMOTE_DEPLOY
} | ssh "${ssh_opts[@]}" "$target" 'bash -se'
if [[ "${KAORI_DOCS_ATTACH_EXISTING_EDGE:-0}" == 1 ]]; then
  printf 'PASS: accepted Docs digest %s deployed and existing Docs edge reconciled; human visual acceptance PENDING.\\n' "$digest"
else
  printf 'PASS: accepted Docs release candidate %s installed privately at digest %s; no public edge/DNS/TLS changes. Browser UAT and human acceptance still PENDING.\n' "$RC_TAG" "$digest"
fi
