# Administration and Security editorial contract — Docs #7

**Status:** Internal source-reviewed editorial draft. **Owner:** Docs #7. **Not a public security runbook or release-qualified guide.** Publication requires Docs #2/#15, accepted KAORI Application release evidence, security owner review, and role-scoped browser UAT.

## Overview pattern

1. Define the reader, domain and safe informational purpose.
2. Separate Access presentation from authentication protocols, RBAC policy evaluation, user persistence and audit-source ownership.
3. Identify source-reviewed workspaces and permission guards; distinguish presence of a route from configured/ready controls.
4. State explicit visibility versus mutation boundaries and avoid sensitive operational details.
5. Describe evidence scope and missing/partial/unknown cases; never equate empty audit counts with global absence.
6. Distinguish implemented global RBAC from accepted but unadmitted resource-scoped authorization design.
7. Record application SHA, exact accepted release manifest, public-disclosure approval, Docs revision, browser UAT and human acceptance.

**Unpublished example:** `content/administration-security/administration-security-overview.md`.

## Roles and Permissions explanation pattern

1. Explain user → active assigned role → permission → server-side route decision.
2. Use only verified permission-key examples; do not duplicate the full private registry.
3. Describe protected defaults, custom-role safeguards and least privilege without a privilege escalation playbook.
4. Distinguish global application permission from source/data scope, approval and provider-native authority.
5. Explicitly label accepted design work as **unadmitted**, never current GA.
6. Avoid credentials, break-glass procedures, sensitive identities, internal trust settings, and incident/forensic details.
7. Require security review, role-based browser tests, accessible diagram and published release mapping.

**Unpublished example:** `content/administration-security/understanding-roles-permissions.md`.

## Source-review register

Pinned `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`:

- `app/access/README.md`: Access navigation, domain ownership, permission-scoped Overview, Activity Audit source boundaries, and authentication-security UAT caveat.
- `app/access/roles/routes.py`: `roles.view` GETs and `roles.manage` protected mutations.
- `app/access/permissions/routes.py`: read-only catalog guarded by `roles.view`.
- `app/access/activity_audit/routes.py`: `activity_audit.view` and separate source-specific permissions.
- `app/access/rbac/{README.md,decorators.py}` and `docs/rbac/README.md`: global RBAC, protected defaults, normalized role, server-side guards and fail-closed behavior.
- `docs/rbac/SCOPED_AUTHORIZATION_V1_DECISION_RECORD.md`: accepted architecture baseline; implementation and UAT **not admitted**.

## Publication checklist

- [x] Source-reviewed English drafts distinguish global RBAC from planned scoped authorization.
- [x] No sensitive break-glass, credential, escalation, incident, or provider trust instructions.
- [ ] Security/domain owner approves exact public claims and disclosures.
- [ ] Accepted KAORI App release tag, SHA, digest/manifest and Docs #15 version map.
- [ ] Role-specific browser UAT: permission allowed/denied, source visibility, empty/error state, and exact UI copy.
- [ ] Six widths (360/390/768/1024/1280/1440), keyboard, 200% zoom, light/dark, screen-reader and sanitized visual checks.
- [ ] Reviewed staging merge, Full Admission, human acceptance, signed Docs RC and deployment evidence.

Developer Check or staging source review alone cannot authorize publication.
