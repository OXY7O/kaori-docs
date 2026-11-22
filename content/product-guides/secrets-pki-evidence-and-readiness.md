---
id: secrets-pki-evidence-and-readiness
title: Secrets & PKI Evidence and Readiness
description: Interpret safe metadata-only Secrets and PKI evidence without claiming verified delivery or exposing secrets.
draft: true
sidebar_position: 5
---

> **Editorial status:** Unpublished source-reviewed draft for Docs #146.
> Source navigation is not proof of a live Vault deployment or accepted stable release.

## Purpose

**Secrets & PKI** is KAORI's provider-neutral operational workspace for committed, safe Secret metadata and public-certificate evidence. Vault remains authoritative for authentication, Secret material, engines and PKI issuance. KAORI does not store or reveal raw Secret values in the ordinary dashboard and Inventory views.

Provider registration and approved mounts are managed separately under **Integrations → Secrets Management → Secrets & PKI → Vault**. A configured connection, verified provider API and completed metadata collection are different readiness states.

The source-defined workspace contains **Overview**, **Inventory**, and **Lifecycle & Assurance**. Each evidence category has independent maturity and source requirements. A visible tab is not a guarantee that every PKI lifecycle capability has been admitted.

## Permissions and prerequisites

- **Read-only views:** The source routes require `secrets_pki.view`.
- **Provider setup:** Registering an instance and approving mounts requires `integrations.manage`.
- **Manual collection:** The registered inventory Job requires `secrets_pki.sync` and `jobs.execute`.
- **Public certificate overlap:** Cross-domain Kubernetes TLS evidence additionally requires `tls_certificates.view`.

Read permission does not authorize raw Secret access, revealing credentials, starting collection, issuing a certificate, or rotating a key. Scope and role controls must be verified for the accepted application candidate.

## Task: inspect Vault inventory readiness

1. Open **Secrets & PKI → Overview** with a permitted viewer account.
2. Check whether an active and enabled Vault source exists for the selected scope.
3. If the source exists, inspect whether an authorized KV v2 mount has been approved.
4. Review the inventory collection prerequisite and its last committed observation.
5. Open **Secrets & PKI → Inventory** and assess qualified aggregate counts, source coverage and evidence freshness.
6. Use the owning integration and Job views for authorized troubleshooting, without inspecting Secret values or exposing provider credentials.

**Expected result:** an honest view of source eligibility, metadata collection and readiness. A normal page load never performs a live Vault API read or launches a Job.

## Interpret the evidence state

- **No eligible source:** No active and enabled provider instance is bound to the selected scope.
- **Mount approval needed:** A source exists but no permitted KV v2 metadata mount was approved.
- **Collection Required:** The approved source is eligible, but no usable inventory commit exists.
- **Collection Failed:** An attempted first collection failed and current counts remain unknown.
- **Stale:** Previously committed evidence remains after a later failed attempt and must retain its old timestamp.
- **Partial:** Some approved source/mount scopes have usable evidence while others are unknown.
- **Scope blocked:** A configured source/mount budget is exceeded; the workspace must not show a falsely complete count.
- **Observed empty:** A qualified successful collection really reported zero records; missing observations are not zero.

Secret version state and public PKI evidence have separate readiness semantics. Soft deletion, scheduled deletion or destroyed KV versions do not prove revocation, certificate rotation or consumer adoption.

## Public PKI observations

The source design supports separate, approved public PKI issuer and optional stored-public-certificate collections. These provide bounded, per-mount evidence and public X.509 fingerprint or validity posture. They do not establish complete issued-certificate inventory, secret material custody or current endpoint TLS serving.

Where qualified and independently authorized, the read-only certificate-overlap projection compares public certificate fingerprints from committed Vault stored-certificate evidence with Kubernetes TLS Governance records. A matching fingerprint indicates identical observed public certificate bytes only. It does not establish Vault issuance origin, delivery by a controller, workload adoption, a successful rotation or current Ingress endpoint presentation.

The overlap requires `secrets_pki.view` and `tls_certificates.view`. Source rights, freshness and collection coverage are independently evaluated. A no-match, unavailable or stale observation cannot be treated as a security verdict.

## Task: inspect Lifecycle and Assurance

1. Open **Secrets & PKI → Lifecycle & Assurance** if the view is permitted in the accepted application candidate.
2. Review each available KV v2 or public PKI evidence category separately.
3. Check the committed generation, observation timestamp and source/mount coverage.
4. If certificate overlap is displayed, verify permissions and evidence readiness for both Vault and Kubernetes.
5. Record observed facts and unknown boundaries without suggesting secret rotation or endpoint delivery is proved.

**Expected result:** a safe interpretation of committed lifecycle and correlation evidence, not a change to Vault or Kubernetes.

## Troubleshooting and safety

- **Blocked after provider setup:** Review mount approval, source scope and the registered inventory Job outcome.
- **Unknown instead of zero:** Check whether a complete successful collection was committed.
- **Stale evidence:** Distinguish the last accepted snapshot from the most recent failed attempt.
- **PKI evidence absent:** Check the separate PKI mount and optional public-certificate collection scope.
- **Certificate overlap unavailable:** Confirm both source permissions and qualified collection states.

Never publish Secret paths, values, hashes, private keys, AppRole credentials, certificate subjects or raw provider responses. Do not start an unapproved mutation just to make a readiness indicator appear healthy.

## Source and release qualification

Reviewed sources: `app/secrets_pki/README.md`, `app/secrets_pki/CERTIFICATE_DELIVERY_CORRELATION.md`, `app/common/workspace_navigation_catalog.py` and provider integration contracts at KAORI Application revision `197a7f7e598c111592a8ae36388865cd3aacf541`.

The article still requires source-specific Vault and permission UAT, negative/failed/partial scenarios, sanitized browser review, exact application candidate evidence and independent human acceptance. It remains `draft: true` and is not a stable product guide.
