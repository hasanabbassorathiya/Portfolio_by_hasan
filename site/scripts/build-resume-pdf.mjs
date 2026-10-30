import { createServer } from 'node:http';
import { readFile, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright-core';

const root = process.cwd();
const dist = path.join(root, 'dist');
const output = path.join(root, 'public/hasan-abbas-sorathiya-resume.pdf');
// dist/ is the deploy artefact and was built before this script ran, so keep both copies identical.
const distOutput = path.join(dist, 'hasan-abbas-sorathiya-resume.pdf');

const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.xml': 'application/xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.jpg': 'image/jpeg',
  '.woff2': 'font/woff2',
  '.pdf': 'application/pdf',
  '.ico': 'image/x-icon',
};

const server = createServer(async (req, res) => {
  const pathname = decodeURIComponent(new URL(req.url || '/', 'http://local').pathname);
  const base = path.join(dist, pathname);
  if (!base.startsWith(dist)) {
    res.writeHead(403).end('forbidden');
    return;
  }
  const candidates = pathname.endsWith('/') ? [path.join(base, 'index.html')] : [base, `${base}.html`];
  for (const candidate of candidates) {
    try {
      const info = await stat(candidate);
      if (info.isFile()) {
        res.writeHead(200, { 'Content-Type': types[path.extname(candidate)] || 'application/octet-stream' });
        res.end(await readFile(candidate));
        return;
      }
    } catch {
      // try the next candidate
    }
  }
  res.writeHead(404).end('not found');
});

await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const { port } = server.address();

let browser;
try {
  browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage({ viewport: { width: 1100, height: 1400 } });
  const response = await page.goto(`http://127.0.0.1:${port}/resume`, { waitUntil: 'networkidle' });
  if (!response || response.status() !== 200) {
    throw new Error(`/resume returned ${response ? response.status() : 'no response'}`);
  }
  await page.evaluate(() => document.fonts.ready);
  const heading = await page.locator('h1').innerText();
  if (!/Hasan Abbas Sorathiya/.test(heading)) throw new Error(`Unexpected resume heading: ${heading}`);
  await page.emulateMedia({ media: 'print' });
  const pdf = await page.pdf({ printBackground: true, preferCSSPageSize: true });
  await writeFile(output, pdf);
  await writeFile(distOutput, pdf);
  const pages = (pdf.toString('latin1').match(/\/Type\s*\/Page[^s]/g) || []).length;
  console.log(
    `Wrote ${path.relative(root, output)} and ${path.relative(root, distOutput)} — ${pdf.length} bytes, ~${pages} A4 pages`,
  );
} finally {
  if (browser) await browser.close();
  await new Promise((resolve) => server.close(resolve));
}
