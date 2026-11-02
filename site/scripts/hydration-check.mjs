import assert from 'node:assert/strict';
import { writeFile } from 'node:fs/promises';
import { chromium } from 'playwright-core';

const base = process.env.SITE_APACHE_URL || 'http://127.0.0.1:8099';
const out = new URL('../evidence/2026-10-31/hydration.json', import.meta.url).pathname;
const routes = [
  '/',
  '/services',
  '/services/flutter-app-development',
  '/apps',
  '/apps/duas-and-aamal',
  '/apps/blankspace',
  '/apps/bulbvpn',
  '/apps/klix',
  '/apps/urban-ledger',
  '/work',
  '/work/evlab',
  '/blog',
  '/blog/rag-that-survives-real-users',
  '/resources',
  '/resume',
  '/brand',
  '/privacy',
  '/404',
];
const themes = ['light', 'dark'];
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const findings = [];
let failures = 0;

for (const scheme of themes) {
  for (const route of routes) {
    const context = await browser.newContext({
      viewport: { width: 1280, height: 900 },
      colorScheme: scheme,
      reducedMotion: 'reduce',
    });
    const page = await context.newPage();
    const problems = [];
    page.on('console', (message) => {
      if (message.type() !== 'error' && message.type() !== 'warning') return;
      if (/hydrat|did not match|server HTML|Minified React error #(418|423|425)/i.test(message.text())) {
        problems.push(message.text());
      }
    });
    page.on('pageerror', (error) => problems.push(`pageerror: ${error.message}`));
    await page.addInitScript(() => {
      window.__rootRemovals = 0;
      window.__lcp = [];
      const attach = () => {
        const root = document.getElementById('root');
        if (!root) return false;
        new MutationObserver((records) => {
          for (const record of records) window.__rootRemovals += record.removedNodes.length;
        }).observe(root, { childList: true });
        return true;
      };
      const watcher = new MutationObserver(() => {
        if (attach()) watcher.disconnect();
      });
      watcher.observe(document, { childList: true, subtree: true });
      attach();
      new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          window.__lcp.push({
            time: entry.startTime,
            size: entry.size,
            element: entry.element ? entry.element.id || entry.element.tagName : null,
          });
        }
      }).observe({ type: 'largest-contentful-paint', buffered: true });
    });

    await page.goto(`${base}${route}`, { waitUntil: 'load' });
    await page.waitForTimeout(800);

    const theme = await page.evaluate(() => document.documentElement.dataset.theme);
    const removals = await page.evaluate(() => window.__rootRemovals);
    const lcp = await page.evaluate(() => window.__lcp.at(-1) || null);
    const heading = await page.locator('h1').first().textContent().catch(() => null);

    assert.equal(theme, scheme, `${route} ${scheme}: theme`);
    assert.ok(heading, `${route} ${scheme}: no h1`);
    if (problems.length) {
      failures += 1;
      findings.push({ route, scheme, status: 'react-problem', problems });
    } else if (removals > 0) {
      failures += 1;
      findings.push({ route, scheme, status: 'markup-replaced', removals });
    } else {
      findings.push({ route, scheme, status: 'hydrated', lcp, removals });
      console.log(`hydrated ${route} [${scheme}] LCP ${Math.round(lcp?.time || 0)}ms → ${lcp?.element || 'n/a'}`);
    }
    assert.deepEqual(problems, [], `${route} ${scheme}: react problems`);
    assert.equal(removals, 0, `${route} ${scheme}: prerendered markup was replaced, not hydrated`);
    await context.close();
  }
}

// Client-side navigation still works after hydration.
const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
const page = await context.newPage();
const errors = [];
page.on('pageerror', (error) => errors.push(error.message));
await page.goto(`${base}/`, { waitUntil: 'load' });
await page.waitForTimeout(500);
await page.getByRole('link', { name: 'Services', exact: true }).first().click();
await page.getByRole('heading', { level: 1 }).waitFor();
assert.equal(new URL(page.url()).pathname, '/services');
await page.getByRole('button', { name: /Switch to (dark|light) theme/ }).filter({ visible: true }).first().click();
const toggled = await page.evaluate(() => document.documentElement.dataset.theme);
assert.ok(toggled === 'dark' || toggled === 'light');
assert.deepEqual(errors, []);
await context.close();

await browser.close();
await writeFile(out, `${JSON.stringify({ ranAt: new Date().toISOString(), base, findings }, null, 2)}\n`);
console.log(`hydration sweep: ${findings.length} checks, ${failures} failures`);
process.exit(failures ? 1 : 0);
