import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { createServer } from 'vite';
import { apps, appBySlug, shipped } from '../src/content/apps.js';

// Public developer listings: Apple id1734376366, Google Play 5895887615343030170.
const inventory = [
  ['duas-and-aamal', 'ios', '6478907381'],
  ['lumio-tv', 'ios', '6766064122'],
  ['hoda', 'ios', '6755375239'],
  ['fragrance-of-mastership', 'ios', '6480333197'],
  ['duas-and-aamal', 'android', 'app.duasandaamal.com'],
  ['lumio-tv', 'android', 'app.lumio_iptv.com'],
  ['hoda', 'android', 'app.hoda.com'],
  ['wallmaster', 'android', 'com.hasanabbassorathiya.wallmaster'],
  ['business-mind', 'android', 'game.businessmind.hasanabbas'],
  ['klix', 'ios', '1593578496'],
  ['klix', 'android', 'com.iklix.klix'],
  ['urban-ledger', 'ios', '1617320844'],
  ['urban-ledger', 'android', 'com.ul.urbanledger'],
];
const additions = ['hoda', 'fragrance-of-mastership', 'wallmaster', 'business-mind'];
const asset = (path) => new URL(`../public${path}`, import.meta.url);

for (const [slug, platform, id] of inventory) {
  test(`${slug}: ${platform} developer listing resolves to the right store app`, () => {
    const app = appBySlug(slug);
    assert.ok(app, `Missing catalogue entry: ${slug}`);
    const url = new URL(app.links[platform]);
    assert.equal(url.protocol, 'https:');
    assert.equal(url.hostname, platform === 'ios' ? 'apps.apple.com' : 'play.google.com');
    assert.equal(platform === 'ios' ? url.pathname.match(/\/id(\d+)$/)?.[1] : url.searchParams.get('id'), id);
    assert.ok(app.platforms.includes(platform === 'ios' ? 'iOS' : 'Android'));
    assert.equal(shipped.filter((row) => row.slug === slug).length, 1, 'Shipped row must link to details exactly once');
  });
}

test('catalogue and shipped list have unique, resolvable identities', () => {
  assert.equal(new Set(apps.map((app) => app.slug)).size, apps.length);
  assert.equal(new Set(shipped.map((app) => app.name)).size, shipped.length);
  for (const row of shipped.filter((app) => app.slug)) {
    assert.ok(appBySlug(row.slug), `Unresolvable shipped link: ${row.slug}`);
  }
  for (const app of apps) {
    assert.ok(shipped.some((row) => row.slug === app.slug), `Missing shipped identity: ${app.slug}`);
  }
});

for (const slug of additions) {
  test(`${slug}: unknown technology, dates, ratings and outcomes stay unspecified`, () => {
    const app = appBySlug(slug);
    assert.ok(app, `Missing catalogue entry: ${slug}`);
    assert.deepEqual(app.stack ?? [], []);
    assert.deepEqual(app.metrics ?? [], []);
    assert.equal(app.rating, undefined);
    assert.ok(!app.year);
    assert.ok(!app.story);
    assert.ok(!/creator|developer|engineer/i.test(app.role));
  });

  test(`${slug}: genuine store icon and two distinct screenshots are local WebP assets`, async () => {
    const app = appBySlug(slug);
    assert.ok(app, `Missing catalogue entry: ${slug}`);
    assert.equal(app.screenshots.length, 2);
    assert.equal(new Set([app.icon, ...app.screenshots]).size, 3);
    assert.equal(app.sources.screenshots.length, 2);
    assert.equal(new Set(app.sources.screenshots).size, 2);
    const hashes = [];
    for (const path of [app.icon, ...app.screenshots]) {
      assert.ok(path.startsWith(`/media/apps/${slug}/`));
      assert.ok(path.endsWith('.webp'));
      const bytes = await readFile(asset(path));
      assert.equal(bytes.toString('ascii', 0, 4), 'RIFF');
      assert.equal(bytes.toString('ascii', 8, 12), 'WEBP');
      assert.ok(bytes.length > 1000, 'Image must not be an empty placeholder');
      hashes.push(createHash('sha256').update(bytes).digest('hex'));
    }
    assert.equal(new Set(hashes).size, 3, 'Icon and screenshots must not duplicate each other');
    for (const url of [app.sources.icon, ...app.sources.screenshots]) {
      const source = new URL(url);
      assert.equal(source.protocol, 'https:');
      assert.ok(/^(is\d+-ssl\.mzstatic\.com|play-lh\.googleusercontent\.com)$/.test(source.hostname));
    }
    assert.ok(app.sources.listings.every((url) => Object.values(app.links).includes(url)));
    assert.ok(app.sources.listings.length > 0);
  });
}

test('book and pilgrimage contributions are explicitly Publisher, not author or developer', () => {
  for (const slug of ['hoda', 'fragrance-of-mastership']) {
    const app = appBySlug(slug);
    assert.ok(app, `Missing catalogue entry: ${slug}`);
    assert.equal(app.role, 'Publisher');
    assert.match(app.attribution, /publish/i);
    assert.equal(shipped.find((row) => row.slug === slug)?.role, 'Publisher');
  }
  assert.match(appBySlug('hoda').summary, /French.*English/i);
  assert.match(appBySlug('hoda').summary, /pilgrimage/i);
  assert.match(appBySlug('fragrance-of-mastership').summary, /Dr\.? Shabeeb Rizvi/);
});

const croppedIcons = {
  petassy: 'f4f1c0e0c4d057e08b650f7edb6b61a47d796c7ed4b6eb59c838c42d714a510e',
  'pool-inspection': '665d5f1ac67b82d3b1053d015e5c9c3090d8c457397c5c40bf8edb00bad1b649',
};
for (const [slug, oldHash] of Object.entries(croppedIcons)) {
  test(`${slug}: replaces the old cropped image with traceable source artwork`, async () => {
    const app = appBySlug(slug);
    const bytes = await readFile(asset(app.icon));
    assert.notEqual(createHash('sha256').update(bytes).digest('hex'), oldHash);
    assert.equal(app.icon, `/media/apps/${slug}/icon.webp`);
    if (slug === 'petassy') {
      assert.equal(app.sources, undefined, 'private repository must not be referenced');
      assert.deepEqual(app.links, {}, 'no source CTA while the repository is private');
    } else {
      assert.match(app.sources.icon, /^https:\/\/is\d+-ssl\.mzstatic\.com\/.*AppIcon.*\/\d+x\d+bb\.png$/);
    }
  });
}

test('all catalogue image references resolve inside the public app media directory', async () => {
  for (const app of apps) {
    for (const path of [app.icon, app.cover, ...app.screenshots].filter(Boolean)) {
      assert.match(path, /^\/media\/apps\/[a-z0-9-]+\/[a-z0-9.-]+$/);
      assert.ok((await readFile(asset(path))).length > 0, `${app.slug}: ${path}`);
    }
  }
});

// Render real pages/hooks; only the browser's document surface is replaced.
// useSeo writes metadata synchronously, while server rendering avoids API requests.
function metadataDocument() {
  const elements = [];
  return {
    title: '',
    createElement(tag) {
      return {
        tag, attrs: {}, textContent: '',
        setAttribute(key, value) { this.attrs[key] = value; },
        remove() { elements.splice(elements.indexOf(this), 1); },
      };
    },
    head: {
      appendChild(element) { elements.push(element); },
      querySelector(selector) { return this.querySelectorAll(selector)[0] ?? null; },
      querySelectorAll(selector) {
        const [, tag, key, value] = selector.match(/^(\w+)\[(\w+)="([^"]+)"\]$/);
        return elements.filter((el) => el.tag === tag && (el.attrs[key] ?? el[key]) === value);
      },
    },
  };
}

test('rendered catalogue and details keep counts, metadata and attribution honest', async (t) => {
  const server = await createServer({
    root: fileURLToPath(new URL('..', import.meta.url)),
    configFile: false,
    server: { middlewareMode: true, hmr: false, watch: null },
    esbuild: { jsx: 'automatic' },
    optimizeDeps: { noDiscovery: true, include: [] },
  });
  const previousDocument = globalThis.document;
  t.after(async () => { globalThis.document = previousDocument; await server.close(); });
  const { AppsPage } = await server.ssrLoadModule('/src/pages/apps.jsx');
  const { AppPage } = await server.ssrLoadModule('/src/pages/app.jsx');
  const { apps: renderedApps } = await server.ssrLoadModule('/src/content/apps.js');
  const render = (component, props) => {
    globalThis.document = metadataDocument();
    const html = renderToStaticMarkup(React.createElement(component, props));
    const jsonLd = JSON.parse(document.head.querySelector('script[type="application/ld+json"]').textContent);
    return { html, jsonLd };
  };

  await t.test('headings and CollectionPage metadata reflect the displayed inventory', () => {
    const { html, jsonLd } = render(AppsPage);
    const collection = jsonLd.find((entry) => entry['@type'] === 'CollectionPage');
    assert.match(html, /21 apps\./);
    assert.match(html, /15 app (?:details|profiles)/);
    assert.equal(collection.mainEntity.numberOfItems, 21);
    assert.equal(collection.mainEntity.itemListElement.length, 21);
    for (const slug of additions) assert.ok(html.includes(`href="/apps/${slug}"`));
    assert.doesNotMatch(html, /Fifteen|Seven|full case study/);
  });

  for (const slug of additions) {
    await t.test(`${slug}: detail has a real OG asset and no invented authorship or stack`, () => {
      const { html, jsonLd } = render(AppPage, { slug });
      const app = appBySlug(slug);
      const schema = jsonLd.find((entry) => entry['@type'] === 'MobileApplication');
      assert.equal(schema.author, undefined);
      assert.ok(schema.image.endsWith(app.icon));
      assert.equal(document.head.querySelector('meta[property="og:image"]').attrs.content, schema.image);
      assert.doesNotMatch(html, />Stack<|Built by Hasan/);
      assert.match(html, /publishing|implementation responsibilities/);
      if (app.role === 'Publisher') assert.equal(schema.publisher.name, 'Hasan Abbas Sorathiya');
      for (const url of Object.values(app.links)) assert.ok(html.includes(`href="${url}"`));
    });
  }

  await t.test('an absent stack is supported as well as an empty stack', () => {
    const app = renderedApps.find((entry) => entry.slug === 'hoda');
    const original = app.stack;
    try {
      delete app.stack;
      assert.doesNotThrow(() => render(AppPage, { slug: 'hoda' }));
    } finally { app.stack = original; }
  });
});
