# Brand kit — instructions

The operating half of the identity. [`BRAND.md`](BRAND.md) is the specification (positioning, mark rules,
colour, type, voice); this file is what to do with the files: where each one goes, how each raster is
rebuilt, and how to install the deliverables.

## 1. What is in this folder

```
brand/
  BRAND.md                  the specification — read this first
  README.md                 this file
  tokens.css                colour + type as CSS custom properties (light and dark)
  logo-mark.svg             bare HS monogram, currentColor
  lockup-horizontal.svg     mark + hairline + name + role, 536 × 120
  seal-ink.svg              ink square, paper mark — favicon, avatar, app icon
  seal-paper.svg            paper square, ink mark — only on ink grounds
  icons/                    5 PNGs rendered from the two seals (see §3)
  boards/                   4 AI-rendered presentation sheets (see §6)
  email-signature.html      3 signature variants + install steps, paste-ready
  signature-plaintext.txt   the plain-text variant on its own
  newsletter-template.html  SHIPPING NOTES masthead, 600px table layout, {{TOKENS}}
  letterhead.html           A4 letterhead, print-ready
  business-card.html        85 × 55 mm, front and back
```

Authoritative sources are the four SVGs and the two HTML files. The boards (see §6) present the
system; they are not the system.

## 2. Where each file is deployed

| File | Lives at | Served as |
| --- | --- | --- |
| `seal-ink.svg` · `seal-paper.svg` | `site/public/media/brand/` as 128 px PNG | `https://hasanabbassorathiya.tech/media/brand/seal-{ink,paper}.png` |
| `icons/apple-touch-icon.png` | `site/public/apple-touch-icon.png` | referenced by `site/index.html` |
| `icons/icon-192.png` · `icon-512.png` | `site/public/icon-192.png` · `icon-512.png` | referenced by `site/public/manifest.webmanifest` |
| the enlarged seal | `site/public/favicon.svg` | referenced by `site/index.html` |
| everything, zipped | `site/public/media/brand/press-kit.zip` | downloaded from `https://hasanabbassorathiya.tech/brand` |

The site copies, not the sources, are what visitors fetch. After changing an SVG, rebuild the rasters
(§3), rebuild the press kit (§5), and copy the results into `site/public/`.

`favicon.svg` is deliberately **not** the same artwork as `seal-ink.svg`: the mark is enlarged to 81 %
of the box instead of 70 %, because at 16 device pixels the standard seal puts the `H` stems under one
pixel. Both exist on purpose — do not "fix" one to match the other.

## 3. Rebuilding the rasters

Every PNG in `icons/` and `site/public/` is reproducible. `rsvg-convert` (Homebrew `librsvg`) regenerates
them byte-for-byte:

```sh
rsvg-convert -w 16   -h 16   site/public/favicon.svg  -o brand/icons/favicon-16.png
rsvg-convert -w 32   -h 32   site/public/favicon.svg  -o brand/icons/favicon-32.png
rsvg-convert -w 180  -h 180  brand/seal-ink.svg       -o brand/icons/apple-touch-icon.png
rsvg-convert -w 192  -h 192  brand/seal-ink.svg       -o brand/icons/icon-192.png
rsvg-convert -w 512  -h 512  brand/seal-ink.svg       -o brand/icons/icon-512.png
rsvg-convert -w 128  -h 128  brand/seal-ink.svg       -o site/public/media/brand/seal-ink.png
rsvg-convert -w 128  -h 128  brand/seal-paper.svg     -o site/public/media/brand/seal-paper.png
rsvg-convert -w 42   -h 42   brand/icons/glyphs/phone.svg -o site/public/media/brand/icons/phone.png
rsvg-convert -w 42   -h 42   brand/icons/glyphs/mail.svg  -o site/public/media/brand/icons/mail.png
rsvg-convert -w 42   -h 42   brand/icons/glyphs/web.svg   -o site/public/media/brand/icons/web.png
```

Verified: re-running these against the checked-in files produced identical bytes (16 px 464 B, 32 px
926 B, 180 px 4368 B, 192 px 4736 B, 512 px 13660 B). If a regeneration does **not** match, the SVG
changed — check it against the construction rules in `BRAND.md` §2 before committing.

`seal-paper.png` on a paper background is invisible by design; it is for ink grounds (the site footer,
dark mode avatars, a deck's closing slide).

## 4. Installing the email signature

Open `email-signature.html` in a browser, select the rendered block between the `BEGIN`/`END` comments,
copy, then paste into the client:

- **Gmail** — Settings (gear) → See all settings → General → Signature → click into the editor → paste →
  scroll to the bottom of the page → **Save changes**. Pasting keeps the table and inline styles;
  Gmail drops `<style>` blocks, which is why the signature never relied on one.
- **Outlook** — File → Options → Mail → Signatures → New → paste.
- **Apple Mail** — Settings → Accounts → select account → Signature → paste.
- **Plain text** (Teams, Slack, ticket replies) — use `signature-plaintext.txt` verbatim.

Use the **text/ink-cell** variant as the default. The `<img>` variant points at
`https://hasanabbassorathiya.tech/media/brand/seal-ink.png` and must not be used until that URL returns 200;
the same rule applies to the glyph rows in variant 2b, which need `media/brand/icons/*.png` live.
Never add a headshot, banner or social-icon row. Phone numbers are on file since 2026-11-02 and are set as
`tel:` links in ink, not signal — see `BRAND.md` §6.

A `data:` URI in a signature `<img>` is worse than a broken URL: Gmail does not fall back to `alt`, it
deletes the entire signature block on the next re-render. Verified 2026-11-02 by inserting a glyph set as
base64 into Settings → Signature — the editor held it, then emptied itself ~1 s later.

## 5. Rebuilding the press kit

```sh
cd site && npm run brand:kit
```

`site/scripts/build-press-kit.mjs` stages the sources, re-renders the 128 px seals, shrinks the four
boards to 1600 px JPEG, and writes `site/public/media/brand/press-kit.zip` with the file count, total size and
SHA-256 printed. It is safe to re-run; the zip is a build product, so keep it out of git if it grows the
repo needlessly — it is committed here because `/brand` offers it as a download.

## 6. Boards

`boards/01…04.png` are AI-rendered presentation sheets of this system (overview, logo specification,
newsletter, signature applications). They carry rendering artefacts — the overview's hex chips are
mistyped and the logo sheet picked up a stray line and a 2024 date — so treat them as direction and
layout references only. The SVG, CSS and HTML in this folder are authoritative. If a board and a source
file disagree, the source file wins.

They are also heavy: 4.2 MB as PNG. The press kit ships 1600 px JPEG versions instead.

## 7. Print files

`letterhead.html` and `business-card.html` are sized for A4 and 85 × 55 mm with 3 mm bleed. Open in
Chrome, print to PDF, keep "Background graphics" on. The lockup's `<text>` nodes are Geist, not outlines:
if a printer needs curves, convert the text in the SVG first (`BRAND.md` §2 says why the width shifts).

## 8. Checks before shipping anything new

1. The mark only ever appears in ink on paper or paper on ink — no third colour, no gradient, no shadow.
2. Clearspace around the mark ≥ the cap height of the `H`.
3. One accent per composition. A blue CTA means the terracotta thread stays out of that screen.
4. Every number in copy is real and attributable; no subscriber counts, no testimonials, no "100K+".
5. Rasters regenerate byte-identically (§3).
6. `npm run build && npm run a11y` passes with the new asset, and `/brand/{seal-ink,seal-paper}.png`
   return 200 wherever a signature or avatar references them.
