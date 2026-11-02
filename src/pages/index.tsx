import React from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

// Issue #11: minimal, truthful build fixture. Approved Docs Home is owned by #1.
export default function DocumentationPreparation(): React.JSX.Element {
  return (
    <Layout
      title="Documentation preparation"
      description="KAORI Docs is being prepared. No versioned product documentation has been published."
    >
      <main className="kaori-foundation">
        <div className="container">
          <div className="kaori-foundation__content">
            <p className="kaori-foundation__eyebrow">KAORI DOCUMENTATION</p>
            <Heading as="h1">KAORI Docs</Heading>
            <p>
              A dedicated home for KAORI product documentation is being prepared.
              Versioned product guides and release notes will appear only after review
              and release qualification.
            </p>
            <p className="kaori-foundation__notice" role="status">
              No public product documentation version is available here yet.
            </p>
            <p>
              For an introduction to the platform, visit the{' '}
              <a href="https://kaori.cloud">KAORI Website</a>.
            </p>
          </div>
        </div>
      </main>
    </Layout>
  );
}
