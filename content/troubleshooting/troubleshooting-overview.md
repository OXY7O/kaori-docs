---
id: troubleshooting-overview
title: Troubleshooting Overview
description: Investigate KAORI evidence gaps with safe, source-scoped checks before requesting changes.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished, source-reviewed draft for Docs #8. Inspected KAORI Application staging at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. No stable application release, executed UAT, or operational remediation is implied.

## Start with the evidence boundary

KAORI presents normalized, committed evidence from authorized external sources. A missing or outdated observation may indicate a source connection issue, an incomplete collection, a stale committed snapshot, a filter mismatch, or a permission boundary. The visible result alone does not identify which cause applies.

Troubleshooting begins with **read-only inspection**, not an automatic retry or privileged infrastructure mutation. The external provider remains authoritative for its live resources; KAORI's committed snapshot records what its collection was able to observe within a defined scope and time.

## A safe investigation sequence

1. **State the symptom.** Describe the visible issue without assuming its cause. For example, “The selected cluster inventory appears older than expected,” not “Kubernetes is down.”
2. **Confirm authorized scope.** Identify the capability, provider/cluster, relevant filters, and account permission. A denied view is not evidence that the resource is missing.
3. **Inspect committed evidence.** Check the available snapshot timestamp, collection coverage, source/connection status, and any stale, incomplete, or unobserved indicators.
4. **Separate collection and presentation.** A job request or queued task does not establish that a new inventory generation was committed. Conversely, an older committed generation may remain readable after a failed attempt.
5. **Review safe alternatives.** Recheck the selected cluster, namespace and resource family; inspect another permitted read-only evidence surface when available.
6. **Escalate with a bounded finding.** Record sanitized scope, observation time, actual state, unknowns, and the owner of the next authorized action. Do not copy credentials, internal endpoints, production identifiers, or private logs.

## Interpret common evidence outcomes

- **No committed snapshot:** there is no inventory generation to interpret; it is not evidence of an empty source.
- **Stale observation:** the committed evidence is older than the applicable freshness window; it does not necessarily mean the live source is unavailable.
- **Incomplete collection evidence:** one or more resource families may lack complete committed coverage; missing rows must not be converted to zero assets.
- **Connection not observed or failed:** current provider readiness is uncertain or reported failed; the previous snapshot and current source health must be considered separately.
- **No matching filtered rows:** the selected committed generation contains no matching rows in that scope; review filters before making a source-wide claim.
- **Permission denied:** request an authorized access review rather than bypassing access controls.

These are **explanatory categories**, not a promised complete public runtime status enum. Exact labels and transitions must be verified against an accepted application release before a separate Evidence States Reference is published.

## Conceptual decision flow

```text
Visible inventory symptom
          |
          v
Confirm permission and source scope
          |
          v
Read committed timestamp + collection coverage
          |
     +----+-----+
     |          |
     v          v
Evidence     Evidence missing,
present      stale or incomplete
     |          |
     +----+-----+
          |
          v
Bounded finding + authorized escalation
```

**Diagram description:** The reader confirms permission and scope, inspects committed evidence, and records either supported observations or explicit uncertainty. The flow never assumes a live source probe or remediation.

## Source and publication status

- **Owner:** Docs #8; inventory tutorial/how-to belongs to Docs #6.
- **Source-reviewed:** `app/kubernetes/inventory/{README.md,overview.py,routes.py,synchronization.py}` and `docs/product/README.md` at the pinned staging SHA.
- **Not yet verified:** real user-facing status vocabulary, exact browser controls, support runbooks, accepted application release applicability, role-specific UAT, screenshots, accessibility, and human acceptance.
- **Publication dependencies:** Docs #2 article shell, Docs #15 release mapping, security/source owner review, staging Full Admission, and human acceptance.

This page stays `draft: true` and out of public routes/search.
