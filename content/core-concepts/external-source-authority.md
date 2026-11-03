---
id: external-source-authority
title: External Source Authority
description: Distinguish an external provider's authoritative data and execution from KAORI's normalized operational context.
draft: true
sidebar_position: 2
---

> **Editorial status:** Review draft, not approved for an application version or public publication.

## Who owns the source of truth?

An external platform remains authoritative for the information and operations it exposes. Depending on the capability, that might be an infrastructure manager, registry, monitoring system, source-control platform, or orchestration engine.

KAORI does not become the new source system merely because it reads, normalizes, and stores observations from one. Instead, KAORI is responsible for an **operational context** that clearly identifies where its observations came from and how they should be interpreted.

This preserves a simple boundary:

- **The external system:** owns its data, state transitions, and provider-specific execution semantics.
- **The integration adapter:** reads supported provider information within an explicit contract and scope, and reports collection outcomes.
- **KAORI:** normalizes and commits evidence, correlates supported relationships, presents operational context, and governs supported workflows.

## Provider state versus KAORI state

Suppose a provider changes an asset after KAORI's last successful collection. KAORI's stored observation still represents the **last committed evidence**, not the provider's current live state. A reader must be able to recognize the observation time and limitations.

Likewise, an unavailable provider is not automatically evidence that all assets formerly observed through it have failed. Connection health, source availability, collection completeness, and asset health are different facts.

When source evidence is missing or partial, KAORI should show **unknown, unavailable, stale, or partial** as appropriate. It should not infer a healthy state, invent missing inventory, or silently transform a source failure into an asset failure.

## Safe interpretation checklist

Before relying on an operational view, ask:

1. Which system and instance supplied this observation?
2. What permissions and collection scope applied?
3. When was the evidence collected or last refreshed?
4. Was the collection complete, partial, or unsuccessful?
5. Which conclusions belong to the provider, and which are correlations computed from committed evidence?

These questions are especially important when a dashboard combines information from independent providers.

## Operations remain governed

A visible action should not directly imply permission to change provider state. KAORI may orchestrate a separately admitted workflow, but the relevant provider or external engine still executes within its own contract. Target scope, authorization, validation, recorded outcome, and audit evidence are mandatory boundaries for any supported mutation.

**Source authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md), especially _Platform Boundary_, _Honest operational state_, and _Visibility before mutation_. No provider support matrix is asserted by this draft.

## Implementation evidence from KAORI staging

KAORI's Integrations module uses provider-neutral registry and adapter contracts, with bindings to managed assets instead of provider-to-provider foreign keys. For example, the **Kubernetes API** remains authoritative for resource state while the committed **Kubernetes Inventory** read path uses normalized database snapshots. Similarly, a registry provider remains authoritative for repository and artifact state while KAORI's Registry domain records source-qualified inventory and scan evidence.

**Source-reviewed staging implementation:** `app/integrations/README.md` and `app/kubernetes/inventory/README.md` at `OXY7O/KAORI` staging commit `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. This is code-level staging evidence, not a claim that every configured provider is ready or that any source was contacted during this documentation review.
