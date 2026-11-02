# KAORI Docs governed delivery

Follow the [KAORI Engineering Delivery Workflow](https://github.com/OXY7O/KAORI/blob/main/docs/engineering/KAORI_DELIVERY_WORKFLOW.md), adapted from the [Website delivery pattern](https://github.com/OXY7O/kaori-website/blob/main/docs/DELIVERY.md) without copying Astro or Application-specific checks.

1. Govern every bounded change by an existing Issue and its dependencies.
2. Work from `kaori/staging` using `kaori/<type>-<issue>-<slug>`. Do not push changes to `main`.
3. Open a **Draft PR into `kaori/staging`**, with exact source SHA, linked issue, scope, risks and pending evidence.
4. Run the **Developer Check** owned by #12 on the exact head. It will be path-aware, with link/MDX/build and dependency validation when applicable; a Draft result is not full admission.
5. Receive independent review and meet the exact-head gates before staging merge.
6. Run **Full Admission** against the exact merged `kaori/staging` SHA, including public-scope/link/asset/security and browser quality. Failed/missing required gates fail closed.
7. Release Candidate and Release Deployment are **manual and separately authorized** under #13 and #14, using exact SHA, verified immutable digest, SBOM, provenance, signature and separate runtime receipts/rollback. Never trigger host deployment on push.
8. Collect staging/server UAT, accessibility/light-dark/mobile/six-viewport evidence and explicit human acceptance.
9. Promote via a `kaori/staging` → `main` PR; publish only after all relevant release and public-edge gates, with separately approved DNS/TLS/Host/SNI changes.

**Approved version/environment contract (issue #38 / #39):**
KAORI Application and Website already treat `vX.Y.Z-rc.N` as the staging
candidate/UAT identity and `vX.Y.Z` as the promoted **main** stable identity
with **the same signed immutable OCI digest**. The Docs bootstrap currently has
no stable tag, so `main` promotion alone is **not** a stable product release.
The stable publisher is an explicit main-only `Full Admission`
`workflow_dispatch` with `stable_version`, `accepted_candidate_tag`,
and `stable_approval_reference`, plus independent RC lineage, digest, signer,
SBOM and provenance checks. It never rebuilds or mutates the VPS. Current
Docs `#33` RC-to-public auto mode is **not** the approved production
release model and must remain disabled pending issue #40.

Application `kaori/rc-request` and `kaori/uat-request` are exact-SHA request
triggers. Website uses approved manual `workflow_dispatch` without those
branches. A future standardization decision on optional request branch parity
is held under [KAORI #4201](https://github.com/OXY7O/KAORI/issues/4201);
do not infer that all repositories already have those branches.

**Current stable production design (issue #40):** the previously admitted
#33 RC-publisher → public auto deployment is **retired**; a signed RC from
staging is **not** a stable production release. The main-only publisher #39
may create stable `vX.Y.Z` from the accepted RC's exact signed digest,
after Human Acceptance and main admission, without rebuilding the image.
Only a **successful main stable publication** can be considered for
automatic Docs production deployment, and only when both repository
Actions variable `KAORI_DOCS_STABLE_AUTO_DEPLOY_ENABLED=true` and the
separate issue #40 Docs-only owner-approved standing marker are present.
The workflow revalidates stable main tag/RC digest, exact publisher
run, current main and admitted original RC before any SSH mutation.
Before enabling standing auto-deploy, perform one **manual stable cutover UAT**
using the same `Release Deployment` workflow on `main` with
`stable_tag=vX.Y.Z`, `publish_existing_edge=true` and an issue #40
write-authorized approval-reference comment containing the exact marker
`KAORI_DOCS_STABLE_DEPLOY_APPROVED:<main-SHA>:<RC-tag>:<stable-tag>:<sha256-digest>`.
The workflow independently verifies the actual signed stable release,
successful publisher run and unchanged signed RC digest; it must not require
the standing auto policy for this bounded manual UAT. Only after public
Docs-only cutover/rollback, all-site edge verification and Human Acceptance
may the separate auto-deploy variable and standing approval be enabled.
The runtime uses the existing isolated `kaori-docs` Compose, committed
receipt and Docs-only shared-edge reattachment, then full all-site
verification. Staging RC/UAT and main stable are **distinct version
authorities**, although the currently deployed single Docs VPS is not
a separately isolated staging environment. Deployment automation
and its public cutover UAT are currently **not active/accepted**.

The initial repository contains only `main`, so issue #11 first creates `kaori/staging` from its existing README commit and then an issue-owned bootstrap work branch. The staging branch creation alone is **not** an approved staging merge. Each later issue remains a bounded workstream.

## Quality and operational boundaries

- Four canonical workflow names: **Developer Check**, **Full Admission**, **Release Candidate**, **Release Deployment**. CI is implemented separately under #12/#13/#14.
- The #14 [private deployment adapter](RELEASE_DEPLOYMENT.md) uses existing Website-style digest/receipt/rollback controls and an independent loopback 18081. The existing shared-edge Nginx/Certbot owns future public Docs ingress under separate authority; source PR/CI cannot authorize host deployment.
- No lockfile or npm registry access means no deterministic install/build PASS. Do not override the block with a placeholder lockfile.
- Runner labels `platform-ci` and `kaori-ci` require confirmed repository access. Labels do not themselves authorize the private Docs repository.
- Private GitHub plan restrictions can make branch protection/environment controls unenforceable. Document a manual compensating procedure; do not claim server-enforced protection without proof.
- Keep issue/PR assignee, canonical labels and native relationships accurate. GitHub Project status, sprint, type, priority and points require operator reconciliation where connector tooling cannot mutate them.
- Docs is a static, non-authenticated publication; production credentials, external providers, application internals and shared-edge mutation are out of scope for content work.
