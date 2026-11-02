import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('bootstrap is accurate and accessible at six viewports and two themes', async ({
  page,
}, testInfo) => {
  await page.goto('/');
  // The static shell renders before Docusaurus hydrates its native color-mode state.
  await expect(page.locator('html')).toHaveAttribute('data-has-hydrated', 'true');
  await expect(page).toHaveTitle(/KAORI Docs/);
  await expect(page.getByRole('heading', {level: 1, name: 'KAORI Docs'})).toHaveCount(1);
  await expect(
    page.getByText('No public product documentation version is available here yet.'),
  ).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('data-theme', /^(light|dark)$/);

  // On compact viewports Docusaurus puts the real theme control and nav links
  // inside its responsive navigation drawer. Open that drawer, never force-click
  // a hidden desktop control or mutate the DOM to simulate theme behavior.
  const navigationToggle = page.getByRole('button', {name: 'Toggle navigation bar'});
  const compactNavigation = await navigationToggle.isVisible();
  if (compactNavigation) {
    await navigationToggle.click();
  }

  // Docusaurus uses three native choices: system -> light -> dark -> system.
  // A system-preferring-light browser must click twice before visually turning
  // dark. Assert each choice and its rendered theme without forcing DOM state.
  const html = page.locator('html');
  const initialSystemTheme = await html.getAttribute('data-theme');
  await expect(html).toHaveAttribute('data-theme-choice', 'system');
  const toggle = page.getByRole('button', {
    name: /Switch between dark and light mode/,
  });
  await expect(toggle).toBeVisible();
  await toggle.click();
  await expect(html).toHaveAttribute('data-theme-choice', 'light');
  await expect(html).toHaveAttribute('data-theme', 'light');
  await toggle.click();
  await expect(html).toHaveAttribute('data-theme-choice', 'dark');
  await expect(html).toHaveAttribute('data-theme', 'dark');
  await toggle.click();
  await expect(html).toHaveAttribute('data-theme-choice', 'system');
  await expect(html).toHaveAttribute('data-theme', initialSystemTheme!);

  await expect(page.locator('a[href="https://kaori.cloud"]').first()).toHaveAttribute(
    'href',
    'https://kaori.cloud',
  );
  await expect(page.locator('a[href="https://app.kaori.cloud"]').first()).toHaveAttribute(
    'href',
    'https://app.kaori.cloud',
  );
  if (compactNavigation) {
    await expect(page.getByRole('link', {name: /Open Application/})).toBeVisible();
  }

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
