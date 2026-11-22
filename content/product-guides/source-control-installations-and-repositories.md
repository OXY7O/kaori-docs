---
id: source-control-installations-and-repositories
title: Source Control Installations and Repositories
description: Understand installation-scoped committed repository evidence, access boundaries, and source-control inventory limitations.
draft: true
sidebar_position: 4
---

> **Editorial status:** Unpublished Source Control product-guide draft
> for Docs #144. The observed staging implementation is not proof
> of live GitHub App installation, non-admin access, broader
> production readiness, or an accepted stable KAORI release.

## What Source Control provides

KAORI separates two responsibilities:

- **Integrations → Source Control → GitHub** owns the provider
  connection, GitHub App identity, validation, approved instances,
  collection and jobs.
- **Source Control** is the product workspace for authorized
  inspection of normalized, *committed* repository inventory and
  the provenance of those observations.

GitHub is authoritative for provider-native accounts, App
installations, repository grants and source revisions. KAORI records
source-qualified identity, access-grant history and collection
outcomes. It does not clone Git repositories or treat a GitHub
login as an application installation.

This guide covers only source-defined **Overview** and
**Repositories**. Pull Requests, Actions, governance, DORA
metrics and cross-domain release lineage are **not** implied
by the existence of the Source Control workspace.

## Access and prerequisites

The current limited product workspace is **temporarily gated
to a local database Super Admin** together with applicable
`integrations.manage` permissions. This is a staging/UAT
authorization boundary, not a generally accepted production
resource-scoped access policy.

An account granted only a generic integration permission may
still be denied access to this workspace. The pending
resource-scoped authorization contract is owned by KAORI #724.
Never bypass access restrictions by guessing a route or switching
to another installation.

Before investigating data, confirm that the intended GitHub App
source was configured and its exact installation scope was
validated by an authorized integration administrator. A saved
connection, available adapter or source-defined menu label does
not imply a successful live installation or committed collection.

## Identities and evidence boundaries

The source identity model distinguishes:

- **Account:** A host-qualified provider-native account identity,
  such as an observed organization or user. Its mutable login
  is not its immutable identity.
- **Installation:** A specific GitHub App installation and
  its granted repository scope, not the GitHub account itself.
- **Repository:** A host-qualified native repository identity.
  One repository may have grants through more than one
  installation.
- **Grant:** An installation-to-repository access relationship,
  recorded independently of source presence, current account
  labels and historical access.
- **Revision:** A repository-scoped immutable exact commit
  SHA only when explicitly collected and committed.
- **Reference:** A mutable branch or tag pointer whose
  observed transitions are distinct from immutable revisions.

A repository missing from one installation's latest authorized
grant is not thereby proved deleted. **Access lost** and
**repository deleted** are different conclusions.

## Task: review source installations

1. Sign in with an authorized local Super Admin account for
   the actual accepted evaluation environment.
2. Open **Source Control → Overview** when this workspace
   is enabled for the account.
3. Review the installation identities and committed collection
   coverage. Check the observed account identity, collection
   status and observation timestamp.
4. Choose an eligible installation to inspect in
   **Source Control → Repositories**. Avoid summing
   overlapping installation counts as if they were distinct
   organization-wide repository totals.
5. Record whether an account, installation or observation is
   *unknown*, *pending*, *stale* or actually committed.
   Missing identity evidence must not be silently invented.

**Expected result:** a source-qualified understanding of
which installation KAORI observed, not a live GitHub
organization-wide inventory.

The current evaluation source caps the scoped installation
list at **50 rows**. A truncated list is explicitly
incomplete and cannot justify claiming full organizational
coverage.

## Task: examine committed repositories

1. In **Source Control → Repositories**, select the
   **specific authorized GitHub App installation**.
2. Review the last successfully committed collection and
   collection scope before interpreting the repository list.
3. Use the available **search**, **visibility** and
   **archive** filters to find recorded repository grants.
4. Move through the normal server-side pagination.
   The shared KAORI standard defaults to **5 rows** and
   supports 5/10/25/50 records per page.
5. Inspect reported repository identity, visibility, archive
   state and granted-access status.
6. Where a default branch and exact commit SHA are present,
   verify the **observation time** and that the reference
   belongs to the selected committed repository scope.
   An observed mutable branch tip is not proof that the
   same SHA is still live at GitHub.

**Expected result:** a bounded, installation-scoped list
of committed grants and available revision evidence.
Viewing this list performs no Git clone or live provider
mutation.

### Unknown is not a verified zero

An authorized completed collection that observed no
granted repositories can be represented as a **true
observed zero**. An unrun, blocked, failed, partial
or superseded collection provides **unknown or
incomplete evidence**, not zero.

Collection generations are fenced; an older collection
must not overwrite a newer accepted one. Repository
rename and grant-loss history remain meaningful.
Do not treat a source outage as proof that repos
have been removed.

## Troubleshooting and safe escalation

- **Workspace absent or access denied:** confirm local
  Super Admin authorization and actual route permission;
  generic integration access is not sufficient.
- **Installation unavailable:** inspect the owning
  Integration instance's validation and eligibility
  with an authorized administrator.
- **Repository list empty:** distinguish no committed
  collection, a completed zero, filters returning no
  matches, or a scoped installation with no grants.
- **Unexpected repository disappearance:** inspect
  collection generation, access-grant history, provider
  scope and effective dates before concluding deletion.
- **Unknown default-branch SHA:** check whether precise
  revision collection was accepted; do not use a stale
  ref or infer a current SHA from repository name.
- **Organization totals look incomplete:** review the
  installation selector, overlapping access grants
  and explicitly bounded/truncated source coverage.

Keep real repository names, organization identifiers,
tokens, private endpoints and webhook data out of
public screenshots or issue text.

## What is still outside this guide

The current app product roadmap separates future
Source Control workstreams for PR/review/check linkage,
engineering-flow/DORA metrics, Actions run/job data,
branch and ruleset governance, release/deployment
lineage and source-to-image-to-runtime correlation.
The presence of integration contracts does **not**
mean these are already installed, observed or approved.

No Source Control dashboard may claim developer
performance rankings, a guessed CI success rate or a
verified Git-to-Registry/Kubernetes runtime link
without independently committed source evidence and
appropriate permissions.

## Source and candidate applicability

Source-reviewed Application authority:
`app/source_control/README.md`,
`app/source_control/README_PRODUCT.md`,
`app/common/workspace_navigation_catalog.py`
and `app/common/workspace_navigation.py`, against
KAORI staging source
`197a7f7e598c111592a8ae36388865cd3aacf541`.

Before publication: verify an exact admitted application
candidate; live role-scoped browser navigation; at least
two isolated installation scopes; unknown versus true
zero; degraded retained snapshots; 50-row truncation;
permission denials; safe visual/rights evidence; and
Human Acceptance. This document remains `draft: true`
and is not part of the current public Docs RC.
