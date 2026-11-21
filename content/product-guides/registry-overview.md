---
id: registry-overview
title: Registry Overview
description: Understand source-qualified artifact inventory, runtime relationships, and evidence limits in KAORI Registry.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished, source-reviewed draft for Docs #4. The implementation described below was inspected in KAORI Application staging, not verified through browser UAT or mapped to an accepted stable release. No supported product version is asserted.

## What Registry is for

**Registry** is a KAORI capability domain for understanding artifact inventory and its operational context. An external registry remains authoritative for the projects, repositories, artifacts, and provider-specific state it owns. KAORI presents normalized, source-qualified evidence to support inventory review, related runtime investigation, and controlled operational analysis.

A configured registry provider is a **source**, not a guarantee that every repository has been collected or every artifact scanned. The Registry capability and the provider integration have distinct responsibilities.

## Who uses this view

Infrastructure and platform operators may use Registry to inspect committed artifact records and investigate observed runtime relationships. Security readers may consult source-qualified findings where their permissions and the available evidence allow it. Integration administrators manage provider connections under separate authorization; this overview is not a provider setup guide.

The staging routes inspected for this draft require `artifact_registry.view` for read-only Registry pages. A user who can view a page does not thereby receive permission to synchronize evidence, manage an integration, or change a provider.

## How the evidence flows

```text
External registry (source authority)
             |
             v
Authorized collection + source scope
             |
             v
KAORI normalized / committed Registry evidence
             |
       +-----+------+
       |            |
       v            v
Artifact inventory  Observed runtime bindings
       |            |
       +-----+------+
             |
             v
Source-qualified operational context
```

This diagram is **conceptual**. It does not represent a live provider connection, a complete dependency graph, a scheduled scan, or a verified application release.

## What the staging implementation exposes

The inspected `app/artifact_registry/routes.py` registers read-only Registry inventory entry points for **projects**, **repositories**, and **artifacts**. Each resource workspace accepts a search query and source/environment/visibility filters, with paginated results and resource-detail views. The route layer checks `artifact_registry.view` before serving these pages.

The same source exposes a **Runtime Overview** and runtime-usage views. Runtime data is filtered by supported source, cluster, namespace, match type, exposure, and artifact identity. These are observed relationships from available committed inputs; a matching mutable image reference must not be treated as equivalent to an immutable digest match.

Registry Security and Supply Chain views are separately source-scoped. Their findings depend on usable committed inventory and scan evidence; an empty list cannot establish that all artifacts are free of vulnerabilities. Cross-domain Security Posture consumes authorized Registry evidence but does not replace the Registry source workspace or grant additional Registry access.

These statements describe **source-reviewed route and read-model contracts** at the pinned staging commit. They are not verified navigation instructions, availability guarantees, or permission claims for every account.

## Reading inventory responsibly

Before drawing an operational conclusion, verify the source instance and the selected inventory scope. Distinguish an asset that is absent from the committed snapshot from an asset proven absent in the external provider. Check when the relevant evidence was observed and whether the last collection was complete, partial, failed, or unavailable.

For runtime context, identify the relationship evidence and its strength. A workload binding is an observed association, not necessarily an application ownership record or a complete impact path. For security findings, retain scan provenance and last-good versus stale/partial evidence distinctions.

A successful job dispatch is not evidence that collection finished. Evidence synchronization is a separate, permissioned workflow and is **not** part of this read-only overview.

## Source-reviewed scope and publication limits

- **Application source:** `OXY7O/KAORI` at `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`, specifically `app/artifact_registry/routes.py`, `app/security_posture/README.md`, and `docs/product/README.md`.
- **Editorial owner:** Docs #4; Registry provider setup belongs to Docs #5 and tutorials to Docs #6.
- **Application applicability:** unassigned. Intended first stable line is not a verified release identity.
- **Pending verification:** exact accepted release manifest; actual browser navigation and role-specific visibility; real source/snapshot states; safe screenshot review; light/dark, keyboard, 200% zoom, and six viewport checks.

Until those checks and the native version mapping are approved, this file remains `draft: true` and excluded from the public documentation build and search. No cross-links to unpublished guides are provided.
