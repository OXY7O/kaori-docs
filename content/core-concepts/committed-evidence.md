---
id: committed-evidence
title: Committed Evidence
description: Interpret source provenance, observation time, freshness, scope and unavailable operational state.
draft: true
---

> **Editorial status:** Review draft. This describes the architectural principle, not live production telemetry or a specific application release.

## What is committed evidence?

**Committed evidence** is operational information accepted into KAORI's own state with enough context to understand its origin, time, and scope. It is different from a transient live API response.

When a reader opens a normal operational page, committed KAORI state can provide a stable point of reference without forcing every view to depend on a real-time request to every provider. That is useful for historical reporting, cross-domain correlation, and reproducible operational decisions.

Committed does **not** mean universally current, complete, or correct. A previously collected observation can become stale, a collection can be partial, or its source can later become unavailable.

## The evidence questions

A credible observation should let the reader distinguish:

- **Source identity:** the provider and configured instance responsible for the information.
- **Scope:** the relevant environment, asset set, permissions, and any collection limits.
- **Observation time:** when information was observed, not merely when a page was rendered.
- **Collection outcome:** whether the attempt succeeded, partially succeeded, failed, or was not attempted.
- **Freshness:** whether the evidence is sufficiently recent for the operational decision.
- **Provenance:** how the evidence relates to its source and any downstream normalization or correlation.

A timestamp alone cannot establish completeness. A successful collection step alone cannot establish that every required asset was within scope.

## Conceptual evidence path

```text
Provider observation
      |
      v
Collection scope + source identity
      |
      v
Normalization and validation
      |
      v
Committed observation + provenance
      |
      v
Operational view / correlation / report
```

This is a conceptual path. It does not assert a specific database table, event schema, provider configuration, or running collection schedule.

## Interpreting uncertain states

**Unknown** means the system lacks sufficient evidence for a conclusion. **Unavailable** indicates a required source or operation cannot presently be consulted. **Partial** means only a subset of the expected scope is supported by the result. **Stale** means the last observation may be too old for the intended decision.

These conditions should be explicit and should never be treated as an implicit PASS. Historical evidence is valuable precisely because operators can inspect its limitations.

## Operational example

An infrastructure asset may have a previously committed inventory record while its current provider connection is unavailable. The inventory record can still support historical identity and ownership research. It cannot, by itself, prove the asset is healthy **now**.

Before acting, verify the source scope, observation freshness, authorization, and current operational boundary.

**Source authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md), especially _Asset Inventory_, _Operational Analytics_, _Reporting and Historical Context_, and _Honest operational state_. Specific implementation details require separate accepted application evidence.
