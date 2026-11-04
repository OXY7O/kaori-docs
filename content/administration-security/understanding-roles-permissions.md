---
id: understanding-roles-permissions
title: Understanding Roles and Permissions
description: Learn how KAORI's source-reviewed global role model and server-side permission checks control access.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished source-reviewed draft for Docs #7. Inspected KAORI Application staging at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. This is a conceptual authorization explanation, not an administrator procedure or an assertion of an accepted stable release.

## The authorization model

KAORI's inspected global RBAC implementation relates an authenticated user to **one normalized assigned role**, which contains a set of permissions from a code-owned registry. Server-side guards evaluate the permission required by each protected route. A missing or inactive role fails closed. UI navigation can reflect permissions but cannot grant them.

```text
Authenticated user
      |
      v
Assigned active role
      |
      v
Permission set from code-owned registry
      |
      v
Server-side route guard
      |
      +--> Allowed when required permission is present
      |
      +--> Denied (HTTP 403) otherwise
```

**Diagram description:** The user, role, permission set, and route guard form a global application authorization decision. This diagram intentionally omits special emergency authority and future resource-scope policy; neither can be inferred from an ordinary role assignment.

## Understand a permission key

A permission describes an action in an application domain, not a universal entitlement to every resource. Examples verified in staging source:

- `roles.view` protects the Roles & Access list/detail and the read-only Permission Catalog.
- `roles.manage` protects role administration endpoints; it does not remove protected-role and delegation safeguards.
- `activity_audit.view` protects Activity Audit entry and details. Additional administrative evidence requires its own source permissions.
- `inventory.view` protects Kubernetes inventory read routes, not inventory synchronization.
- `clusters.sync` protects a separate Kubernetes inventory synchronization request; queueing a job is not proof of a committed new generation.

These examples identify **source-reviewed guards**. They are not a complete permission catalog, nor proof that a feature is enabled in an accepted release.

## Protected defaults and custom roles

The staging RBAC source defines five protected default role baselines: **Viewer, Operator, Editor, Admin, and Auditor**. These baselines are source-controlled and cannot be edited, deactivated, or deleted through ordinary role administration. Custom roles are separately governed; their changes must satisfy server-side delegation limits, protected-role rules, and mutation validation.

A special emergency authority exists outside ordinary role aggregation, but its use is governed separately and is not a normal role or a public escalation procedure. Do not infer privileged access from a role's display name.

## A permission is not a resource-scoped grant

The inspected implementation provides **global** application permission checks. The accepted resource-scoped authorization design is a separate, **not-yet-admitted** workstream. Do not represent per-cluster, namespace, tenant, integration-instance, or Secret-specific scoped grants as generally available because a design record exists.

Similarly, an Identity Provider's external group membership or a provider-native ACL is not automatically a KAORI resource grant. Approval for a sensitive operation, authorization to invoke a route, and the source provider's own permissions are separate checks.

## Interpret access safely

When a workspace is unavailable, first distinguish an unauthenticated session from a permission-denied request and from an unavailable source. Do not assume that a hidden navigation item proves the underlying data is absent. Ask an authorized administrator to review the role and intended task; never recommend self-granting permissions or modifying protected roles as a troubleshooting shortcut.

When reviewing audit evidence, preserve source scope. The Notification-backed Activity Register and separately permissioned administrative records are not a single complete audit corpus. A read-only permission does not authorize a mutation, and a recorded event is not a substitute for checking the actual source-owned result.

## Source and acceptance status

- **Owner:** Docs #7.
- **Reviewed source:** `docs/rbac/README.md`, `app/access/rbac/{README.md,decorators.py}`, `app/access/roles/routes.py`, `app/access/permissions/routes.py`, `app/access/activity_audit/routes.py`, and `docs/rbac/SCOPED_AUTHORIZATION_V1_DECISION_RECORD.md` at `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`.
- **Source-reviewed:** current global role/permission checks, protected default role rules, read-vs-manage guards, and separate audit permissions.
- **Planned/unadmitted:** resource-scoped grant evaluator and migration, security UAT for additional authentication controls, and any broader scope/approval contract not evidenced by accepted code.
- **Pending:** release-qualified applicability, security-owner review, actual role-based browser UAT, accessibility/responsive checks, Full Admission, and human acceptance.

This `draft: true` page is excluded from public documentation routes, sidebar, and search.
