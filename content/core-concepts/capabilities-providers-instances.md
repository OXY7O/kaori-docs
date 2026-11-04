---
id: capabilities-providers-instances
title: Capabilities, Providers, and Instances
description: Learn the KAORI capability-first information architecture without confusing providers with product capabilities.
draft: true
sidebar_position: 1
---

> **Editorial status:** Review draft. This article is not mapped to an accepted KAORI Application release and is not publicly served.

## Why KAORI starts with capabilities

A capability is an operational responsibility, not the name of a vendor. KAORI organizes infrastructure information by the work an operator needs to understand or perform. A provider integration contributes information or execution to that capability; a configured instance identifies a particular connection and scope.

The hierarchy is:

1. **Capability or domain:** the operational purpose, such as infrastructure inventory, integration management, or controlled operational workflows.
2. **Provider:** an external technology that exposes information or supported operations through a defined integration contract.
3. **Instance:** a configured connection to that provider, with its own identity, environment, permissions, source scope, and collection state.

For example, **Integrations → Registry → Harbor** illustrates the hierarchy: Registry is the capability, Harbor is an example provider, and a configured connection represents an instance. This is a conceptual naming example, **not** a claim that a particular Registry workflow is supported in the currently deployed application.

## Why the distinction matters

An operator should not need to learn a completely different global navigation model for every external system. Capability-first organization helps different sources contribute to a consistent asset and evidence model while preserving their distinct contracts.

The layers must not be collapsed:

- A capability is not a promise that every provider is supported.
- A provider name does not establish that an instance is connected or healthy.
- An instance listed in inventory is not proof that its most recent collection is complete.
- Visibility of an asset does not authorize a state-changing operation.

## A conceptual reading path

```text
Operational question
      |
      v
Capability / domain
      |
      v
Provider integration contract
      |
      v
Configured instance + scope
      |
      v
Committed evidence and freshness
```

The diagram is **conceptual**, not a representation of an actual KAORI deployment.

## What an operator should verify

When reading an integration-backed page, first identify the capability and the configured source instance. Then check the environment, collection scope, last observation time, known limitations, and permissions before interpreting a result.

A provider remains authoritative for the data and execution it owns. KAORI is responsible for connecting that information through normalization, provenance, cross-domain context, and governance—not for copying the provider's entire product.

**Source authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/7272c81e495ef8e4d590355f1d1e6c4dd785eb91/docs/product/README.md), especially _Capability-first, not product-first_ and _Integration through explicit adapters_. This article requires release applicability and editorial approval before public publication.

## Implementation evidence from KAORI staging

The current source-reviewed **Integrations Overview** implements an independently counted Provider Catalog, persisted-runtime overview, and domain-coverage workspace. Kubernetes API targets, Prometheus/Thanos metrics instances and Alertmanager instances are counted by their own provider contracts. A Prometheus or Alertmanager instance does **not** have to be bound to a Kubernetes cluster to appear in the provider catalog.

For an operator, this means:

- Select the **capability** first (for example Observability), then the corresponding provider workspace.
- Inspect a **configured instance** before interpreting its runtime readiness and collection scope.
- Treat a planned provider card as a roadmap entry, not an available configuration flow.
- Treat a missing provider instance or unknown runtime observation as an explicit absence of evidence, never a healthy connection.

**Source-reviewed staging implementation:** `app/integrations/README.md` and `docs/modules/integrations/UI_REFERENCE.md` at `OXY7O/KAORI` staging commit `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. This draft has **not** passed application release publication/UAT; routes and availability must be revalidated against the accepted release before publication.
