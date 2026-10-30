import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { chromium } from 'playwright-core';
import { services } from '../src/content/services.js';

const base = process.env.SITE_TEST_URL || 'http://127.0.0.1:5173';
let browser;
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

async function pageFor(t, width = 390) {
  const page = await browser.newPage({ viewport: { width, height: 900 }, reducedMotion: 'reduce' });
  page.setDefaultTimeout(10000);
  t.after(() => page.close());
  return page;
}

test('home presents Petassy and Pool Inspection icons without cropping or overlays', async (t) => {
  const page = await pageFor(t);
  await page.goto(base);
  for (const slug of ['petassy', 'pool-inspection']) {
    const card = page.locator(`#work a[href="/apps/${slug}"]`);
    const image = card.locator('img');
    await card.scrollIntoViewIfNeeded();
    await image.waitFor();
    assert.match(await image.getAttribute('src'), /\/icon\.(webp|png|jpe?g)$/);
    await image.evaluate((img) => img.decode());
    assert.equal(await image.evaluate((img) => getComputedStyle(img).objectFit), 'contain');
    assert.equal(await card.locator('[aria-hidden="true"][class*="gradient"]').count(), 0);
  }
});

test('visitors can follow the full-stack offer, navigate services, and return to contact', async (t) => {
  const page = await pageFor(t, 1440);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto(base);
  const link = page.locator('#services').getByRole('link', { name: /MERN & full-stack/ });
  await link.click();
  await page.getByRole('heading', { level: 1, name: 'MERN & full-stack API development' }).waitFor();
  assert.equal(new URL(page.url()).pathname, '/services/full-stack-api-development');
  await page.getByRole('link', { name: 'All services', exact: true }).click();
  for (const service of services) {
    await page.locator(`main a[href="/services/${service.slug}"]`).click();
    await page.getByRole('heading', { level: 1, name: service.title, exact: true }).waitFor();
    assert.equal(await page.locator('link[rel="canonical"]').getAttribute('href'), `https://hasanabbassorathiya.tech/services/${service.slug}`);
    const schema = await page.locator('script[type="application/ld+json"]').allTextContents();
    assert.ok(schema.some((text) => JSON.parse(text)['@type'] === 'Service'));
    await page.getByRole('link', { name: 'All services', exact: true }).click();
  }
  await page.getByRole('link', { name: 'Discuss your project', exact: true }).click();
  await page.locator('#contact').getByRole('link', { name: 'Email me', exact: true }).waitFor();
  await page.goto(`${base}/services/not-a-service`);
  assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
  assert.deepEqual(errors, []);
});

for (const width of [320, 390, 768, 1024, 1280, 1440]) {
  for (const theme of ['light', 'dark']) {
    test(`${width}px ${theme}: header, contact and footer stay usable without overflow`, async (t) => {
      const page = await pageFor(t, width);
      await page.addInitScript((value) => localStorage.setItem('hs-theme', value), theme);
      await page.goto(base);
      await page.getByRole('heading', { level: 1 }).waitFor();
      assert.equal(await page.locator('html').getAttribute('data-theme'), theme);
      const nextTheme = theme === 'light' ? 'dark' : 'light';
      await page.getByRole('button', { name: `Switch to ${nextTheme} theme`, exact: true }).filter({ visible: true }).click();
      assert.equal(await page.locator('html').getAttribute('data-theme'), nextTheme);
      await page.getByRole('button', { name: `Switch to ${theme} theme`, exact: true }).filter({ visible: true }).click();
      assert.equal(await page.evaluate(() => localStorage.getItem('hs-theme')), theme);
      assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
      const cta = page.locator('header').getByRole('link', { name: 'Start a project', exact: true }).filter({ visible: true });
      assert.equal(await cta.count(), 1);
      await cta.click();
      await page.waitForFunction(() => {
        const rect = document.getElementById('contact').getBoundingClientRect();
        return rect.top >= 70 && rect.top < 180;
      });
      const email = page.locator('#contact').getByRole('link', { name: 'Email me', exact: true });
      const box = await email.boundingBox();
      assert.ok(box && box.x >= 0 && box.x + box.width <= width && box.y + box.height < 900);
      if (width < 1024) {
        await page.getByRole('button', { name: 'Open menu', exact: true }).click();
        await page.getByRole('navigation', { name: 'Mobile', exact: true }).waitFor();
        await page.keyboard.press('Escape');
        assert.equal(await page.getByRole('button', { name: 'Open menu', exact: true }).getAttribute('aria-expanded'), 'false');
      }
      await page.locator('footer').scrollIntoViewIfNeeded();
      assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
      assert.ok(await page.locator('footer').getByRole('link', { name: 'Email Hasan', exact: true }).isVisible());
    });
  }
}
