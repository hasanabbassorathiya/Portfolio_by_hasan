import React from 'react';
import { trackCta } from '../lib/analytics';
import { SITE_NAME, SITE_URL, useSeo } from '../lib/seo';
import { Arrow, ArrowBadge, Kicker } from '../sections/ref-ui';

const PAPER = '#F3EFE6';
const SURFACE = '#FBF8F2';
const DEEP = '#E9E2D5';
const INK = '#14110D';
const TEXT = '#16130F';
const MUTED = '#665F52';
const SIGNAL = '#1D3CFF';
const THREAD = '#A33F1C';
const THREAD_SOFT = '#E08A5F';

const swatches = [
  { name: 'paper', hex: PAPER, on: INK, role: 'Default canvas' },
  { name: 'surface', hex: SURFACE, on: INK, role: 'Cards, newsletter body' },
  { name: 'deep', hex: DEEP, on: INK, role: 'Secondary ground, footer bands' },
  { name: 'ink', hex: INK, on: PAPER, role: 'Text and the mark' },
  { name: 'text', hex: TEXT, on: SURFACE, role: 'Body copy' },
  { name: 'muted', hex: MUTED, on: SURFACE, role: 'Labels, mono meta' },
  { name: 'signal', hex: SIGNAL, on: SURFACE, role: 'Links and one CTA. Never decoration.' },
  { name: 'thread', hex: THREAD, on: SURFACE, role: 'Numbered lists, the rare warning' },
  { name: 'thread-soft', hex: THREAD_SOFT, on: INK, role: 'Thread on ink grounds' },
];

const marks = [
  {
    file: 'logo-mark.svg',
    use: 'Bare monogram, currentColor',
    box: { w: 175, h: 104, viewBox: '-1 -1 175 104' },
    ground: PAPER,
    fg: INK,
  },
  {
    file: 'seal-ink.svg',
    use: 'Favicon, avatar, app icon',
    box: { w: 64, h: 64, viewBox: '0 0 64 64' },
    ground: SURFACE,
    fg: INK,
    seal: 'ink',
  },
  {
    file: 'seal-paper.svg',
    use: 'Only on ink grounds',
    box: { w: 64, h: 64, viewBox: '0 0 64 64' },
    ground: INK,
    fg: PAPER,
    seal: 'paper',
  },
];

const rules = [
  'Ink on paper, or paper on ink. Never a third colour for the mark itself.',
  'Clearspace on all four sides at least the cap height of the H.',
  'No rotation, outline, drop shadow, gradient fill, or non-uniform scaling.',
  'The seal reads at 32px. Below that use the enlarged favicon, not the standard seal.',
  'One accent per composition: if a screen has a blue CTA, the thread colour stays out.',
  'Hairlines are 1px at 13% ink. There is no second rule weight.',
];

const files = [
  ['4 vector marks', 'logo-mark.svg, lockup-horizontal.svg, seal-ink.svg, seal-paper.svg'],
  ['5 icon PNGs', 'favicon 16 and 32, apple-touch 180, maskable sizes 192 and 512'],
  ['2 rendered seals', 'seal-ink-128.png and seal-paper-128.png for remote-avatar slots'],
  ['4 boards', 'the presentation sheets at 1600px JPEG rather than 4.2MB of PNG'],
  ['2 print sheets', 'letterhead.html (A4) and business-card.html (85 × 55 mm)'],
  ['3 email files', 'email-signature.html, signature-plaintext.txt, newsletter-template.html'],
  ['4 references', 'BRAND.md, README.md, tokens.css, LICENSE.txt'],
];

function Monogram({ color, width = 120 }) {
  return (
    <svg viewBox="-1 -1 175 104" width={width} role="img" aria-label="HS monogram" style={{ color, display: 'block', height: 'auto' }}>
      <g fill="currentColor">
        <rect x="1" y="1" width="18" height="100" />
        <rect x="63" y="1" width="18" height="100" />
        <rect x="17" y="42" width="48" height="18" />
      </g>
      <path d="M155.5 13.9A21 21 0 1 0 142 51a21 21 0 1 1-13.5 37.1" fill="none" stroke="currentColor" strokeWidth="18" />
    </svg>
  );
}

function Seal({ variant, size = 64 }) {
  const dark = variant === 'ink';
  return (
    <svg viewBox="0 0 64 64" width={size} height={size} role="img" aria-label="Hasan Abbas Sorathiya" style={{ display: 'block' }}>
      <rect width="64" height="64" rx="13" fill={dark ? INK : PAPER} />
      <g transform="translate(9.24 18.58) scale(0.2631)">
        <g fill={dark ? PAPER : INK}>
          <rect x="1" y="1" width="18" height="100" />
          <rect x="63" y="1" width="18" height="100" />
          <rect x="17" y="42" width="48" height="18" />
        </g>
        <path d="M155.5 13.9A21 21 0 1 0 142 51a21 21 0 1 1-13.5 37.1" fill="none" stroke={dark ? PAPER : INK} strokeWidth="18" />
      </g>
    </svg>
  );
}

function Block({ id, kicker, title, body, children, tone = 'light' }) {
  const dark = tone === 'dark';
  return (
    <section
      id={id}
      aria-labelledby={`${id}-h`}
      className={`border-t ${dark ? 'border-transparent bg-band text-band-fg' : 'border-ink/10'}`}
    >
      <div className="mx-auto max-w-[1180px] px-5 py-14 md:py-20">
        <p className={`font-mono text-[10px] uppercase tracking-[0.2em] ${dark ? 'text-band-fg/70' : 'text-accent'}`}>{kicker}</p>
        <div className="mt-4 grid gap-6 lg:grid-cols-[0.9fr_1.1fr] lg:gap-14 [&>*]:min-w-0">
          <div>
            <h2 id={`${id}-h`} className={`font-serif text-[clamp(1.9rem,4vw,2.8rem)] leading-[1.05] tracking-[-0.02em] ${dark ? 'text-band-fg' : 'text-text'}`}>
              {title}
            </h2>
            <p className={`mt-4 max-w-[52ch] text-[15px] leading-[1.8] ${dark ? 'text-band-fg/75' : 'text-text-muted'}`}>{body}</p>
          </div>
          {children}
        </div>
      </div>
    </section>
  );
}

export function BrandPage() {
  useSeo({
    title: `Brand · Identity system and press kit · ${SITE_NAME}`,
    description:
      'The Hasan Abbas Sorathiya identity system: the HS monogram and how it is constructed, the paper-and-ink palette with exact hex values, the type scale, email signature and newsletter templates, and a press kit download.',
    path: '/brand',
    jsonLd: {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'Brand and press kit',
      url: `${SITE_URL}/brand`,
      description: 'Identity system, assets and press kit for Hasan Abbas Sorathiya.',
      isPartOf: { '@type': 'WebSite', url: SITE_URL },
    },
  });

  return (
    <main className="pt-28 pb-24 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 md:pb-16">
        <Kicker>Brand · Identity system</Kicker>
        <div className="mt-6 grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-end lg:gap-16">
          <h1 className="max-w-[15ch] font-serif text-[clamp(2.9rem,6.6vw,5.6rem)] font-normal leading-[0.98] tracking-[-0.025em] text-text">
            Ink on <em className="italic text-accent">paper.</em>
          </h1>
          <div>
            <p className="max-w-[54ch] text-[16px] leading-[1.8] text-text-muted">
              The whole identity is two grotesque capitals on a printed page: constructed geometry, one
              paper ground, one ink, one blue for links. Nothing here was invented for a portfolio — it
              is the palette, type and monogram this site already runs, written down so it can be used
              outside the browser.
            </p>
            <div className="mt-7 flex flex-wrap items-center gap-x-6 gap-y-3">
              <a
                href="/media/brand/press-kit.zip"
                download
                onClick={() => trackCta('press-kit', 'brand-hero')}
                className="group inline-flex min-h-11 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
              >
                Download the press kit
                <ArrowBadge tone="dark" />
              </a>
              <a href="#rebuild" className="group inline-flex min-h-11 items-center gap-2 text-sm font-medium text-text rule-link">
                How every raster is rebuilt
                <Arrow />
              </a>
            </div>
          </div>
        </div>
      </header>

      <Block
        id="mark"
        kicker="The mark"
        title="Geometry, not a font."
        body="The H is three rectangles on an 18-unit stem. The S is two tangent 21-unit arcs stroked at 18. Because it is drawn rather than set, it renders identically in every browser with no font installed — which is the only reason it survives a 16px favicon."
      >
        <div className="grid gap-4 sm:grid-cols-3">
          {marks.map((mark) => (
            <figure
              key={mark.file}
              className="rounded-[1.4rem] border border-ink/10 p-5"
              style={{ background: mark.ground }}
            >
              <div className="flex min-h-[92px] items-center justify-center">
                {mark.seal ? (
                  <Seal variant={mark.seal} size={72} />
                ) : (
                  <Monogram color={mark.fg} width={130} />
                )}
              </div>
              <figcaption
                className="mt-4 font-mono text-[10px] uppercase tracking-[0.14em]"
                style={{ color: mark.fg === INK ? MUTED : 'rgba(243,239,230,.72)' }}
              >
                {mark.file}
                <br />
                <span style={{ color: mark.fg === INK ? TEXT : PAPER }}>{mark.use}</span>
              </figcaption>
            </figure>
          ))}
        </div>
      </Block>

      <div className="border-t border-ink/10">
        <div className="mx-auto max-w-[1180px] px-5 py-12">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">Rules</p>
          <ul className="mt-5 grid gap-3 md:grid-cols-2 md:gap-x-12">
            {rules.map((rule, i) => (
              <li key={rule} className="flex gap-3 text-[15px] leading-[1.7] text-text">
                <span className="font-mono text-[11px] leading-[1.7] text-hl-a">{String(i + 1).padStart(2, '0')}</span>
                {rule}
              </li>
            ))}
          </ul>
          <div className="mt-9 flex flex-wrap items-end gap-8 border-t border-ink/10 pt-8">
            <div
              className="rounded-[1.4rem] border border-ink/10 px-5 py-4"
              style={{ background: PAPER }}
            >
              <p className="font-mono text-[10px] uppercase tracking-[0.14em]" style={{ color: MUTED }}>
                Horizontal lockup
              </p>
              <svg viewBox="0 0 536 120" className="mt-1 w-[min(100%,420px)]" role="img" aria-label="Hasan Abbas Sorathiya — Senior Software and AI Engineer">
                <g transform="translate(14 29.4) scale(0.6)" fill={INK}>
                  <rect x="1" y="1" width="18" height="100" />
                  <rect x="63" y="1" width="18" height="100" />
                  <rect x="17" y="42" width="48" height="18" />
                  <path d="M155.5 13.9A21 21 0 1 0 142 51a21 21 0 1 1-13.5 37.1" fill="none" stroke={INK} strokeWidth="18" />
                </g>
                <rect x="138" y="32" width="1" height="56" fill={TEXT} opacity="0.13" />
                <text x="160" y="60" fill={INK} fontFamily="Geist, 'Helvetica Neue', Helvetica, Arial, sans-serif" fontSize="23" fontWeight="600" letterSpacing="3.2">
                  HASAN ABBAS SORATHIYA
                </text>
                <text x="161" y="84" fill={MUTED} fontFamily="'Geist Mono', ui-monospace, Menlo, monospace" fontSize="12.5" letterSpacing="1.5">
                  SENIOR SOFTWARE &amp; AI ENGINEER
                </text>
                <circle cx="440" cy="80" r="3.5" fill={SIGNAL} />
              </svg>
            </div>
            <p className="max-w-[44ch] text-sm leading-[1.7] text-text-muted">
              The lockup is 536 wide because that is what Geist 600 measures at 23/12.5 with this
              tracking. Where Geist is unavailable the lines shift, so outline the two text nodes before
              sending it to a print vendor.
            </p>
          </div>
        </div>
      </div>

      <Block
        id="colour"
        kicker="Colour"
        title="Nine values, one accent per screen."
        body="The grounds are a printed page, not a design trend. Signal blue is a link or one call to action; thread terracotta is a numbered list or a rare warning. Dark mode inverts the grounds and softens the blue to #8B9BFF, and the mark simply flips from ink to paper."
      >
        <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          {swatches.map((swatch) => (
            <li key={swatch.name} className="overflow-hidden rounded-[1.1rem] border border-ink/10">
              <div className="flex h-16 items-end p-3" style={{ background: swatch.hex }}>
                <span className="font-mono text-[11px] tracking-[0.06em]" style={{ color: swatch.on }}>
                  {swatch.hex}
                </span>
              </div>
              <p className="bg-surface px-3 py-2.5 text-[12px] leading-snug text-text-muted">
                <span className="font-mono uppercase tracking-[0.12em] text-text">{swatch.name}</span>
                <br />
                {swatch.role}
              </p>
            </li>
          ))}
        </ul>
      </Block>

      <Block
        id="type"
        kicker="Type"
        title="Three faces, and a fallback that holds."
        body="Geist, Geist Mono and Instrument Serif are self-hosted on this site, so the specimen above is the real thing, not a stand-in. Every role has a fallback that keeps the layout honest in an email client that has none of them installed."
      >
        <div className="space-y-5">
          {[
            ['Display and wordmark', 'Geist 600', 'Hasan Abbas Sorathiya', "Geist, 'Helvetica Neue', Helvetica, Arial, sans-serif", 'uppercase, 600, tracking .18em'],
            ['Body', 'Geist 400', 'Six years shipping real products for iOS and Android.', "Geist, 'Helvetica Neue', Helvetica, Arial, sans-serif", '400, 62–74ch measure, never justified'],
            ['Labels, data, code', 'Geist Mono 400/600', 'SENIOR SOFTWARE & AI ENGINEER', "'Geist Mono', ui-monospace, Menlo, Consolas, monospace", 'uppercase, tracking .14–.18em'],
            ['Editorial headlines', 'Instrument Serif italic', 'Ink on paper.', "'Instrument Serif', Georgia, 'Times New Roman', serif", 'normal weight, tracking −0.025em'],
          ].map(([role, face, sample, stack, spec]) => (
            <div key={role} className="border-b border-ink/10 pb-5 last:border-0 last:pb-0">
              <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">{role} · {face}</p>
              <p className="mt-2 text-[clamp(1.35rem,2.6vw,1.9rem)] leading-tight text-text" style={{ fontFamily: stack }}>
                {sample}
              </p>
              <p className="mt-2 font-mono text-[11px] leading-relaxed text-text-muted">
                {spec}
                <br />
                <span className="text-hl-a">{stack}</span>
              </p>
            </div>
          ))}
        </div>
      </Block>

      <Block
        id="applications"
        kicker="Applications"
        title="Built for the clients that strip styling."
        body="Table layout, inline styles only, no style blocks, no required image. Gmail and Outlook remove everything else, so the signature carries its own monogram as a solid ink cell — it still looks right when remote images are blocked."
      >
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="rounded-[1.4rem] border border-ink/10 bg-surface p-5">
            <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">Email signature</p>
            <div className="mt-4 flex items-start gap-4">
              <span
                className="flex h-14 w-14 flex-none items-center justify-center rounded-[11px] font-mono text-[15px] font-semibold tracking-[0.12em]"
                style={{ background: INK, color: PAPER }}
              >
                HS
              </span>
              <p className="text-[13px] leading-[1.6] text-text">
                <strong className="font-semibold">Hasan Abbas Sorathiya</strong>
                <br />
                <span className="font-mono text-[11px] text-text-muted">Senior Software &amp; AI Engineer</span>
                <br />
                <a href="https://hasanabbassorathiya.tech" className="text-accent no-underline">
                  hasanabbassorathiya.tech
                </a>
              </p>
            </div>
            <p className="mt-4 text-[12px] leading-relaxed text-text-muted">
              Three variants plus install steps in the kit. No phone number, no headshot, no banner, no
              social icons.
            </p>
          </div>

          {[
            ['Newsletter', 'SHIPPING NOTES', 'A 600px table masthead with {{TOKENS}} for headline, body, notes and the two links. No subscriber count, no testimonial.'],
            ['Print', 'Letterhead + card', 'A4 letterhead and an 85 × 55 mm card, front ink-on-paper and back paper-on-ink. Print at 100% with background graphics on.'],
            ['Icons', '16 to 512 px', 'Favicon pair, 180px Apple touch icon, and the 192/512 manifest sizes — all rendered from the two seals, all byte-reproducible.'],
          ].map(([k, title, body]) => (
            <div key={k} className="rounded-[1.4rem] border border-ink/10 bg-surface p-5">
              <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">{k}</p>
              <h3 className="mt-3 font-serif text-xl leading-tight text-text">{title}</h3>
              <p className="mt-2.5 text-[13px] leading-[1.7] text-text-muted">{body}</p>
            </div>
          ))}
        </div>
      </Block>

      <Block
        id="rebuild"
        kicker="Provenance"
        title="Every raster is a command away."
        body="The boards you might see quoted elsewhere are AI-rendered presentations of this system and they carry artefacts — mistyped hex chips on the overview sheet, a stray line and a 2024 date on the logo sheet. The vectors, CSS and HTML are authoritative. If a board disagrees with a source file, the source wins."
        tone="dark"
      >
        <div>
          <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-band-fg/70">Rebuild the rasters</p>
          <pre className="mt-3 overflow-x-auto rounded-[1.1rem] border border-band-fg/15 bg-black/25 p-4 font-mono text-[11.5px] leading-[1.9] text-band-fg/90"><code>{`rsvg-convert -w 16  -h 16  public/favicon.svg -o brand/icons/favicon-16.png
rsvg-convert -w 180 -h 180 brand/seal-ink.svg  -o brand/icons/apple-touch-icon.png
rsvg-convert -w 512 -h 512 brand/seal-ink.svg  -o brand/icons/icon-512.png
cd site && npm run brand:kit`}</code></pre>
          <p className="mt-4 text-[13px] leading-[1.7] text-band-fg/75">
            Re-running those against the checked-in files produced identical bytes. If yours do not
            match, the SVG changed — check it against the construction rules before committing.
          </p>
        </div>
      </Block>

      <div className="border-t border-ink/10">
        <div className="mx-auto max-w-[1180px] px-5 py-14 md:py-20">
          <div className="grid gap-8 lg:grid-cols-[1fr_1fr] lg:gap-16">
            <div>
              <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">Press kit</p>
              <h2 className="mt-4 font-serif text-[clamp(1.9rem,4vw,2.8rem)] leading-[1.05] tracking-[-0.02em] text-text">
                Everything, in one archive.
              </h2>
              <p className="mt-4 max-w-[46ch] text-[15px] leading-[1.8] text-text-muted">
                Twenty-four files: the vectors, every icon size, the specification, the instructions, the
                email and newsletter templates, the print sheets, and the boards at 1600px instead of
                4.2MB. Built from this folder, so it is never out of date with the sources.
              </p>
              <a
                href="/media/brand/press-kit.zip"
                download
                onClick={() => trackCta('press-kit', 'brand-footer')}
                className="group mt-7 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-text rule-link"
              >
                Download press-kit.zip
                <Arrow />
              </a>
            </div>
            <ul className="space-y-0">
              {files.map(([count, what]) => (
                <li key={count} className="flex gap-5 border-b border-ink/10 py-3.5 first:border-t">
                  <span className="w-[128px] flex-none font-mono text-[11px] uppercase tracking-[0.1em] text-hl-a">{count}</span>
                  <span className="text-[13.5px] leading-[1.7] text-text-muted">{what}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </main>
  );
}
