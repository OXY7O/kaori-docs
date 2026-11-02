---
id: cross-domain-correlation
title: Cross-Domain Correlation
description: Understand how separately sourced evidence may support shared operational context without inventing relationships.
draft: true
---

> **Editorial status:** Conceptual review draft only; no current feature availability or specific correlation accuracy is asserted.

## Why correlation matters

One infrastructure tool sees only the domain and resources it manages. An operational decision may involve multiple domains: an infrastructure asset, its environment, a workload, a related service, a change record, or an operational finding.

KAORI's architectural objective is to connect **supported, committed evidence across domains** so an operator can see context that no single provider can provide by itself. The result should improve investigation and governance rather than become another isolated provider dashboard.

## Evidence before relationships

Correlation requires evidence of identity and relationships. A shared label, similar hostname, or coincident timestamp may be useful as a research clue, but it does not necessarily prove that two records describe the same asset or that one service depends on another.

A responsible view distinguishes:

- **Observed relation:** supported by a defined, traceable source or accepted mapping.
- **Possible relation:** a hypothesis or candidate match that has not yet met the evidence contract.
- **Unknown relation:** insufficient source evidence to draw a conclusion.
- **Out-of-scope relation:** a relationship the current integration or collection does not cover.

KAORI should not invent an impact path merely because a visualization needs an edge to draw.

## Conceptual correlation flow

```text
Source A                 Source B
   |                        |
   v                        v
Committed evidence      Committed evidence
   |                        |
   +--------+  +------------+
            |  |
            v  v
    Identity + relationship evidence
                 |
                 v
       Correlated operational context
                 |
                 v
        Scope-aware investigation
```

The flow describes an intended method. It is not a screenshot of active data, a dependency graph in use, or a claim that two particular integrations are available.

## Read an operational relationship safely

For any asset, dependency, or impact path, an operator should be able to ask where both sides came from, what rule established the relationship, when it was observed, and whether the supporting evidence is complete.

Without that context, a correlation is an exploratory lead rather than a verified fact. This distinction becomes more important when findings are used for risk prioritization, incident response, or a proposed change.

## From correlation to action

A correlated view can help someone understand scope or potential impact, but it does not automatically authorize infrastructure mutation. Any supported operational action still requires permissions, explicit target selection, validation, and audit evidence.

**Source authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md), especially _Infrastructure Mapping_, _Asset Inventory_, and _Operational Analytics_. Release-specific feature behavior must be reconciled to accepted application evidence before publication.
