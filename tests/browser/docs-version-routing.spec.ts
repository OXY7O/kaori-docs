import {expect, test} from '@playwright/test';

test('no unverified application documentation version is public', async ({page}) => {
  test.skip(
    process.env.KAORI_DOCS_EDITORIAL_PREVIEW === '1',
    'Public-version isolation is measured against production static output',
  );
  await page.goto('/');
  await expect(page.getByRole('link', {name: /KAORI v0\.3/i})).toHaveCount(0);
  await expect(page.getByRole('link', {name: /version/i})).toHaveCount(0);
  await expect(page.locator('a[href^="/v0.3/"]')).toHaveCount(0);
  const response = await page.goto('/v0.3/getting-started/introduction');
  expect(response?.status()).toBe(404);
  await expect(page.getByRole('heading', {name: /Page Not Found/i})).toBeVisible();
});

test('opt-in native version route preview remains clearly unreleased', async ({page}) => {
  test.skip(
    process.env.KAORI_DOCS_VERSION_ROUTE_PREVIEW !== '1',
    'Native version preview requires explicit local development opt-in',
  );
  const response = await page.goto('/v0.3/getting-started/introduction');
  expect(response?.ok()).toBe(true);
  await expect(
    page.getByRole('heading', {level: 1, name: 'Introduction to KAORI'}),
  ).toBeVisible();
  await expect(page.getByText('unpublished review draft')).toBeVisible();
  await expect(page.getByText(/Unreleased/i).first()).toBeVisible();
});
