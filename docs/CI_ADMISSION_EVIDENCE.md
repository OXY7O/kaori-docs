# KAORI Docs admission evidence reuse and Fast Smoke

Authority: [Docs #45](https://github.com/OXY7O/kaori-docs/issues/45)
and the approved
[KAORI Delivery Workflow](https://github.com/OXY7O/KAORI/blob/main/docs/engineering/KAORI_DELIVERY_WORKFLOW.md).

## Source and validation authority

Docs uses the same KAORI principle:

> Same immutable source tree and validation authority fingerprint means full
> evidence may be reused **only after independent verification**, followed by
> a fresh Fast Smoke. Otherwise, run one fresh Full Admission.

The fingerprint covers workflows, CI and release scripts, browser/runtime
tests, dependency lock and toolchain, Docusaurus/TypeScript/Playwright
configuration, Dockerfile, Nginx and Compose authority. The source Git
tree SHA is bound independently; a matching fingerprint alone does not
authorize reuse of tests for changed content.

The canonical staging `Full Admission` publishes a 30-day artifact
containing source SHA, tree SHA, fingerprint, workflow execution SHA/ref,
run and attempt, repository, event, required gate conclusions, timestamp,
and `profile`.

A **fresh full** result carries `schema_version: 2`,
`profile: full` and `reuse_authorized: true` only after Promotion Policy,
Full Admission, Container Admission, and Browser Quality all succeed.
A **reused** result records its original Full Admission run and
`reuse_authorized: false`. Reused evidence must never become a new full
source in a transitive trust chain.

## Trusted resolution and fallback

Before any comprehensive job is skipped, `Resolve Admission Evidence`
uses the GitHub Actions API to inspect previously **completed-successful
canonical staging push** runs. It accepts evidence only when:

- Repository, workflow path and event identity are trusted.
- The prior commit is in the current source ancestry and its tree matches.
- The validation authority fingerprint and source SHA are exact.
- The source artifact is unique, unexpired and its ZIP SHA-256 matches
  GitHub's recorded artifact digest.
- The evidence schema, timestamp, original run/attempt, workflow SHA,
  profile and all mandatory gate results are intact.
- GitHub's original run contains exactly one successful job for each
  required gate, including the artifact-publishing gate.
- For a promotion PR, the source is exactly the same-repository
  `kaori/staging` branch targeting `main`.

Any missing, stale, malformed, changed, failed, skipped, cancelled,
untrusted or ambiguous result produces explicit **FALLBACK**, not a
synthetic PASS or a bypass. The existing comprehensive validation jobs
then run normally on that governed integration SHA.

## Fresh Fast Smoke for verified reuse

Only a verified `REUSED` decision permits the lighter checks. Fresh
checks still require source SHA and committed lock identity, Docusaurus
build/approved public content boundary, pinned desktop browser keyboard
and navigation test, staging and production Compose render, and
release-script syntax and safety guards.

When a tree, workflow, browser test, security input, dependency lock,
Dockerfile or release contract changes, fingerprints/trees differ and
the full formatting, TypeScript, npm audit, runtime/Trivy and six-viewport
light/dark Browser Quality gates run normally.

CI test reuse never implies release/UAT acceptance. Signed immutable RC
identity, exact full admission lineage, stable main release with the
same digest, host deployment receipt, shared-edge verification, rollback,
and explicit Human Acceptance remain independent mandatory controls.

## Activation and rollback of the CI routing

This #45 implementation changes **only** the canonical Docs quality
workflow and helper scripts. The initial staging integration of this
policy must itself execute one fresh Full Admission. It may create the
first schema-v2 reusable artifact only after all tests pass.

If the resolver encounters network issues or missing evidence, its
fail-closed default is `FALLBACK`. If fresh Fast Smoke fails, the
governed transition fails; it does **not** silently convert a failed
Fast Smoke into successful reuse. Correct the issue on an issue-linked
branch and rerun normal validation.

Do not set any release auto-deploy flag as a cache workaround. The
legacy #33 RC-public auto trigger remains inactive; the #40 stable
production policy and private RC/UAT #43 have separate acceptance gates.
