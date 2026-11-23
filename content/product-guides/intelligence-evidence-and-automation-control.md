---
id: intelligence-evidence-and-automation-control
title: Intelligence Evidence and Automation Control
description: Inspect recommendations, alert evidence, rule definitions and governed automation decisions safely.
draft: true
sidebar_position: 8
---

> **Editorial status:** Unpublished Intelligence operator draft.
> Reviewed against the Application RC.3 source for Docs #159.
> Provider UAT, role-scoped browser behavior, and public RC
> publication remain independently unaccepted.

## Intelligence in KAORI

**Intelligence** owns cross-domain recommendation semantics,
rule definitions, source-qualified alert enrichment, accepted-risk
governance and immutable decisions. It does not become the
authoritative owner of Kubernetes objects, Object Storage
buckets, Registry scanner findings or provider alerts.

The operational domains collect and commit the relevant
facts. Intelligence interprets eligible evidence and
expresses recommendations or governed decisions.
External alert and execution engines retain their own
authoritative state.

An Intelligence result is meaningful only when its
source, impacted asset, collection time, scope and
evaluation status are qualified. A rule definition is
not proof that the provider or evaluator is running.

## Menus and access boundaries

The source navigation exposes five workspaces:

- **Intelligence → Overview:** Committed summary,
  evidence freshness, workspace posture and navigation.
- **Intelligence → Recommendations:** Source-qualified,
  read-only findings and their evidence/details.
- **Intelligence → Alert Intelligence:** Scoped
  alert records, correlation guidance, notification
  delivery and evidence ownership.
- **Intelligence → Rule Catalog:** Canonical rule
  definitions and support or reserved status.
- **Intelligence → Automation Control:** Governance,
  runbooks, bindings, decision review, execution
  configuration and production-readiness posture.

The Overview, Recommendations and Rule Catalog
read routes are protected by `intelligence.view`;
the nav catalog also requires `intelligence.view`
to expose the five workspaces. A visible menu
does not grant authority to mutate a decision,
publish a runbook, dispatch a worker or access
an otherwise forbidden provider asset.

Action routes have **separate** permissions, including
`intelligence.decisions.create`,
`intelligence.decisions.approve`,
`intelligence.decisions.execute`,
`knowledge.runbooks.manage` and
`knowledge.runbooks.publish`. Actual availability
requires the accepted App candidate's server-side
scope, governance state and additional worker gates.

## Task: review Intelligence Overview

1. Open **Intelligence → Overview** using an
   account authorized to read Intelligence.
2. Read the source-qualified summary indicators,
   including registered asset coverage, committed
   findings and Rule Catalog posture.
3. Inspect evidence freshness. The source
   describes a **24-hour committed Inventory**
   qualification; the displayed status is not
   proof of a live provider query.
4. Follow the available workspace links rather
   than inferring implementation from a card
   title or summary count.
5. When a source is unavailable or stale,
   record the uncertainty before escalating.

**Expected result:** an understanding of the
current committed-evidence and rule posture,
not an assertion of overall provider health
or permission to trigger remediation.

## Task: investigate a recommendation

1. Open **Intelligence → Recommendations**.
2. Filter and review recommendations relevant
   to the authorized infrastructure scope.
3. Open a finding's detail to identify the
   canonical rule, owning domain, source,
   affected asset, evidence and advised action.
4. Check the source collection generation
   and data freshness before interpreting
   the recommendation as a current condition.
5. Distinguish an available evaluator from
   reserved, imported or unqualified signals.
6. Escalate the recommended remediation
   through the owning operational workflow.
   Reading a finding must not mutate the
   external provider.

**Expected result:** a source-qualified
recommendation that can be investigated
without claiming an automated fix succeeded.

Kubernetes findings are cluster-scoped
to their permitted Kubernetes consumers.
Object Storage findings rely on committed,
provider-neutral observations, with
MinIO an implementation rather than
the global capability definition.
Artifact Registry and other domains
have independently bounded evidence paths.

## Task: interpret the Rule Catalog

1. Open **Intelligence → Rule Catalog**.
2. Review the rule's source, domain,
   status and supported evidence inputs.
3. Distinguish **Available** evaluator
   coverage from **Reserved Plan** rule
   definitions and imported signals.
4. Inspect the affected asset and
   recommendation details when source
   evidence and permissions are present.
5. Do not treat a planned rule as
   observed noncompliance or a completed
   alert delivery.

Rule Catalog is the central definition
owner. An analytics page must not
invent a second recommendation rule
for the same evidence.

### Accepted Risk is not remediation

A rule exception may govern an active
finding through time-bounded accepted risk.
The source supports two separate scopes:

- `rule_asset`: eligible current and
  future active findings of the same
  rule and exact asset during the
  accepted period.
- `finding_keys`: explicitly identified
  findings for that asset only.

An accountable record requires reason,
risk/change reference, owner, expiry
and revocation evidence. Overlapping
active exception scopes are rejected.
An exception does **not** remove the
underlying recommendation finding; it
changes eligible AlertCase promotion
only within the valid accepted-risk
window. Expired or revoked exceptions
restore normal evaluation eligibility.

Create, approve or revoke exceptions
only through authorized governance
routes and separately accepted UAT.
No permanent silent suppressions.

## Task: examine Alert Intelligence

1. Open **Intelligence → Alert Intelligence**.
2. Confirm the authorized domain,
   selected asset and source context.
3. In **Alert Records**, review eligible
   committed AlertCase observations
   and current filtering by search,
   severity and state.
4. In **Correlation & Guidance**,
   distinguish contextual recommendations
   from a proven causal relationship.
5. In **Notification Delivery**,
   inspect configured delivery evidence;
   do not infer delivery from the
   existence of an AlertCase.
6. In **Evidence & Ownership**,
   identify the source and accountable
   operator without exposing provider
   credentials or private payloads.

The source describes Alertmanager-first
collection with a bounded Metrics Source
fallback for qualifying domains.
Artifact Registry committed AlertCase
browsing is independently scoped to
an enabled, active integration instance;
it does not prove provider-native
Registry alert materialization.
Registry notifications require an explicit
validated Registry-scoped routing policy.
Unknown or disabled scopes fail closed.
Server and HCI alert enrichment remain
reserved, not silently available.

## Automation Control: governance before execution

**Intelligence → Automation Control** is
an application-layer coordination workspace,
not a second infrastructure automation
engine. It exposes several stages:

- **Overview:** Current governance,
  allowed readiness and evidence.
- **Runbooks & Bindings:** Source-controlled
  system runbook contracts and explicit
  environment-specific bindings.
- **Decision Review:** Candidate evidence,
  accountable review and immutable
  approval/rejection.
- **Execution Control:** Permissioned
  control plane and execution eligibility.
- **Production Readiness:** Safety
  policy, verification evidence and
  reviewed rollout configuration.

The normal configuration may be
**Governance Only**. Validated runbook
activation, bindings, decision review
and readiness configuration can be
prepared without opening provider
execution. These are governance
mutations with their own permissions;
they are not ordinary read-only actions.

Infrastructure execution is **default
deny**, with source gate
`AUTOMATION_EXECUTION_ENABLED=false`.
An eligible execution requires
independent authorization, exact source
evidence, policy admission and worker
revalidation. The candidate source
describes a bounded Kubernetes
Deployment restart pilot with one-time
authorization, server-side dry-run,
rollout-health verification and
immutable recovery/dead-letter evidence.
This is **not** blanket permission
to restart production workloads.

Custom runbook authoring remains
gated separately and is not claimed
as generally production supported.
Do not change execution flags,
manually replay a dead letter or
run provider commands from this
documentation. A retry must be
a new governed evidence/decision
lifecycle.

## Degraded data and safe escalation

- **No committed inventory:** A missing
  baseline does not mean zero findings.
- **Stale or partial evidence:** Preserve
  source age and coverage limitations.
- **Reserved rule:** Definition present
  without an admitted evaluator or
  source-specific observation.
- **Unknown AlertCase scope:** Check
  source eligibility and permissions
  before assuming no active alerts.
- **Notification not confirmed:** Do not
  infer delivery from routing configuration.
- **Governance Only:** Execution remains
  blocked even when a runbook and decision
  are configured.
- **Denied action:** Inspect separate
  decision/runbook permission and server
  policy; never bypass by URL manipulation.

Escalate with sanitized issue, source,
asset scope, job or decision reference
and evidence timestamp. Do not paste
raw alert payloads, provider tokens,
customer topology or private runbooks
into public screenshots or issue text.

## Release and evidence applicability

This chapter reflects source-reviewed
KAORI Application
`app/intelligence/README.md`,
`app/intelligence/routes.py`,
`app/intelligence/automation_control/routes.py`,
and canonical navigation, pinned to
`v0.3.0-rc.3@197a7f7e598c111592a8ae36388865cd3aacf541`.

The published Application RC.3 is
**UAT pending**. Before allowing this
article into a public candidate manual,
verify actual candidate roles, source
permissions, real browser navigation,
blocked and positive workflows,
provider-instance isolation, rights
and sanitization, and separate Human
Acceptance. It remains `draft: true`
and is absent from the public
KAORI Docs build.
