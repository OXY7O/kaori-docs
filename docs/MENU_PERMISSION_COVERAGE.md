# KAORI application navigation and documentation coverage matrix

**Authority:** [Docs #130](https://github.com/OXY7O/kaori-docs/issues/130), [Docs #127](https://github.com/OXY7O/kaori-docs/issues/127). **Source revision:** [KAORI Application `197a7f7e598c111592a8ae36388865cd3aacf541`](https://github.com/OXY7O/KAORI/blob/197a7f7e598c111592a8ae36388865cd3aacf541/app/common/workspace_navigation_catalog.py) (observed staging 2026-11-22). **Scope:** static source-derived menu **inventory**, not actual permission/UAT or supported product release.

This register enumerates **12 top-level workspaces, 54 primary capability entries and 56 nested tab/view entries** in the canonical catalog. The route is a Flask **endpoint identifier**, not a verified public URL. None of these entries alone demonstrates that the destination works or is permitted for every user.

## Interpretation and safeguards

- The source file is `app/common/workspace_navigation_catalog.py`; the behavior layer is `app/common/workspace_navigation.py`. The actual navigation function uses an **any-of** check when a catalog entry lists permission names; no listed permission means no restriction **at this catalog filter**, not global authorization. A route decorator, a resource scope, a provider condition, or a separate policy may enforce more.
- Source Control capability tabs carry an additional **local Super Admin** navigation restriction in the behavior layer; the `integrations.manage` catalog tuple alone is insufficient. The Internal Certificates tab has an additional `governance.view` **and** `clusters.view` requirement. Role-scoped staging browser and route permission evidence are required before publishing user-facing steps.
- User menus are **filtered by permissions**; source-defined names are not proof that all 12 workspaces appear for a specific user. Some nested tabs are suppressed when fewer than two remain visible. Provider configured state, development feature flags and source/UAT maturity must be checked separately.
- **Source-owned** means a documented UI candidate, not Available/GA. The entire detailed guide set is **not yet accepted**. Do not infer an endpoint's public URL, current provider readiness or the authority to perform a mutation from this list.
- The registered `content/` product articles remain unpublished drafts. This register lives in the Docs repo `docs/` engineering area and is **not** in the Docusaurus public output. It still must contain no secrets or private inventories because the GitHub repo is public.
- Canonical editorial template: purpose, applicability, roles/permissions, prerequisites and scope, menu navigation, supported read/write steps, expected state/committed evidence, freshness/uncertainty, error/empty/loading, governance and recovery, sanitized example, owning issue/source/release/UAT.
- For each leaf, **required next evidence** is: source route/decorator, actual role-scoped browser presence, supported scenario, owner issue, acceptance evidence, sanitized visual and active application candidate revision. Labels below describe pending documentation ownership, not operational availability.

## Authoring ownership

| Domain family | Existing/new owning issue | Current editorial status |
| --- | --- | --- |
| Kubernetes operations, inventory, governance, tenant and analytics | #6 and missing-domain breakdown under #130 | Source indexed; domain user guides/UAT pending |
| Object Storage overview, inventory and analytics | #4/#6 and missing-domain breakdown under #130 | Source indexed; provider instance and user guide UAT pending |
| Artifact Registry | [#4](https://github.com/OXY7O/kaori-docs/issues/4), [#5](https://github.com/OXY7O/kaori-docs/issues/5) | Registry/Harbor drafts only; complete views missing |
| Source Control and Secrets & PKI | #5/#7 and dedicated #130 follow-up issues | Provider/access-specific and sensitive-action guides pending |
| Security findings, Intelligence, Reports | #4/#7 and #130 follow-up issues | Domain guides and permission/evidence acceptance missing |
| Operations Center | #6/#7/#8 and #130 follow-up issues | Jobs, data lifecycle, Kubernetes admin UAT pending |
| Integrations | [#5](https://github.com/OXY7O/kaori-docs/issues/5) | Integration/Harbor drafts only; provider-neutral guide expansion needed |
| Access and Settings | [#7](https://github.com/OXY7O/kaori-docs/issues/7) | Roles/permissions drafts; other submenus and UAT pending |

## Complete source-defined menu inventory

The catalog permission listing records the **navigation any-of filter**, not the full route policy. Empty means no permission tuple is declared in this catalog and still requires route review.

### Infrastructure — Kubernetes

**Workspace key:** `kubernetes`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `kubernetes_dashboard.index`
  - Catalog navigation permission: `dashboard.view`
- **Inventory** (`inventory`)
  - Catalog endpoint: `inventory.overview`
  - Catalog navigation permission: `inventory.view`
  - Nested views (10):
    - **Overview** (`overview`): `inventory.overview` — nav `inventory.view`
    - **Topology** (`topology`): `inventory.topology` — nav `inventory.view`
    - **Nodes** (`nodes`): `inventory.nodes` — nav `inventory.view`
    - **Namespaces** (`namespaces`): `inventory.namespaces` — nav `inventory.view`
    - **Workloads** (`workloads`): `inventory.workloads` — nav `inventory.view`
    - **Pods** (`pods`): `inventory.pods` — nav `inventory.view`
    - **Services** (`services`): `inventory.services` — nav `inventory.view`
    - **Ingresses** (`ingresses`): `inventory.ingresses` — nav `inventory.view`
    - **Storage** (`storage`): `inventory.storage` — nav `inventory.view`
    - **Configuration** (`configuration`): `inventory.configuration` — nav `inventory.view`
- **Operations** (`operations`)
  - Catalog endpoint: `kubernetes_operations.overview`
  - Catalog navigation permission: `kubernetes_configmaps.view`, `kubernetes_configmaps.create`, `kubernetes_configmaps.update`, `kubernetes_configmaps.delete`, `kubernetes_secrets.view`, `kubernetes_secrets.create`, `kubernetes_secrets.replace`, `kubernetes_secrets.delete`, `kubernetes_secrets.reveal`, `kubernetes_secrets.approve_reveal`, `kubernetes_secrets.rotate_tls`, `kubernetes_secrets.bulk_rotate_tls`
  - Nested views (3):
    - **Overview** (`overview`): `kubernetes_operations.overview` — nav `kubernetes_configmaps.view`, `kubernetes_configmaps.create`, `kubernetes_configmaps.update`, `kubernetes_configmaps.delete`, `kubernetes_secrets.view`, `kubernetes_secrets.create`, `kubernetes_secrets.replace`, `kubernetes_secrets.delete`, `kubernetes_secrets.reveal`, `kubernetes_secrets.approve_reveal`, `kubernetes_secrets.rotate_tls`, `kubernetes_secrets.bulk_rotate_tls`
    - **ConfigMaps** (`configmaps`): `kubernetes_operations.configmap_management` — nav `kubernetes_configmaps.view`, `kubernetes_configmaps.create`, `kubernetes_configmaps.update`, `kubernetes_configmaps.delete`
    - **Secrets** (`secrets`): `kubernetes_operations.secret_management` — nav `kubernetes_secrets.view`, `kubernetes_secrets.create`, `kubernetes_secrets.replace`, `kubernetes_secrets.delete`, `kubernetes_secrets.reveal`, `kubernetes_secrets.approve_reveal`, `kubernetes_secrets.rotate_tls`, `kubernetes_secrets.bulk_rotate_tls`
- **Governance** (`governance`)
  - Catalog endpoint: `governance.overview`
  - Catalog navigation permission: `governance.view`, `tls_certificates.view`, `internal_certificates.view`
  - Nested views (3):
    - **Overview** (`overview`): `governance.overview` — nav `governance.view`
    - **TLS Certificates** (`tls_certificates`): `governance.tls_certificates` — nav `tls_certificates.view`
    - **Internal Certificates** (`internal_certificates`): `governance.internal_certificates` — nav `internal_certificates.view`
- **Tenant** (`tenant`)
  - Catalog endpoint: `tenant.index`
  - Catalog navigation permission: `tenant.view`, `tenant.manage`
  - Nested views (5):
    - **Overview** (`overview`): `tenant.index` — nav `tenant.view`, `tenant.manage`
    - **Tenants** (`tenants`): `tenant.tenants` — nav `tenant.view`, `tenant.manage`
    - **Resource Profiles** (`resource_profiles`): `tenant.resource_profiles` — nav `tenant.view`, `tenant.manage`
    - **Namespace Provisioning** (`namespace_provisioning`): `tenant.namespace_provisioning` — nav `tenant.view`, `tenant.manage`
    - **Operations** (`operations`): `tenant.operations` — nav `tenant.view`, `tenant.manage`
- **Analytics** (`analytics`)
  - Catalog endpoint: `analytics.overview`
  - Catalog navigation permission: `analytics.view`
  - Nested views (8):
    - **Overview** (`overview`): `analytics.overview` — nav `analytics.view`
    - **Usage** (`utilization`): `analytics.utilization` — nav `analytics.view`
    - **Capacity** (`capacity`): `analytics.capacity` — nav `analytics.view`
    - **Workloads** (`workloads`): `analytics.workload` — nav `analytics.view`
    - **Storage** (`storage`): `analytics.storage` — nav `analytics.view`
    - **Consumers** (`consumers`): `analytics.top_consumers` — nav `analytics.view`
    - **Forecast** (`forecast`): `analytics.forecast` — nav `analytics.view`
    - **Alerts & Anomalies** (`alerts`): `analytics.alerts` — nav `analytics.view`

### Infrastructure — Object Storage

**Workspace key:** `object_storage`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `object_storage_dashboard.index`
  - Catalog navigation permission: `dashboard.view`
- **Inventory** (`inventory`)
  - Catalog endpoint: `object_storage_inventory.overview`
  - Catalog navigation permission: `object_storage_inventory.view`
  - Nested views (3):
    - **Overview** (`overview`): `object_storage_inventory.overview` — nav `object_storage_inventory.view`
    - **Systems** (`systems`): `object_storage_inventory.systems` — nav `object_storage_inventory.view`
    - **Buckets & Containers** (`buckets`): `object_storage_inventory.buckets` — nav `object_storage_inventory.view`
- **Analytics** (`analytics`)
  - Catalog endpoint: `analytics.object_storage_overview`
  - Catalog navigation permission: `object_storage_analytics.view`
  - Nested views (6):
    - **Overview** (`overview`): `analytics.object_storage_overview` — nav `object_storage_analytics.view`
    - **Capacity & Usage** (`capacity`): `analytics.object_storage_capacity` — nav `object_storage_analytics.view`
    - **Performance** (`performance`): `analytics.object_storage_performance` — nav `object_storage_analytics.view`
    - **Forecast** (`forecast`): `analytics.object_storage_forecast` — nav `object_storage_analytics.view`
    - **Top Consumers** (`consumers`): `analytics.object_storage_top_consumers` — nav `object_storage_analytics.view`
    - **Alerts & Anomalies** (`alerts`): `analytics.object_storage_alerts` — nav `object_storage_analytics.view`

### Infrastructure — Artifact Registry

**Workspace key:** `artifact_registry`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `artifact_registry.overview`
  - Catalog navigation permission: `artifact_registry.view`
- **Inventory** (`inventory`)
  - Catalog endpoint: `artifact_registry.inventory`
  - Catalog navigation permission: `artifact_registry.view`
  - Nested views (4):
    - **Overview** (`overview`): `artifact_registry.inventory` — nav `artifact_registry.view`
    - **Projects** (`projects`): `artifact_registry.inventory_projects` — nav `artifact_registry.view`
    - **Repositories** (`repositories`): `artifact_registry.inventory_repositories` — nav `artifact_registry.view`
    - **Artifacts** (`artifacts`): `artifact_registry.inventory_artifacts` — nav `artifact_registry.view`
- **Security** (`security`)
  - Catalog endpoint: `artifact_registry.security_overview`
  - Catalog navigation permission: `artifact_registry.view`
  - Nested views (3):
    - **Overview** (`overview`): `artifact_registry.security_overview` — nav `artifact_registry.view`
    - **Vulnerabilities** (`vulnerabilities`): `artifact_registry.security` — nav `artifact_registry.view`
    - **Supply Chain** (`supply_chain`): `artifact_registry.security_supply_chain` — nav `artifact_registry.view`
- **Runtime** (`runtime`)
  - Catalog endpoint: `artifact_registry.runtime_overview`
  - Catalog navigation permission: `artifact_registry.view`
  - Nested views (3):
    - **Overview** (`overview`): `artifact_registry.runtime_overview` — nav `artifact_registry.view`
    - **Runtime Usage** (`usage`): `artifact_registry.runtime` — nav `artifact_registry.view`
    - **Topology** (`topology`): `artifact_registry.runtime_topology` — nav `artifact_registry.view`
- **Governance** (`governance`)
  - Catalog endpoint: `artifact_registry.governance`
  - Catalog navigation permission: `artifact_registry.view`
- **Analytics** (`analytics`)
  - Catalog endpoint: `artifact_registry.analytics`
  - Catalog navigation permission: `artifact_registry.view`
  - Nested views (8):
    - **Overview** (`overview`): `artifact_registry.analytics` — nav `artifact_registry.view`
    - **Growth** (`growth`): `artifact_registry.analytics_growth` — nav `artifact_registry.view`
    - **Capacity** (`capacity`): `artifact_registry.analytics_capacity` — nav `artifact_registry.view`
    - **Usage** (`usage`): `artifact_registry.analytics_usage` — nav `artifact_registry.view`
    - **Risk** (`risk`): `artifact_registry.analytics_risk` — nav `artifact_registry.view`
    - **Governance** (`governance`): `artifact_registry.analytics_governance` — nav `artifact_registry.view`
    - **Alerts & Anomalies** (`alerts`): `artifact_registry.analytics_alerts` — nav `artifact_registry.view`
    - **Insights** (`insights`): `artifact_registry.analytics_insights` — nav `artifact_registry.view`

### Infrastructure — Source Control

**Workspace key:** `source_control`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `source_control.overview`
  - Catalog navigation permission: `integrations.manage`
- **Repositories** (`repositories`)
  - Catalog endpoint: `source_control.repositories`
  - Catalog navigation permission: `integrations.manage`

### Infrastructure — Secrets & PKI

**Workspace key:** `secrets_pki`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `secrets_pki.overview`
  - Catalog navigation permission: `secrets_pki.view`
- **Inventory** (`inventory`)
  - Catalog endpoint: `secrets_pki.inventory`
  - Catalog navigation permission: `secrets_pki.view`
- **Lifecycle & Assurance** (`lifecycle`)
  - Catalog endpoint: `secrets_pki.lifecycle`
  - Catalog navigation permission: `secrets_pki.view`

### Assurance — Security

**Workspace key:** `security_posture`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `security_posture.overview`
  - Catalog navigation permission: `security_posture.view`
- **Findings** (`findings`)
  - Catalog endpoint: `security_posture.findings`
  - Catalog navigation permission: `security_posture.view`

### Insights — Intelligence

**Workspace key:** `intelligence`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `intelligence.index`
  - Catalog navigation permission: `intelligence.view`
- **Recommendations** (`recommendations`)
  - Catalog endpoint: `intelligence.recommendations`
  - Catalog navigation permission: `intelligence.view`
- **Alert Intelligence** (`alert_intelligence`)
  - Catalog endpoint: `alert_intelligence.index`
  - Catalog navigation permission: `intelligence.view`
- **Rule Catalog** (`catalog`)
  - Catalog endpoint: `intelligence.catalog`
  - Catalog navigation permission: `intelligence.view`
- **Automation Control** (`automation_control`)
  - Catalog endpoint: `automation_control.index`
  - Catalog navigation permission: `intelligence.view`

### Insights — Reports

**Workspace key:** `reports`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `reports.overview`
  - Catalog navigation permission: `reports.view`
- **Generate** (`generate`)
  - Catalog endpoint: `reports.generate_report`
  - Catalog navigation permission: `reports.generate`
- **Generated** (`generated`)
  - Catalog endpoint: `reports.generated_reports`
  - Catalog navigation permission: `reports.view`
- **Templates** (`templates`)
  - Catalog endpoint: `reports.report_templates`
  - Catalog navigation permission: `reports.manage_templates`
- **Storage** (`storage`)
  - Catalog endpoint: `reports.storage`
  - Catalog navigation permission: `reports.manage_storage`
- **Schedules** (`schedules`)
  - Catalog endpoint: `reports.schedules`
  - Catalog navigation permission: `reports.manage_schedules`

### Platform — Operations Center

**Workspace key:** `operations_center`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `platform_operations.overview.index`
  - Catalog navigation permission: `jobs.view`, `platform_operations.view_data_lifecycle`, `kubernetes_secrets.manage_reveal`
- **Jobs** (`jobs`)
  - Catalog endpoint: `jobs.executions`
  - Catalog navigation permission: `jobs.view`
- **Data Lifecycle** (`data_lifecycle`)
  - Catalog endpoint: `platform_operations.data_lifecycle.index`
  - Catalog navigation permission: `platform_operations.view_data_lifecycle`
- **Kubernetes Admin** (`kubernetes_admin`)
  - Catalog endpoint: `platform_operations.kubernetes.index`
  - Catalog navigation permission: `kubernetes_secrets.manage_reveal`

### Platform — Integrations

**Workspace key:** `integrations`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `integrations.overview`
  - Catalog navigation permission: `integrations.manage`
- **Orchestration** (`orchestration`)
  - Catalog endpoint: `integrations.orchestration`
  - Catalog navigation permission: `integrations.manage`
- **Observability** (`observability`)
  - Catalog endpoint: `integrations.observability`
  - Catalog navigation permission: `integrations.manage`
- **Storage** (`storage`)
  - Catalog endpoint: `integrations.storage`
  - Catalog navigation permission: `integrations.manage`
- **Registry** (`registry`)
  - Catalog endpoint: `integrations.registry`
  - Catalog navigation permission: `integrations.manage`
- **Secrets Management** (`secrets_management`)
  - Catalog endpoint: `integrations.secrets_management`
  - Catalog navigation permission: `integrations.manage`
- **Source Control** (`source_control`)
  - Catalog endpoint: `integrations.source_control`
  - Catalog navigation permission: `integrations.manage`
- **Notification Channels** (`notifications`)
  - Catalog endpoint: `notification_channels.index`
  - Catalog navigation permission: `integrations.manage`

### Administration — Access

**Workspace key:** `access`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **Overview** (`overview`)
  - Catalog endpoint: `access.overview.index`
  - Catalog navigation permission: `users.view`, `users.manage`, `identity_providers.view`, `roles.view`, `activity_audit.view`
- **Users** (`users`)
  - Catalog endpoint: `users.index`
  - Catalog navigation permission: `users.view`
- **Identity Providers** (`identity_providers`)
  - Catalog endpoint: `identity_providers.index`
  - Catalog navigation permission: `identity_providers.view`
- **Authentication Security** (`authentication_security`)
  - Catalog endpoint: `access.authentication_security.index`
  - Catalog navigation permission: `identity_providers.view`
- **Roles** (`roles`)
  - Catalog endpoint: `access.roles.index`
  - Catalog navigation permission: `roles.view`
- **Permissions** (`permissions`)
  - Catalog endpoint: `access.permissions.index`
  - Catalog navigation permission: `roles.view`
- **Activity Audit** (`activity_audit`)
  - Catalog endpoint: `access.activity_audit.index`
  - Catalog navigation permission: `activity_audit.view`

### Administration — Settings

**Workspace key:** `settings`. **UI status:** source-declared only; permission-scoped browser UAT and product maturity pending.

- **General** (`general`)
  - Catalog endpoint: `settings.general`
  - Catalog navigation permission: none declared
- **Account** (`account`)
  - Catalog endpoint: `settings.account`
  - Catalog navigation permission: none declared

## Completeness and remaining audits

- **Static catalog inventory:** 12 workspaces, 54 capability entries, 56 nested views in 11 nested-capability groups. All nested-capability groups resolve to one declared workspace/capability key.
- **Runtime/role coverage:** NOT VERIFIED; for each catalog endpoint inspect the actual registered blueprint, route decorators, permission scopes and any additional gate.
- **Rendered menu coverage:** NOT VERIFIED; compare a permitted staging instance for viewer/operator/administrator roles with the navigation catalog (including feature flags and provider availability).
- **Documentation completeness:** NOT VERIFIED; every item above requires issue-owned end-user guidance or explicit pending/unsupported designation, links, expected evidence and user UAT.
- **Publication status:** full-content pre-stable RC review policy [#131](https://github.com/OXY7O/kaori-docs/issues/131) pending. Versioned stable product guide line [#15](https://github.com/OXY7O/kaori-docs/issues/15) withheld until accepted App `v0.3.0`. No auto-publish.
- **Source drift:** regenerate this inventory through human source review (not a new CI script) when `workspace_navigation_catalog.py`, permission behavior or actual release scope changes. File/route mismatches are source authority conflicts, not permission to invent navigation aliases.

### Bounded follow-up checklist

- [ ] Cross-check the 54 primary endpoints and 56 nested endpoints against actual route registration and view decorators.
- [ ] Inspect dynamic special-case redirects or hidden/suppressed menus against real role grants; record exact effective access.
- [ ] Record exact application RC source/tag and provider-configured maturity for each scoped workflow.
- [ ] Produce dedicated human-reviewed article workstreams where existing Docs #4–#8 ownership is insufficient.
- [ ] Review original diagrams/screenshots, redact real infrastructure, and prove browser navigation, keyboard/mobile/light/dark/axe.
- [ ] Publish only after #131 safety, independent rights review and existing signed RC/public swap authority, then Human UAT.

**Scope statement:** the catalog is full at the source-definition level; **product/menu documentation and release acceptance are still incomplete**.
