---
id: harbor-provider-guide
title: Harbor Registry Provider
description: Review the staging Harbor connection contract, validation boundaries, and evidence required before a release-qualified setup guide can be published.
draft: true
sidebar_position: 2
---

> **Editorial status:** Unpublished, source-reviewed staging draft for Docs #5. The controls below were inspected in source code and templates, **not** exercised through accepted browser UAT. This is not a released setup procedure or permission to connect a real provider.

## Purpose and authority

Harbor is an external OCI Registry provider under KAORI's Registry integration domain. Harbor remains authoritative for its projects, repositories, artifacts, scan evidence, and provider-side policies. KAORI owns the configured integration identity, validation evidence, runtime observation, and separately committed normalized inventory.

A registered connection is not proof of a completed collection, current security posture, or readiness of optional downstream consumers.

## Prerequisites and permission boundary

The staging Harbor workspace routes for connection registration, testing, detail, Full Validation, and Runtime Refresh are guarded by `integrations.manage`. Registry artifact inventory read pages use a **different** permission, `artifact_registry.view`; Registry Security Sync uses `artifact_registry.sync`. A reader of Registry evidence must not assume integration-management or synchronization privileges.

The inspected registration form defines connection name, environment, optional description, Harbor API endpoint, authentication method, username/password for Basic Authentication, request timeout, TLS verification, and an enabled flag. The source supports Basic Authentication and Anonymous/Public Read-Only modes. A Harbor identity should be provisioned with only the read scope required by the approved integration contract. Never paste passwords, tokens, endpoint secrets, or real tenant details into documentation, screenshots, tickets, or logs.

Harbor outbound transport requires an **approved HTTPS origin** and verified certificate trust. Application/worker origin allowlisting and trusted CA configuration are operator-owned prerequisites; documentation readers should not disable TLS verification, bypass network egress controls, or copy private CA material. A connection test cannot compensate for an unapproved endpoint.

## Source-reviewed connection sequence

The following is a **code-level workflow outline**, not a validated click-by-click procedure for any released KAORI version.

1. **Prepare an authorized connection scope.** Identify the intended Harbor environment, approved HTTPS origin, least-privilege read identity, and which projects should be visible. Administrative network/CA configuration is out of scope.
2. **Inspect the Registry provider workspace.** Staging code defines an `Integrations → Registry → Harbor` workspace and a separate registration form. Actual menu visibility and navigation must be confirmed with an authorized browser account.
3. **Supply the connection fields and Test Connection.** The test checks provider identity/reachability only. Source code binds the successful test proof to the current user and submitted fields for ten minutes. Changing a bound field or letting the proof expire requires a new test.
4. **Register the connection only when authorized.** The source enforces a valid test proof before saving a new connection. Registration creates an integration instance, not a validated Registry inventory.
5. **Review Full Validation separately.** The provider validates system identity, provider health, project discovery, repository discovery, version/compatibility, and required capability evidence. A representative visible project is needed to prove repository discovery; an empty project list must not be misreported as complete readiness.
6. **Interpret Runtime & History separately.** Runtime Refresh observes lightweight health; it does not substitute for Full Validation, inventory collection, or source freshness. A queued validation/refresh job is not a completed successful result.

The source detail template includes **Configuration**, **Validation & Capabilities**, **Runtime & History**, and **Inventory & Lifecycle** sections. These are staging template labels, not a promise that every section or action is available to every role in a released build.

## Evidence interpretation

| Observation | What it can support | What it does not prove |
| --- | --- | --- |
| Successful Test Connection | Submitted endpoint identity and reachability at test time | Compatibility, inventory completeness, or provider readiness |
| Full Validation readiness | Provider-owned compatibility and required API capability evidence | Every project/artifact collected or optional consumer binding ready |
| Runtime health observation | Lightweight provider health at observation time | Fresh committed Registry inventory |
| Inventory evidence | Scoped committed source observations, if collected | Entire Harbor truth or current vulnerability-free state |
| Optional metrics/webhook coverage | Downstream adoption when independently evidenced | Mandatory core Registry readiness |

The application separates provider core readiness from optional Metrics Source and webhook reconciliation coverage. A webhook event is a fast path; scheduled reconciliation remains the correctness path. Neither delivery nor a queued job is evidence that all artifacts have been synchronized.

## Safe investigation before escalation

When a connection appears unavailable or evidence is missing, first check the account's permitted scope, selected source/environment, last validation result, observation time, and any partial or failed collection state. Distinguish **connection not ready**, **provider unavailable**, **no visible projects**, **not collected**, and **stale/partial committed data** without assuming they share a single runtime status enum. Escalate endpoint allowlisting, certificate trust, credential rotation, or worker availability to an authorized integration operator; do not suggest insecure TLS, privileged reruns, or Harbor policy mutation.

## Source evidence and remaining gates

- **Application source:** `OXY7O/KAORI@7272c81e495ef8e4d590355f1d1e6c4dd785eb91`.
- **Inspected implementation:** `app/integrations/registry/providers/harbor/README.md`, `application/routes.py`, `application/forms.py`, `application/registration.py`, `validation.py`, `app/templates/integrations/registry/providers/harbor/instance_form.html`, `instance_detail.html`, and `app/definitions/catalogs/integrations/registry/contract.yaml`.
- **Authorization cross-check:** `app/integrations/routes.py` and `app/artifact_registry/routes.py`.
- **Editorial owner:** Docs #5. **App release applicability:** unassigned; first intended stable release remains a target, not accepted evidence.
- **Required before publication:** accepted release mapping and immutable App manifest, authorized real-account UAT of each field/action/status, actual permission and failure scenarios, security review of credential/TLS guidance, sanitized screenshots, native article navigation, accessibility and six-viewport/two-theme checks, staging Full Admission, human acceptance, and signed Docs release.

Keep this file `draft: true`, out of public routes and search. Do not link to other unpublished articles.
