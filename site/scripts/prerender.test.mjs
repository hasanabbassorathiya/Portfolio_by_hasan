import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { createServer } from 'vite';

const root = fileURLToPath(new URL('../', import.meta.url));
let vite;
before(async () => {
  vite = await createServer({ root, server: { middlewareMode: true, hmr: false, watch: null }, appType: 'custom', logLevel: 'silent' });
});
after(async () => { await vite?.close(); });

test('home, navigation and service content render without browser globals', async () => {
  const { HomePage } = await vite.ssrLoadModule('/src/pages/home.jsx');
  const { SiteHeader } = await vite.ssrLoadModule('/src/components/site-header.jsx');
  const { ServicePage } = await vite.ssrLoadModule('/src/pages/service.jsx');
  const { RouteProvider } = await vite.ssrLoadModule('/src/lib/router.jsx');
  const html = renderToStaticMarkup(React.createElement(RouteProvider, { initialRoute: { path: '/', hash: '' } },
    React.createElement(SiteHeader), React.createElement(HomePage)));
  assert.match(html, /<header\b/);
  assert.match(html, /<main\b/);
  assert.match(html, /Ready to/);
  assert.match(renderToStaticMarkup(React.createElement(ServicePage, { slug: 'full-stack-api-development' })), /Backend, API &amp; full-stack integrations/);
});

test('resources page renders the pub.dev package and only real links', async () => {
  const { ResourcesPage } = await vite.ssrLoadModule('/src/pages/resources.jsx');
  const { SeoContext } = await vite.ssrLoadModule('/src/lib/seo.js');
  const { matchRoute } = await vite.ssrLoadModule('/src/lib/router.jsx');
  let metadata;
  const html = renderToStaticMarkup(React.createElement(SeoContext.Provider, { value: (value) => { metadata = value; } },
    React.createElement(ResourcesPage)));
  assert.equal(matchRoute('/resources').page, 'resources');
  assert.equal(metadata.path, '/resources');
  assert.equal((html.match(/<h1\b/g) || []).length, 1);
  assert.match(html, /stoolap_flutter/);
  assert.match(html, /https:\/\/pub\.dev\/packages\/stoolap_flutter/);
  assert.match(html, /flutter pub add stoolap_flutter/);
  assert.match(html, /href="\/services"/);
  assert.match(html, /href="\/services\/app-audit-consulting"/);
  assert.match(html, /href="\/blog\/flutter-startup-time"/);
  assert.doesNotMatch(html, /Some links in this section are referral links/, 'no affiliate disclosure without affiliate links');
});

test('privacy notice matches what the enquiry form and newsletter actually store', async () => {
  const { PrivacyPage } = await vite.ssrLoadModule('/src/pages/privacy.jsx');
  const { SeoContext } = await vite.ssrLoadModule('/src/lib/seo.js');
  const { matchRoute } = await vite.ssrLoadModule('/src/lib/router.jsx');
  const { SiteFooter } = await vite.ssrLoadModule('/src/components/site-footer.jsx');
  let metadata;
  const html = renderToStaticMarkup(React.createElement(SeoContext.Provider, { value: (value) => { metadata = value; } },
    React.createElement(PrivacyPage)));
  assert.equal(matchRoute('/privacy').page, 'privacy');
  assert.equal(metadata.path, '/privacy');
  assert.equal((html.match(/<h1\b/g) || []).length, 1);
  assert.match(html, /What this site/);
  assert.match(html, /keyed hash of your IP/);
  assert.match(html, /Google Analytics 4 is optional/);
  assert.match(html, /IP anonymisation/);
  assert.match(html, /first-party cookies/);
  assert.match(html, /_ga/);
  assert.match(html, /unsubscribe link/);
  assert.match(html, /Hostinger web hosting/);
  assert.doesNotMatch(html, /testimonial|guarantee/i);
  const footer = renderToStaticMarkup(React.createElement(SiteFooter));
  assert.match(footer, /href="\/privacy"/);
});

test('build emits readable route bodies, real metadata, service sitemap and a noindex 404', async () => {
  execFileSync('npm', ['run', 'build'], { cwd: root, stdio: 'pipe' });
  const routes = [
    ['index.html', /Ready to/],
    ['services.html', /Flutter app development/],
    ['resources.html', /Useful things/],
    ['privacy.html', /What this site/],
    ['community.html', /A room for people who/],
    ['_views/services/full-stack-api-development.html', /Backend, API &amp; full-stack integrations/],
    ['_views/apps/hoda.html', /Hoda/],
    ['_views/work/good2go-loans.html', /Good2Go/],
    ['blog.html', /Notes/],
    ['404.html', /This page went/],
  ];
  for (const [file, content] of routes) {
    const html = await readFile(`${root}dist/${file}`, 'utf8');
    assert.match(html, /<main\b/, `${file}: no readable main content`);
    assert.match(html, content, `${file}: missing route content`);
    assert.equal((html.match(/<h1\b/g) || []).length, 1, `${file}: one primary heading`);
    assert.doesNotMatch(html, /<div id="boot"/);
    assert.doesNotMatch(html, /SearchAction/);
    const schemas = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)];
    for (const [, json] of schemas) JSON.parse(json);
  }
  const home = await readFile(`${root}dist/index.html`, 'utf8');
  const person = [...home.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)]
    .flatMap(([, json]) => JSON.parse(json))
    .find((schema) => schema['@type'] === 'Person');
  assert.ok(person.sameAs.includes('https://play.google.com/store/apps/dev?id=5895887615343030170'));
  assert.ok(person.sameAs.includes('https://apps.apple.com/us/developer/hasan-abbas-sorathiya/id1734376366'));
  const hoda = await readFile(`${root}dist/_views/apps/hoda.html`, 'utf8');
  const schemas = [...hoda.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].flatMap(([, json]) => JSON.parse(json));
  const app = schemas.find((schema) => schema['@type'] === 'MobileApplication');
  assert.ok(app.publisher);
  assert.equal(app.author, undefined);
  const missing = await readFile(`${root}dist/404.html`, 'utf8');
  assert.match(missing, /name="robots" content="noindex, follow"/);
  const sitemap = await readFile(`${root}dist/sitemap.xml`, 'utf8');
  assert.match(sitemap, /<loc>https:\/\/hasanabbassorathiya.tech\/services\/full-stack-api-development<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/hasanabbassorathiya.tech\/resources<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/hasanabbassorathiya.tech\/privacy<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/hasanabbassorathiya.tech\/community<\/loc>/);
  assert.match((await readFile(`${root}dist/community.html`, 'utf8')), /<link rel="canonical" href="https:\/\/hasanabbassorathiya.tech\/community"/);
  assert.doesNotMatch(sitemap, /\/404/);
  const privacy = await readFile(`${root}dist/privacy.html`, 'utf8');
  assert.match(privacy, /<link rel="canonical" href="https:\/\/hasanabbassorathiya.tech\/privacy"/);
  assert.doesNotMatch(privacy, /name="robots" content="noindex/);
  assert.match((await readFile(`${root}dist/index.html`, 'utf8')), /href="\/privacy"/, 'footer links the privacy notice');
  const resources = await readFile(`${root}dist/resources.html`, 'utf8');
  assert.match(resources, /<link rel="canonical" href="https:\/\/hasanabbassorathiya.tech\/resources"/);
  assert.match(resources, /https:\/\/pub\.dev\/packages\/stoolap_flutter/);
  assert.doesNotMatch(resources, /Some links in this section are referral links/);
  const llms = await readFile(`${root}dist/llms.txt`, 'utf8');
  assert.match(llms, /^# Hasan Abbas Sorathiya/);
  assert.match(llms, /https:\/\/hasanabbassorathiya\.tech/);
  assert.match(llms, /https:\/\/pub\.dev\/packages\/stoolap_flutter/);
  for (const service of [
    'flutter-app-development',
    'ai-integration-automation',
    'full-stack-api-development',
    'app-audit-consulting',
    'digital-platform-development',
    'ui-ux-product-design',
  ]) {
    assert.match(llms, new RegExp(`services/${service}`), `llms.txt links ${service}`);
  }
  assert.match(llms, /\/privacy/, 'llms.txt links the privacy notice');
  assert.doesNotMatch(llms, /Cal\.com|cal\.com/, 'no booking link until the owner supplies one');
});
