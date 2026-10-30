import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { fileURLToPath } from 'node:url';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { createServer } from 'vite';

const root = fileURLToPath(new URL('../', import.meta.url));
const origin = 'https://hasanabbassorathiya.tech';
const email = 'mailto:hasanabbassorathiya12@gmail.com';
const slugs = [
  'flutter-app-development',
  'ai-integration-automation',
  'full-stack-api-development',
  'app-audit-consulting',
  'digital-platform-development',
  'ui-ux-product-design',
];
let vite;

before(async () => {
  vite = await createServer({
    root,
    configFile: `${root}vite.config.js`,
    server: { middlewareMode: true, hmr: false, watch: null },
    appType: 'custom',
    optimizeDeps: { noDiscovery: true, include: [] },
  });
});
after(async () => { await vite?.close(); });

// useSeo currently writes to document during render. Supply only its head DOM
// boundary; keep the real hook, router Link, JSX transform and React SSR intact.
function headDocument() {
  const nodes = [];
  const matches = (node, selector) => {
    const match = selector.match(/^(\w+)\[(\w+)="([^"]+)"\]$/);
    assert.ok(match, `Unsupported head selector: ${selector}`);
    return node.tag === match[1] && (node[match[2]] ?? node.attrs[match[2]]) === match[3];
  };
  return {
    title: '',
    head: {
      querySelector: (selector) => nodes.find((node) => matches(node, selector)),
      querySelectorAll: (selector) => nodes.filter((node) => matches(node, selector)),
      appendChild: (node) => { nodes.push(node); return node; },
    },
    createElement: (tag) => ({
      tag,
      attrs: {},
      setAttribute(key, value) { this.attrs[key] = String(value); },
      getAttribute(key) { return this.attrs[key]; },
      remove() { const index = nodes.indexOf(this); if (index !== -1) nodes.splice(index, 1); },
    }),
  };
}

function render(Component, props = {}, document = headDocument()) {
  const previous = Object.getOwnPropertyDescriptor(globalThis, 'document');
  Object.defineProperty(globalThis, 'document', { value: document, configurable: true });
  try {
    return { html: renderToStaticMarkup(React.createElement(Component, props)), document };
  } finally {
    if (previous) Object.defineProperty(globalThis, 'document', previous);
    else delete globalThis.document;
  }
}

function schemas(document) {
  return document.head.querySelectorAll('script[type="application/ld+json"]')
    .flatMap((node) => {
      const value = JSON.parse(node.textContent);
      return Array.isArray(value) ? value : value['@graph'] ?? [value];
    });
}

const escapeHtml = (text) => text.replaceAll('&', '&amp;').replaceAll('"', '&quot;')
  .replaceAll("'", '&#x27;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
const hrefs = (html) => [...html.matchAll(/<a\b[^>]*\bhref="([^"]+)"/g)].map((match) => match[1]);

async function loadPages() {
  const { ServicesPage } = await vite.ssrLoadModule('/src/pages/services.jsx');
  const { ServicePage } = await vite.ssrLoadModule('/src/pages/service.jsx');
  return { ServicesPage, ServicePage };
}

test('service content contract supplies six complete, independently addressable offers', async () => {
  const { services } = await vite.ssrLoadModule('/src/content/services.js');
  assert.deepEqual(services.map((service) => service.slug), slugs);
  assert.deepEqual(services.map((service) => service.featured), [true, true, true, false, false, false]);
  for (const [index, service] of services.entries()) {
    assert.equal(service.index, String(index + 1).padStart(2, '0'));
    for (const field of ['title', 'tag', 'copy', 'seoTitle', 'seoDescription', 'enquiry']) {
      assert.ok(service[field]?.trim(), `${service.slug}: missing ${field}`);
    }
    for (const field of ['points', 'deliverables', 'process', 'questions']) {
      assert.ok(service[field].length >= 3, `${service.slug}: incomplete ${field}`);
    }
    assert.ok(service.audience.for.length && service.audience.notFor.length);
    assert.ok(service.evidence.length >= 2);
    for (const evidence of service.evidence) {
      assert.ok(evidence.label && evidence.copy);
      assert.ok(Boolean(evidence.to) !== Boolean(evidence.href));
      assert.match(evidence.to ?? evidence.href, /^(\/(apps|work|blog)\/[a-z0-9-]+|https:\/\/github\.com\/hasanabbassorathiya\/[\w-]+)$/);
    }
  }
});

test('router reaches the services index and all six detail pages', async () => {
  const { matchRoute } = await vite.ssrLoadModule('/src/lib/router.jsx');
  assert.deepEqual(matchRoute('/services'), { page: 'services' });
  for (const slug of slugs) {
    assert.deepEqual(matchRoute(`/services/${slug}`), { page: 'service', slug });
  }
  assert.deepEqual(matchRoute('/services/a/b'), { page: '404' });
});

test('index SSR exposes all six detail anchors and working enquiry destinations', async () => {
  const { ServicesPage } = await loadPages();
  const { html, document } = render(ServicesPage);
  assert.equal((html.match(/<h1\b/g) ?? []).length, 1);
  for (const slug of slugs) assert.ok(hrefs(html).includes(`/services/${slug}`), slug);
  assert.ok(hrefs(html).includes('/#contact'));
  assert.ok(hrefs(html).some((href) => href.startsWith(email)));
  assert.equal(document.head.querySelector('link[rel="canonical"]').getAttribute('href'), `${origin}/services`);
});

for (const slug of slugs) {
  test(`${slug}: real SSR renders scope, evidence, FAQ and route-specific Service schema`, async () => {
    const { ServicePage } = await loadPages();
    const { services } = await vite.ssrLoadModule('/src/content/services.js');
    const service = services.find((entry) => entry.slug === slug);
    const { html, document } = render(ServicePage, { slug });
    assert.equal((html.match(/<h1\b/g) ?? []).length, 1);
    assert.ok(html.includes(escapeHtml(service.title)));
    for (const item of [...service.deliverables, ...service.audience.for, ...service.audience.notFor]) {
      assert.ok(html.includes(escapeHtml(item)), `${slug}: missing scope item`);
    }
    for (const step of service.process) {
      assert.ok(html.includes(escapeHtml(step.title)) && html.includes(escapeHtml(step.copy)));
    }
    for (const { question, answer } of service.questions) {
      assert.ok(html.includes(escapeHtml(question)) && html.includes(escapeHtml(answer)));
    }
    for (const evidence of service.evidence) {
      assert.ok(hrefs(html).includes(escapeHtml(evidence.to ?? evidence.href)), evidence.label);
      assert.ok(html.includes(escapeHtml(evidence.copy)));
    }
    assert.ok(html.includes(escapeHtml(service.enquiry)));
    assert.ok(hrefs(html).includes('/services'));
    assert.ok(hrefs(html).includes('/#contact'));
    assert.ok(hrefs(html).some((href) => href.startsWith(email)));
    assert.ok(html.replace(/<[^>]+>/g, ' ').split(/\s+/).length > 350, 'Detail should be substantial, not a teaser');
    assert.equal(document.title, service.seoTitle);
    assert.equal(document.head.querySelector('meta[name="description"]').getAttribute('content'), service.seoDescription);
    assert.equal(document.head.querySelector('link[rel="canonical"]').getAttribute('href'), `${origin}/services/${slug}`);
    const serviceSchema = schemas(document).find((entry) => entry['@type'] === 'Service');
    assert.ok(serviceSchema, 'Service schema is present in the head');
    assert.equal(serviceSchema.name, service.title);
    assert.equal(serviceSchema.url, `${origin}/services/${slug}`);
    assert.equal(serviceSchema.provider['@id'], `${origin}/#person`);
    assert.equal(serviceSchema.description, service.seoDescription);
    assert.equal(serviceSchema.offers, undefined, 'Do not invent prices or availability');
    assert.equal(serviceSchema.aggregateRating, undefined, 'App ratings are not service ratings');
    assert.equal(schemas(document).filter((entry) => entry['@type'] === 'FAQPage').length, 0);
  });
}

test('evidence links resolve to existing app, client and article content', async () => {
  const { services } = await vite.ssrLoadModule('/src/content/services.js');
  const { apps } = await vite.ssrLoadModule('/src/content/apps.js');
  const { clients } = await vite.ssrLoadModule('/src/content/clients.js');
  const { posts } = await vite.ssrLoadModule('/src/content/posts.js');
  const routes = new Set([
    ...apps.map((entry) => `/apps/${entry.slug}`),
    ...clients.map((entry) => `/work/${entry.slug}`),
    ...posts.map((entry) => `/blog/${entry.slug}`),
  ]);
  for (const evidence of services.flatMap((service) => service.evidence)) {
    if (evidence.to) assert.ok(routes.has(evidence.to), `Missing destination: ${evidence.to}`);
  }
});

test('unknown, empty and malformed slugs use the real NotFoundPage without retaining Service metadata', async () => {
  const { ServicePage } = await loadPages();
  const { NotFoundPage } = await vite.ssrLoadModule('/src/pages/not-found.jsx');
  const expected = render(NotFoundPage).html;
  for (const slug of [undefined, '', 'missing-service', '../flutter-app-development', 'constructor']) {
    const document = headDocument();
    render(ServicePage, { slug: slugs[0] }, document);
    const { html } = render(ServicePage, { slug }, document);
    assert.equal(html, expected);
    assert.equal(document.head.querySelector('meta[name="robots"]').getAttribute('content'), 'noindex, follow');
    assert.equal(schemas(document).some((entry) => entry['@type'] === 'Service'), false);
    render(ServicePage, { slug: slugs[1] }, document);
    assert.equal(document.head.querySelector('meta[name="robots"]'), undefined);
    assert.equal(schemas(document).filter((entry) => entry['@type'] === 'Service').length, 1);
  }
});
