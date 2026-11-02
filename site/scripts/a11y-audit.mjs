import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { chromium } from 'playwright-core';

const base = process.env.SITE_APACHE_URL || 'http://127.0.0.1:8099';
const out = new URL('../evidence/2026-10-31/', import.meta.url).pathname;
const require = createRequire(import.meta.url);
const axeSource = await readFile(require.resolve('axe-core/axe.min.js'), 'utf8');

const routes = [
  '/',
  '/services',
  '/services/flutter-app-development',
  '/services/ai-integration-automation',
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
  '/community',
  '/404',
];
const widths = [1440, 390];
const schemes = ['light', 'dark'];
const tags = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

await mkdir(out, { recursive: true });
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const findings = [];
const summary = [];

for (const scheme of schemes) {
  for (const width of widths) {
    for (const route of routes) {
      const context = await browser.newContext({
        viewport: { width, height: 900 },
        reducedMotion: 'reduce',
        colorScheme: scheme,
      });
      const page = await context.newPage();
      const response = await page.goto(`${base}${route}`, { waitUntil: 'load' });
      await page.locator('h1').first().waitFor();
      await page.evaluate(() => document.fonts.ready);
      const theme = await page.evaluate(() => document.documentElement.dataset.theme);
      if (theme !== scheme) throw new Error(`${route} rendered ${theme} while auditing ${scheme}`);
      const outline = await page.evaluate(() => {
        const levels = [...document.querySelectorAll('main h1, main h2, main h3, main h4, main h5, main h6')]
          .map((heading) => Number(heading.tagName[1]));
        const skips = [];
        let previous = 0;
        for (const level of levels) {
          if (previous && level > previous + 1) skips.push(`${previous}->${level}`);
          previous = level;
        }
        return { h1: document.querySelectorAll('h1').length, skips };
      });
      await page.addScriptTag({ content: axeSource });
      const result = await page.evaluate(async (runTags) => {
        const report = await window.axe.run(document, { runOnly: { type: 'tag', values: runTags } });
        return {
          violations: report.violations.map((violation) => ({
            id: violation.id,
            impact: violation.impact,
            help: violation.help,
            nodes: violation.nodes.slice(0, 4).map((node) => ({
              target: node.target,
              summary: node.failureSummary,
            })),
            total: violation.nodes.length,
          })),
          passes: report.passes.length,
          incomplete: report.incomplete.length,
        };
      }, tags);

      for (const violation of result.violations) {
        findings.push({ route, width, scheme, status: response?.status(), ...violation });
      }
      if (outline.h1 !== 1 || outline.skips.length) {
        findings.push({
          route, width, scheme, status: response?.status(),
          id: 'heading-outline', impact: 'serious',
          help: 'One h1 and no skipped heading levels inside main',
          nodes: [{ target: ['main'], summary: `h1=${outline.h1}; skips=${outline.skips.join(',') || 'none'}` }],
          total: 1,
        });
      }
      summary.push({
        route,
        width,
        scheme,
        status: response?.status(),
        violations: result.violations.length + (outline.h1 !== 1 || outline.skips.length ? 1 : 0),
        serious: result.violations.filter((item) => item.impact === 'serious' || item.impact === 'critical').length
          + (outline.h1 !== 1 || outline.skips.length ? 1 : 0),
        passes: result.passes,
        h1: outline.h1,
        headingSkips: outline.skips,
      });
      await context.close();
    }
  }
}

await browser.close();
await writeFile(`${out}a11y.json`, `${JSON.stringify({ ranAt: new Date().toISOString(), tags, summary, findings }, null, 2)}\n`);

for (const row of summary) {
  const flag = row.serious ? 'FAIL' : row.violations ? 'warn' : 'ok';
  console.log(`${flag.padEnd(4)} ${row.scheme.padEnd(5)} ${String(row.width).padEnd(4)} ${row.route.padEnd(42)} violations=${row.violations} serious=${row.serious} passes=${row.passes}`);
}
if (findings.length) {
  console.log('\nFinding detail:');
  for (const finding of findings) {
    console.log(`- [${finding.impact}] ${finding.id} on ${finding.route} @${finding.width}/${finding.scheme} (${finding.total} nodes)`);
    for (const node of finding.nodes) console.log(`    ${node.target.join(' ')}`);
  }
}
const blocking = findings.filter((finding) => finding.impact === 'serious' || finding.impact === 'critical');
console.log(`\n${summary.length} page checks · ${findings.length} violations · ${blocking.length} serious/critical`);
process.exit(blocking.length ? 1 : 0);
