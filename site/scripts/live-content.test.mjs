import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { chromium } from 'playwright-core';

// Run against the existing local Vite server; only the HTTP API boundary is replaced.
const base = 'http://127.0.0.1:5173';
const empty = { data: [] };
const unavailable = { status: 500, body: '{"error":"Unavailable"}' };
const petassy = {
  slug: 'petassy', name: 'CMS Petassy', tagline: 'Published by the CMS',
  role: 'Creator · Flutter developer', year: '', platforms: '["iOS","Android"]',
  genre: 'Lifestyle', icon: '/media/apps/petassy/icon.webp', screenshots: '[]',
  rating_value: null, rating_count: null, stack: '[]',
  links: '{"github":"https://github.com/hasanabbassorathiya/petassy"}',
  summary: 'CMS publication only.', features: '["Published feature"]', story: '', metrics: '[]',
};
let browser;
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

async function pageFor(t, responses = {}, width = 1440) {
  const page = await browser.newPage({ viewport: { width, height: 900 }, reducedMotion: 'reduce' });
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
    const reply = responses[url.searchParams.get('entity')] ?? unavailable;
    return route.fulfill({
      status: reply.status ?? 200,
      contentType: 'application/json',
      body: reply.body ?? JSON.stringify(reply),
    });
  });
  return page;
}

async function visit(page, path = '/') {
  await page.goto(`${base}${path}`, { waitUntil: 'networkidle' });
}

async function schemas(page) {
  return (await page.locator('script[type="application/ld+json"]').allTextContents())
    .flatMap((text) => JSON.parse(text));
}

async function assertHiddenProfiles(page) {
  assert.equal(await page.locator('main a[href="/apps/hoda"], main a[href="/apps/duas-and-aamal"]').count(), 0);
  // The separate open-source biography mentions duas-crm; it is not an app profile.
  const inventory = await page.locator('#top').count() ? page.locator('#top, #work, #receipts') : page.locator('main');
  assert.doesNotMatch((await inventory.allInnerTexts()).join(' '), /Hoda|Duas and Aamal/i);
}

for (const width of [390, 1440]) {
  test(`${width}px: empty CMS apps leave home, portrait and contact intact without old app cards or ratings`, async (t) => {
    const page = await pageFor(t, { apps: empty }, width);
    await visit(page);
    assert.match(await page.locator('h1').innerText(), /I build Flutter apps/);
    assert.ok(await page.getByAltText('Portrait of Hasan Abbas Sorathiya').isVisible());
    assert.ok(await page.locator('#contact').getByRole('link', { name: 'Email me', exact: true }).isVisible());
    assert.equal(await page.locator('main a[href^="/apps/"]').count(), 0);
    assert.equal(await page.locator('#top .marquee img').count(), 0);
    assert.doesNotMatch(await page.locator('#top, #work, #receipts').allInnerTexts().then((text) => text.join(' ')), /\d\.\d\s*★|★\s*\d/);
    assert.match(await page.locator('#work').innerText(), /0 app profiles/);
    assert.ok(await page.locator('#work a[href^="/work/"]').count() > 0, 'Client cards survive an empty app response');
  });
}

test('empty apps remove every catalogue profile and schema item', async (t) => {
  const page = await pageFor(t, { apps: empty });
  await visit(page, '/apps');
  assert.match(await page.locator('h2').first().innerText(), /0 app profiles/);
  assert.equal(await page.locator('main a[href^="/apps/"]').count(), 0);
  await assertHiddenProfiles(page);
  assert.doesNotMatch(await page.locator('main').innerText(), /ChucklePlay|EVLAB|Kokoro Michi/);
  const collection = (await schemas(page)).find((item) => item['@type'] === 'CollectionPage');
  assert.equal(collection.mainEntity.numberOfItems, 0);
  assert.equal(collection.mainEntity.itemListElement.length, 0);
});

test('one CMS app replaces the inventory across home, list, detail and hidden routes', async (t) => {
  const page = await pageFor(t, { apps: { data: [petassy] } });
  await visit(page);
  await assertHiddenProfiles(page);
  assert.equal(await page.locator('#work a[href^="/apps/"]').count(), 1);
  assert.match(await page.locator('#work').innerText(), /CMS publication only\./);
  const source = page.locator('#top .marquee a').first();
  assert.equal(await source.getAttribute('href'), 'https://github.com/hasanabbassorathiya/petassy');

  await visit(page, '/apps');
  assert.match(await page.locator('h2').first().innerText(), /1 app profiles/);
  assert.equal(await page.locator('main a[href^="/apps/"]').count(), 1);
  await assertHiddenProfiles(page);
  const collection = (await schemas(page)).find((item) => item['@type'] === 'CollectionPage');
  assert.equal(collection.mainEntity.numberOfItems, 1);
  assert.equal(collection.mainEntity.itemListElement.filter((item) => item.url?.includes('/apps/')).length, 1);

  await page.locator('main a[href="/apps/petassy"]').click();
  await page.getByRole('heading', { level: 1, name: 'CMS Petassy', exact: true }).waitFor();
  assert.match(await page.locator('main').innerText(), /CMS publication only\./);
  await assertHiddenProfiles(page);
  const appSchema = (await schemas(page)).find((item) => item['@type'] === 'MobileApplication');
  assert.equal(appSchema.name, 'CMS Petassy');
  assert.equal(appSchema.author.name, 'Hasan Abbas Sorathiya');
  assert.equal(appSchema.aggregateRating, undefined);

  for (const slug of ['hoda', 'duas-and-aamal']) {
    await visit(page, `/apps/${slug}`);
    assert.match(await page.locator('h1').innerText(), /not in the showcase/);
    assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
    assert.ok(!(await schemas(page)).some((item) => item['@type'] === 'MobileApplication'));
  }
  // Client-side navigation must clear the missing-page robots state again.
  await page.getByRole('link', { name: 'See all apps', exact: true }).click();
  await page.locator('main a[href="/apps/petassy"]').click();
  await page.getByRole('heading', { level: 1, name: 'CMS Petassy', exact: true }).waitFor();
  assert.equal(await page.locator('meta[name="robots"]').count(), 0);
});

test('unknown app route is noindex and has no app schema even during seed fallback', async (t) => {
  const page = await pageFor(t);
  await visit(page, '/apps/not-a-published-app');
  assert.match(await page.locator('h1').innerText(), /not in the showcase/);
  assert.equal(await page.locator('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
  assert.ok(!(await schemas(page)).some((item) => item['@type'] === 'MobileApplication'));
});

test('a published app with no external links never creates a href-less marquee anchor', async (t) => {
  const page = await pageFor(t, { apps: { data: [{ ...petassy, links: '{}' }] } });
  await visit(page);
  assert.equal(await page.locator('#top .marquee a:not([href]), #top .marquee a[href="undefined"]').count(), 0);
  assert.ok(await page.locator('#top').getByText('CMS Petassy', { exact: true }).count() > 0);
});

const malformed = [
  ['HTTP 500', unavailable],
  ['invalid JSON', { body: '<html>Not JSON</html>' }],
  ['missing data', {}],
  ['non-array data', { data: {} }],
  ['null data', { data: null }],
  ['bare array', []],
  ['null payload', { body: 'null' }],
  ['invalid row', { data: [{}] }],
  ['partially invalid rows', { data: [petassy, null] }],
];
for (const [label, reply] of malformed) {
  test(`${label}: failed or malformed apps retain the seed catalogue`, async (t) => {
    const page = await pageFor(t, { apps: reply });
    await visit(page, '/apps');
    assert.match(await page.locator('h2').first().innerText(), /21 app profiles/);
    assert.equal(await page.locator('main a[href^="/apps/"]').count(), 21);
    assert.equal(await page.locator('main a[href="/apps/hoda"]').count(), 1);
    assert.equal(await page.locator('main a[href="/apps/duas-and-aamal"]').count(), 1);
    assert.equal((await schemas(page)).find((item) => item['@type'] === 'CollectionPage').mainEntity.numberOfItems, 21);
  });
}

for (const rating of [null, '4.4']) {
  test(`CMS Duas rating ${rating}: home never resurrects the static rating`, async (t) => {
    const page = await pageFor(t, { apps: { data: [{
      ...petassy, slug: 'duas-and-aamal', name: 'Duas and Aamal',
      rating_value: rating, rating_count: rating ? 22 : null,
    }] } });
    await visit(page);
    const text = (await page.locator('#top, #work, #receipts').allInnerTexts()).join(' ');
    assert.doesNotMatch(text, /4\.9|1,058/);
    if (rating) {
      assert.match(await page.locator('#receipts').innerText(), /4\.4★/);
      assert.match(await page.locator('#receipts').innerText(), /22 public Google Play reviews/);
    } else {
      assert.equal(await page.locator('#receipts a[href="/apps/duas-and-aamal"]').count(), 0);
      assert.doesNotMatch(text, /\d\.\d\s*★|★\s*\d/);
    }
  });
}

test('empty posts and clients clear their home cards without affecting a failed apps fallback', async (t) => {
  const page = await pageFor(t, { clients: empty, posts: empty });
  await visit(page);
  assert.equal(await page.locator('#writing a[href^="/blog/"]').count(), 0);
  assert.equal(await page.locator('#work a[href^="/work/"]').count(), 0);
  assert.match(await page.locator('#work').innerText(), /21 app profiles and 0 client engagements/);
  assert.equal(await page.locator('#work a[href^="/apps/"]').count(), 21);
});

test('empty CMS posts keep /blog readable without draft links and recover seed fallback on API failure', async (t) => {
  const responses = { posts: empty };
  const page = await pageFor(t, responses);
  await visit(page, '/blog');
  assert.match(await page.locator('h1').innerText(), /Notes from production/);
  assert.equal(await page.locator('main a[href^="/blog/"]').count(), 0);
  assert.equal(await page.getByText(/^Featured essay/).count(), 0);
  assert.ok(await page.getByText('No essays published yet. Check back soon.', { exact: true }).isVisible());
  assert.match(await page.locator('main').innerText(), /0 essays/i);
  assert.deepEqual((await schemas(page)).find((item) => item['@type'] === 'Blog').blogPost, []);

  responses.posts = unavailable;
  await visit(page, '/blog');
  assert.match(await page.locator('h1').innerText(), /Notes from production/);
  assert.ok(await page.locator('main a[href^="/blog/"]').filter({ hasText: 'Featured essay' }).isVisible());
  assert.ok(await page.locator('main a[href^="/blog/"]').count() > 0);
  assert.equal(await page.getByText('No essays published yet. Check back soon.', { exact: true }).count(), 0);
});

test('malformed clients and posts retain their seed cards while valid empty apps stay empty', async (t) => {
  const page = await pageFor(t, { apps: empty, clients: { data: {} }, posts: {} });
  await visit(page);
  assert.equal(await page.locator('#work a[href^="/apps/"]').count(), 0);
  assert.ok(await page.locator('#work a[href^="/work/"]').count() > 0);
  assert.equal(await page.locator('#writing a[href^="/blog/"]').count(), 3);
});

test('the seed is visible while the API is pending, then an empty array clears it', async (t) => {
  const page = await pageFor(t);
  let release;
  const pending = new Promise((resolve) => { release = resolve; });
  t.after(() => release());
  await page.route('**/api/index.php?entity=apps', async (route) => {
    await pending;
    await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(empty) });
  });
  await page.goto(`${base}/apps`, { waitUntil: 'domcontentloaded' });
  await page.locator('main a[href="/apps/hoda"]').waitFor();
  assert.equal(await page.locator('main a[href^="/apps/"]').count(), 21);
  release();
  await page.waitForLoadState('networkidle');
  assert.equal(await page.locator('main a[href^="/apps/"]').count(), 0);
});
