---
id: introduction
title: Introduction to KAORI
description: Understand KAORI's role, source authority, committed evidence, and operational boundaries.
draft: true
---

> **Editorial status:** This introduction is a review draft. It is not an accepted product-version guide or evidence of a stable KAORI release.

## What is KAORI?

KAORI is an extensible infrastructure operations platform designed to connect infrastructure visibility, operational workflows, analytics, reporting, and governance. It provides a consistent operational context across integrated infrastructure assets and data sources.

KAORI is **not** a replacement for every infrastructure provider, monitoring engine, inventory source, or configuration tool. Each external system remains authoritative for the data and execution it owns. KAORI's value comes from connecting that information through explicit capability and domain contracts.

The platform is intended for infrastructure operators, platform and reliability engineers, and teams responsible for evidence-based operational governance. A documentation topic does not, by itself, mean that its corresponding capability is available in a specific application release.

## Start with a capability, not a vendor

KAORI's structure follows three levels:

1. **Capability or domain:** the operational responsibility, such as infrastructure inventory, integration management, or a governed workflow.
2. **Provider:** an external system integrated under that domain through an explicit source-of-truth and normalization contract.
3. **Instance:** a configured provider connection with its own scope, environment, health, permissions, and collected evidence.

For example, a registry is an integration capability; Harbor is a possible provider; a particular Harbor connection is an instance. Describing the hierarchy does **not** assert that a given provider workflow is supported by an accepted KAORI application release.

## From external sources to operational context

The diagram below is **conceptual**. It does not show a live environment or guarantee that all depicted functions are available today.

```text
External systems
(authoritative data and execution)
                 |
                 v
KAORI source adapters
(normalization, scope and provenance)
                 |
                 v
Committed KAORI evidence
(observed identity, collection time and status)
                 |
                 v
Cross-domain operational context
(correlation, analysis, governance and workflows)
```

**Accessible reading order:** external systems provide authoritative source information; adapters normalize that information with explicit scope and provenance; KAORI preserves committed evidence; connected evidence may support cross-domain operational context and governed workflows.

## What does committed evidence mean?

A live provider response and the last committed KAORI observation are not necessarily the same thing. An operational view should make clear when a result was collected, which source it came from, and whether the scope is complete, partial, stale, unknown, or unavailable.

Committed evidence allows operational context to be inspected and correlated without making every normal page load depend on a live provider request. It does not authorize KAORI to invent a missing fact, a relationship, an asset's health, or an operational recommendation.

A correlation should be treated as an observed relationship only when its source evidence supports that conclusion. Otherwise, it remains incomplete or a hypothesis.

## Read-only visibility versus operational action

Seeing an asset is different from changing it. A governed operational action requires a permitted and explicit target, validation of scope and impact, server-side authorization, and an auditable result. The provider or external execution engine remains the execution authority where applicable.

This distinction is important when reading future product guides:

- **Observe:** understand the asset, source, environment and observation time.
- **Interpret:** evaluate completeness, provenance and related evidence.
- **Act:** use a separately supported, authorized and auditable workflow only when that capability is actually available.

## What comes next?

Return to the [Documentation Home](/) to explore the planned article categories. Versioned Getting Started, Core Concepts, Product Guides and Integration articles will be linked only after their content is reviewed and mapped to an accepted KAORI application release.

**Source and attribution:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md) governs platform positioning and capability language. Current release authority and feature availability live in the KAORI application repository, not in this draft.
