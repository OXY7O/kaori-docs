import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('documentation home is accurate and accessible at six viewports and two themes', async ({
  page,
}, testInfo) => {
  await page.goto('/');
  // Docusaurus hydrates its native color-mode state after rendering the static shell.
  await expect(page.locator('html')).toHaveAttribute('data-has-hydrated', 'true');
  await expect(page).toHaveTitle(/KAORI Docs/);
  await expect(page.getByRole('heading', {level: 1, name: 'KAORI Docs'})).toHaveCount(1);
  await expect(
    page.getByText('No public product documentation version is available here yet.'),
  ).toBeVisible();
  await expect(
    page.getByText('Versioned guides, release notes, and search appear after review.'),
  ).toBeVisible();
  await expect(
    page.getByRole('heading', {level: 2, name: 'Getting Started'}),
  ).toBeVisible();
  await expect(
    page.getByRole('heading', {level: 2, name: 'Explore Capabilities'}),
  ).toBeVisible();
  await expect(page.locator('.kaori-docs-home__category')).toHaveCount(8);
  await expect(page.locator('.kaori-docs-home__step')).toHaveCount(3);
  await expect(page.locator('.kaori-docs-home__category-status')).toHaveCount(8);
  await expect(
    page.getByRole('heading', {level: 2, name: 'Documentation publication status'}),
  ).toBeVisible();
  await expect(page.locator('a[href="#getting-started"]')).toBeVisible();
  await expect(page.locator('a[href="#explore-capabilities"]')).toBeVisible();
  await expect(page.locator('html')).toHaveAttribute('data-theme', /^(light|dark)$/);

  const navigationToggle = page.getByRole('button', {name: 'Toggle navigation bar'});
  const compactNavigation = await navigationToggle.isVisible();
  if (compactNavigation) {
    await navigationToggle.click();
  }

  // Use the actual Docusaurus system -> light -> dark -> system color-mode cycle.
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
  const footer = page.locator('footer');
  await expect(footer.getByText('Explore', {exact: true})).toBeVisible();
  await expect(footer.getByText('Product', {exact: true})).toBeVisible();
  await expect(footer.getByText('Contact', {exact: true})).toBeVisible();
  await expect(footer.getByRole('link', {name: 'Contact owner'})).toHaveAttribute(
    'href',
    'mailto:lethisaputri@gmail.com',
  );
  await expect(footer.getByRole('link', {name: 'Catalog'})).toHaveAttribute(
    'href',
    '/#explore-capabilities',
  );
  if (compactNavigation) {
    await expect(
      page.getByRole('link', {name: /Open Application/}).first(),
    ).toBeVisible();
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
    path: testInfo.outputPath('kaori-docs-home.png'),
    fullPage: true,
  });
});

test('same-page discovery and unpublished features stay honest', async ({page}) => {
  await page.goto('/');
  await page.keyboard.press('Tab');
  const focused = await page.evaluate(() => {
    const node = document.activeElement;
    return Boolean(node && node !== document.body && node !== document.documentElement);
  });
  expect(focused, 'Keyboard focus must be visible on an interactive control').toBe(true);

  await page.getByRole('link', {name: 'Explore Catalog', exact: true}).click();
  await expect(page).toHaveURL(/#explore-capabilities$/);
  await expect(
    page.getByRole('heading', {level: 3, name: 'Core Concepts'}),
  ).toBeVisible();
  await expect(page.getByRole('searchbox')).toHaveCount(0);
  await expect(page.getByRole('link', {name: /version/i})).toHaveCount(0);
  await expect(page.getByRole('heading', {level: 1})).toHaveCount(1);
  await expect(page.locator('.kaori-docs-home__category a')).toHaveCount(0);
});

test('navigation, content availability, and external destinations stay scoped', async ({
  page,
}) => {
  await page.goto('/');
  const footer = page.locator('footer');
  await expect(footer.getByRole('link', {name: 'Open Application'})).toHaveAttribute(
    'href',
    'https://app.kaori.cloud',
  );
  await expect(footer.getByRole('link', {name: 'KAORI Website'})).toHaveAttribute(
    'href',
    'https://kaori.cloud',
  );
  await expect(footer.getByRole('link', {name: 'How to Use'})).toHaveAttribute(
    'href',
    '/#how-to-use',
  );
  await expect(page.locator('.kaori-docs-home__preview > div')).toHaveCount(3);
  await expect(page.locator('.kaori-docs-home__flow > div')).toHaveCount(3);
  await expect(page.locator('h2#explore-capabilities')).toHaveCount(1);
  await expect(page.locator('h2#how-to-use')).toHaveCount(1);
  await expect(page.locator('.kaori-docs-home__category a')).toHaveCount(0);
  await expect(page.locator('a[href^="/v"]')).toHaveCount(0);
});
