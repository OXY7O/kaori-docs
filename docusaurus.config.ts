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
  title: 'KAORI Docs',
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
      title: 'KAORI Docs',
      logo: {alt: 'KAORI logo', src: 'branding/kaori-logo.svg'},
      items: [
        {href: 'https://kaori.cloud', label: 'KAORI Website', position: 'right'},
        {href: 'https://app.kaori.cloud', label: 'Open Application', position: 'right'},
      ],
    },
    footer: {
      style: 'light',
      links: [],
      copyright: 'KAORI documentation · Release-qualified content only',
    },
  } satisfies Preset.ThemeConfig,
};
export default config;
