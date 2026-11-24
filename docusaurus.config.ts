import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import {resolvePublishedApplicationDocs} from './src/versioning/publication';

// The public build must never enable unverified application-version documentation.
// Issue #2 permits native article review only in an explicitly opted-in local dev session.
// Issue #15 separately owns release-qualified version routing and publication.
const editorialPreview =
  process.env.KAORI_DOCS_EDITORIAL_PREVIEW === '1' &&
  process.env.npm_lifecycle_event === 'dev' &&
  process.env.NODE_ENV !== 'production' &&
  process.env.CI !== 'true';

// Native route smoke only in opt-in development, not in any public build.
const versionRoutePreview =
  editorialPreview && process.env.KAORI_DOCS_VERSION_ROUTE_PREVIEW === '1';
const publishedApplicationDocs = resolvePublishedApplicationDocs();
const publishedLines = publishedApplicationDocs.map((entry) => entry.line);

const publishedDocsOptions: Preset.Options['docs'] =
  publishedLines.length === 0
    ? false
    : {
        path: 'content',
        routeBasePath: '/',
        sidebarPath: './sidebars.ts',
        breadcrumbs: true,
        includeCurrentVersion: false,
        lastVersion: publishedLines[0],
        onlyIncludeVersions: publishedLines,
        versions: Object.fromEntries(
          publishedApplicationDocs.map((entry) => [
            entry.line,
            {
              label: 'KAORI ' + entry.line + '.x',
              path: entry.line,
              banner: 'none',
              badge: true,
            },
          ]),
        ),
      };

const config: Config = {
  title: 'KAORI Documentation',
  tagline: 'Knowledge, Automation, Operations, Resilience & Intelligence',
  url: 'https://docs.kaori.cloud',
  baseUrl: '/',
  favicon: 'branding/kaori-logo.svg',
  trailingSlash: false,
  scripts: editorialPreview ? [] : [{src: '/analytics.js', defer: true}],
  clientModules: editorialPreview ? [] : [require.resolve('./src/analytics/client')],
  onBrokenLinks: 'throw',
  i18n: {defaultLocale: 'en', locales: ['en']},
  presets: [
    [
      'classic',
      {
        docs: versionRoutePreview
          ? {
              path: 'content',
              routeBasePath: '/',
              sidebarPath: './sidebars.ts',
              breadcrumbs: true,
              lastVersion: 'current',
              versions: {
                current: {
                  label: 'Unreleased version-routing preview',
                  path: 'v0.3',
                  banner: 'unreleased',
                },
              },
            }
          : editorialPreview
            ? {
                path: 'content',
                routeBasePath: 'editorial-preview',
                sidebarPath: './sidebars.ts',
                breadcrumbs: true,
              }
            : publishedDocsOptions,
        blog: false,
        theme: {customCss: './src/css/custom.css'},
      } satisfies Preset.Options,
    ],
  ],
  themeConfig: {
    image: 'branding/kaori-logo.svg',
    colorMode: {
      defaultMode: 'light',
      respectPrefersColorScheme: true,
      disableSwitch: false,
    },
    navbar: {
      title: 'KAORI Documentation',
      logo: {alt: 'KAORI logo', src: 'branding/kaori-logo.svg'},
      items: [
        {to: '/', label: 'Overview', position: 'left'},
        ...(publishedLines.length > 0
          ? [{type: 'docsVersionDropdown' as const, position: 'left' as const}]
          : []),
        {href: '/#explore-capabilities', label: 'Catalog', position: 'left'},
        {href: '/#how-to-use', label: 'How to Use', position: 'left'},
        {href: 'https://kaori.cloud', label: 'KAORI Website', position: 'right'},
        {
          href: 'https://app.kaori.cloud',
          label: 'Open Application',
          position: 'right',
          className: 'kaori-docs-nav-app',
        },
      ],
    },
    footer: {
      style: 'light',
      logo: {
        alt: 'KAORI Documentation',
        src: 'branding/kaori-logo.svg',
        width: 32,
        height: 32,
      },
      links: [
        {
          title: 'Explore',
          items: [
            {label: 'Overview', to: '/'},
            {label: 'Catalog', href: '/#explore-capabilities'},
            {label: 'How to Use', href: '/#how-to-use'},
          ],
        },
        {
          title: 'Product',
          items: [
            {label: 'Open Application', href: 'https://app.kaori.cloud'},
            {label: 'KAORI Website', href: 'https://kaori.cloud'},
          ],
        },
        {
          title: 'Contact',
          items: [
            {label: 'Contact owner', href: 'mailto:lethisaputri@gmail.com'},
            {
              html: '<details><summary>Analytics privacy</summary><p>If you allow analytics and the operator enables it, self-hosted Umami measures page paths, referring sites, device and language information, and selected link clicks. Network metadata is processed to derive session and location statistics. Query strings, URL fragments, custom identities, search terms and session recordings are excluded. Browser privacy signals are respected. Your preference is stored in this browser; disable analytics at any time.</p><button class="button button--secondary" type="button" data-kaori-analytics-choice="allow">Allow analytics</button> <button class="button button--secondary" type="button" data-kaori-analytics-choice="deny">Disable analytics</button><p role="status" data-kaori-analytics-status></p></details>',
            },
          ],
        },
      ],
      copyright: '© 2026 KAORI. All rights reserved. · Release-qualified content only.',
    },
  } satisfies Preset.ThemeConfig,
};
export default config;
