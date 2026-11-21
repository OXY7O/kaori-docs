---
id: administration-security-overview
title: Administration and Security Overview
description: Understand KAORI Access administration, permission boundaries, and source-qualified activity evidence.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished source-reviewed draft for Docs #7. Reviewed KAORI Application staging at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. No browser UAT, supported application release, or security certification is asserted.

## Purpose and audience

KAORI groups administrative work under **Access** while keeping identity, authorization, authentication, and audit responsibilities separate. This overview is for authorized platform administrators and readers who need to understand which evidence is visible and why an administrative page is not itself proof of a security control's operational readiness.

The source-reviewed Access workspace groups **Overview**, **User Management**, **Identity Providers**, **Authentication Security**, **Roles & Access**, **Permission Catalog**, and **Activity Audit**. These are implementation/navigation contracts in staging, not a guarantee that every feature has completed security UAT or is enabled for every account.

## How Access responsibilities fit together

```text
Authenticated user and identity source
                 |
                 v
KAORI role and code-owned permission registry
                 |
                 v
Server-side authorization decision
                 |
         +-------+--------+
         |                |
         v                v
Allowed workspace   Denied request (403)
         |
         v
Permission-scoped activity and evidence views
```

**Diagram description:** Identity and assigned role inform a server-side permission decision; authorized users see only permitted workspaces and source-qualified evidence. This is conceptual and does not depict a live sign-in or resource-scoped policy engine.

## Source-reviewed administration areas

### Users and identity providers

The Access domain owns administrative presentation for user lifecycle and Identity Provider configuration; authentication protocols and identity persistence have separate source owners. An identity provider's presence in the UI does not prove that an external provider is configured, healthy, or admitted for production use. User and provider-specific procedures require separate role, authentication, and release review.

### Roles and Permission Catalog

The inspected **Roles & Access** routes distinguish `roles.view` for role lists/details from `roles.manage` for custom-role administration. The read-only **Permission Catalog** also requires `roles.view`. A permission registry entry describes a possible authority; it does not grant it to the current user or prove a provider operation is enabled.

Protected default roles are source-controlled. Custom roles have guarded lifecycle rules and delegation limits; administrative changes are not part of this overview. A visible button is not a substitute for the server-side permission guard.

### Authentication Security

The staging Access documentation identifies an authentication-assurance workspace with policy/provider controls, but **security UAT is pending**. Do not claim MFA, CAPTCHA, external authentication, or other assurance mechanisms are universally enabled or generally available solely because configuration code or a page exists. Exact behavior and account applicability require an accepted release and security-owner evidence.

### Activity Audit

The staging **Activity Audit** route is guarded by `activity_audit.view`. Its primary Activity Register uses Notification-backed records; administrative evidence from other sources is separately permission-scoped. An event count is not a complete cross-system audit inventory, and zero warnings is not proof that no administrative or security event occurred. The source preserves recorded actor, target, timestamp, outcome, and sanitized evidence within its own visibility boundary.

## Permission, scope, and approval are different

- **Permission** answers whether an authenticated user has a defined KAORI action authority.
- **Source/data scope** identifies which evidence a domain view can legitimately show; it must not be inferred from the menu alone.
- **Approval** is a distinct governed decision for sensitive changes; permission to view does not authorize execution.
- **Provider authority** remains with the integrated source. A KAORI role does not automatically grant a provider-native role.

The current inspected RBAC contract is **global application RBAC**. Resource-scoped authorization has an accepted design direction but **its implementation and UAT are not admitted**; it must not be advertised as an available general control.

## Safe review and escalation

For a denied page, verify the intended workspace and request an authorized access review. Do not attempt to bypass the role boundary, change privileges, inspect other users' records, or expose configuration secrets. For an ambiguous audit record, retain only sanitized scope and observed event details, and escalate to the appropriate owner rather than inventing a cause or recommending an unapproved action.

## Evidence and publication boundary

- **Owner:** Docs #7.
- **Reviewed source:** `app/access/README.md`, `app/access/roles/routes.py`, `app/access/permissions/routes.py`, `app/access/activity_audit/routes.py`, `app/access/rbac/decorators.py`, `docs/rbac/README.md`, and `docs/rbac/SCOPED_AUTHORIZATION_V1_DECISION_RECORD.md` at the pinned staging SHA.
- **Not established:** an accepted stable KAORI Application release, release-qualified feature/permission coverage, authentication security UAT, live IdP configuration, browser navigation, responsive/accessibility evidence, or human acceptance.
- **Required before publication:** security-owner public-disclosure review, exact release manifest and Docs #15 mapping, tested role-specific pages, sanitized visuals, browser/Full Admission evidence, and explicit human acceptance.

Keep `draft: true`; do not link this page from public navigation or search.
