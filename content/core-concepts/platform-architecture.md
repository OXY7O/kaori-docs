---
id: platform-architecture
title: Platform Architecture
description: Understand KAORI's source-authoritative, committed-evidence operating model, logical components, and deployment boundaries.
draft: true
sidebar_position: 6
---

> **Editorial status:** This is an unpublished, release-neutral architecture
> review draft. It explains the documented design and source boundaries,
> **not** an approved production topology, supported customer installer,
> service availability guarantee, or proof of a stable KAORI release.

## Architectural purpose

KAORI is an infrastructure operations platform. It provides a common view of
infrastructure assets, operational context, analytics, reporting and governed
workflows across systems that already own data and perform operations.

The platform is **capability/domain first, provider second, instance third**.
For example, **Integrations → Registry → Harbor** names a capability,
a provider implementation and a configured connection. A specific provider
is not the definition of the entire KAORI platform.

KAORI does not replace Kubernetes, a registry, an observability platform,
a secret manager, GitHub or an automation engine. Those remain authoritative
for their own source data and execution. KAORI adds source-aware
normalization, committed evidence, cross-domain correlation, orchestration,
policy, access control and auditability.

## Logical component model

The following diagram describes **responsibilities**, not one deployed
network, installed provider set, or a request-by-request synchronous pipeline.

```text
Operator / administrator / reviewer
                  |
                  v
KAORI web experience (navigation, access, feedback)
                  |
                  v
Domain services and permission-scoped read models
        |                            |
        v                            v
Committed normalized evidence    Governed workflow
(identity, scope, time,          (target validation,
 outcome, completeness)          authorization, audit)
        ^                            |
        |                            v
Collection/normalization       Job orchestration
adapters and domain workers    and result evidence
        ^                            |
        |                            v
Authoritative providers  <---- External execution engines
```

The logical model has several important boundaries:

- **Web and authorization:** KAORI's web application presents
  permission-filtered workspaces, domain-specific views, and operational
  feedback. A visible menu does not grant access to the underlying route
  or mutation.
- **Application services:** Each domain owns business rules, source scope,
  normalization and evidence contracts. Shared infrastructure provides
  consistent navigation, pagination, errors, feedback and access checks,
  without moving every business rule into a global module.
- **Committed storage:** Normal read paths favor observations that KAORI
  has actually committed. Stored evidence is not guaranteed to equal the
  provider's live state at the moment a page opens.
- **Background execution:** Collection, scheduled tasks, reporting and
  governed operations may be handled by registered jobs and workers rather
  than by blocking a browser request. Queued does not mean completed.
- **External authority:** Provider APIs, collectors and execution engines
  remain responsible for current source truth and actual operations.
  KAORI must not invent an outcome because a request was accepted.

The current application deployment documentation describes a Flask-based
web service, PostgreSQL persistence, Redis-backed asynchronous processing
with Celery workers and scheduled execution, plus frontend assets.
The precise services, queue topology and availability characteristics must
be verified for the selected application candidate and deployment mode.
This chapter does not guarantee every service is installed in every mode.

## From external data to an operational view

An integration should explicitly identify the capability, provider,
configured instance, collection scope, source identity and validation state.
A successful connection test and a successful complete inventory collection
are different facts.

A source observation can move through these conceptual stages:

1. **Acquire with scope.** Identify which external instance was queried,
   what resources the collection attempted, and when it ran.
2. **Normalize with provenance.** Translate provider-specific records into
   domain-owned identities, relationships and state without destroying
   the underlying source attribution.
3. **Commit outcomes.** Record actual accepted observations and a
   collection/job outcome. Partial, stale, unsupported, unavailable and
   unknown must not be silently converted into healthy or empty.
4. **Read and correlate.** Domain views and other authorized consumers
   read the committed state, respecting source visibility and evidence
   limitations. A relationship is displayed as supported only when its
   identity/binding contract warrants that conclusion.
5. **Govern an action.** Where a workflow is actually supported,
   verify the target, relevant dependencies, permission and impact before
   dispatching execution to the responsible system. Retain the auditable
   result or explicit failure.

KAORI can provide operational value even when one provider alone cannot
see a cross-domain relationship. But correlation remains an evidence-backed
interpretation, **not** permission to invent dependencies or infer root
cause from matching names, tags or timing.

## Example: Registry evidence and a workload

Imagine an artifact registry reports a vulnerability affecting an image
digest, while Kubernetes inventory contains a recorded runtime image
binding. A meaningful cross-domain finding requires verified evidence
that the runtime observation and registry artifact refer to the same
identity. An immutable digest is stronger evidence than a mutable tag.

This is a **conceptual, read-only example**, not a report of a real issue
or a guarantee that every workload, cluster or registry is collected.
A user who can view aggregated Security Posture findings may still need
separate authorization to inspect the source Registry records. A missing
finding cannot demonstrate that every asset is secure.

## Security and operational governance

KAORI separates **view**, **interpret**, **propose** and **execute**
responsibilities. Relevant controls include:

- Server-side permission and resource-scope enforcement, even if UI menus
  are hidden or disabled.
- Sensitive credential handling within integration-owned boundaries;
  secret values should not appear in documentation, audit output or
  ordinary user-visible evidence.
- Explicit action target and impact confirmation before an
  infrastructure-changing operation.
- CSRF protection and controlled server mutation paths for browser
  operations where applicable.
- Persisted job and activity evidence that distinguishes requested,
  queued, running, succeeded, failed, cancelled and unknown outcomes
  according to the owning workflow contract.
- Source, freshness, completeness and uncertainty shown alongside
  cross-domain findings and recommendations.

An architecture description does **not** establish that a particular
provider operation is available to all users or that automation can
modify an environment without an independent authorization check.

## Deployment boundaries

KAORI's application documentation distinguishes three different
ways of running the software:

- **Developer workspace:** a VS Code Dev Container with isolated local
  development configuration and source-mounted services.
- **Disposable local evaluation:** a separate standalone Compose
  example consuming an admitted immutable RC image rather than
  treating working source as a released application.
- **Governed server/UAT release:** a reviewed immutable image and
  separately approved server configuration, backup, migration,
  service/worker verification and recoverable release process.

These are **different operational purposes**, not interchangeable
installation methods. In particular, a development environment or
a pre-release image is not an accepted stable production distribution.
Customer-managed self-hosting and OXY7O-managed customer instances
are roadmap delivery models until their distribution and security
requirements are accepted; multiple Kubernetes namespaces do not
constitute multi-customer SaaS isolation.

Detailed install, upgrade, backup, rollback and disaster-recovery
instructions belong to the independently tested installation and
operations chapters, not to this conceptual overview.

## How to use this architecture when reading a product guide

For each product menu, inventory or operational action, ask:

- Which **capability and provider instance** owns the data?
- What is the **resource, environment and collection scope**?
- Which **committed observation** and timestamp support the view?
- Is the result **fresh, partial, unavailable, unknown or verified**?
- Which **role and permission** may see or change this resource?
- If an action exists, which **external system executes it** and
  where is the job/audit outcome recorded?
- Which behavior is supported for the **accepted KAORI application
  release** being reviewed?

These questions keep source evidence, interpretation and execution
separate and help prevent overconfident operational decisions.

## Source and applicability

This draft is based on KAORI Platform Direction
(`docs/product/README.md`), architecture index
(`docs/architecture/README.md`), integration kernel
(`app/integrations/README.md`), domain-owned references and runtime
modes in `docs/RUNNING.md` and `docs/DEPLOYMENT.md` at the
source-reviewed application staging baseline of 2026-11-22.

The content owner must revalidate those exact source contracts, capability
maturity, role-scoped UI and actual UAT against the candidate to be
documented. No native stable application documentation line is assigned
to this draft. Its content must not become an accepted public guide
merely because Docusaurus can render it.
