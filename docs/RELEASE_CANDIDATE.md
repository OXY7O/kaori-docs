# Immutable KAORI Docs release candidates

**Authority:** Issue #13 owns the manual Release Candidate publisher. Issue #10 governs credentials and trust; #12 owns exact-staging Full Admission, and #14 owns deployment and rollback.

## Runtime contract

The multi-stage Dockerfile builds Docusaurus using locked Node 22 dependencies, then serves static assets from the existing Website-approved digest-pinned unprivileged Nginx runtime on internal port 8080. Internal engineering docs are excluded from the image. The staging Container Admission runs the shared-style scripts/container_smoke.sh check for non-root, read-only runtime, Nginx, /healthz, root page and Trivy HIGH/CRITICAL. It does not deploy a server.

## Manual release authority

The canonical Release Candidate workflow is .github/workflows/publish-staging-image.yml. It is manual-only and must run against kaori/staging at an exact SHA with a completed-success Full Admission run. Complete the repository-specific Variables/Secrets and registry robot-scope checks in #10 before dispatch. The image repository must end with /kaori-docs.

Provide a permanent GitHub comment URL as approval_reference. That comment must belong to issue #13 and include a complete approval marker line of the form:

    KAORI_DOCS_RC_APPROVED:<40-character-staging-sha>:<vX.Y.Z-rc.N>

The publisher verifies the exact marker and the comment author's repository write, maintain or admin permission. The candidate_tag and reviewed SPDX license_identifier are required; NOASSERTION is rejected. An inaccessible or unrelated approval fails closed. This approval is for publishing an RC only, not UAT, VPS changes or stable promotion.

A candidate is built once and uses immutable OCI SHA256 digest, checked source/revision/version/created/title/description/documentation/license metadata, offline runtime smoke, Trivy HIGH/CRITICAL scan, SPDX SBOM, source/run-linked provenance and cosign keyless digest signatures plus SBOM/provenance attestations. Signature and attestation verification must complete before Git tag and prerelease metadata creation. All identities are separate from KAORI Application version routing.

## Recovery without mutation

If an earlier attempt already pushed the candidate but was interrupted, use resume_existing=true with the exact previously evidenced expected_digest. The workflow pulls rather than rebuilds, refuses a changed digest, checks OCI labels and reruns scan/signature/attestation verification. A mismatched Git tag or prerelease is rejected. Never overwrite or silently republish an existing candidate.

## Default-branch dispatch limitation

GitHub generally requires workflow_dispatch workflows to exist on the default branch. Current Docs main promotion is separately governed. Do not push this workflow directly to main or invent a bypass. A missing Run Workflow button means activation is blocked until an accepted promotion or separately reviewed dispatch adapter is available.

## Evidence boundary

A source CI PASS is not registry authentication, signed publication, deployment or UAT. Issue #14 may only consume an explicitly accepted immutable digest. Public DNS/TLS/shared-edge, real host health, rollback, manual zoom/screen-reader QA and human acceptance are independent gates.
