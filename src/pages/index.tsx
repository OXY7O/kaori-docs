import React from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import DocsIcon, {type DocsIconName} from '../components/DocsIcon';

interface DocumentationTopic {
  title: string;
  description: string;
  icon: DocsIconName;
}

const documentationSections: DocumentationTopic[] = [
  {
    title: 'Getting Started',
    description: 'Meet KAORI and learn the operating model.',
    icon: 'book-open',
  },
  {
    title: 'Core Concepts',
    description: 'Understand capabilities, providers, and evidence.',
    icon: 'layers',
  },
  {
    title: 'Product Guides',
    description: 'Navigate verified capability workflows.',
    icon: 'box',
  },
  {
    title: 'Integrations',
    description: 'Discover provider contracts and prerequisites.',
    icon: 'network',
  },
  {
    title: 'Tutorials & How-to',
    description: 'Follow scoped operational walkthroughs.',
    icon: 'terminal',
  },
  {
    title: 'Administration & Security',
    description: 'Explore access, permissions, and governance.',
    icon: 'shield-check',
  },
  {
    title: 'Troubleshooting & Reference',
    description: 'Interpret findings and recovery guidance.',
    icon: 'wrench',
  },
  {
    title: 'Releases & Compatibility',
    description: 'Check approved releases and applicability.',
    icon: 'database',
  },
];

const firstSteps: {
  number: string;
  title: string;
  description: string;
  icon: DocsIconName;
}[] = [
  {
    number: '01',
    title: 'Understand the platform',
    description:
      'KAORI connects infrastructure context without replacing source systems.',
    icon: 'layers',
  },
  {
    number: '02',
    title: 'Follow source authority',
    description: 'External systems execute. KAORI connects the evidence.',
    icon: 'shield-check',
  },
  {
    number: '03',
    title: 'Check scope and freshness',
    description: 'Review evidence scope before making a decision.',
    icon: 'clock',
  },
];

export default function DocumentationHome(): React.JSX.Element {
  return (
    <Layout
      title="Documentation Home"
      description="Explore KAORI infrastructure operations, documentation topics, and publication readiness."
    >
      <main className="kaori-docs-home" id="overview">
        <section className="kaori-docs-home__hero" aria-labelledby="docs-home-heading">
          <div className="container kaori-docs-home__hero-grid">
            <div className="kaori-docs-home__hero-content">
              <p className="kaori-docs-home__eyebrow">DOCUMENTATION HOME</p>
              <Heading as="h1" id="docs-home-heading">
                KAORI <span>Documentation</span>
              </Heading>
              <p className="kaori-docs-home__lead">
                Documentation for connected infrastructure operations.
              </p>
              <p className="kaori-docs-home__summary">
                Explore the platform by capability, workflow, and committed evidence.
              </p>
              <div
                className="kaori-docs-home__actions"
                aria-label="Explore documentation"
              >
                <a
                  className="button button--primary kaori-docs-home__primary"
                  href="#getting-started"
                >
                  Get Started <DocsIcon name="arrow-right" size={17} />
                </a>
                <a
                  className="button button--outline button--secondary kaori-docs-home__secondary"
                  href="#explore-capabilities"
                >
                  <DocsIcon name="layers" size={18} /> Explore Catalog
                </a>
              </div>
              <ul
                className="kaori-docs-home__principles"
                aria-label="Documentation principles"
              >
                <li>
                  <DocsIcon name="layers" size={15} /> Capability-first
                </li>
                <li>
                  <DocsIcon name="shield-check" size={15} /> Verified content only
                </li>
                <li>
                  <DocsIcon name="clock" size={15} /> Guides in preparation
                </li>
              </ul>
            </div>
            <aside
              className="kaori-docs-home__notice"
              aria-labelledby="docs-publication-status"
            >
              <div className="kaori-docs-home__notice-heading">
                <DocsIcon name="info" size={23} />
                <Heading as="h2" id="docs-publication-status">
                  Documentation publication status
                </Heading>
              </div>
              <p>Versioned guides, release notes, and search appear after review.</p>
              <div
                className="kaori-docs-home__preview"
                aria-label="Documentation topics not yet published"
              >
                <div>
                  <DocsIcon name="file-text" size={18} />
                  <span>Product guides &amp; how-to</span>
                  <small>In preparation</small>
                </div>
                <div>
                  <DocsIcon name="box" size={18} />
                  <span>Core concepts</span>
                  <small>In preparation</small>
                </div>
                <div>
                  <DocsIcon name="book-open" size={18} />
                  <span>Getting started</span>
                  <small>In preparation</small>
                </div>
              </div>
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
              <p>Learn the model, follow source authority, and verify context.</p>
            </div>
            <div className="kaori-docs-home__steps">
              {firstSteps.map((step) => (
                <article className="kaori-docs-home__step" key={step.number}>
                  <span className="kaori-docs-home__step-icon">
                    <DocsIcon name={step.icon} size={25} />
                  </span>
                  <div className="kaori-docs-home__step-content">
                    <span className="kaori-docs-home__step-number">{step.number}</span>
                    <Heading as="h3">{step.title}</Heading>
                    <p>{step.description}</p>
                  </div>
                </article>
              ))}
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
                Eight documentation topics. Articles become available after verification.
              </p>
            </div>
            <div className="kaori-docs-home__catalog">
              {documentationSections.map((section) => (
                <article className="kaori-docs-home__category" key={section.title}>
                  <div className="kaori-docs-home__category-icon">
                    <DocsIcon name={section.icon} size={23} />
                  </div>
                  <Heading as="h3">{section.title}</Heading>
                  <p>{section.description}</p>
                  <span className="kaori-docs-home__category-status">
                    <DocsIcon name="file-text" size={13} /> In preparation
                  </span>
                </article>
              ))}
            </div>
          </section>

          <section
            className="kaori-docs-home__section kaori-docs-home__context"
            id="how-to-use"
            aria-labelledby="docs-boundary-heading"
          >
            <div className="kaori-docs-home__context-copy">
              <p className="kaori-docs-home__eyebrow">HOW TO USE DOCUMENTATION</p>
              <Heading as="h2" id="docs-boundary-heading">
                A consistent source of <span>operational context</span>
              </Heading>
              <p>
                Organize by capability, provider, and instance. External systems remain
                authoritative for their data and execution.
              </p>
              <p>
                This diagram explains the KAORI model, not a specific deployed
                environment.
              </p>
              <p className="kaori-docs-home__source">
                <DocsIcon name="layers" size={17} />
                Product authority:{' '}
                <a href="https://github.com/OXY7O/KAORI/blob/main/docs/product/README.md">
                  KAORI Platform Direction
                  <DocsIcon name="arrow-up-right" size={14} />
                </a>
              </p>
            </div>
            <div
              className="kaori-docs-home__flow"
              role="group"
              aria-label="Conceptual model: authoritative external systems, KAORI normalization and committed evidence, and cross-domain operational context."
            >
              <div>
                <DocsIcon name="server" size={22} />
                <span>External authoritative systems</span>
              </div>
              <DocsIcon
                name="arrow-right"
                size={19}
                className="kaori-docs-home__flow-arrow"
              />
              <div className="kaori-docs-home__flow-focus">
                <DocsIcon name="layers" size={23} />
                <span>KAORI normalization &amp; committed evidence</span>
              </div>
              <DocsIcon
                name="arrow-right"
                size={19}
                className="kaori-docs-home__flow-arrow"
              />
              <div>
                <DocsIcon name="network" size={22} />
                <span>Cross-domain operational context</span>
              </div>
            </div>
          </section>
        </div>
      </main>
    </Layout>
  );
}
