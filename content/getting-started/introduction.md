---
id: introduction
title: Introduction to KAORI
sidebar_label: Introduction
sidebar_position: 1
slug: /getting-started/introduction
description: Learn how KAORI connects authoritative infrastructure sources, committed evidence, and governed operational context.
draft: true
---

> **Editorial status:** This article is an unpublished review draft. It has no verified application-release applicability and must not appear in public documentation, navigation, or search.

KAORI is an extensible **infrastructure operations platform** that brings visibility, operational context, analytics, reporting, and governance together across integrated infrastructure assets. It helps teams interpret information from multiple systems without replacing the tools that own that information.

## Who is KAORI for?

- **Infrastructure operators:** understand assets, operational state, and the evidence behind a finding.
- **Platform and reliability engineers:** correlate context across systems while respecting each integration's boundaries.
- **Operational owners and reviewers:** evaluate traceable evidence, permissions, and the outcome of governed workflows.

This Introduction explains the platform's design principles, **not** a guaranteed feature list for a particular release.

## The capability-first model

KAORI organizes its architecture from capability to provider to instance.

| Level | Meaning |
| --- | --- |
| **Capability or domain** | The operational concern, such as inventory, integration management, or governance. |
| **Provider** | An external tool integrated within that capability under an explicit authority and normalization contract. |
| **Instance** | A specific configured connection with its own scope, environment, permissions, and collection state. |

For example, **Integrations → Registry → Harbor** describes the hierarchy, not a claim that every Harbor operation is available in a published application release.

## From source truth to shared context

The flow below is **conceptual**, not a live architecture diagram, environment inventory, or released-capability guarantee.

```text
External authoritative systems
         |
         v
KAORI adapters: scope, identity, normalization, provenance
         |
         v
Committed evidence: observed state, collection time, outcome
         |
         v
Cross-domain context: supported correlations and governance
```

**Accessible reading order:** External providers remain authoritative for their data and execution. KAORI adapters normalize observations with explicit scope and provenance. Committed evidence records what was actually observed. Supported cross-domain relationships may then inform operational context and governed decisions.

## Why committed evidence matters

Live provider state and KAORI's **last committed observation** can differ. A useful operational view distinguishes:

- **Source and identity:** which external system and assets the evidence describes.
- **Time and freshness:** when the information was collected and whether it may be stale.
- **Scope and completeness:** whether collection succeeded, was partial, unavailable, or remains unknown.
- **Provenance:** what evidence supports a relationship, finding, or recommendation.

Normal operational views can use committed KAORI state without requiring a live provider call for every page load. Missing evidence is not permission to invent asset health, connectivity, readiness, or a remediation recommendation.

## Visibility is not authorization

Finding an asset does not authorize changing it. The operating model separates three activities:

1. **Observe:** identify the source, asset, scope, and observation time.
2. **Interpret:** assess freshness, completeness, related evidence, and uncertainty.
3. **Act when supported and authorized:** validate an explicit target and impact, enforce permissions, let the authoritative provider or execution engine perform the operation, and preserve an auditable outcome.

A documentation example does not establish that an execution workflow is available in the application version a reader uses.

## Continue exploring

Return to the [Documentation Home](/) for the documentation catalog and orientation. Links to Getting Started follow-ups, Core Concepts, and other articles become available only after their content and applicable **KAORI application Major.Minor** release have been accepted.

**Editorial source:** KAORI Platform Direction. Product/release authority and source references are maintained in the internal Docs editorial register rather than presented as a publicly supported release claim.
