# Design System — Hasan Abbas Sorathiya (hasanabbassorathiya.tech)

Status: current. Describes the **Bone & Ink** system that ships from `src/`. Tokens live in
`src/index.css` + `tailwind.config.js`; components in `src/sections/ref-*.jsx` and `src/components/`.
An earlier jade/obsidian proposal was abandoned before launch and is not implemented anywhere.

## 1. Atmosphere

An editorial, paper-like engineering portfolio: warm bone canvas, near-black ink type, one cobalt
accent, a terracotta second highlight, and a barely visible paper grain. Light is the default; dark
mode is the same language inverted, with fixed dark "bands" that stay dark in both themes so work,
contact and case-study heroes read as wells rather than slabs. Density is comfortable, not sparse;
hierarchy comes from type scale, serif italics and hairline rules, not from shadows or cards.

## 2. Color tokens

All colors are RGB triplets consumed by Tailwind as `rgb(var(--token) / <alpha>)`
(`canvas`, `surface`, `deep`, `accent`, `accent-solid`, `on-accent`, `text`, `text-muted`, `ink`,
`band`, `band-fg`, `hl-a`, `hl-b`, …).

| Token | Light | Dark | Role |
|---|---|---|---|
| `canvas` | `243 239 230` (#f3efe6) | `18 16 12` | Page background |
| `surface` | `251 248 242` | `27 23 18` | Panels, inputs, raised areas |
| `deep` | `233 226 213` | `38 33 25` | Recessed blocks, image beds |
| `text` | `22 19 15` | `243 239 230` | Primary copy |
| `text-muted` | `102 95 82` | `169 161 147` | Secondary copy, metadata |
| `ink` | `20 17 13` | `243 239 230` | Hairlines via `border-ink/10`, monogram |
| `accent` | `29 60 255` (#1d3cff) | `139 155 255` | Links, italic emphasis, focus ring |
| `accent-solid` | `29 60 255` | `47 73 255` | Filled buttons (white text) |
| `on-accent` | `251 248 242` | `247 243 234` | Text on `accent-solid` |
| `band` | `20 17 13` | `11 9 6` | Fixed dark sections (work, contact, footer) |
| `band-fg` | `243 239 230` | `236 230 218` | Copy inside bands |
| `hl-a` | `163 63 28` (terracotta) | `224 138 95` | Second italic highlight |
| `hl-b` | `29 60 255` | `139 155 255` | Blue highlight span |

Rules:
- `ink` flips to bone in dark mode, so `border-ink/10`, hairline rules and the monogram invert for free.
- Band sections use `bg-band text-band-fg` and must never follow the theme canvas.
- `text-hl-a` on cream is only ~3:1; inside bands it is never used directly. `.bg-band .text-hl-a`
  maps to the lighter `--hl-a-ink` so highlighted words stay legible.
- Selection is `accent-solid` with `on-accent` text. No gradients as fills, no glow shadows.

## 3. Typography

| Role | Family | Usage |
|---|---|---|
| Display | **Instrument Serif** (`font-serif`, 400/italic) | H1/H2 headlines, pull quotes, big numerals |
| Body/UI | **Geist** (`font-body`, 400/500/600) | Paragraphs, buttons, navigation |
| Mono | **Geist Mono** (`font-mono`, 400/600) | Kickers, labels, dates, stats, tech chips |

- Self-hosted woff2 only; Geist 400/600 and Instrument Serif are declared inline in `index.html` so
  the faces start with the document; remaining faces load from `index.css`.
- Headlines: `clamp()` scaling, tight leading (`0.97`–`1.05`), tracking `-0.02em`, one italic
  emphasis per headline (`em.italic.text-accent` or `.text-hl-a`).
- Kickers/labels: mono, 9–11px, uppercase, `tracking-[0.16em]`–`[0.2em]`.
- Body: 15–17px, leading `1.65`–`1.8`, max `54ch`–`65ch`.
- Banned: Inter, Times/Georgia, system-ui as identity faces, all-caps body copy.
- `Bricolage Grotesque` is still declared in `index.css` but unused; remove the `@font-face` and
  `public/fonts/BricolageGrotesque-VF.woff2` when convenient (no runtime download today).

## 4. Layout

- Content width: `max-w-[1180px]`, page gutters `px-5`; blog prose narrows to `max-w-[720px]`.
- Header is a floating pill inside the same 1180px rail; mobile menu is a full-height sheet.
- Grid-first: hero is a 7/5 split on `lg`, work and services use asymmetric 12-column spans.
- Radii: `rounded-full` for buttons, pills, avatars and chips; `rounded-xl`/`rounded-2xl` for panels
  and media; `rounded-[9px]/[10px]` for small icon tiles. No 4px "default" squares.
- Borders are 1px `border-ink/10`–`/15`; depth is hairlines + `deep` fills, not drop shadows.
- Sticky floating nav; `scroll-padding-top: 104px` keeps anchors clear of it.

## 5. Components

- **Buttons** — primary: pill, `bg-accent-solid text-on-accent`, arrow badge on the right,
  `active:scale-[0.98]`, 500ms ease. Secondary: text link with a bottom rule that grows on hover
  (`.rule-link`). No outlines or shadows.
- **Kicker / SectionHead** — mono kicker above an Instrument Serif headline with an optional blurb
  and a right-aligned link (`ref-ui.jsx`). `tone="dark"` for band sections.
- **Work** — a dark band: one featured case-study card (screenshot left, serif title, rating/outcome
  stats, "Read the case study"), then a 2/4-column grid of app and client cards, closed by a mono
  provenance line naming where ratings and client metrics come from.
- **Service rows** — hairline-separated rows (mono index, serif title, copy, checklist, tag, arrow)
  that invert to an ink panel with a `1.4rem` radius on hover; secondary services sit below as
  underlined text links.
- **Bands** — dark wells for selected work, case-study hero, contact and footer; inner content keeps
  the 1180px rail.
- **Forms** — label above, 15px Geist, `rounded-xl border-ink/15 bg-surface`, focus via the global
  2px accent outline; inline validation text, never alert-only.
- **Chips** — mono 11px, `border-ink/15`, transparent fill, `rounded-full`.
- **Imagery** — app icons and screenshots at native aspect, `rounded-xl`, hairline border. Images are
  full colour in both themes; no grayscale, no duotone, no dark-mode dimming.
- **Grain overlay** — fixed `body::after`, opacity `0.024`, pointer-events none, hidden in print.
- **Theme toggle** — sun/moon icon in the header, persists to `localStorage['hs-theme']`.
- **Boot frame** — inline "H S" monogram painted before JS, removed on mount; session-gated.

## 6. Motion

- **Lenis** smooth wheel scrolling (lerp 0.1, anchors offset -84px, 1.1s); not initialised at all
  under reduced motion, in which case anchors fall back to instant `scrollIntoView`.
- Entrance: `.rise` (26px translate + opacity, 0.9s `cubic-bezier(0.22,1,0.36,1)`), staggered
  `rise-1…rise-4`.
- Reveal-on-scroll: `useReveal` (opacity + 16px translate, 0.7s); anything already in view reveals
  immediately. Count-up: `useCountUp` cubic ease-out.
- Marquee: 42s linear loop, pauses on hover, mask-faded edges.
- `prefers-reduced-motion: reduce` disables marquee and animations/transitions globally; reveal and
  count-up snap to their end state.
- Motion is transform/opacity only; no layout animation, no parallax, no scroll-jacking beyond Lenis.

## 7. Themes

- Light is the default render (SSR snapshot `light`); first visit follows `prefers-color-scheme`
  until the visitor chooses. Choice is stored in `localStorage['hs-theme']` and applied in a
  pre-paint boot script so there is no flash.
- `<meta name="theme-color">` follows the active theme (`#f3efe6` / `#12100c`).
- Both themes are audited at 1440 and 390 with axe (64 checks, WCAG 2.0/2.1/2.2 A+AA).

## 8. Accessibility

- One `h1` per route, ordered headings (enforced by the axe run's outline assertion).
- Visible `:focus-visible` ring: 2px `accent`, 3px offset, on every interactive element.
- Skip-to-content link as the first tab stop (`App.jsx`).
- Honeypot field is `aria-hidden`, `tabindex="-1"`, and not focusable.
- Text contrast meets AA in both themes; `text-hl-a` is remapped inside bands (see §2).
- Forms expose `aria-busy`, `role="status"` for success and `role="alert"` for errors.

## 9. Print

`/resume` is the print source for the PDF: `@page A4`, 13mm/14mm margins, only the résumé sheet
survives (nav, footer, grain and floating UI are hidden). Regenerate with `npm run resume:pdf`.

## 10. Content and data

Copy and catalogue live in `src/content/{apps,clients,posts,resources,resume,services}.js` and
`src/content/posts/*.md`; pages are prerendered from them. After mount, `src/lib/live-content.jsx`
fetches `/api/index.php` and swaps in CMS-edited apps, clients and posts, so list/detail views pick
up CMS changes without a rebuild — but the prerendered HTML, metadata and sitemap only change on the
next build. Never add a metric, testimonial or client relationship that is not in the verified facts
list (DELIVERY.md §5).
