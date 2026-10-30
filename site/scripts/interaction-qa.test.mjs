import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { chromium } from 'playwright-core';

const base = process.env.SITE_TEST_URL || 'http://127.0.0.1:5173';
let browser;

before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

async function open(t, path = '/', { width = 390, reducedMotion = 'reduce' } = {}) {
  const context = await browser.newContext({ viewport: { width, height: 844 }, reducedMotion });
  t.after(() => context.close());
  const page = await context.newPage();
  await page.goto(`${base}${path}`);
  await page.getByRole('heading', { level: 1 }).waitFor();
  return page;
}

test('mobile menu opens, locks scroll, closes on Escape and returns focus', async (t) => {
  const page = await open(t, '/');
  await page.locator('header button[aria-label="Open menu"]').click();
  const toggle = page.locator('header button[aria-label="Close menu"]');
  assert.equal(await toggle.getAttribute('aria-expanded'), 'true');
  await page.locator('nav[aria-label="Mobile"]').waitFor({ state: 'visible' });
  assert.equal(await page.evaluate(() => document.body.style.overflow), 'hidden');
  await page.keyboard.press('Escape');
  await page.locator('nav[aria-label="Mobile"]').waitFor({ state: 'detached' });
  assert.equal(await page.evaluate(() => document.activeElement?.getAttribute('aria-label')), 'Open menu');
  assert.equal(await page.evaluate(() => document.body.style.overflow), '');
});

test('skip link is the first tab stop, visibly focused, and moves focus to main', async (t) => {
  const page = await open(t, '/', { width: 1440 });
  await page.keyboard.press('Tab');
  const skip = await page.evaluate(() => {
    const element = document.activeElement;
    const rect = element.getBoundingClientRect();
    return {
      href: element.getAttribute('href'),
      width: rect.width,
      height: rect.height,
      outline: getComputedStyle(element).outlineWidth,
    };
  });
  assert.equal(skip.href, '#main');
  assert.ok(skip.width > 0 && skip.height > 0, 'skip link must not stay visually hidden while focused');
  assert.notEqual(skip.outline, '0px', 'focused skip link must show a focus ring');
  await page.keyboard.press('Enter');
  assert.equal(await page.evaluate(() => location.hash), '#main');
  assert.equal(await page.evaluate(() => document.activeElement?.id), 'main');
});

test('reduced-motion visitors get no running animations after load', async (t) => {
  const page = await open(t, '/', { reducedMotion: 'reduce' });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(900);
  const running = await page.evaluate(() => document.getAnimations()
    .filter((animation) => animation.playState === 'running')
    .map((animation) => animation.animationName || animation.transitionProperty || 'unknown'));
  assert.deepEqual(running, []);
});

test('resume download resolves to a real PDF', async (t) => {
  const page = await open(t, '/resume', { width: 1440 });
  const link = page.getByRole('link', { name: 'Download PDF', exact: true });
  const href = await link.getAttribute('href');
  assert.equal(href, '/hasan-abbas-sorathiya-resume.pdf');
  const response = await page.request.get(`${base}${href}`);
  assert.equal(response.status(), 200);
  assert.match(response.headers()['content-type'], /application\/pdf/);
  const body = await response.body();
  assert.ok(body.length > 200000, `PDF looks truncated: ${body.length} bytes`);
  assert.equal(body.subarray(0, 5).toString(), '%PDF-');
});

test('enquiry form blocks empty submissions and shows success and error states', async (t) => {
  const page = await open(t, '/#contact', { width: 1440 });
  const posts = [];
  page.on('request', (request) => {
    if (request.url().includes('/api/enquiries.php')) posts.push(request);
  });
  await page.locator('#contact button[type="submit"]').click();
  assert.equal(await page.locator('#contact-name').evaluate((element) => element.matches(':invalid')), true);
  assert.equal(posts.length, 0, 'an empty form must not reach the API');

  await page.route('**/api/enquiries.php', (route) => route.fulfill({
    status: 201,
    contentType: 'application/json',
    body: JSON.stringify({ ok: true, reference: 'a'.repeat(32) }),
  }));
  await page.fill('#contact-name', 'QA Person');
  await page.fill('#contact-email', 'qa@example.com');
  await page.selectOption('#contact-type', { index: 1 });
  await page.fill('#contact-message', 'A twenty-plus character project description used by the QA run.');
  await page.check('#contact-consent');
  await page.locator('#contact button[type="submit"]').click();
  const status = page.getByRole('status').filter({ hasText: 'Enquiry saved' });
  await status.waitFor({ state: 'visible' });
  assert.match(await status.textContent(), /a{32}/);

  const errorPage = await open(t, '/#contact', { width: 1440 });
  await errorPage.route('**/api/enquiries.php', (route) => route.fulfill({
    status: 500,
    contentType: 'application/json',
    body: JSON.stringify({ ok: false }),
  }));
  await errorPage.fill('#contact-name', 'QA Person');
  await errorPage.fill('#contact-email', 'qa@example.com');
  await errorPage.fill('#contact-message', 'A twenty-plus character project description used by the QA run.');
  await errorPage.check('#contact-consent');
  await errorPage.locator('#contact button[type="submit"]').click();
  const alert = errorPage.getByRole('alert');
  await alert.waitFor({ state: 'visible' });
  assert.ok((await alert.textContent()).trim().length > 20);
});

test('profile links in the footer are https and open with a safe rel', async (t) => {
  const page = await open(t, '/', { width: 1440 });
  for (const [name, host] of [['LinkedIn', 'linkedin.com'], ['GitHub', 'github.com']]) {
    const link = page.locator('footer').getByRole('link', { name, exact: true });
    assert.equal(await link.count(), 1, `${name} link missing`);
    const href = await link.getAttribute('href');
    assert.ok(href.startsWith('https://') && href.includes(host), href);
    assert.equal(await link.getAttribute('target'), '_blank');
    assert.match(await link.getAttribute('rel'), /noreferrer|noopener/);
  }
});
