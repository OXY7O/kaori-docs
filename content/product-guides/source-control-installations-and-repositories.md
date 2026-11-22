---
id: source-control-installations-and-repositories
title: Source Control Installations and Repositories
description: Understand qualified installation-scoped repository observations and permission boundaries.
draft: true
sidebar_position: 4
---

> **Editorial status:** Unpublished source-reviewed guide for Docs #144.
> A staging implementation is not accepted production or stable-release evidence.

## Purpose

KAORI separates **Source Control** as an operational capability from **Integrations → Source Control → GitHub** as the provider registration and synchronization owner. The external GitHub service remains authoritative for accounts, App installations, repositories, references and access grants. KAORI presents committed, source-qualified evidence rather than cloning Git history.

The current product workspace exposes **Overview** and **Repositories**. Pull Requests, Actions, branch governance, DORA metrics, releases and source-to-runtime correlation belong to separate future workstreams and are not available merely because a GitHub integration has been registered.

## Access prerequisites

The bounded staging product workspace currently requires a **local database Super Admin** with `integrations.manage`. This temporary UAT gate is not a production resource-scoped authorization model. KAORI #724 separately owns broader resource permissions.

An integration may be registered while provider validation, a GitHub App installation, an authorized collection or a committed generation is still unavailable. A visible menu or a successful connection check does not establish a completed repository inventory.

## Identity and evidence

- **Account:** Provider-native account identity, distinct from its mutable login name.
- **Installation:** The exact GitHub App installation and its authorized grant scope.
- **Repository:** Host-qualified native repository identity, distinct from owner/name.
- **Grant:** An installation-to-repository access relationship with its own history.
- **Revision:** An immutable repository-scoped exact SHA only when observed and committed.
- **Reference:** A mutable branch or tag pointer; its observed tip is not guaranteed current.

One repository can be granted through multiple installations. Do not sum overlapping installation counts as an organization-wide total. Access lost from one installation does not establish that a repository was deleted or that another installation lost its grant.

A complete successful collection may establish an **observed zero**. Pending, failed, revoked, incomplete or superseded collection yields **unknown or partial evidence**, not a verified zero. Retained previous snapshots remain historical when the provider is unavailable.

## Task: review installation coverage

1. Sign in using an account authorized for the accepted staging evaluation scope.
2. Open **Source Control → Overview** and inspect the source installation identities.
3. Check the committed collection status, coverage and last observation timestamp.
4. Distinguish the observed native Account from the App Installation identity.
5. Select the intended installation before investigating its repository grants.
6. Record any unknown, incomplete or stale evidence rather than inventing totals.

**Expected result:** an explicitly scoped, read-only installation coverage assessment. The current installation list has a bounded **50-row** limit and must signal truncation rather than advertise organization-wide completeness.

## Task: inspect recorded repositories

1. Open **Source Control → Repositories** under the permitted installation.
2. Select that installation explicitly; do not combine unrelated grants.
3. Apply the available search, visibility and archive filters.
4. Review the committed repository records using the canonical default **5-row** pagination with 5/10/25/50 page-size options.
5. Inspect repository identity, grant/access status and the last committed collection.
6. Where an exact default-branch SHA appears, check its observation timestamp. The observed branch tip may have changed at GitHub after collection.

**Expected result:** a read-only list of source-qualified committed grants, not a live provider query, Git clone or complete organization inventory.

## Interpretation and troubleshooting

- **Workspace missing:** Check temporary local Super Admin and route authorization; `integrations.manage` alone is insufficient.
- **Source not ready:** Inspect the owning GitHub Integration instance, application validation and authorized installation.
- **No repository rows:** Distinguish observed zero, uncollected source, partial generation and filtered no-match.
- **Repository disappeared:** Examine effective-dated grant/access history before concluding deletion.
- **Unknown SHA:** An exact revision is unavailable until a verified source revision was committed.
- **Incomplete totals:** Check overlapping installation grants, the source scope and the bounded installation list.

Do not include real repository names, customer organizations, installation identifiers, private endpoints, webhook payloads or access tokens in public examples and screenshots.

## Source and release qualification

Reviewed Application sources: `app/source_control/README.md`, `app/source_control/README_PRODUCT.md`, `app/common/workspace_navigation_catalog.py` and `app/common/workspace_navigation.py`, at `197a7f7e598c111592a8ae36388865cd3aacf541`.

The article still needs the exact admitted App candidate, independent reviewer approval and role-scoped browser UAT for denied access, two-installation isolation, unknown-versus-zero, stale collections and truncated inventory. It remains `draft: true` and is not currently published as an Application stable guide.
