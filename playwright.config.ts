import {defineConfig, devices} from '@playwright/test';

const viewports = [
  {name: 'desktop-large', width: 1440, height: 900},
  {name: 'desktop', width: 1280, height: 800},
  {name: 'laptop', width: 1024, height: 768},
  {name: 'tablet', width: 768, height: 1024},
  {name: 'mobile', width: 390, height: 844},
  {name: 'mobile-small', width: 360, height: 800},
] as const;

// Explicit opt-in tests the native article shell against the local Docusaurus
// dev server; normal Full Admission keeps using the production static build.
const editorialPreview = process.env.KAORI_DOCS_EDITORIAL_PREVIEW === '1';
const serverUrl = editorialPreview
  ? 'http://127.0.0.1:3000'
  : 'http://127.0.0.1:14321';

const projects = viewports.flatMap((viewport) =>
  (['light', 'dark'] as const).map((theme) => ({
    name: `${viewport.name}-${theme}`,
    use: {
      ...devices['Desktop Chrome'],
      viewport: {width: viewport.width, height: viewport.height},
      colorScheme: theme,
    },
  })),
);

export default defineConfig({
  testDir: './tests/browser',
  fullyParallel: true,
  forbidOnly: true,
  retries: 1,
  workers: 2,
  timeout: 30_000,
  reporter: [
    ['list'],
    ['html', {open: 'never', outputFolder: 'playwright-report'}],
    ['json', {outputFile: 'test-results/browser-results.json'}],
  ],
  outputDir: 'test-results',
  use: {
    baseURL: serverUrl,
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
    actionTimeout: 10_000,
  },
  projects,
  webServer: {
    command: editorialPreview
      ? 'npm run dev'
      : 'npx docusaurus serve --host 127.0.0.1 --port 14321',
    url: serverUrl,
    timeout: editorialPreview ? 90_000 : 45_000,
    reuseExistingServer: false,
  },
});
