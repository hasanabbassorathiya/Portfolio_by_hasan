import { createServer } from 'vite';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import React from 'react';
import { renderToString } from 'react-dom/server';

const root = process.cwd();
const dist = path.join(root, 'dist');
const template = await readFile(path.join(dist, 'index.html'), 'utf8');
const escapeHtml = (value) => String(value)
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
const set = (html, pattern, value) => html.replace(pattern, (_, open, close) => open + escapeHtml(value) + close);

function shell(metadata, markup, site, person) {
  const { title, description, path: route, type, image, jsonLd, noindex, published, tags } = metadata;
  const url = `${site}${route}`;
  let html = template
    .replace(/<script type="application\/ld\+json">[\s\S]*?<\/script>/g, '')
    .replace(/<style id="boot-frame">[\s\S]*?<\/style>/, '')
    .replace(/<!-- Boot frame monogram painted before JS -->/, '')
    .replace(/<div id="boot">[\s\S]*?<\/div>/, '')
    .replace(/<noscript>[\s\S]*?<\/noscript>/, '<noscript><style>form,button{display:none!important}</style><p style="padding:1rem;text-align:center">Interactive forms need JavaScript. You can still use the direct email and page links.</p></noscript>')
    .replace('<div id="root"></div>', () => `<div id="root" data-route="${escapeHtml(route)}">${markup}</div>`);
  if (route !== '/') html = html.replace(/^.*\/hasan\.webp.*$\n?/m, '');
  html = html.replace(/<title>[\s\S]*?<\/title>/, () => `<title>${escapeHtml(title)}</title>`);
  html = set(html, /(<meta\s+name="description"\s+content=")[^"]*(")/, description);
  html = set(html, /(<link rel="canonical" href=")[^"]*(")/, url);
  for (const [key, value] of Object.entries({ title, description, type, url, image: `${site}${image}` })) {
    html = set(html, new RegExp(`(<meta property="og:${key}" content=")[^"]*(")`), value);
  }
  for (const [key, value] of Object.entries({ title, description, image: `${site}${image}` })) {
    html = set(html, new RegExp(`(<meta name="twitter:${key}" content=")[^"]*(")`), value);
  }
  html = html.replace(/\s*<meta property="og:image:(?:width|height)"[^>]*>/g, '');
  const head = [];
  const gsc = process.env.GSC_VERIFICATION;
  if (gsc && /^[A-Za-z0-9_-]{10,120}$/.test(gsc)) {
    head.push(`<meta name="google-site-verification" content="${escapeHtml(gsc)}" />`);
  }
  if (noindex) head.push('<meta name="robots" content="noindex, follow" />');
  if (published) head.push(`<meta property="article:published_time" content="${escapeHtml(published)}" />`);
  for (const tag of tags || []) head.push(`<meta property="article:tag" content="${escapeHtml(tag)}" />`);
  if (jsonLd) {
    const schemas = Array.isArray(jsonLd) ? jsonLd : [jsonLd];
    if (!schemas.some((entry) => entry['@id'] === person['@id'])) schemas.unshift(person);
    head.push(`<script type="application/ld+json">${JSON.stringify(schemas).replaceAll('<', '\\u003c')}</script>`);
  }
  return html.replace('</head>', () => `${head.join('\n')}\n</head>`);
}

const vite = await createServer({
  root, appType: 'custom', logLevel: 'silent',
  server: { middlewareMode: true, hmr: false, watch: null },
});

try {
  const { posts } = await vite.ssrLoadModule('/src/content/posts.js');
  const { apps } = await vite.ssrLoadModule('/src/content/apps.js');
  const { clients } = await vite.ssrLoadModule('/src/content/clients.js');
  const { services } = await vite.ssrLoadModule('/src/content/services.js');
  const { SeoContext, SITE_URL, personJsonLd } = await vite.ssrLoadModule('/src/lib/seo.js');
  const { App } = await vite.ssrLoadModule('/src/App.jsx');
  const routes = [
    { route: '/', page: 'home', name: 'HomePage', output: 'index.html' },
    { route: '/services', page: 'services', name: 'ServicesPage' },
    { route: '/resources', page: 'resources', name: 'ResourcesPage' },
    { route: '/community', page: 'community', name: 'CommunityPage' },
    { route: '/activity', page: 'activity', name: 'ActivityPage' },
    { route: '/resume', page: 'resume', name: 'ResumePage' },
    { route: '/brand', page: 'brand', name: 'BrandPage' },
    { route: '/privacy', page: 'privacy', name: 'PrivacyPage' },
    { route: '/apps', page: 'apps', name: 'AppsPage' },
    { route: '/work', page: 'work', name: 'WorkPage' },
    { route: '/blog', page: 'blog', name: 'BlogPage' },
    ...services.map(({ slug }) => ({ route: `/services/${slug}`, page: 'service', name: 'ServicePage', slug })),
    ...apps.map(({ slug }) => ({ route: `/apps/${slug}`, page: 'app', name: 'AppPage', slug })),
    ...clients.map(({ slug }) => ({ route: `/work/${slug}`, page: 'case-study', name: 'CaseStudyPage', slug })),
    ...posts.map(({ slug, date }) => ({ route: `/blog/${slug}`, page: 'post', name: 'PostPage', slug, date })),
    { route: '/404', page: 'not-found', name: 'NotFoundPage' },
  ];

  for (const entry of routes) {
    const module = await vite.ssrLoadModule(`/src/pages/${entry.page}.jsx`);
    let metadata;
    const initialPage = React.createElement(module[entry.name], entry.slug ? { slug: entry.slug } : {});
    const markup = renderToString(React.createElement(SeoContext.Provider, { value: (value) => { metadata = value; } },
      React.createElement(App, { initialRoute: { path: entry.route, hash: '' }, initialPage })));
    if (!metadata) throw new Error(`Missing metadata for ${entry.route}`);
    const output = entry.output || `${entry.slug ? '_views/' : ''}${entry.route.slice(1)}.html`;
    const file = path.join(dist, output);
    await mkdir(path.dirname(file), { recursive: true });
    await writeFile(file, shell(metadata, markup, SITE_URL, personJsonLd));
    console.log(`prerendered ${entry.route}`);
  }

  // /404 and /activity are intentionally noindex and stay out of the sitemap.
  const sitemapEntries = routes.filter(({ route }) => route !== '/404' && route !== '/activity').map(({ route, date }) =>
    `<url><loc>${SITE_URL}${route}</loc>${date ? `<lastmod>${escapeHtml(date)}</lastmod>` : ''}</url>`);
  await writeFile(path.join(dist, 'sitemap.xml'), `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${sitemapEntries.join('\n')}\n</urlset>\n`);
  console.log(`sitemap.xml (${sitemapEntries.length} urls)`);

  const rfc822 = (date) => new Date(`${date}T00:00:00Z`).toUTCString();
  const items = posts.map((post) => `<item>
<title>${escapeHtml(post.title)}</title>
<link>${SITE_URL}/blog/${post.slug}</link>
<guid>${SITE_URL}/blog/${post.slug}</guid>
<pubDate>${rfc822(post.date)}</pubDate>
<category>${escapeHtml(post.category)}</category>
<description>${escapeHtml(post.dek)}</description>
</item>`).join('\n');
  await writeFile(path.join(dist, 'rss.xml'), `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom"><channel>
<title>Hasan Abbas Sorathiya — Notes from production</title>
<link>${SITE_URL}/blog</link>
<description>Field notes on Flutter architecture, AI in production, localization, and performance.</description>
<language>en</language>
<atom:link href="${SITE_URL}/rss.xml" rel="self" type="application/rss+xml" />
${items}
</channel></rss>\n`);
  console.log(`rss.xml (${posts.length} items)`);
} finally {
  await vite.close();
}
