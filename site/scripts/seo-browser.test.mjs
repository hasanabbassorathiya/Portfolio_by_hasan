import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { chromium } from 'playwright-core';

let browser;
const dev = process.env.SITE_TEST_URL || 'http://127.0.0.1:5173';
const apache = process.env.SITE_APACHE_URL || 'http://127.0.0.1:8099';
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

test('article-only metadata is removed after client-side navigation to services', async (t) => {
  const page = await browser.newPage({ reducedMotion: 'reduce' });
  t.after(() => page.close());
  await page.goto(`${dev}/blog/clean-architecture-flutter-teams`);
  await page.locator('article h1').waitFor();
  assert.equal(await page.locator('meta[property="article:published_time"]').count(), 1);
  assert.ok(await page.locator('meta[property="article:tag"]').count() > 0);
  await page.locator('header nav[aria-label="Primary"] a[href="/services"]').click();
  await page.waitForURL('**/services');
  await page.getByRole('heading', { name: /A clear scope/ }).waitFor();
  assert.equal(await page.locator('meta[property="article:published_time"]').count(), 0);
  assert.equal(await page.locator('meta[property="article:tag"]').count(), 0);
});

test('missing client case studies are excluded from indexing', async (t) => {
  const page = await browser.newPage();
  t.after(() => page.close());
  await page.goto(`${dev}/work/not-a-client`);
  await page.getByRole('heading', { name: 'That engagement is not in the archive.' }).waitFor();
  assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
});

test('Apache serves readable services and contact links with JavaScript disabled', async (t) => {
  const context = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 390, height: 844 } });
  t.after(() => context.close());
  const page = await context.newPage();
  const response = await page.goto(`${apache}/services/full-stack-api-development`);
  assert.equal(response.status(), 200);
  assert.ok(await page.getByRole('heading', { level: 1, name: 'MERN & full-stack API development' }).isVisible());
  await page.getByRole('link', { name: 'Discuss your project', exact: true }).click();
  const email = page.locator('#contact').getByRole('link', { name: 'Email me', exact: true });
  assert.ok(await email.isVisible());
  assert.equal(await email.getAttribute('href'), 'mailto:hasanabbassorathiya12@gmail.com');
  assert.equal(await page.locator('form').filter({ visible: true }).count(), 0);
  assert.equal(await page.getByRole('heading', { level: 1 }).count(), 1);
});

test('Apache returns genuine 404 status for unknown static routes and missing assets', async (t) => {
  const page = await browser.newPage({ javaScriptEnabled: false });
  t.after(() => page.close());
  for (const route of ['/unknown-route', '/services/not-a-service', '/missing-image.webp']) {
    const response = await page.goto(`${apache}${route}`);
    assert.equal(response.status(), 404, route);
    assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
    assert.ok(await page.getByRole('heading', { level: 1, name: 'This page went offline.' }).isVisible());
  }
});
