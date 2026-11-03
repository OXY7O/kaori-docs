import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// The public build must never enable unverified application-version documentation.
// Issue #2 permits native article review only in an explicitly opted-in local dev session.
// Issue #15 separately owns release-qualified version routing and publication.
const editorialPreview =
  process.env.KAORI_DOCS_EDITORIAL_PREVIEW === '1' &&
  process.env.npm_lifecycle_event === 'dev' &&
  process.env.NODE_ENV !== 'production' &&
  process.env.CI !== 'true';
const config: Config = {
  title: 'KAORI Documentation',
  tagline: 'Knowledge, Automation, Operations, Resilience & Intelligence',
  url: 'https://docs.kaori.cloud',
  baseUrl: '/',
  favicon: 'branding/kaori-logo.svg',
  trailingSlash: false,
  onBrokenLinks: 'throw',
  i18n: {defaultLocale: 'en', locales: ['en']},
  presets: [
    [
      'classic',
      {
        docs: editorialPreview
          ? {
              path: 'content',
              routeBasePath: 'editorial-preview',
              sidebarPath: './sidebars.ts',
              breadcrumbs: true,
            }
          : false,
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
          items: [{label: 'Contact owner', href: 'mailto:lethisaputri@gmail.com'}],
        },
      ],
      copyright: '© 2026 KAORI. All rights reserved. · Release-qualified content only.',
    },
  } satisfies Preset.ThemeConfig,
};
export default config;
