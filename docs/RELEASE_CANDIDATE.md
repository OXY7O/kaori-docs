# Immutable KAORI Docs release candidates

**Authority:** Issue #13 owns the manual Release Candidate publisher. Issue #10 governs credentials and trust; #12 owns exact-staging Full Admission, and #14 owns deployment and rollback.

## Runtime contract

The multi-stage Dockerfile builds Docusaurus using locked Node 22 dependencies, then serves static assets from the existing Website-approved digest-pinned unprivileged Nginx runtime on internal port 8080. Internal engineering docs are excluded from the image. The staging Container Admission runs the shared-style scripts/container_smoke.sh check for non-root, read-only runtime, Nginx, /healthz, root page and Trivy HIGH/CRITICAL. It does not deploy a server.

## License authority

The rights holder selected **the same proprietary KAORI Internal Use License**
as the Application (the Website has no separate open-source grant). The exact
root [LICENSE](../LICENSE) is copied from the approved KAORI source; do not
substitute MIT or Apache-2.0. The OCI license identifier for KAORI-owned
material is `LicenseRef-KAORI-Internal-Use`, a valid SPDX custom reference,
**not** an entry in the SPDX License List. The signed SPDX document must
contain a `hasExtractedLicensingInfos` record with the complete license
text. Never replace licenses of third-party packages. The label and signed SBOM
are not authorization to publish internal KAORI source or sensitive docs.

## Staging-only RC activation — temporary issue #24

GitHub requires `workflow_dispatch` definitions to exist on default `main`,
which is intentionally not promoted before Docs UAT. Issue #24 temporarily
adds a **path-scoped staging `push` trigger to the canonical**
`.github/workflows/publish-staging-image.yml`. It is not a new publisher or a
permanent automatic push-to-release pipeline. Unlike a copied `rc-once.yml`,
the actual signer remains the canonical workflow identity already pinned by
`deploy-release.sh`.

The runtime checks the canonical workflow path against the **first parent of the exact two-parent staging merge commit**, not with bare `git diff-tree -r` (which returns no changed paths on an ordinary merge). This is a fail-closed activation check; a missing changed path or non-merge SHA is rejected. The push path must change the **publisher workflow itself**, and its accepted
staging merge commit message must contain the exceptional marker
`[KAORI_DOCS_RC_ISSUE_24]`. Missing the marker, ordinary staging pushes,
PRs, forks and non-staging branches cannot start its publish job. This trigger
must only be merged after an issue #24 review and explicit maintainer
authorization of the upcoming staging RC bootstrap. Exact-source **new**
Full Admission on that merge SHA is mandatory.

The bootstrap attempts a lookup for **exactly one authorized issue #13
approval comment** containing `KAORI_DOCS_RC_APPROVED:<current-merge-sha>:<rc-tag>`.
It rejects zero or multiple matches. The canonical publisher subsequently
revalidates the comment's origin, author repository permission, current
staging HEAD, successful Full Admission, registry identity/credentials,
proprietary license, tag uniqueness, Trivy, OCI digest, Cosign signature and
signed SPDX/SLSA attestations. No automatic publication is allowed without
this second approval. Because the merge SHA is not known before integration,
a first attempt will normally **fail closed**; the maintainer must post the
approval after new Full Admission PASS, then explicitly **rerun the same
failed GitHub Actions job** on the exact, unchanged SHA. This is an intentional
manual approval step and does not bypass immutable source verification.

After RC acceptance, a separate issue-linked PR must **remove the temporary
push trigger/bootstrap step**, retain normal workflow_dispatch and keep
previous signed release evidence. Its removal is part of #24 completion.
Do not use this bootstrap for stable release or public DNS/TLS, and do not
promote Docs to `main` solely to enable manual workflow execution.

## Manual release authority

The canonical Release Candidate workflow is .github/workflows/publish-staging-image.yml. It is manual-only except for the explicitly guarded one-time #24 staging bootstrap described above, and must run against kaori/staging at an exact SHA with a completed-success Full Admission run. Complete the repository-specific Variables/Secrets and registry robot-scope checks in #10 before dispatch. The image repository must end with /kaori-docs.

Provide a permanent GitHub comment URL as approval_reference. That comment must belong to issue #13 and include a complete approval marker line of the form:

    KAORI_DOCS_RC_APPROVED:<40-character-staging-sha>:<vX.Y.Z-rc.N>

The publisher verifies the exact marker and the comment author's repository write, maintain or admin permission. The candidate_tag and reviewed SPDX license_identifier are required; NOASSERTION is rejected. An inaccessible or unrelated approval fails closed. This approval is for publishing an RC only, not UAT, VPS changes or stable promotion.

A candidate is built once and uses immutable OCI SHA256 digest, checked source/revision/version/created/title/description/documentation/license metadata, offline runtime smoke, Trivy HIGH/CRITICAL scan, SPDX SBOM, source/run-linked provenance and cosign keyless digest signatures plus SBOM/provenance attestations. Signature and attestation verification must complete before Git tag and prerelease metadata creation. All identities are separate from KAORI Application version routing.

## Registry digest authority and incomplete RC quarantine — issue #30

The immutable digest must come from the **registry's actual manifest/index**, retrieved through the existing Docker buildx `imagetools inspect --format '{{json .Manifest}}'` contract, not from comparing Docker's local `RepoDigests` repository string byte-for-byte. Docker Hub may present a familiar name without the optional `docker.io/` prefix; a local image alias is not a reliable registry identity proof. The publisher validates the registry SHA256 format, explicitly pulls `<configured-image>@sha256:<digest>`, checks exact source/version/license labels and performs all Trivy/Cosign/SPDX/SLSA gates before creating GitHub tag/prerelease evidence. Failed digest resolution blocks publication.

**Quarantine record (2026-11-02):** Attempt 2 of [RC run #41447703825](https://github.com/OXY7O/kaori-docs/actions/runs/41447703825) built/pushed the registry tag `v0.1.0-rc.1` from staging source `129336ff33d7e96a76d4ae9ea1df4b35e1628c2e`. Docker push and pull reported digest `sha256:c466a76d617ae3aa92439630b36bc618e9acf191882ab5385e844daf9b4ebc1d`, but strict local `RepoDigests` equality failed **before signature/SBOM attestation and GitHub release finalization**. Therefore `v0.1.0-rc.1` is **INCOMPLETE / QUARANTINED / NEVER DEPLOY**, even though registry storage contains a tag. No mutating retry, retag, overwrite or deletion is authorized by the digest fix. A newly admitted source must use a **new** explicitly approved artifact tag, initially proposed `v0.1.0-rc.2`, with complete signed evidence. Registry tag visibility never substitutes for acceptance.

## Automated downstream handoff (issue #33)

GitHub Actions `GITHUB_TOKEN` creates the signed prerelease metadata only
after immutable digest, Trivy, Cosign and signed SPDX/SLSA verification.
GitHub suppresses downstream `release.published` workflow triggers
generated with the same token; release auto-deployment therefore uses the
canonical publisher's completed-success `workflow_run` on the default branch
after separate issue #33 standing policy and first-public/UAT acceptance.
Publisher approval remains **per exact staging SHA and RC tag** under #13.
The deployment workflow revalidates the signed release; publisher success
alone is not server-change authority. Details:
[Release Deployment](RELEASE_DEPLOYMENT.md).

## Recovery without mutation

If an earlier attempt already pushed the candidate but was interrupted, use resume_existing=true with the exact previously evidenced expected_digest. The workflow pulls rather than rebuilds, refuses a changed digest, checks OCI labels and reruns scan/signature/attestation verification. A mismatched Git tag or prerelease is rejected. Never overwrite or silently republish an existing candidate.

## Default-branch dispatch limitation

GitHub generally requires workflow_dispatch workflows to exist on the default branch. Current Docs main promotion is separately governed. Do not push this workflow directly to main or invent a bypass. A missing Run Workflow button means activation is blocked until an accepted promotion or separately reviewed dispatch adapter is available.

## Evidence boundary

A source CI PASS is not registry authentication, signed publication, deployment or UAT. Issue #14 may only consume an explicitly accepted immutable digest. Public DNS/TLS/shared-edge, real host health, rollback, manual zoom/screen-reader QA and human acceptance are independent gates.

## Review and evidence retention

The Developer Check invokes the existing runtime smoke only for changes to the Dockerfile,
Docker context or runtime server adapter. This is a pre-merge engineering signal;
Full Admission still reruns Container Admission on the exact staging merge SHA.
The publisher rechecks staging HEAD before creating release metadata, since a
long-running build must not silently publish a superseded staging source.
The manual workflow retains generated SPDX, provenance and cryptographic
verification JSON as private, run-scoped Actions artifacts for 30 days,
including partial-run evidence when a later step fails. A missing artifact,
failed signing step or incomplete publication is not an accepted release.
