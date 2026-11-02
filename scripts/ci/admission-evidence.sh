#!/usr/bin/env bash
# Issue #45: durable admission identity emitted only after all canonical gates PASS.
# Reuse is NOT authorized by this writer; a separate trusted consumer must
# validate the artifact, source tree, workflow identity and fresh smoke.
set -Eeuo pipefail

fail() { printf 'BLOCK: %s\n' "$*" >&2; exit 1; }
[[ "${1:-}" == write && "$#" == 2 ]] || fail 'usage: admission-evidence.sh write <output.json>'
output="$2"
[[ "${KAORI_DOCS_SOURCE_SHA:-}" =~ ^[a-f0-9]{40}$ ]] || fail 'exact source SHA missing'
[[ "$(git rev-parse HEAD)" == "$KAORI_DOCS_SOURCE_SHA" ]] || fail 'checkout differs from requested source'
[[ "${GITHUB_REPOSITORY:-}" == OXY7O/kaori-docs ]] || fail 'untrusted repository'
[[ "${GITHUB_RUN_ID:-}" =~ ^[1-9][0-9]*$ ]] || fail 'invalid run ID'
[[ "${GITHUB_RUN_ATTEMPT:-}" =~ ^[1-9][0-9]*$ ]] || fail 'invalid run attempt'
[[ "${GITHUB_WORKFLOW_SHA:-}" =~ ^[a-f0-9]{40}$ ]] || fail 'workflow execution SHA missing'
[[ "${GITHUB_WORKFLOW_REF:-}" == OXY7O/kaori-docs/.github/workflows/quality.yml@* ]] ||
  fail 'workflow identity must be canonical Full Admission'
case "${GITHUB_EVENT_NAME:-}" in
  push|pull_request|workflow_dispatch) ;;
  *) fail 'unsupported admission event' ;;
esac
if [[ "$GITHUB_EVENT_NAME" == pull_request ]]; then
  [[ "${GITHUB_HEAD_REF:-}" == kaori/staging &&
     "${GITHUB_BASE_REF:-}" == main &&
     "${ADMISSION_HEAD_REPO:-}" == OXY7O/kaori-docs ]] ||
    fail 'only same-repository staging-to-main promotion PR is admissible'
else
  [[ "${GITHUB_REF:-}" == refs/heads/main ||
     "${GITHUB_REF:-}" == refs/heads/kaori/staging ]] ||
    fail 'only approved long-lived refs may emit evidence'
fi
for gate in PROMOTION FULL CONTAINER BROWSER; do
  var="ADMISSION_${gate}"
  [[ "${!var:-}" == success ]] || fail "gate $gate did not report success"
done
profile="${ADMISSION_PROFILE:-full}"
[[ "$profile" == full || "$profile" == reused ]] ||
  fail 'admission profile must be full or independently verified reused'
reuse_authorized=false
reused_from="${ADMISSION_REUSED_FROM:-}"
if [[ "$profile" == full ]]; then
  [[ -z "$reused_from" ]] || fail 'full evidence may not inherit reused source'
  reuse_authorized=true
else
  [[ "$reused_from" =~ ^[1-9][0-9]*$ ]] ||
    fail 'reused profile requires a verified prior full run and fresh browser smoke'
fi
created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

tree="$(git rev-parse HEAD^{tree})"
[[ "$tree" =~ ^[a-f0-9]{40}$ ]] || fail 'invalid source tree SHA'
# Include every file that can affect the admission toolchain and validation
# contract. The whole tree is separately bound; this fingerprint MUST NOT be
# used as permission to reuse evidence for a different source tree.
authority_paths=(
  .github/workflows .github/ci scripts tests
  package.json package-lock.json .npmrc .nvmrc
  .prettierrc.json .prettierignore
  playwright.config.ts docusaurus.config.ts
  tsconfig.json sidebars.ts Dockerfile .dockerignore
  deploy/server compose.dev.yml
)
authority_listing="$(git ls-tree -r HEAD -- "${authority_paths[@]}" | LC_ALL=C sort)"
[[ -n "$authority_listing" ]] || fail 'validation authority inventory empty'
fingerprint="$(
  { printf '%s\n' 'KAORI_DOCS_ADMISSION_AUTHORITY_V1'
    printf '%s\n' "$authority_listing"; } | sha256sum | awk '{print $1}'
)"
[[ "$fingerprint" =~ ^[a-f0-9]{64}$ ]] || fail 'invalid validation fingerprint'

# Reject pre-existing evidence path, symlinks and output outside current
# checked-out workspace. An immutable artifact is published from this file.
[[ "$output" != /* && "$output" != *../* && ! -e "$output" ]] ||
  fail 'evidence path must be a new relative path'
mkdir -p -- "$(dirname -- "$output")"
jq -n \
  --arg source "$KAORI_DOCS_SOURCE_SHA" \
  --arg tree "$tree" \
  --arg fingerprint "$fingerprint" \
  --arg run "$GITHUB_RUN_ID" \
  --arg attempt "$GITHUB_RUN_ATTEMPT" \
  --arg workflow "$GITHUB_WORKFLOW_REF" \
  --arg workflow_sha "$GITHUB_WORKFLOW_SHA" \
  --arg event "$GITHUB_EVENT_NAME" \
  --arg ref "$GITHUB_REF" \
  --arg profile "$profile" \
  --arg reused_from "$reused_from" \
  --arg created_at "$created_at" \
  --argjson reusable "$reuse_authorized" \
  '{
    schema_version: 2,
    profile: $profile,
    created_at: $created_at,
    reused_from_full_run: (if $reused_from == "" then null else ($reused_from|tonumber) end),
    repository: "OXY7O/kaori-docs",
    canonical_workflow: ".github/workflows/quality.yml",
    source_sha: $source,
    source_tree_sha: $tree,
    validation_authority_fingerprint: ("sha256:" + $fingerprint),
    evidence_run_id: ($run|tonumber),
    evidence_attempt: ($attempt|tonumber),
    executed_workflow_ref: $workflow,
    executed_workflow_sha: $workflow_sha,
    source_event: $event,
    source_ref: $ref,
    mandatory_gate_conclusions: {
      "Promotion Policy": "success",
      "Full Admission": "success",
      "Container Admission": "success",
      "Browser Quality Evidence": "success"
    },
    reuse_authorized: $reusable
  }' > "$output"
jq -e '.schema_version == 2 and
  (.profile == "full" or .profile == "reused") and
  ((.profile == "full" and .reuse_authorized == true and .reused_from_full_run == null)
    or (.profile == "reused" and .reuse_authorized == false and
      (.reused_from_full_run|type) == "number")) and
  (.source_tree_sha | test("^[a-f0-9]{40}$")) and
  (.validation_authority_fingerprint | test("^sha256:[a-f0-9]{64}$"))' "$output" >/dev/null ||
  fail 'invalid admission evidence serialization'
echo "PASS: immutable Docs admission identity written for source=$KAORI_DOCS_SOURCE_SHA tree=$tree fingerprint=sha256:$fingerprint (profile=$profile, reusable=$reuse_authorized)"
