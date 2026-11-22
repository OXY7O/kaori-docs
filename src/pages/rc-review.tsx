import React from 'react';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

const operatingQuestions = [
  {
    title: 'Sources: Who owns the information?',
    answer:
      'An external monitoring, infrastructure, registry, or other integrated system remains authoritative for its own data and supported operations. Identify its configured instance and scope before drawing a conclusion.',
  },
  {
    title: 'Context: Which records can be related?',
    answer:
      'KAORI can normalize identities and use source-supported relationships to assemble cross-domain context. Similar names, timestamps, or labels alone do not prove that two resources are connected.',
  },
  {
    title: 'Evidence: What was actually observed?',
    answer:
      'Committed observations describe a known collection result. Check the source, observation time, completeness, and any missing or stale evidence instead of assuming a live provider state.',
  },
  {
    title: 'Governance: What action is allowed?',
    answer:
      'Viewing a finding is not permission to modify infrastructure. A supported workflow must verify its target, the operator’s authorization, impact, provider execution boundary, and auditable result.',
  },
];

export default function RcReview(): React.JSX.Element {
  return (
    <Layout
      title="Operational Model — RC Review"
      description="A release-neutral preview of how KAORI connects authoritative sources, context, committed evidence, and governed decisions."
    >
      <main className="container margin-vert--lg" id="rc-review">
        <div className="row">
          <article className="col col--8 col--offset-2 markdown">
            <p className="kaori-docs-home__eyebrow">
              DOCUMENTATION RC · CONCEPTUAL REVIEW
            </p>
            <Heading as="h1">How KAORI connects operational evidence</Heading>
            <blockquote>
              <p>
                <strong>Pre-release editorial preview.</strong> This page
                explains the operating model. It is not a versioned product
                guide, a live application view, or evidence that any specific
                integration or workflow is available in a stable release.
              </p>
            </blockquote>
            <p>
              Infrastructure work spans different tools. Each source describes
              part of an operational situation. KAORI is designed to connect
              authorized, traceable context across those domains without
              replacing the systems that own the data or execute operations.
            </p>

            <section aria-labelledby="rc-questions">
              <Heading as="h2" id="rc-questions">
                Four questions for every investigation
              </Heading>
              <ol>
                {operatingQuestions.map((question) => (
                  <li key={question.title}>
                    <strong>{question.title}</strong>
                    <p>{question.answer}</p>
                  </li>
                ))}
              </ol>
              <p>
                Sources, Context, Evidence, and Governance describe a way to
                reason about work. They are <strong>not</strong> a required
                synchronous pipeline or a claim that all providers are
                connected.
              </p>
            </section>

            <section aria-labelledby="rc-example">
              <Heading as="h2" id="rc-example">
                Example: interpreting a monitoring signal
              </Heading>
              <p>
                Imagine a monitoring system reports a possible workload
                problem. An inventory record and a registry observation might
                provide additional clues, but only a verified identity or
                binding can connect them to that workload. The following is a
                fictional, read-only learning example, not an observed
                incident.
              </p>
              <table>
                <thead>
                  <tr>
                    <th scope="col">Question</th>
                    <th scope="col">What to verify</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Is the signal current?</td>
                    <td>Source, timestamp, collection scope and freshness.</td>
                  </tr>
                  <tr>
                    <td>Is the asset the same?</td>
                    <td>
                      Authoritative identity and supported relationship evidence.
                    </td>
                  </tr>
                  <tr>
                    <td>Is the explanation complete?</td>
                    <td>
                      Unknown, unavailable, stale or partial observations.
                    </td>
                  </tr>
                  <tr>
                    <td>Can an action be taken?</td>
                    <td>
                      Supported workflow, explicit target, permissions and audit.
                    </td>
                  </tr>
                </tbody>
              </table>
              <p>
                A signal does not prove root cause. Missing findings do not
                prove health. Correlation can guide an investigation, but it
                must not invent relationships or authorize a change.
              </p>
            </section>

            <section aria-labelledby="rc-next">
              <Heading as="h2" id="rc-next">
                What comes after this preview?
              </Heading>
              <p>
                The Introduction, Core Concepts, Product Guides, Integrations,
                Tutorials, Administration and Troubleshooting articles remain
                separate <strong>unpublished review drafts</strong>. Their
                actual UI steps, permissions, compatibility and release scope
                require application evidence and human acceptance before
                versioned documentation can be published.
              </p>
              <p>
                <strong>Source authority:</strong> KAORI Platform Direction and
                the accepted KAORI Website product storytelling contract. This
                preview introduces concepts only; it asserts no specific KAORI
                Application release applicability.
              </p>
              <p>
                <Link to="/">Return to Documentation Home</Link>
              </p>
            </section>
          </article>
        </div>
      </main>
    </Layout>
  );
}
