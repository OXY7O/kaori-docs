---
id: security-posture-overview-and-findings
title: Security Posture Overview and Findings
description: Safely investigate source-qualified CVE findings and runtime evidence without mistaking missing coverage for security.
draft: true
sidebar_position: 6
---

> **Editorial status:** Unpublished read-only draft for Docs
> #148. Product behavior is based on KAORI Application
> staging source, not an accepted live deployment or
> stable-release security assessment.

## Purpose and evidence ownership

**Security** is an Assurance workspace for interpreting
cross-domain committed security evidence. It does
**not** replace external scanners, the Artifact
Registry source workspace, a SIEM or an automated
remediation engine.

In the current source design, **Artifact Registry**
owns artifact digests, packages, scanner CVEs,
scan generations and source evidence. Kubernetes
and runtime owners provide separately committed
workload binding evidence. Security correlates
only those facts it can qualify without inventing
application ownership or runtime exposure.

A finding is useful only when its source, scan
freshness, affected artifacts, observed runtime
binding and relevant permission boundaries
are understood.

## Access and product navigation

The source-declared Assurance workspace contains
two entries:

- **Security → Overview:** A read-only security
  summary and source/evidence perspective.
- **Security → Findings:** The detailed,
  source-qualified CVE investigation registry.

Both routes require `security_posture.view`
in the source-owned route layer. Viewing
**Artifact Registry → Security** or opening
an exact-CVE source impact link also requires
the independent `artifact_registry.view`
permission. An aggregate Security view
does not grant source-domain read permission.

Other cross-links, including Intelligence,
Reports and Integrations, are separately
permission-filtered.

## Task: review the Security overview

1. Sign in with Security Posture viewing
   permission and open **Security → Overview**.
2. Inspect the Security Snapshot and source
   readiness before interpreting severity
   counts as a fleet-wide answer.
3. Review the **Exposure Analysis** summary.
   Its **Finding Highlights** display only
   the first three qualified severity-ordered
   CVEs and source-wide counters.
4. Use the other perspectives—**Assets & Impact**,
   **Findings & Investigation**, and
   **Evidence & Sources**—to examine
   available digests, observed runtime
   bindings and their evidence limitations.
5. Select **Open Findings** to move into
   the full investigation workspace.
   This is the authoritative Security
   page for detailed filtering and pagination.

**Expected result:** an explicitly qualified
view of collected scanner and runtime
evidence. An absent highlight is not proof
that no vulnerable artifacts exist.

### What freshness and coverage mean

- **Scanner freshness:** An unchanged CVE
  count does not prove that a rescanning
  event did or did not take place.
  Scanner evidence may be current,
  stale or incomplete.
- **Partial coverage:** Assets not covered
  by a usable scan cannot be counted
  as secure, remediated or absent.
- **Runtime correlation:** The presence
  of a CVE against an artifact digest
  does not automatically prove a workload
  is running that same immutable digest.
- **Unknown runtime scope:** When
  correlation is not Ready, runtime
  binding totals must remain
  **Unknown**, not zero.
- **Distinct CVEs:** Overview counts
  aggregate qualified latest usable
  scanner CVEs and are independent
  of the three visible highlights.

A scanner refresh, a Security source
view refresh, and a runtime correlation
worker are different operations with
different outcomes. Normal Security
GET requests must not silently trigger
them.

## Task: investigate the Findings registry

1. Open **Security → Findings**.
2. Review the Provider Authority,
   committed Evidence Qualification,
   scanner freshness and runtime
   correlation readiness in the
   page's source context.
3. Apply **Search CVE** or **Severity**
   filters to narrow the list.
4. Inspect the grouped CVE record,
   affected digest/source count and
   known observed bindings.
5. Use the canonical table pagination,
   defaulting to **5 rows** and offering
   5/10/25/50 page sizes.
6. Select a permitted exact-CVE impact
   link to Artifact Registry only if
   your account holds that independent
   source-domain permission.
7. Use **Refresh View** to refresh the
   *committed UI projection*, not to
   launch a scanner or provider call.

**Expected result:** a reproducible,
source-backed and permission-scoped
finding investigation. The result
does not assert actual exploitability,
full fleet coverage, successful patching
or verified remediation.

## Interpreting empty and degraded views

- **No Registry source:** The Assurance
  page cannot invent scan evidence.
- **Source registered but uncollected:**
  Inventory readiness remains unknown
  until a usable committed observation.
- **Failed later refresh:** Last-good
  scanner evidence may remain visible
  with explicit age and stale status.
- **Newer usable scan:** The newer
  accepted scan supersedes older
  artifact findings in normal reads.
- **Runtime correlation unavailable:**
  Scope counts and links must remain
  qualified instead of implying
  observed non-exposure.
- **Permission denied:** The Security
  page may be available even when
  Artifact Registry detail is not.
  Do not treat access denial as
  missing CVE evidence.

Do not run active scans, delete artifact
records or deploy patches just to force
a healthy-looking Security dashboard.
Those actions have separate domain,
job and change-approval controls.

## Source and candidate applicability

Reviewed Application authority:
`app/security_posture/README.md`,
`app/security_posture/routes.py`,
`app/common/workspace_navigation_catalog.py`,
and committed Artifact Registry
security/runtime evidence contracts
from KAORI staging source
`197a7f7e598c111592a8ae36388865cd3aacf541`.

Before RC publication, confirm the
admitted App candidate, real
permission-scoped browser behavior,
scanner generation and freshness
states, partial/unknown inputs,
Registry source-link 403 boundaries,
rightful sanitized visuals, and
Human Acceptance. This article
remains `draft: true` and does not
represent a stable security guarantee.
