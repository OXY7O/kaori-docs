import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('bootstrap is accurate and accessible at six viewports and two themes', async ({
  page,
}, testInfo) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/KAORI Docs/);
  await expect(page.getByRole('heading', {level: 1, name: 'KAORI Docs'})).toHaveCount(1);
  await expect(
    page.getByText('No public product documentation version is available here yet.'),
  ).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('data-theme', /^(light|dark)$/);

  const htmlTheme = await page.locator('html').getAttribute('data-theme');
  const toggle = page.getByRole('button', {name: /dark|light/i}).first();
  await expect(toggle).toBeVisible();
  await toggle.click();
  await expect(page.locator('html')).toHaveAttribute(
    'data-theme',
    htmlTheme === 'dark' ? 'light' : 'dark',
  );
  // Toggle back using the real native Docusaurus control.
  await toggle.click();

  await expect(page.getByRole('link', {name: 'KAORI Website'}).first()).toHaveAttribute(
    'href',
    'https://kaori.cloud',
  );
  await expect(page.getByRole('link', {name: 'Open Application'})).toHaveAttribute(
    'href',
    'https://app.kaori.cloud',
  );

  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth - window.innerWidth,
  );
  expect(overflow, 'No horizontal overflow').toBeLessThanOrEqual(1);

  const scan = await new AxeBuilder({page})
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
    .analyze();
  expect(scan.violations, JSON.stringify(scan.violations, null, 2)).toEqual([]);
  await page.screenshot({
    path: testInfo.outputPath('kaori-docs-bootstrap.png'),
    fullPage: true,
  });
});

test('tab focus and public version/search absence', async ({page}) => {
  await page.goto('/');
  await page.keyboard.press('Tab');
  const focused = await page.evaluate(() => {
    const node = document.activeElement;
    return Boolean(node && node !== document.body && node !== document.documentElement);
  });
  expect(focused, 'Keyboard focus must be visible on an interactive control').toBe(true);
  await expect(page.getByRole('searchbox')).toHaveCount(0);
  await expect(page.getByRole('link', {name: /version/i})).toHaveCount(0);
  await expect(page.getByRole('heading', {level: 1})).toHaveCount(1);
});
