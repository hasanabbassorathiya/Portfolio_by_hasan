import { createServer } from 'vite';
import { mkdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright-core';

const root = process.cwd();
const outDir = path.join(root, 'public', 'og');

const escapeHtml = (value) =>
  String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

const mime = { '.woff2': 'font/woff2', '.webp': 'image/webp', '.png': 'image/png', '.jpg': 'image/jpeg' };
const dataUri = async (p) => {
  const ext = path.extname(p);
  const buf = await readFile(path.join(root, p));
  return `data:${mime[ext]};base64,${buf.toString('base64')}`;
};

const fontFaces = `
@font-face { font-family: 'Geist'; src: url('${await dataUri('public/fonts/Geist-400.woff2')}') format('woff2'); font-weight: 400; }
@font-face { font-family: 'Geist'; src: url('${await dataUri('public/fonts/Geist-600.woff2')}') format('woff2'); font-weight: 600; }
@font-face { font-family: 'Geist Mono'; src: url('${await dataUri('public/fonts/GeistMono-400.woff2')}') format('woff2'); font-weight: 400; }
@font-face { font-family: 'Instrument Serif'; src: url('${await dataUri('public/fonts/InstrumentSerif-Regular.woff2')}') format('woff2'); font-weight: 400; }
@font-face { font-family: 'Instrument Serif'; src: url('${await dataUri('public/fonts/InstrumentSerif-Italic.woff2')}') format('woff2'); font-weight: 400; font-style: italic; }
`;

const portrait = await dataUri('public/hasan.webp');

const baseCss = `
${fontFaces}
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1200px; height: 630px; }
body {
  background: #f3efe6;
  color: #16130f;
  font-family: 'Geist', sans-serif;
  -webkit-font-smoothing: antialiased;
}
.card {
  position: relative;
  width: 1200px;
  height: 630px;
  padding: 60px 72px 52px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background:
    radial-gradient(760px 460px at 84% -18%, rgba(29,60,255,0.10), transparent 68%),
    #f3efe6;
}
.glow {
  position: absolute;
  width: 820px;
  height: 820px;
  right: -260px;
  top: -470px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(29,60,255,0.12) 0%, rgba(29,60,255,0.04) 46%, transparent 70%);
}
.grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(22,19,15,0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(22,19,15,0.05) 1px, transparent 1px);
  background-size: 72px 72px;
  mask-image: radial-gradient(ellipse at 50% 0%, black 15%, transparent 72%);
}
header, footer, .body { position: relative; z-index: 1; }
header { display: flex; align-items: center; justify-content: space-between; }
.brand { display: flex; align-items: center; gap: 14px; }
.monogram {
  width: 42px; height: 42px; display: grid; place-items: center;
  border-radius: 11px;
  color: #f3efe6; font-family: 'Geist'; font-weight: 600; font-size: 15px; letter-spacing: 0.06em;
  background: #14110d;
}
.brand-name { display: block; font-family: 'Geist'; font-weight: 600; font-size: 16px; letter-spacing: -0.01em; color: #16130f; }
.brand-role { display: block; margin-top: 3px; font-family: 'Geist Mono'; font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase; color: #6f675c; }
.kicker {
  display: inline-flex; align-items: center; gap: 9px;
  font-family: 'Geist Mono'; font-size: 12px; letter-spacing: 0.2em; text-transform: uppercase; color: #6f675c;
}
.kicker::before { content: ''; width: 5px; height: 5px; border-radius: 50%; background: #1d3cff; }
.body { flex: 1; margin-top: 18px; padding-bottom: 18px; display: flex; flex-direction: column; justify-content: center; gap: 24px; }
h1 {
  font-family: 'Instrument Serif', serif; font-weight: 400; letter-spacing: -0.015em; line-height: 1.02;
  max-width: 1010px; color: #16130f;
}
.hl-a { color: #a33f1c; font-style: italic; }
.hl-b { color: #1d3cff; font-style: italic; }
.dek { max-width: 780px; font-size: 21px; line-height: 1.52; color: #6f675c; }
footer { margin-top: 0; display: flex; align-items: flex-end; justify-content: space-between; border-top: 1px solid rgba(22,19,15,0.12); padding-top: 22px; }
.who { display: flex; align-items: center; gap: 15px; }
.who img { width: 52px; height: 52px; border-radius: 50%; object-fit: cover; border: 1px solid rgba(22,19,15,0.15); filter: grayscale(1); }
.who strong { display: block; font-family: 'Geist'; font-weight: 600; font-size: 17px; letter-spacing: -0.01em; color: #16130f; }
.who span { display: block; margin-top: 3px; font-family: 'Geist Mono'; font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase; color: #6f675c; }
.site { font-family: 'Geist Mono'; font-size: 12px; letter-spacing: 0.08em; color: #16130f; }
.meta { display: flex; align-items: center; gap: 12px; font-family: 'Geist Mono'; font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase; color: #6f675c; }
.meta .dot { width: 3px; height: 3px; border-radius: 50%; background: rgba(22,19,15,0.35); }
.rating { display: inline-flex; align-items: center; gap: 8px; padding: 7px 13px; border: 1px solid rgba(22,19,15,0.2); border-radius: 999px; font-family: 'Geist Mono'; font-size: 11px; letter-spacing: 0.04em; color: #16130f; }
.app-head { display: flex; align-items: center; gap: 24px; }
.icon { width: 92px; height: 92px; border-radius: 21px; border: 1px solid rgba(22,19,15,0.12); object-fit: cover; }
`;

function cardHtml({ kicker, title, titleHtml, dek, meta, rating, icon, footerNote }) {
  const size = title.length > 78 ? 54 : title.length > 58 ? 62 : title.length > 40 ? 70 : 78;
  return `<!doctype html><html><head><meta charset="utf-8"><style>${baseCss}</style></head><body>
  <div class="card">
    <div class="glow"></div>
    <div class="grid"></div>
    <header>
      <div class="brand">
        <span class="monogram">HS</span>
        <div>
          <span class="brand-name">Hasan Abbas Sorathiya</span>
          <span class="brand-role">Senior software &amp; AI engineer · Dubai</span>
        </div>
      </div>
      <span class="kicker">${escapeHtml(kicker)}</span>
    </header>
    <div class="body">
      ${
        icon
          ? `<div class="app-head"><img class="icon" src="${icon}" alt="" />
             <h1 style="font-size:${size}px">${escapeHtml(title)}</h1></div>`
          : `<h1 style="font-size:${size}px">${titleHtml || escapeHtml(title)}</h1>`
      }
      ${dek ? `<p class="dek">${escapeHtml(dek)}</p>` : ''}
      <div class="meta">
        ${meta.map((m) => escapeHtml(m)).join('<span class="dot"></span>')}
        ${rating ? `<span class="dot"></span><span class="rating">★ ${escapeHtml(rating)}</span>` : ''}
      </div>
    </div>
    <footer>
      <div class="who">
        <img src="${portrait}" alt="" />
        <div>
          <strong>Hasan Abbas Sorathiya</strong>
          <span>${escapeHtml(footerNote)}</span>
        </div>
      </div>
      <span class="site">hasanabbassorathiya.tech</span>
    </footer>
  </div>
  </body></html>`;
}

const vite = await createServer({
  root,
  appType: 'custom',
  logLevel: 'silent',
  server: { middlewareMode: true },
});

const browser = await chromium.launch({ channel: 'chrome' });
const page = await browser.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });

try {
  await mkdir(outDir, { recursive: true });
  const { posts } = await vite.ssrLoadModule('/src/content/posts.js');
  const { apps } = await vite.ssrLoadModule('/src/content/apps.js');

  const cards = [
    {
      output: '../og.png',
      html: cardHtml({
        kicker: 'Portfolio · Mobile & AI',
        title: 'I build mobile apps and AI systems that survive production.',
        titleHtml:
          'I build <span class="hl-b">mobile apps</span> and AI systems that <span class="hl-a">survive production</span>.',
        dek: 'Senior mobile and AI engineer in Dubai — native iOS and Android, Flutter as my primary stack. Fifteen shipped products and 100K+ users.',
        meta: ['15 apps shipped', '100K+ users', '7+ years'],
        footerNote: 'Senior Software & AI Engineer · Dubai',
      }),
    },
    {
      output: 'blog.png',
      html: cardHtml({
        kicker: 'Writing',
        title: 'Notes from production',
        titleHtml: 'Notes from <span class="hl-b">production</span>',
        dek: 'Field notes on Flutter, AI, and the work of shipping software people trust.',
        meta: ['7 essays', 'Every two weeks'],
        footerNote: 'Senior Software & AI Engineer · Dubai',
      }),
    },
    ...posts.map((post) => ({
      output: `${post.slug}.png`,
      html: cardHtml({
        kicker: `Essay · ${post.category}`,
        title: post.title,
        dek: post.dek,
        meta: [post.dateLabel, `${post.minutes} min read`],
        footerNote: 'Senior Software & AI Engineer · Dubai',
      }),
    })),
    {
      output: 'apps.png',
      html: cardHtml({
        kicker: 'Apps',
        title: 'Fifteen apps. One standard.',
        titleHtml: 'Fifteen apps. One <span class="hl-b">standard</span>.',
        dek: 'Shipped for iOS, Android, web, and Android TV — from a 4.9★ prayer companion to a TV-first IPTV player.',
        meta: ['15 apps', '100K+ users', '4.8–5.0★'],
        footerNote: 'Creator & lead developer',
      }),
    },
    {
      output: 'work.png',
      html: cardHtml({
        kicker: 'Selected work',
        title: 'Client platforms, with the decisions behind them.',
        titleHtml: 'Client platforms, with the <span class="hl-b">decisions</span> behind them.',
        dek: 'EVLAB at Chalhoub Group, Good2Go Loans, and Nakheel Marinas — mobile delivery owned from architecture to production support.',
        meta: ['3 client engagements', '15 apps', '7+ years'],
        footerNote: 'Client work · 2019—2026',
      }),
    },
    ...(await Promise.all(
      apps.map(async (app) => ({
        output: `app-${app.slug}.png`,
        html: cardHtml({
          kicker: 'App',
          title: app.name,
          dek: app.tagline,
          icon: await dataUri(`public${app.icon}`),
          meta: [app.genre, app.platforms.join(' · '), String(app.year)],
          rating: app.rating ? `${app.rating.value.toFixed(1)} (${app.rating.count.toLocaleString('en-US')})` : '',
          footerNote: app.role,
        }),
      })),
    )),
  ];

  for (const card of cards) {
    await page.setContent(card.html, { waitUntil: 'load' });
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({
      path: path.join(outDir, card.output),
      clip: { x: 0, y: 0, width: 1200, height: 630 },
    });
    console.log(`og card ${card.output}`);
  }
} finally {
  await browser.close();
  await vite.close();
}
