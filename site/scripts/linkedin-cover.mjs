import { mkdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright-core';

// Renders the LinkedIn cover from the site's own brand: self-hosted fonts, the
// paper/ink palette and the drawn HS monogram. The headline keeps the site's voice
// but leads with AI systems (owner is pivoting to AI SWE / FDE roles, 2026-11-12);
// the site hero itself still leads with Flutter. The headline stays on one line:
// LinkedIn's avatar overlays the bottom-left ~45% of the banner on desktop.
// Output is 1584x396 logical at 2x (3168x792). Re-run: node scripts/linkedin-cover.mjs
const root = process.cwd();
const out = path.join(root, 'public', 'media', 'brand', 'linkedin-cover.png');

const W = 1584;
const H = 396;
const SCALE = 2;

const PAPER = '#f3efe6';
const INK = '#14110d';
const TEXT = '#16130f';
const MUTED = '#6f675c';
const SIGNAL = '#1d3cff';
const THREAD = '#a33f1c';

const mime = { '.woff2': 'font/woff2' };
const dataUri = async (p) => {
  const buf = await readFile(path.join(root, p));
  return `data:${mime[path.extname(p)]};base64,${buf.toString('base64')}`;
};

const fontFaces = `
@font-face { font-family: 'Geist'; src: url('${await dataUri('public/fonts/Geist-400.woff2')}') format('woff2'); font-weight: 400; }
@font-face { font-family: 'Geist'; src: url('${await dataUri('public/fonts/Geist-600.woff2')}') format('woff2'); font-weight: 600; }
@font-face { font-family: 'Geist Mono'; src: url('${await dataUri('public/fonts/GeistMono-400.woff2')}') format('woff2'); font-weight: 400; }
@font-face { font-family: 'Instrument Serif'; src: url('${await dataUri('public/fonts/InstrumentSerif-Regular.woff2')}') format('woff2'); font-weight: 400; font-style: normal; }
@font-face { font-family: 'Instrument Serif'; src: url('${await dataUri('public/fonts/InstrumentSerif-Italic.woff2')}') format('woff2'); font-weight: 400; font-style: italic; }
`;

// The mark is drawn, not set: H = three rects on an 18-unit stem, S = two tangent
// 21-unit arcs stroked at 18. Same geometry as src/pages/brand.jsx.
const monogram = (color) => `
<svg viewBox="-1 -1 175 104" xmlns="http://www.w3.org/2000/svg" style="display:block;width:100%;height:auto;color:${color}">
  <g fill="currentColor">
    <rect x="1" y="1" width="18" height="100"/>
    <rect x="63" y="1" width="18" height="100"/>
    <rect x="17" y="42" width="48" height="18"/>
  </g>
  <path d="M155.5 13.9A21 21 0 1 0 142 51a21 21 0 1 1-13.5 37.1" fill="none" stroke="currentColor" stroke-width="18"/>
</svg>`;

const html = `<!doctype html><html><head><meta charset="utf-8"><style>
${fontFaces}
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: ${W}px; height: ${H}px; }
body {
  background: ${PAPER}; color: ${TEXT}; font-family: 'Geist', sans-serif;
  -webkit-font-smoothing: antialiased; position: relative; overflow: hidden;
}
.glow {
  position: absolute; width: 900px; height: 900px; right: -240px; top: -560px; border-radius: 50%;
  background: radial-gradient(circle, rgba(29,60,255,0.13) 0%, rgba(29,60,255,0.05) 46%, transparent 70%);
}
.grid {
  position: absolute; inset: 0;
  background-image:
    linear-gradient(rgba(22,19,15,0.045) 1px, transparent 1px),
    linear-gradient(90deg, rgba(22,19,15,0.045) 1px, transparent 1px);
  background-size: 66px 66px;
  -webkit-mask-image: radial-gradient(ellipse at 82% 8%, black 8%, transparent 62%);
  mask-image: radial-gradient(ellipse at 82% 8%, black 8%, transparent 62%);
}
.mark-bg { position: absolute; right: -70px; top: 50%; transform: translateY(-50%); width: 600px; opacity: 0.055; }
.frame { position: relative; z-index: 1; width: 100%; height: 100%; padding: 42px 72px 40px 80px; }
.topbar { display: flex; align-items: center; justify-content: space-between; padding-bottom: 18px; border-bottom: 1px solid rgba(22,19,15,0.13); }
.brand { display: flex; align-items: center; gap: 15px; }
.seal { width: 42px; height: 42px; border-radius: 11px; background: ${INK}; display: grid; place-items: center; flex: none; }
.seal > div { width: 27px; }
.brand-name { display: block; font-family: 'Geist'; font-weight: 600; font-size: 19px; letter-spacing: 0.045em; color: ${INK}; }
.brand-role { display: block; margin-top: 4px; font-family: 'Geist Mono'; font-size: 10.5px; letter-spacing: 0.18em; text-transform: uppercase; color: ${MUTED}; }
.status { display: flex; align-items: center; gap: 9px; font-family: 'Geist Mono'; font-size: 11px; letter-spacing: 0.16em; text-transform: uppercase; color: ${MUTED}; }
.status .dot { width: 7px; height: 7px; border-radius: 50%; background: #059669; flex: none; }
.headline {
  margin-top: 26px; font-family: 'Instrument Serif', serif; font-weight: 400;
  font-size: 64px; line-height: 1.045; letter-spacing: -0.02em; color: ${TEXT}; max-width: 1440px;
}
.hl-b { color: ${SIGNAL}; font-style: italic; }
.hl-a { color: ${THREAD}; font-style: italic; }
.footer { position: absolute; right: 72px; bottom: 38px; display: flex; align-items: center; gap: 11px; }
.footer .dot { width: 6px; height: 6px; border-radius: 50%; background: ${SIGNAL}; flex: none; }
.footer .site { font-family: 'Geist Mono'; font-size: 15px; letter-spacing: 0.05em; color: ${INK}; }
</style></head><body>
  <div class="glow"></div>
  <div class="grid"></div>
  <div class="mark-bg">${monogram(INK)}</div>
  <div class="frame">
    <div class="topbar">
      <div class="brand">
        <span class="seal"><div>${monogram(PAPER)}</div></span>
        <div>
          <span class="brand-name">HASAN ABBAS SORATHIYA</span>
          <span class="brand-role">Senior AI Software Engineer · FDE · Dubai</span>
        </div>
      </div>
      <span class="status"><span class="dot"></span>Available for new work</span>
    </div>
    <h1 class="headline">I build <em class="hl-b">AI systems</em> and Flutter apps <em class="hl-a">people keep using.</em></h1>
    <div class="footer"><span class="dot"></span><span class="site">hasanabbassorathiya.tech</span></div>
  </div>
</body></html>`;

const browser = await chromium.launch({ channel: 'chrome' });
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: SCALE });
try {
  await page.setContent(html, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  const overflow = await page.evaluate(() => {
    const h = document.querySelector('.headline');
    return { headlineWidth: Math.round(h.getBoundingClientRect().width), scrollWidth: document.body.scrollWidth };
  });
  await mkdir(path.dirname(out), { recursive: true });
  await page.screenshot({ path: out, clip: { x: 0, y: 0, width: W, height: H } });
  console.log(`linkedin cover → ${out} (${W * SCALE}x${H * SCALE})`, overflow);
} finally {
  await browser.close();
}