import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';
import { createServer } from 'vite';

// Unit half runs through Vite (the content seeds import .md?raw); browser half
// expects the local dev server on 5173, same as live-content.test.mjs.
const root = fileURLToPath(new URL('../', import.meta.url));
const base = 'http://127.0.0.1:5173';
const unavailable = { status: 500, contentType: 'application/json', body: '{"error":"Unavailable"}' };

let vite;
let browser;

before(async () => {
  vite = await createServer({
    root,
    appType: 'custom',
    logLevel: 'silent',
    server: { middlewareMode: true, hmr: false, watch: null },
  });
  browser = await chromium.launch({ channel: 'chrome', headless: true });
});

after(async () => {
  await browser?.close();
  await vite?.close();
});

test('mapActivities orders newest first and formats the date label', async () => {
  const { mapActivities } = await vite.ssrLoadModule('/src/lib/content-mappers.js');
  const feed = mapActivities([
    { external_id: 'older', provider: 'linkedin', channel: '', kind: 'post', text: 'Older', url: '', image: '', posted_at: '2026-10-30 10:00:00' },
    { external_id: 'newer', provider: 'x', channel: '', kind: 'post', text: 'Newer', url: 'https://x.com/a', image: '', posted_at: '2026-10-31 09:00:00' },
  ]);
  assert.deepEqual(feed.map((post) => post.id), ['newer', 'older']);
  assert.equal(feed[0].postedAt, '2026-10-31T09:00:00Z');
  assert.equal(feed[0].dateLabel, '31 Oct 2026');
});

test('webhook normalizer passes its contract and every touched PHP file parses', () => {
  for (const file of ['api/social.php', 'api/social-lib.php', 'api/index.php']) {
    execFileSync('php', ['-l', path.join(root, file)], { stdio: 'pipe' });
  }
  const output = execFileSync('php', [path.join(root, 'scripts/social-normalize-check.php')], {
    encoding: 'utf8',
  });
  assert.match(output, /all checks passed/);
});

async function pageFor(t, activityReply = { data: [] }) {
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, reducedMotion: 'reduce' });
  page.setDefaultTimeout(10000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  t.after(async () => {
    await page.close();
    assert.deepEqual(errors, [], 'No uncaught browser errors');
  });
  await page.route('**/*', async (route) => {
    const url = new URL(route.request().url());
    if (url.origin !== base) return route.abort();
    if (url.pathname !== '/api/index.php') return route.continue();
    if (url.searchParams.get('entity') !== 'activity') {
      return route.fulfill({ status: unavailable.status, contentType: unavailable.contentType, body: unavailable.body });
    }
    return route.fulfill({
      status: activityReply.status ?? 200,
      contentType: 'application/json',
      body: activityReply.body ?? JSON.stringify(activityReply),
    });
  });
  return page;
}

async function visit(page, route = '/activity') {
  await page.goto(`${base}${route}`, { waitUntil: 'networkidle' });
}

const rows = [
  {
    external_id: 'li-1', provider: 'linkedin', channel: 'Hasan on LinkedIn', kind: 'post',
    text: 'EVLAB release notes.', url: 'https://www.linkedin.com/posts/example', image: '',
    posted_at: '2026-10-30 10:00:00',
  },
  {
    external_id: 'x-2', provider: 'x', channel: 'hasan', kind: 'post',
    text: 'Flutter startup time notes.', url: 'https://x.com/example/status/1', image: '',
    posted_at: '2026-10-31 09:00:00',
  },
];

test('empty activity shows the empty state, noindex, and no footer entry', async (t) => {
  const page = await pageFor(t);
  await visit(page);
  assert.match(await page.locator('h1').innerText(), /What I publish/);
  assert.match(await page.locator('main').innerText(), /Nothing cross-posted yet\./);
  assert.equal(await page.locator('main ol > li').count(), 0);
  assert.equal(await page.locator('footer a[href="/activity"]').count(), 0);
  assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
  assert.equal(
    await page.locator('link[rel="canonical"]').getAttribute('href'),
    'https://hasanabbassorathiya.tech/activity',
  );
});

test('live activity renders newest first with safe external links and a footer entry', async (t) => {
  const page = await pageFor(t, { data: rows });
  await visit(page);
  const cards = page.locator('main ol > li');
  assert.equal(await cards.count(), 2);
  assert.match(await cards.first().innerText(), /Flutter startup time notes\./);
  assert.match(await cards.first().innerText(), /X/);
  assert.match(await cards.first().innerText(), /31 Oct 2026/);
  assert.match(await cards.last().innerText(), /EVLAB release notes\./);
  assert.match(await cards.last().innerText(), /LinkedIn/);

  const link = cards.first().locator('a', { hasText: 'View the original' });
  assert.equal(await link.getAttribute('href'), 'https://x.com/example/status/1');
  assert.equal(await link.getAttribute('target'), '_blank');
  assert.equal(await link.getAttribute('rel'), 'noreferrer');
  assert.equal(await page.locator('footer a[href="/activity"]').count(), 1);
  assert.match(await page.locator('main').innerText(), /2 posts/i);
});

test('the footer Activity entry follows hydration on other routes', async (t) => {
  const page = await pageFor(t, { data: rows });
  await visit(page, '/');
  assert.equal(await page.locator('footer a[href="/activity"]').count(), 1);
});

test('post text is escaped, never injected as markup', async (t) => {
  const page = await pageFor(t, {
    data: [{
      external_id: 'evil', provider: 'x', channel: '', kind: 'post',
      text: '<img src=x onerror="window.__xss=1">', url: '', image: '',
      posted_at: '2026-10-31 09:00:00',
    }],
  });
  await visit(page);
  assert.equal(await page.locator('main img[src="x"]').count(), 0);
  assert.equal(await page.evaluate(() => window.__xss), undefined);
  assert.match(await page.locator('main ol > li').first().innerText(), /<img src=x/);
});

for (const [label, reply] of [
  ['empty object', { data: {} }],
  ['null rows', { data: null }],
  ['invalid row', { data: [{}] }],
  ['HTTP 500', { status: 500, body: '{"error":"Unavailable"}' }],
]) {
  test(`${label} keeps the feed empty instead of rendering bad rows`, async (t) => {
    const page = await pageFor(t, reply);
    await visit(page);
    assert.match(await page.locator('main').innerText(), /Nothing cross-posted yet\./);
    assert.equal(await page.locator('main ol > li').count(), 0);
  });
}
