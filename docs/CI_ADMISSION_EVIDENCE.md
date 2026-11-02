# KAORI Docs admission evidence and Fast Smoke

Authority: [Docs #45](https://github.com/OXY7O/kaori-docs/issues/45),
[KAORI Delivery Workflow](https://github.com/OXY7O/KAORI/blob/main/docs/engineering/KAORI_DELIVERY_WORKFLOW.md),
and the existing Docs [delivery contract](DELIVERY.md).

## Evidence contract

**Current phase: evidence production only. Reuse is NOT active.**

The existing Full Admission, Container Admission, and Browser Quality Evidence
jobs still run on every governed source integration. A new downstream
**Admission Evidence** job executes only if all four required gates report
`success` for the current canonical run. It emits an artifact containing:

- Exact tested source SHA and Git source tree SHA.
- Deterministic SHA-256 validation-authority fingerprint.
- Canonical workflow execution identity and workflow SHA.
- GitHub run ID, attempt, event, source ref, and repository.
- Required gate conclusions and `reuse_authorized: false`.

The authority fingerprint covers existing workflows, scripts, tests,
dependency lock, pinned toolchains, TypeScript/Playwright/Docusaurus
configuration, Dockerfile, Compose and runtime/release controls. It is not a
standalone cache key. An exact source tree and fingerprint are both necessary
for future reuse, but neither proves acceptance, correct run provenance,
completeness, UAT, or release eligibility on its own.

The artifact has 30-day retention and is not uploaded when an admission gate
is failed, cancelled or skipped. Existing npm/BuildKit/Trivy caches are
performance caches only, not PASS evidence.

## Fresh bounded smoke contract

`scripts/ci/fast-smoke.sh <exact-source-SHA>` implements a fresh, bounded
Docusaurus static build and one pinned desktop browser/keyboard/navigation
test. It is intended to run only **after** a future dedicated trusted
artifact-reuse verifier establishes all required source-tree, authority,
workflow/job and promotion-lineage constraints. The script does not grant
reuse or skip any existing Full Admission job.

When a verifier is implemented in a later #45 integration, it must reject
missing, wrong-repository, wrong-workflow, partial, expired, stale, cancelled,
failed, skipped, or modified evidence and use **one fresh Full Admission
fallback** on staging/main. Changed content, browser configuration, security
rules, runtime, or build inputs must not inherit an unrelated green result.

Do not permit release publisher/deployer source authorization from an npm
cache, a browser screenshot artifact, or merely matching commit messages.
Cryptographically signed immutable RC evidence, stable-main acceptance,
Docs-only production deployment, human UAT, and rollback remain independent
hard gates.

## Future activation

A separate reviewed #45 commit must implement and test the full trusted
evidence-reader, strict fingerprint/lineage matching, and fresh Fast Smoke
routing **before any comprehensive test is skipped**. This artifact writer
deliberately sets `reuse_authorized: false` so that its initial staging
admission cannot be mistaken for permission to bypass later tests.
