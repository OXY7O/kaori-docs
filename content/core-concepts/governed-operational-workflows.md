---
id: governed-operational-workflows
title: Governed Operational Workflows
description: Separate visibility, authorization, orchestration, external execution, and auditable outcomes.
draft: true
sidebar_position: 5
---

> **Editorial status:** Review draft. The workflow described here is conceptual and is not an instruction to change live infrastructure.

## Seeing is not changing

Operational visibility and infrastructure mutation have different safety requirements. An operator may be allowed to inspect an asset while being restricted from restarting, updating, deleting, or reconfiguring it.

KAORI is designed to connect information and govern selected operational workflows when this adds real value. That is distinct from rebuilding an external platform's full management interface inside KAORI.

## The responsibility boundary

The principle is straightforward:

**Git defines; external engines execute; KAORI orchestrates; committed evidence proves.**

This describes responsibility rather than claiming a particular engine or integration is currently available. Source-control systems define versioned desired state where relevant. External providers and execution engines retain authority for the actions they perform. KAORI can govern target selection, policy, orchestration context, correlation, and audit records.

## Conceptual workflow stages

1. **Observe.** Establish the affected asset, environment, source instance, and evidence freshness.
2. **Understand impact.** Review available dependencies, risk context, and collection limitations.
3. **Request an action.** Identify the exact operation, target, scope, and authorized principal.
4. **Validate.** Enforce server-side permission, prerequisites, relevant safety checks, and explicit approvals where required.
5. **Execute through the authority.** Use an integrated provider or external engine under its own contract.
6. **Record the outcome.** Preserve meaningful status, evidence, correlation, and auditable activity without leaking sensitive payloads.

These stages are a **conceptual contract**. They do not guarantee that any specific command, provider, or approval UI is currently implemented.

## Failures and partial outcomes

An attempted workflow is not successful merely because a request was accepted. A useful operational result distinguishes requested, authorized, dispatched, executed, failed, partially completed, or unverified states when those distinctions are supported.

If the external executor is unavailable or its result cannot be verified, the user interface should not silently report success. Evidence should show what was actually observed and the next safe investigation step.

## How to evaluate a future guide

A release-qualified operational guide should explain prerequisites, supported scope, permission requirements, expected evidence, failure behavior, and any safe rollback or recovery path. It must also distinguish read-only instructions from infrastructure-changing procedures.

The fact that a provider exposes an API is not, by itself, a reason to expose that operation in KAORI.

**Source authority:** [KAORI Platform Direction](https://github.com/OXY7O/KAORI/blob/7272c81e495ef8e4d590355f1d1e6c4dd785eb91/docs/product/README.md), especially _Centralized Operational Activities_, _Administration, Governance, and Audit_, and _Visibility before mutation_. Feature-level behavior must be linked to the accepted application implementation and release before publishing.

## Implementation evidence from KAORI staging

The **Artifact Registry** uses separate permissions for read-only inspection (`artifact_registry.view`) and manual evidence synchronization (`artifact_registry.sync`). Its Security Sync action dispatches an explicitly registered background job and can return **Queued**, **Already Active**, **Could Not Start**, or worker-unavailable feedback. An accepted dispatch is not proof that a registry scan ran or that all findings were collected. The synchronization path is read-only toward providers and preserves operational activity evidence.

In the **Access** domain, `roles.view` and `roles.manage` distinguish registry inspection from custom-role mutation; protected default roles cannot be directly edited or deleted. The server enforces permissions instead of relying on UI visibility.

**Source-reviewed staging implementation:** `app/artifact_registry/routes.py`, `app/access/README.md`, and `docs/rbac/README.md` at `OXY7O/KAORI` staging commit `7272c81e495ef8e4d590355f1d1e6c4dd785eb91`. These examples are staging implementation evidence and do not replace release-specific authorization and UAT.
