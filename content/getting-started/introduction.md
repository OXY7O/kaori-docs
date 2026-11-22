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

## Four questions behind KAORI's operating model

The [KAORI Website](https://kaori.cloud/) introduces four connected ideas:
**Sources, Context, Evidence, and Governance**. They help explain how to
interpret an operational situation; they are **not** a fixed, synchronous
execution pipeline or a promise that every integration is enabled.

1. **Sources — What system is authoritative?** Identify the external tool,
   configured instance, resource and collection scope. The provider still
   owns its data and executes its own supported operations.
2. **Context — What can be connected?** Use normalized identities and
   supported relationships across domains. Similar names, timestamps or
   labels alone do not establish a dependency.
3. **Evidence — What was actually observed?** Inspect committed observations,
   provenance, collection time, completeness and unknown states before
   treating a finding as current or reliable.
4. **Governance — What decision is permitted?** Separate a read-only finding
   from a recommendation or authorized workflow. Any supported change needs
   explicit target and impact validation, permissions, provider execution
   and an auditable result.

**Illustrative example:** A monitoring signal may suggest that a workload
needs investigation, while another tool records an artifact or infrastructure
asset. Those records only form a trustworthy relationship if an accepted
identity or binding connects them. A signal does not prove root cause, a
matching name does not prove dependency, and seeing a possible action does
not grant permission to execute it.

This way of reading KAORI applies across capabilities. The actual pages,
supported sources, permissions and workflows must be verified for an
**accepted KAORI Application release** before any version-specific guide
is published.

## The capability-first model

KAORI organizes its architecture from capability to provider to instance.

| Level                    | Meaning                                                                                                    |
| ------------------------ | ---------------------------------------------------------------------------------------------------------- |
| **Capability or domain** | The operational concern, such as inventory, integration management, or governance.                         |
| **Provider**             | An external tool integrated within that capability under an explicit authority and normalization contract. |
| **Instance**             | A specific configured connection with its own scope, environment, permissions, and collection state.       |

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

## A safe way to read an operational finding

Suppose an inventory view shows a resource that was last observed during an earlier collection. This example is illustrative; it is **not** a screenshot, a live system state, or evidence of a particular release.

| Operator question              | Evidence to examine                                                                         | What it cannot prove alone                             |
| ------------------------------ | ------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Which resource is this?        | The configured provider instance, resource identity, and collection scope                   | That the source still exposes the resource now         |
| How recent is the information? | Observation time, last completed collection, and reported freshness                         | That all assets were successfully collected            |
| Why is a finding shown?        | Supporting committed observations, correlation inputs, and missing-data indicators          | That the relationship is confirmed beyond the evidence |
| May an action be taken?        | Current authorization, supported workflow, verified target, and provider execution boundary | That viewing the record grants mutation permission     |

An **unknown** state is not an empty healthy state. If current provider verification is required for a change, perform it through the separately authorized operating workflow; do not infer it from historical evidence. The provider remains authoritative for execution and current source truth.

These principles are version-neutral. Exact UI routes, supported providers, permissions, automation operations, and troubleshooting commands must be validated against an accepted KAORI Application release before this draft is published as a supported guide.

## Continue exploring

Return to the [Documentation Home](/) for the documentation catalog and orientation. Links to Getting Started follow-ups, Core Concepts, and other articles become available only after their content and applicable **KAORI application Major.Minor** release have been accepted.

**Editorial source:** KAORI Platform Direction. Product/release authority and source references are maintained in the internal Docs editorial register rather than presented as a publicly supported release claim.
