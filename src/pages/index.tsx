import React from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

const documentationSections = [
  {
    title: 'Getting Started',
    description:
      'An introduction to KAORI, its audience, and how to read the documentation.',
  },
  {
    title: 'Core Concepts',
    description:
      'Capabilities, providers, instances, committed evidence, and cross-domain context.',
  },
  {
    title: 'Product Guides',
    description:
      'Capability-first guidance for inventory and other verified product workflows.',
  },
  {
    title: 'Integrations',
    description:
      'Domain-specific provider contracts, prerequisites, and verified setup guidance.',
  },
  {
    title: 'Tutorials & How-to',
    description:
      'Practical, scoped operational walkthroughs with clear expected results.',
  },
  {
    title: 'Administration & Security',
    description: 'Access, permissions, governance, and safe operational boundaries.',
  },
  {
    title: 'Troubleshooting & Reference',
    description:
      'Interpreting evidence, incomplete states, and documented recovery patterns.',
  },
  {
    title: 'Releases & Compatibility',
    description: 'Approved application release notes and documentation applicability.',
  },
] as const;

export default function DocumentationHome(): React.JSX.Element {
  return (
    <Layout
      title="Documentation Home"
      description="Explore KAORI infrastructure operations concepts, documentation topics, and publication status."
    >
      <main className="kaori-docs-home">
        <section className="kaori-docs-home__hero" aria-labelledby="docs-home-heading">
          <div className="container">
            <div className="kaori-docs-home__hero-content">
              <p className="kaori-docs-home__eyebrow">KAORI DOCUMENTATION</p>
              <Heading as="h1" id="docs-home-heading">
                KAORI Docs
              </Heading>
              <p className="kaori-docs-home__lead">
                A clearer path through infrastructure operations.
              </p>
              <p className="kaori-docs-home__summary">
                KAORI brings infrastructure visibility, operational workflows, analytics,
                reporting, and governance into a consistent operational context. This
                documentation space will explain the platform by capability first, then by
                integration and provider.
              </p>
              <div className="kaori-docs-home__actions" aria-label="Explore this page">
                <a className="button button--primary" href="#getting-started">
                  Get Started
                </a>
                <a
                  className="button button--outline button--secondary"
                  href="#explore-capabilities"
                >
                  Explore Capabilities
                </a>
              </div>
            </div>
            <aside
              className="kaori-docs-home__notice"
              aria-labelledby="docs-publication-status"
            >
              <Heading as="h2" id="docs-publication-status">
                Documentation publication status
              </Heading>
              <p>No public product documentation version is available here yet.</p>
              <p>
                Versioned guides, release notes, and search will be enabled only after
                their content and applicable application release have been reviewed and
                verified.
              </p>
            </aside>
          </div>
        </section>

        <div className="container kaori-docs-home__body">
          <section
            className="kaori-docs-home__section"
            id="getting-started"
            aria-labelledby="getting-started-heading"
          >
            <div className="kaori-docs-home__section-heading">
              <p className="kaori-docs-home__eyebrow">FIRST STEPS</p>
              <Heading as="h2" id="getting-started-heading">
                Getting Started
              </Heading>
              <p>
                Start with the operating model, then follow the evidence to the capability
                and provider responsible for each piece of context.
              </p>
            </div>
            <div className="kaori-docs-home__steps">
              <article className="kaori-docs-home__step">
                <span className="kaori-docs-home__step-number" aria-hidden="true">
                  01
                </span>
                <Heading as="h3">Understand the platform</Heading>
                <p>
                  KAORI is an infrastructure operations layer. It is not a replacement for
                  every integrated management or monitoring system.
                </p>
              </article>
              <article className="kaori-docs-home__step">
                <span className="kaori-docs-home__step-number" aria-hidden="true">
                  02
                </span>
                <Heading as="h3">Follow source authority</Heading>
                <p>
                  External systems own their source data and execution. KAORI normalizes
                  and connects the evidence needed for operational decisions.
                </p>
              </article>
              <article className="kaori-docs-home__step">
                <span className="kaori-docs-home__step-number" aria-hidden="true">
                  03
                </span>
                <Heading as="h3">Check scope and freshness</Heading>
                <p>
                  Read the source, collection scope, and evidence freshness before
                  interpreting a view or taking an operational action.
                </p>
              </article>
            </div>
          </section>

          <section
            className="kaori-docs-home__section"
            id="explore-capabilities"
            aria-labelledby="explore-capabilities-heading"
          >
            <div className="kaori-docs-home__section-heading">
              <p className="kaori-docs-home__eyebrow">DOCUMENTATION CATALOG</p>
              <Heading as="h2" id="explore-capabilities-heading">
                Explore Capabilities
              </Heading>
              <p>
                These are the approved documentation topics, not a claim that every
                underlying product capability is released. Articles will become navigable
                when verified and published.
              </p>
            </div>
            <div className="kaori-docs-home__catalog">
              {documentationSections.map((section) => (
                <article className="kaori-docs-home__category" key={section.title}>
                  <Heading as="h3">{section.title}</Heading>
                  <p>{section.description}</p>
                  <span className="kaori-docs-home__category-status">
                    Documentation in preparation
                  </span>
                </article>
              ))}
            </div>
          </section>

          <section
            className="kaori-docs-home__section kaori-docs-home__context"
            aria-labelledby="docs-boundary-heading"
          >
            <div>
              <p className="kaori-docs-home__eyebrow">HOW TO READ KAORI DOCS</p>
              <Heading as="h2" id="docs-boundary-heading">
                A consistent source of operational context
              </Heading>
              <p>
                Organize by capability and domain, then by provider and instance. External
                systems remain authoritative for their own data and execution; KAORI
                connects normalized, committed evidence across operational domains.
              </p>
              <p>
                This is a conceptual explanation of KAORI's product direction, not a
                description of a particular deployed environment.
              </p>
              <p className="kaori-docs-home__source">
                Product authority:{' '}
                <a href="https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md">
                  KAORI Platform Direction
                </a>
              </p>
            </div>
            <div
              className="kaori-docs-home__flow"
              role="group"
              aria-label="Conceptual flow: external systems provide source evidence; KAORI normalizes and commits evidence; operational context connects domains."
            >
              <div>External authoritative systems</div>
              <span aria-hidden="true">↓</span>
              <div>KAORI normalization &amp; committed evidence</div>
              <span aria-hidden="true">↓</span>
              <div>Cross-domain operational context</div>
            </div>
          </section>
        </div>
      </main>
    </Layout>
  );
}
