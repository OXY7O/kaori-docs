# Integration Catalog and Provider Guide editorial pattern — Docs #5

**Status:** Internal source-reviewed editorial draft, not a public Docusaurus page. **Owner:** Docs #5. **Upstream:** Docs #2 article shell, Docs #15 verified version routing, and accepted KAORI Application release authority.

## Catalog contract

1. Start with **domain → capability → provider → configured instance**. A provider is a source definition; a configured instance is environment- and permission-specific.
2. Read domain/capability labels from the canonical application taxonomy and provider lifecycle from the provider matrix at an **exact application source SHA**.
3. Distinguish source metadata `available` from release-supported, UAT-tested, connected, and collecting. Never expose `planned` providers as released setup actions.
4. Separate provider identity/reachability, compatibility/Core Validation, runtime health, downstream binding eligibility, optional coverage, and committed inventory freshness.
5. If search/filter controls are actually shipped, verify keyboard operation, version scoping, empty results, and semantics in browser UAT; do not implement an independent public catalog API.
6. Show only accepted, published and version-qualified provider guide links. No cross-link to `draft: true` articles.

## Provider Guide contract

1. **Purpose and authority:** provider-owned source truth, KAORI normalization/commit boundary, and exact released application applicability.
2. **Prerequisites and least privilege:** confirmed permissions, allowed endpoints, network/TLS trust, safe credentials, and scope.
3. **Verified setup:** UI steps only from release-matched real-account UAT, never extrapolated solely from route names or screenshots of design mocks.
4. **Evidence sequence:** Test Connection → Registration → Full Validation → Runtime Refresh / downstream collection as distinct operations; identify asynchronous queued versus completed states.
5. **Readiness and limitations:** distinguish required provider capabilities from optional consumer adoption, inventory freshness, and incomplete or stale source evidence.
6. **Troubleshooting:** safe read-only checks first; never include secrets, internal addresses, insecure TLS workarounds, or privileged provider mutation.
7. **Publication evidence ledger:** app issue and accepted SHA, signed release/tag/digest, Docs revision, exact permissioned UAT, sanitized screenshot approval, security review, accessibility/browser evidence, Full Admission and human acceptance.

## Current staging-only example

At `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`, Harbor appears in `app/definitions/catalogs/integrations/provider_matrix.yaml` as source-catalog `available`. `app/integrations/registry/providers/harbor/application/routes.py` and `forms.py` define permissioned registration/test/validation/runtime workflows. `application/registration.py` binds the successful connection proof to the user and fields for 600 seconds. `validation.py` differentiates connection identity from provider compatibility and required read capabilities. `README.md` defines HTTPS/CA/origin restrictions and optional integration coverage.

**Drafts:** `content/integrations/integration-catalog.md` and `content/integrations/harbor-provider-guide.md`. Both are intentionally unpublished. Neither proves a stable release, a real Harbor connection, executed tests, or a browser-tested procedure.

## Activation checklist

- [x] Source-reviewed taxonomy and Harbor registration/validation boundaries recorded.
- [x] Provider Guide and catalog editorial contracts established without new runtime features.
- [ ] Independent content/security review, exact App release manifest and version mapping.
- [ ] Browser UAT with approved roles and failure cases; screenshots sanitized and accepted.
- [ ] Native Docusaurus sidebar, TOC, search/index isolation, links, keyboard, 200% zoom, six viewports, and light/dark QA.
- [ ] Reviewed staging merge, Full Admission on merged SHA, human acceptance, signed Docs RC and authorized deployment.

A Developer Check on a draft branch is not Full Admission, release approval, or UAT.
