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

The initial repository contains only `main`, so issue #11 first creates `kaori/staging` from its existing README commit and then an issue-owned bootstrap work branch. The staging branch creation alone is **not** an approved staging merge. Each later issue remains a bounded workstream.

## Quality and operational boundaries

- Four canonical workflow names: **Developer Check**, **Full Admission**, **Release Candidate**, **Release Deployment**. CI is implemented separately under #12/#13/#14.
- No lockfile or npm registry access means no deterministic install/build PASS. Do not override the block with a placeholder lockfile.
- Runner labels `platform-ci` and `kaori-ci` require confirmed repository access. Labels do not themselves authorize the private Docs repository.
- Private GitHub plan restrictions can make branch protection/environment controls unenforceable. Document a manual compensating procedure; do not claim server-enforced protection without proof.
- Keep issue/PR assignee, canonical labels and native relationships accurate. GitHub Project status, sprint, type, priority and points require operator reconciliation where connector tooling cannot mutate them.
- Docs is a static, non-authenticated publication; production credentials, external providers, application internals and shared-edge mutation are out of scope for content work.
