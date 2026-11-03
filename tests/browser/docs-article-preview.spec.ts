import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// These tests run only against an explicitly opted-in local development server.
// The public build must never include an editorial-preview or a draft guide.
test('Introduction uses native, accessible Docusaurus article layout', async ({
  page,
}, testInfo) => {
  test.skip(
    process.env.KAORI_DOCS_EDITORIAL_PREVIEW !== '1',
    'Unpublished article preview is local-only',
  );

  const response = await page.goto('/editorial-preview/getting-started/introduction');
  expect(response?.ok(), 'Native editorial preview route should exist').toBe(true);
  await expect(page.locator('html')).toHaveAttribute('data-has-hydrated', 'true');

  const article = page.locator('article');
  await expect(article).toBeVisible();
  await expect(
    article.getByRole('heading', {level: 1, name: 'Introduction to KAORI'}),
  ).toHaveCount(1);
  await expect(
    article.getByText('unpublished review draft', {exact: false}),
  ).toBeVisible();
  await expect(
    article.getByRole('heading', {level: 2, name: 'The capability-first model'}),
  ).toBeVisible();
  await expect(
    article.getByRole('heading', {level: 2, name: 'Why committed evidence matters'}),
  ).toBeVisible();
  await expect(
    article.getByRole('heading', {level: 2, name: 'Visibility is not authorization'}),
  ).toBeVisible();
  await expect(article.getByRole('table')).toBeVisible();
  await expect(article.getByRole('link', {name: 'Documentation Home'})).toHaveAttribute(
    'href',
    '/',
  );

  if ((page.viewportSize()?.width ?? 0) >= 997) {
    const sidebar = page.locator('.theme-doc-sidebar-container');
    await expect(sidebar).toBeVisible();
    await expect(sidebar.getByRole('link', {name: 'Introduction'})).toBeVisible();
    await expect(page.locator('.table-of-contents')).toBeVisible();
  }

  // No application version has been authorized for public product guides.
  await expect(page.getByRole('link', {name: /KAORI v0\.3/i})).toHaveCount(0);
  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth - window.innerWidth,
  );
  expect(overflow, 'Article has no horizontal overflow').toBeLessThanOrEqual(1);

  const scan = await new AxeBuilder({page})
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
    .analyze();
  expect(scan.violations, JSON.stringify(scan.violations, null, 2)).toEqual([]);
  await page.screenshot({
    path: testInfo.outputPath('kaori-docs-introduction-preview.png'),
    fullPage: true,
  });
});
