// Positioning copy: one approved line, no retired variants, every proof figure derived from data.
// Run: node --test scripts/positioning.test.mjs
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { before, test } from 'node:test';
import path from 'node:path';
import { createServer } from 'vite';

const root = process.cwd();
const read = (p) => readFile(path.join(root, p), 'utf8').catch((error) => {
  if (error.code === 'ENOENT') throw new Error(`${p} is missing — run "npm run build" first`);
  throw error;
});

const HEADLINE = 'I build Flutter apps and AI systems people keep using.';

// Retired lines: each promised a floor ("does not break") instead of an outcome.
const RETIRED = [
  'survive production',
  'Built for production',
  'Built to keep working after launch',
];

const CARRIERS = [
  'src/sections/ref-hero.jsx',
  'src/content/profile.js',
  'src/lib/seo.js',
  'scripts/og-cards.mjs',
  'index.html',
];

// Apps carrying a link a stranger can open right now: a store listing or a source repo.
const LINKED_APPS = [
  { slug: 'a', links: { android: 'https://play.google.com/store/apps/details?id=app.a' } },
  { slug: 'b', links: { ios: 'https://apps.apple.com/ae/app/b/id1' } },
  { slug: 'c', links: { github: 'https://github.com/hasan/c' } },
  { slug: 'd', links: {} },
  { slug: 'e', links: null, storeUrl: '' },
];

let profile;
let interpolate;
let computeMetrics;
let linkedMetrics;

before(async () => {
  const vite = await createServer({ root, appType: 'custom', logLevel: 'silent', server: { middlewareMode: true } });
  try {
    profile = (await vite.ssrLoadModule('/src/content/profile.js')).profile;
    ({ interpolate, computeMetrics } = await vite.ssrLoadModule('/src/lib/site-metrics.js'));
    linkedMetrics = computeMetrics({ apps: LINKED_APPS, clients: [], experiences: [], profile });
  } finally {
    await vite.close();
  }
});

test('control: the SSR module graph loads and existing tokens still interpolate', () => {
  assert.equal(interpolate('{{apps}} app profiles', linkedMetrics), '5 app profiles');
});

test('the headline lives in the CMS-driven profile, as one approved line', () => {
  assert.equal(profile.headline, HEADLINE);
});

test('the h1 renders profile.headline instead of hardcoded prose', async () => {
  const hero = await read('src/sections/ref-hero.jsx');
  assert.match(hero, /profile\.headline/, 'h1 must be overridable from the CMS profile store');
  for (const retired of RETIRED) {
    assert.ok(!hero.includes(retired), `ref-hero.jsx still carries the retired line "${retired}"`);
  }
});

test('no shipped carrier repeats a retired positioning line', async () => {
  for (const carrier of CARRIERS) {
    const text = await read(carrier);
    for (const retired of RETIRED) {
      assert.ok(!text.includes(retired), `${carrier} still carries the retired line "${retired}"`);
    }
  }
});

test('the outreach docs do not reintroduce a retired line', async () => {
  for (const doc of ['LINKEDIN.md', '../hasan.md']) {
    const text = await read(doc);
    for (const retired of RETIRED) {
      assert.ok(!text.includes(retired), `${doc} still carries the retired line "${retired}"`);
    }
  }
});

test('the public-listing count is derived from the apps list, not typed by hand', () => {
  assert.equal(linkedMetrics.publicLinks, 3);
  assert.equal(linkedMetrics.tokens.public_links, '3');
});

test('the sub-line interpolates to the live count with no token left behind', () => {
  const sub = interpolate(profile.sub, linkedMetrics);
  assert.doesNotMatch(sub, /\{\{[a-z_]+/, `unresolved token in sub-line: ${sub}`);
  assert.match(sub, /3 of them/, 'sub-line must carry the public-listing count');
});

test('the packaged shell serves the new line to crawlers and link previews', async () => {
  const shell = await read('dist/index.html');
  assert.ok(shell.includes('people keep using'), 'dist/index.html does not render the new headline');
  for (const retired of RETIRED) {
    assert.ok(!shell.includes(retired), `dist/index.html still ships "${retired}"`);
  }
});
