import assert from 'node:assert/strict';
import { test, before, after } from 'node:test';
import { chromium } from 'playwright-core';

const base = process.env.SITE_TEST_URL || 'http://127.0.0.1:5173';
let browser;
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

async function openPage(t, width = 390) {
  const page = await browser.newPage({ viewport: { width, height: 844 }, reducedMotion: 'reduce' });
  t.after(() => page.close());
  await page.goto(base);
  await page.getByRole('heading', { level: 1 }).waitFor();
  return page;
}

test('mobile visitors can reach the email CTA without opening the navigation menu', async (t) => {
  const page = await openPage(t);
  const trigger = page.locator('header').getByRole('link', { name: 'Start a project', exact: true });
  const visible = await trigger.all().then(async (links) => (await Promise.all(links.map((link) => link.isVisible()))).filter(Boolean));
  assert.equal(visible.length, 1, 'one project CTA must be visible in the mobile header');
  await trigger.filter({ visible: true }).click();
  const email = page.locator('#contact').getByRole('link', { name: 'Email me', exact: true });
  await email.waitFor({ state: 'visible' });
  assert.match(await email.getAttribute('href'), /^mailto:hasanabbassorathiya12@gmail\.com(?:\?|$)/);
  await page.waitForFunction(() => {
    const rect = document.getElementById('contact').getBoundingClientRect();
    return rect.top >= 0 && rect.top < 180;
  });
  const rect = await email.boundingBox();
  assert.ok(rect && rect.y > 70 && rect.y + rect.height < 844, 'email CTA must be in view and clear of the sticky header');
  await page.evaluate(() => window.scrollTo(0, 0));
  await trigger.filter({ visible: true }).click();
  await page.waitForFunction(() => {
    const top = document.getElementById('contact').getBoundingClientRect().top;
    return top >= 70 && top < 180;
  }, undefined, { timeout: 3000 });
});

test('the footer keeps a direct email route on every page', async (t) => {
  const page = await openPage(t, 1440);
  const footer = page.locator('footer');
  const primary = footer.getByRole('link', { name: 'Email Hasan', exact: true });
  assert.equal(await primary.count(), 1, 'footer must expose a clearly named direct email CTA');
  assert.match(await primary.getAttribute('href'), /^mailto:hasanabbassorathiya12@gmail\.com/);
  for (const name of ['LinkedIn', 'GitHub']) {
    assert.equal(await footer.getByRole('link', { name, exact: true }).count(), 1);
  }
});

test('a CMS app without a rating still renders the home page', async (t) => {
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  t.after(() => page.close());
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.route('**/api/index.php?entity=apps', (route) => route.fulfill({
    json: { data: [{ slug: 'unrated-app', name: 'Unrated App', tagline: 'A published app.', platforms: '["iOS"]', icon: '/media/apps/duas-and-aamal/icon.webp', screenshots: '[]', links: '{}', features: '[]', metrics: '[]', stack: '[]', rating_value: null, rating_count: null }] },
  }));
  const response = page.waitForResponse((res) => res.url().endsWith('entity=apps'));
  await page.goto(base);
  await response;
  await page.getByRole('heading', { level: 1 }).waitFor();
  await page.waitForFunction(() => document.body.textContent.includes('Unrated App'));
  assert.deepEqual(errors, [], 'optional CMS ratings must not crash the hero');
  assert.equal(await page.locator('#contact').count(), 1);
});
