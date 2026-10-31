import { mkdir, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright-core';

const base = process.env.SITE_APACHE_URL || 'http://127.0.0.1:8099';
const out = new URL('../evidence/2026-10-31/', import.meta.url).pathname;
const widths = [
  [1440, 900],
  [1280, 800],
  [1024, 768],
  [768, 1024],
  [390, 844],
  [320, 568],
];
const pages = [
  ['home', '/'],
  ['services', '/services'],
  ['apps', '/apps'],
  ['work', '/work'],
  ['blog', '/blog'],
  ['resources', '/resources'],
  ['resume', '/resume'],
  ['privacy', '/privacy'],
];

await mkdir(out, { recursive: true });
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const report = [];
let failed = false;

for (const [label, path] of pages) {
  const targets = widths;
  for (const [width, height] of targets) {
    const context = await browser.newContext({
      viewport: { width, height },
      deviceScaleFactor: 1,
      reducedMotion: 'reduce',
      colorScheme: 'light',
    });
    const page = await context.newPage();
    const consoleErrors = [];
    const failedRequests = [];
    const badResponses = [];
    page.on('console', (message) => {
      if (message.type() === 'error') consoleErrors.push(message.text());
    });
    page.on('requestfailed', (request) => failedRequests.push(`${request.url()} ${request.failure()?.errorText}`));
    page.on('response', (response) => {
      if (response.status() >= 400) badResponses.push(`${response.status()} ${response.url()}`);
    });

    const response = await page.goto(`${base}${path}`, { waitUntil: 'domcontentloaded' });
    const status = response?.status();
    await page.locator('h1').first().waitFor();
    await page.evaluate(() => document.fonts.ready);
    await page.waitForTimeout(800);

    const metrics = await page.evaluate(() => {
      const root = document.documentElement;
      const wideElements = [...document.querySelectorAll('body *')]
        .filter((element) => {
          const rect = element.getBoundingClientRect();
          return rect.width > 1 && (rect.right > root.clientWidth + 1 || rect.left < -1);
        })
        .slice(0, 5)
        .map((element) => `${element.tagName.toLowerCase()}.${[...element.classList].join('.')}`);
      return {
        scrollWidth: root.scrollWidth,
        clientWidth: root.clientWidth,
        wideElements,
        fontsLoaded: document.fonts.status,
      };
    });

    const file = `${label}-${width}`;
    await page.screenshot({ path: `${out}${file}.jpg`, type: 'jpeg', quality: 82, animations: 'disabled' });
    if (label === 'home' && (width === 1440 || width === 390)) {
      await page.screenshot({ path: `${out}${file}-full.jpg`, type: 'jpeg', quality: 76, fullPage: true, animations: 'disabled' });
    }

    const overflow = metrics.scrollWidth > metrics.clientWidth + 1;
    // The local Apache harness is a static snapshot with no PHP/MySQL, so the
    // content API returns 404 and the client falls back to seeds. Those misses
    // are recorded, not treated as failures; every other error still gates.
    const expectedApiMisses = badResponses.filter((line) => line.includes('/api/'));
    const unexpectedResponses = badResponses.filter((line) => !line.includes('/api/'));
    const unexpectedConsole = consoleErrors.filter((line) => !/status of 404/.test(line));
    if (overflow || !status?.toString().startsWith('2') || status >= 400 || unexpectedResponses.length || unexpectedConsole.length || failedRequests.length || metrics.fontsLoaded !== 'loaded') {
      failed = true;
    }
    report.push({ page: label, width, status, overflow, ...metrics, expectedApiMisses, badResponses, consoleErrors, failedRequests });
    await context.close();
  }
}

await browser.close();
await writeFile(`${out}report.json`, `${JSON.stringify(report, null, 2)}\n`);
for (const row of report) {
  console.log(`${row.page} ${row.width}px status=${row.status} overflow=${row.overflow} fonts=${row.fontsLoaded} errors=${row.consoleErrors.length} failed=${row.failedRequests.length} apiMisses=${row.expectedApiMisses.length}`);
  for (const item of row.wideElements) console.log(`  wide (clipped): ${item}`);
}
if (failed) {
  console.error('evidence capture failed a check');
  process.exit(1);
}
console.log(`screenshots written to site/evidence/2026-10-31/`);
