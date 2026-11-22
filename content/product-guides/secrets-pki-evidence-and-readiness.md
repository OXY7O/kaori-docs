---
id: secrets-pki-evidence-and-readiness
title: Secrets & PKI Evidence and Readiness
description: Safely interpret source-qualified secret metadata, public PKI observations, blocked prerequisites, and cross-domain evidence.
draft: true
sidebar_position: 5
---

> **Editorial status:** Unpublished, source-reviewed operator draft for
> Docs #146. This is not an approved production Vault integration guide,
> secret-reveal procedure, certificate rotation playbook or stable
> product claim. All examples are conceptual and contain no real data.

## What Secrets & PKI does

**Secrets & PKI** is KAORI's provider-neutral infrastructure
capability for understanding the readiness of secret metadata
collection and qualified public-certificate evidence.

A provider such as Vault remains authoritative for credentials,
secret engines, PKI issuance and material. KAORI does not
replace Vault or expose raw secret values in its ordinary
Inventory, Overview or Lifecycle read models.

The operational workspace is separate from provider setup:

- **Secrets & PKI → Overview:** Read-only operational
  dashboard and collection prerequisites.
- **Secrets & PKI → Inventory:** Safe aggregate
  KV v2 metadata, coverage and supported public PKI posture.
- **Secrets & PKI → Lifecycle & Assurance:**
  Source-qualified lifecycle/assurance interpretation.
- **Integrations → Secrets Management → Secrets & PKI
  → Vault:** Provider instance, credentials, eligible
  source and approved mount configuration.

A source-declared tab does not establish all PKI lifecycle,
consumer or historical analytics functionality as
generally available. Each evidence category is qualified
separately.

## Audience, authorization and prerequisites

Ordinary read-only Overview/Inventory access is guarded by
`secrets_pki.view` in the source-owned routes. Provider
connection and approved mount configuration require the
separate `integrations.manage` permission.

Manual inventory collection is a governed registered Job
whose owning contract requires `secrets_pki.sync` and
`jobs.execute` authorization. Being able to view an
Inventory summary does not authorize initiating collection
or modifying a Vault instance.

The current metadata inventory depends on an active,
enabled Vault provider instance and explicitly approved
KV v2 mounts. Connection validation, mount approval,
job completion and committed Inventory readiness are
**different facts**.

The source enforces collection scope limits. Over-budget
source/mount scope must remain **Blocked** rather than
producing an incomplete yet apparently healthy count.

## Task: inspect collection readiness safely

1. Sign in with the appropriate viewing role and open
   **Secrets & PKI → Overview**.
2. Inspect the source and collection prerequisites.
   Distinguish a missing eligible Vault source from a
   registered instance without an approved KV v2 mount.
3. If a mount is configured but not collected, read the
   **Collection Required** state. An authorized operator
   handles the registered collection Job separately;
   the dashboard does not dispatch jobs on GET.
4. Open **Secrets & PKI → Inventory** and review the
   committed coverage and observation timestamp.
5. Compare the displayed evidence state with the
   actual permitted source and mount scope. A
   connection probe alone is not KV v2 inventory proof.
6. If the result is blocked, partial, stale or failed,
   use the sanctioned integration or job workflow
   to investigate without exposing Secret paths
   or credential material.

**Expected result:** a safe understanding of what
aggregate metadata was committed, which prerequisites
are missing, and why a readiness state was assigned.

Normal viewing never needs to enumerate Vault secret
values, log AppRole credentials or reveal private keys.

## Interpret blocked, empty and stale states

- **No eligible source:** No qualifying active and
  enabled Vault connection for the selected scope.
- **Mount approval needed:** A Vault connection exists
  without an explicitly approved KV v2 metadata mount.
- **Collection Required:** The relevant source/mount
  is configured, but no accepted inventory commit exists.
- **Inventory Collection Failed:** A first attempted
  collection failed; there is no qualifying committed
  snapshot. The observed counts remain unknown.
- **Stale previous evidence:** A previous successful
  collection was retained after a later failure.
  It is historical evidence, not a fresh source claim.
- **Partial:** Only some authorized source/mount
  observations were qualified; totals must not imply
  complete coverage.
- **Scope limit exceeded:** The source budget prevented
  a qualified collection; counts remain withheld
  instead of being silently truncated.
- **Observed empty:** A genuinely successful
  complete collection can record a qualified zero.
  Missing or failed collection cannot.

A secret version that is soft deleted, scheduled for
deletion or destroyed is a source-owned lifecycle
observation. None of those states establishes
revocation, certificate rotation or consumer adoption.

## Public PKI evidence and its limitations

Some reviewed source slices can summarize approved
Vault **public issuer** and optionally enumerated
**stored public certificate** observations. These
are different collection contracts from KV v2
metadata inventory and may be disabled or unqualified.

The source model preserves per-mount timestamps and
public X.509 fingerprints/validity evidence.
Ordinary summary views do **not** reveal KV secret
names, paths, credential hashes, private key material,
certificate subject/SAN or raw provider responses.

The dedicated read-only **certificate overlap**
projection can compare approved stored public
certificate fingerprints from Vault with committed
Kubernetes TLS Governance fingerprints. This
requires independent visibility rights: both
`secrets_pki.view` and `tls_certificates.view`.

An exact public-certificate fingerprint match proves
only **matching public certificate bytes** in the
observed sources. It does not prove:

- That Vault originally issued the certificate.
- That a controller deployed it to a running workload.
- That an Ingress controller actually loaded it.
- That an endpoint is currently serving the certificate.
- That automated renewal or rotation succeeded.

Where available, Ingress-reference qualification
describes *recorded* Kubernetes references and
declared host coverage, not live TLS serving.
Unknown, stale, partially collected or denied
source evidence must remain qualified as such.

## Task: interpret lifecycle or certificate posture

1. Confirm the role and source prerequisites for
   **Secrets & PKI → Lifecycle & Assurance**.
2. Review the source-qualified readiness for each
   relevant KV v2 or public PKI evidence category.
3. Check the collection time, approved source/mount
   scope and coverage before treating aggregate
   lifecycle counts as meaningful.
4. For a permitted cross-domain certificate-overlap
   section, verify both independent source
   permissions and collection freshness.
5. Treat a match as a correlation hypothesis
   grounded in public fingerprint identity,
   **not** authorization to rotate a Secret
   or a verified endpoint-delivery audit.

**Expected result:** a read-only evidence assessment
that states exactly which sources were observed and
what remains unverified.

## Troubleshooting without secret disclosure

- If the Overview remains blocked after connection
  setup, check approved mount scope and last
  committed Job outcome, not the provider password.
- If Inventory shows unknown instead of zero,
  confirm whether a qualified complete observation
  was committed for the current generation.
- If counts look stale, distinguish a new failed
  attempt from the last accepted snapshot.
- If an optional PKI section is missing, check
  the relevant approved PKI mount, opt-in and
  separate collection authority.
- If certificate overlap is missing, verify
  permission and evidence for **both** Vault
  and Kubernetes TLS Governance.
- If Lifecycle returns an error, collect a
  sanitized route/error record for the owner
  rather than attempting to dump raw Vault
  responses or secret values.

Do not add an unapproved mount, reveal private
material, restart provider services or trigger
secret rotation merely to make the dashboard
appear Ready. Those actions require their own
governed workflow and evidence.

## Source and applicability

Source-reviewed against KAORI Application
`app/secrets_pki/README.md`,
`app/secrets_pki/CERTIFICATE_DELIVERY_CORRELATION.md`,
`app/common/workspace_navigation_catalog.py`
and provider-owned Secrets & PKI integration
contracts, with source reference
`197a7f7e598c111592a8ae36388865cd3aacf541`.

Before any RC publication, verify the exact
admitted App candidate, source-specific Vault
read-only permissions, source/mount limitation,
PKI optional-feature readiness, denied/failed
and partial data, safe browser output, rights
and independent Human Acceptance. This article
remains `draft: true` and is absent from the
current public KAORI Docs build.
