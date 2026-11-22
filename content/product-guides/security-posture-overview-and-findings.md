---
id: security-posture-overview-and-findings
title: Security Posture Overview and Findings
description: Investigate qualified CVE evidence and runtime correlation without mistaking unobserved assets for clean posture.
draft: true
sidebar_position: 6
---

> **Editorial status:** Unpublished source-reviewed draft for Docs #148.
> Staging source is not an accepted live scanner assessment or stable release.

## Purpose and source authority

**Security** is a cross-domain Assurance workspace that consumes committed observations rather than operating a scanner, SIEM or remediation engine. **Artifact Registry** remains authoritative for artifact digests, scan generations, affected packages and CVEs. Kubernetes and runtime owners independently supply observed workload bindings.

Security can correlate evidence only when the relevant source and permission boundaries have been qualified. A finding is not proof of exploitability, complete coverage, ownership of an application or a running workload with that immutable digest.

## Permissions and navigation

- **Security → Overview:** Read-only Security Snapshot, Exposure Analysis and qualified source context.
- **Security → Findings:** Detailed grouped CVE investigation, filters, pagination and source-qualified impact links.

Both routes require `security_posture.view`. Reading source-specific Artifact Registry Security details requires the additional `artifact_registry.view` permission. An Assurance reader cannot inherit access to Registry data solely from the aggregate Security role.

Source catalog visibility and actual runtime access must be verified with an accepted application candidate. Intelligence, Reports and Integration links also retain their independent permissions.

## Task: inspect Security Overview

1. Open **Security → Overview** with an authorized account.
2. Review the source readiness and scanner freshness before interpreting severity totals.
3. Inspect **Finding Highlights** for up to three qualified, severity-ordered CVEs and accompanying source-wide counters.
4. Examine **Assets & Impact**, **Findings & Investigation**, and **Evidence & Sources** for observed digest, runtime and source context.
5. Use **Open Findings** to reach the full investigation registry when you need search or pagination.

**Expected result:** a source-backed explanation of the latest usable security and runtime observations. Three highlighted findings are not the complete Registry finding set, and an empty highlight is not an all-clear.

## Task: investigate the Findings registry

1. Open **Security → Findings** and read the Evidence Qualification information.
2. Inspect source freshness separately from runtime-correlation readiness.
3. Apply the available **Search CVE** and **Severity** filters.
4. Review the grouped CVE, affected digest count and available observed runtime binding evidence.
5. Page through records with the canonical default **5-row** pagination and 5/10/25/50 size options.
6. Follow a permitted exact-CVE impact link into Artifact Registry only if you hold its separate source permission.
7. Use **Refresh View** to refresh the committed page projection, not to request a provider scan.

**Expected result:** a bounded read-only investigation of current committed evidence. Normal GET requests do not launch scans, synchronize sources or mutate workloads.

## Interpret missing and stale evidence

- **No eligible Registry integration:** Security cannot invent a scan or assert absence of vulnerabilities.
- **Inventory not collected:** Findings and affected-asset coverage remain unknown.
- **Failed refresh:** Last-good scanner evidence may be retained with explicit age and stale status.
- **New successful scan:** The latest usable source generation supersedes older scanner observations.
- **Partial assessment:** Unscanned or unsupported artifacts cannot be counted as remediated or secure.
- **Runtime correlation unavailable:** Binding totals and impact must remain **Unknown**, not zero.
- **Source permission denied:** The user may see an authorized aggregate but not Registry impact details.

A successful Security page response is not a live provider request or validation of current container runtime. Scanner freshness, Registry synchronization, Security View refresh and runtime correlation represent different operations.

## Troubleshooting and safety

If a finding appears inconsistent, compare the scanner generation, artifact digest, source selection, collection timestamp and runtime-correlation status. If records disappear, check source coverage, filters, access and the accepted generation before interpreting it as remediation.

Do not run a scanner, delete artifacts, restart workloads or change security controls merely to make an empty or stale dashboard appear healthy. Such actions require separate authorized operational workflows and evidence.

Use sanitized illustrations only. Real artifact identifiers, customer applications, private CVE exposure reports, internal endpoints, provider credentials and incident evidence are not suitable for this public documentation source.

## Source and release qualification

Reviewed Application sources: `app/security_posture/README.md`, `app/security_posture/routes.py`, `app/common/workspace_navigation_catalog.py` and authoritative Artifact Registry security/runtime contracts at revision `197a7f7e598c111592a8ae36388865cd3aacf541`.

Before publication, verify an admitted application candidate, actual role-scoped browser navigation, scanner stale/partial states, correlation-denied/unknown paths, Registry link authorization, accessibility and independent Human Acceptance. The article remains `draft: true` and is not a stable security guarantee.
