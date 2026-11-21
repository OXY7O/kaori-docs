# KAORI Docs

**Product knowledge, organized for evidence-driven operations.**

[Documentation portal](https://docs.kaori.cloud) · [KAORI Website](https://kaori.cloud) · [KAORI Application](https://app.kaori.cloud)

![Docusaurus 3](https://img.shields.io/badge/Docusaurus-3-7C3AED)
![Static documentation](https://img.shields.io/badge/Delivery-Read--only%20site-475569)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6)
![NGINX](https://img.shields.io/badge/Runtime-Unprivileged%20NGINX-0F766E)

---

## Documentation for the KAORI ecosystem

**KAORI Docs** is the documentation-facing companion to **KAORI — Knowledge, Automation, Operations, Resilience & Intelligence**.

It is designed to make approved product knowledge easier to discover and navigate. It complements the [public product website](https://kaori.cloud) and the [authenticated application](https://app.kaori.cloud); it does **not** operate infrastructure or replace the product's canonical source-of-truth documentation.

### What belongs in Docs

| Information                 | Editorial boundary                                                                                  |
| :-------------------------- | :-------------------------------------------------------------------------------------------------- |
| **Product introduction**    | Clear, approved explanations of KAORI capabilities and operating principles.                        |
| **Concepts & architecture** | Capability/domain-first, provider-second, instance-third principles and committed evidence.         |
| **User guidance**           | Release-qualified, reviewed documentation when published.                                           |
| **Release-aware content**   | Versioned articles and navigation only after their explicit approval and source-to-release mapping. |

**Publication note:** An RC container or public endpoint does not prove that all documentation, versioned guides, search features, or a stable Docs release are available. Only specifically approved content is authoritative.

## Container profile

This is a **static read-only documentation image**. It is not the KAORI Application or its operational API.

|                             |                                                                                         |
| :-------------------------- | :-------------------------------------------------------------------------------------- |
| **Repository**              | `lethisaputri/kaori-docs`                                                               |
| **Generator**               | Docusaurus with TypeScript/React                                                        |
| **Runtime**                 | Unprivileged NGINX serving prebuilt static files                                        |
| **Internal HTTP**           | Port `8080` with `/healthz`                                                             |
| **Operational connections** | No user authentication, database, Redis or live infrastructure-provider access          |
| **Target host**             | [docs.kaori.cloud](https://docs.kaori.cloud), subject to the accepted publication state |

Docs has its own isolated container/release identity and independently governed deployment. A Docs release never automatically publishes an Application or Website release.

## Pull an approved image

Select a release-qualified image by its **immutable registry digest**:

```bash
docker pull lethisaputri/kaori-docs@sha256:<approved-digest>
```

Replace `<approved-digest>` with the complete accepted SHA-256 manifest digest. Use the documented Docs release/deployment procedure; pulling an image alone does not establish a public Docs release.

| Reference          | Meaning                                                                    |
| :----------------- | :------------------------------------------------------------------------- |
| `vX.Y.Z-rc.N`      | Signed/admitted candidate only when backed by the exact required evidence. |
| `vX.Y.Z`           | Stable Docs image only after accepted promotion.                           |
| `@sha256:<digest>` | Immutable identity for a specific Docs artifact.                           |
| `latest`           | Not an approved release-selection contract.                                |

Docs image versions and **KAORI Application documentation versions are separate**. A container tag must never be treated as proof that its corresponding application version has a complete published documentation set.

## Explore and verify

- [Documentation endpoint](https://docs.kaori.cloud) — availability and published scope depend on accepted release evidence
- [KAORI Website](https://kaori.cloud) — product introduction
- [KAORI Application](https://app.kaori.cloud) — authenticated operational platform
- [KAORI Docs GitHub](https://github.com/OXY7O/kaori-docs) — source, development and editorial governance
- [Docs GitHub Releases](https://github.com/OXY7O/kaori-docs/releases) — signed RC/stable release records where available
- [KAORI product source](https://github.com/OXY7O/KAORI) — product and architecture authority

## Security, attribution and publication

Public documentation must be reviewed for release applicability, secrets, private endpoints and internal operational evidence before publication. The static container does not need production-provider credentials.

**Software code, public documentation text, third-party materials and KAORI brand assets have different rights scopes.** Check the license and notices associated with the exact accepted Docs release. Neither the container image nor a public documentation page grants rights to protected KAORI/OXY7O trademarks, logo or artwork.

For vulnerability reports, use the repository's approved **private** security-reporting channel; do not disclose credentials or sensitive findings in public issues.

---

**KAORI Docs — Find the context. Follow the evidence. Apply the right guidance.**
