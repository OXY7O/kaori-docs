---
id: integration-catalog
title: Integration Catalog
description: Understand KAORI integration domains, provider definitions, and the difference between a catalog entry and a usable connection.
draft: true
sidebar_position: 1
---

> **Editorial status:** Unpublished, source-reviewed staging draft for Docs #5. Provider lifecycle entries below describe the application source catalog at the pinned staging commit, **not** verified availability in a supported KAORI release. No application version or public integration URL is claimed.

## Find an integration by capability

KAORI organizes integrations as **domain → capability → provider → configured connection**. Start with the operational capability, then inspect the source provider and the particular connection that owns the data or operation. A provider name in the catalog does not establish that a connection exists, is authorized, or has produced fresh committed evidence.

The source taxonomy groups provider definitions into the following domains. The table is a **source-reviewed catalog snapshot**, not a published support matrix.

| Domain | Capability represented in source | Provider examples in source definitions |
| --- | --- | --- |
| Orchestration | Container Orchestrator | Kubernetes (catalog: available); Rancher and Sangfor Kubernetes Engine (catalog: planned) |
| Observability | Metrics Source and Alert Source | Prometheus, Thanos Query, Alertmanager (catalog: available) |
| Storage | Object, File, and Block Storage | MinIO (catalog: available); Garage, AWS S3, Azure Blob Storage, NetApp and HPE definitions (catalog: planned) |
| Registry | Registry | Harbor (catalog: available); ECR, Google Artifact Registry, ACR, GHCR and OCI Distribution (catalog: planned) |
| Secrets Management | Secrets & PKI | HashiCorp Vault (catalog: available); OpenBao (catalog: planned) |
| Source Control | Source Control | GitHub (catalog: available); GitLab and Bitbucket (catalog: planned) |

**Meaning of catalog lifecycle:** `available` and `planned` above are the exact provider-matrix metadata categories at the inspected source SHA. They do **not** mean a provider has passed staging UAT, is connected in an environment, or is supported in a signed stable release. The planned providers must not be offered as setup instructions or selectable released options.

## What a connection represents

```text
Capability domain
    |
    +-- Provider definition (adapter and compatibility contract)
             |
             +-- Configured instance (endpoint, environment, permissions)
                      |
                      +-- Test Connection (identity / reachability)
                      +-- Full Validation (provider capability evidence)
                      +-- Runtime observation (separate health evidence)
                      +-- Committed source observations (scope and freshness)
```

**Accessible reading order:** A domain groups a capability; a provider definition describes a possible adapter; an instance identifies a configured connection. Connection testing, provider validation, runtime observation, and downstream collection are distinct evidence stages. The diagram is conceptual and contains no live integration data.

## Interpret readiness and coverage separately

- **Test Connection** is an identity/reachability check, not a provider-ready or inventory-complete result.
- **Full Validation** evaluates compatibility and provider-owned required capabilities. A ready provider does not prove that every downstream asset binding is eligible.
- **Runtime Refresh** observes lightweight health; it does not replace Full Validation or the last committed inventory.
- **Committed inventory** has its own source, collection scope, timestamps, and partial/stale/unavailable conditions.
- **Integration Coverage** can include optional downstream adoption (for example, metrics or webhooks). A missing optional adoption dimension is not automatically a failed core provider connection.

A source definition does not authorize a reader to manage credentials or run jobs. The inspected integration-domain GET routes use the server-side `integrations.manage` permission. Exact visible controls and role behavior still require release-specific browser UAT.

## Registry provider example

Harbor is the first source-reviewed Registry provider in the staging adapter catalog. Harbor remains authoritative for registry projects, repositories, artifacts, scans, and native policies; KAORI holds normalized connection and committed observation evidence. This draft deliberately does not link to an unpublished Harbor procedure.

## Evidence and publication boundary

- **Application source:** `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`.
- **Reviewed files:** `app/definitions/catalogs/integrations/taxonomy.yaml`, `provider_matrix.yaml`, `app/integrations/provider_matrix.py`, `app/integrations/routes.py`, `app/integrations/README.md`, and `docs/product/README.md`.
- **Editorial owner:** Docs #5; upstream article shell Docs #2 and release mapping Docs #15 are not accepted publication authority.
- **Release applicability:** unassigned. Neither a development `VERSION` nor a Docs RC identifies a supported application release.
- **Still required:** accepted App manifest, role-specific browser verification, catalog filter/no-results behavior, mobile/theme/a11y evidence, Docs version mapping, reviewed staging admission, and human acceptance.

This file remains `draft: true` and must not be added to public sidebar, routes, or search until all publication gates are satisfied.
