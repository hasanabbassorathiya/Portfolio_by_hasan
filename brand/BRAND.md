# Hasan Abbas Sorathiya — brand system

Everything here is derived from what already ships on [hasanabbassorathiya.tech](https://hasanabbassorathiya.tech): the paper-and-ink palette in `site/src/index.css`, the letterspaced `H S` boot monogram in `site/index.html`, and the self-hosted Geist / Geist Mono / Instrument Serif in `site/public/fonts/`. No new identity was invented — the existing one was specified.

## 1. Positioning

**Who it is for:** recruiters and founders evaluating a senior Flutter + AI engineer, and app users arriving from a store listing.

**The claim:** six years shipping real products for iOS and Android — apps in the stores, RAG systems, backends. Not a personal-brand abstraction; the evidence is the catalogue.

**The register:** a printed page. Paper, ink, hairline rules, one blue signal, one terracotta thread. Restraint reads as seniority; decoration reads as a template.

**Anti-pattern to avoid:** the site's own worst-possible version of itself — gradient glow, glassmorphism, generated ornament, mood imagery. If a layout could belong to any engineer's portfolio, it fails.

## 2. The mark

Two grotesque capitals, `H` then `S`, weight 600, uppercase, ~18% letterspacing.

The shipped SVG is **constructed geometry, not a font**: the `H` is three rectangles on an 18-unit stem, the `S` is two tangent 21-unit arcs stroked at 18. It renders identically in every browser, on every machine, with no font installed — which is why it survives a 16px favicon.

| File | Use |
| --- | --- |
| `brand/logo-mark.svg` | The bare monogram, `viewBox="-1 -1 175 104"`. `currentColor`, so it inherits ink or paper. |
| `brand/lockup-horizontal.svg` | Mark + hairline + name + role, `536 × 120`. Headers, letterheads, PDF cover. |
| `brand/seal-ink.svg` | Ink square, paper mark. Favicon, avatar, app icon. |
| `brand/seal-paper.svg` | Paper square, ink mark. On ink backgrounds only. |
| `brand/icons/` | `favicon-16.png`, `favicon-32.png`, `apple-touch-icon.png` (180), `icon-192.png`, `icon-512.png`. |
| `brand/icons/glyphs/` | `phone.svg`, `mail.svg`, `web.svg` — three 24×24 contact glyphs drawn on the same rules as the mark: 2-unit stroke, square caps, miter joins, ink `#14110D`, no third colour. Built here, not taken from an icon set. |
| `site/public/media/brand/icons/` | The same three glyphs rasterised at 42 px (3× the 14 px they render at): `rsvg-convert -w 42 -h 42 brand/icons/glyphs/<name>.svg -o site/public/media/brand/icons/<name>.png`. |
| `brand/tokens.css` | The palette and type as CSS custom properties, light and dark, copied from `site/src/index.css`. For work outside the site (decks, email HTML, print, Figma). |
| `brand/README.md` | Instructions: where each file deploys, the verified `rsvg-convert` commands that rebuild every raster, install steps, press-kit build, pre-ship checks. |
| `brand/signature-plaintext.txt` | The plain-text signature on its own, for Teams/Slack/ticket replies. |
| `brand/letterhead.html` | A4 letterhead, print-ready. |
| `brand/business-card.html` | 85 × 55 mm, front ink-on-paper and back paper-on-ink. |
| `site/public/favicon.svg` | The ink seal with the mark enlarged to 81% of the box. Was violet `#14101F` + gold `#F1CF78` + Bricolage Grotesque — off-system, and the one asset that contradicted the site. |
| `site/public/{apple-touch-icon,icon-192,icon-512}.png` | The new seal; `manifest.webmanifest` and `site/index.html` already point at these names, so no markup change was needed. |
| `site/public/media/brand/seal-ink.png` · `seal-paper.png` | 128px renders for the image variant of the email signature and any remote-avatar slot. |
| `site/public/media/brand/press-kit.zip` | Built by `cd site && npm run brand:kit`, downloadable from `/brand`. |

Three construction details that are easy to get wrong and are already handled:

- The `S` arcs bulge past the letter box, so the ink runs from `y = -1` to `y = 101`. The viewBox carries 1 unit of bleed; a box tight to `0 0 171 100` clips the arc terminals.
- The crossbar overlaps each stem by 2 units (`x=17`, `width=48`). Same fill, so nothing shows — but abutting edges anti-alias against the ground and leave a visible seam inside the `H`.
- The lockup's `536` width is measured against Geist 600 at 23/12.5 with the tracking below. Without Geist the fallback shifts, so outline the two `<text>` nodes before sending to print.

**Rules**

- Clearspace on all four sides ≥ the cap height of the `H`.
- Ink on paper, or paper on ink. Never a third colour for the mark itself.
- No rotation, outline, drop shadow, gradient fill, or non-uniform scaling.
- Size floor: the seal reads at 32px. At 16 device pixels the `S` bowls collapse — browsers render `favicon.svg` as vector, so retina displays get the crisp 32px-equivalent, and `favicon-16.png` is only the legacy fallback. Below 32px, prefer the seal over the bare letters.

## 3. Colour

| Token | Hex | Role |
| --- | --- | --- |
| paper | `#F3EFE6` | Default canvas |
| surface | `#FBF8F2` | Cards, newsletter body |
| deep | `#E9E2D5` | Secondary ground, footer bands |
| ink | `#14110D` | Text and the mark |
| text | `#16130F` | Body copy |
| muted | `#665F52` | Labels, mono meta, rules' companion |
| signal | `#1D3CFF` | Links and one CTA. Never decoration. |
| thread | `#A33F1C` | Numbered lists, the rare warning |
| thread-soft | `#E08A5F` | Thread on ink grounds |

Hairlines are `rgba(22,19,15,.13)` at 1px. Dark mode inverts the grounds (`#12100C` canvas, `#F3EFE6` text) and softens signal to `#8B9BFF`.

**Discipline:** one accent per composition. If a screen has a blue CTA, the thread colour stays out.

## 4. Type

| Role | Face | Fallback for email/print |
| --- | --- | --- |
| Display, wordmark | Geist 600 | Helvetica Neue, Arial |
| Body | Geist 400 | Helvetica Neue, Arial |
| Labels, data, code | Geist Mono 400/600 | Menlo, Consolas, monospace |
| Editorial headlines | Instrument Serif italic | Georgia, Times New Roman |

Wordmark tracking `.18em`, uppercase. Mono labels uppercase at `.14–.18em`. Body measure 62–74 characters; never justify.

## 5. Voice

Short declarative sentences. Name the technology, the decision, and the consequence. Numbers only when they are real and attributable — the site has already had an unsubstantiated "100K+" removed once, and metrics carry their source. No "passionate", "guru", "ninja", "leverage", or "delve". First person for stories, third person for facts.

## 6. Applications

**Email signature** — `brand/email-signature.html`. Four variants in one file (HTML clients, image-mark, glyph contact rows, plain text), with install steps for Gmail/Outlook/Apple Mail. The default variant draws the monogram as a solid ink cell with letterspaced text, so it survives blocked remote images. Its three contact rows lead with a 20px ink chip carrying one Geist Mono capital — M, E, W — the monogram's construction at a fifth of the size, so the rows read as an icon system without depending on a hosted file. Variant 2b replaces the chips with the drawn glyphs; use it only once `media/brand/icons/*.png` is live, because Gmail deletes the whole signature when an `<img>` in it uses a `data:` URI (verified 2026-11-02) and shows an empty box when the URL 404s. Contact details are the owner's, on file since 2026-11-02: `+971 58 960 2320`, `+91 7021707223`, `hasanabbassorathiya12@gmail.com`, `hasanabbassorathiya.tech`. Phone numbers are `tel:` links set in ink, not signal — blue stays reserved for the mailbox and the site. Deliberately absent: social-network icons, a headshot, a banner.

**Newsletter** — `brand/newsletter-template.html`, masthead **SHIPPING NOTES**. 600px table layout, inline styles, `{{TOKENS}}` for headline/body/notes/CTA/subscribe links. Nothing in the template asserts a subscriber count or a testimonial. The masthead name was confirmed on 2026-11-02; changing it is one string.

**Print** — `brand/letterhead.html` (A4) and `brand/business-card.html` (85 × 55 mm, front ink-on-paper, back paper-on-ink). Both print from Chrome at 100% with background graphics on.

**On the site** — `/brand` renders this system (mark, palette, type, applications) and offers `press-kit.zip`. Colours and files on that page are generated from the same sources this document describes, so a token change shows up in both places.

**Boards** — `brand/boards/01…04.png`: overview, logo specification, newsletter system, signature applications. These are AI-rendered presentations of the system, so treat the SVG and HTML above as authoritative: the boards carry a few rendering artefacts (the overview's hex labels are mistyped, and the logo sheet picked up a stray "SIMPLE IDEAS FURTHER" line and a 2024 date). The mark, palette and lockups they show are the real ones.

## 7. Open, owner-side

1. Where dispatches are sent from (manual Gmail, or Beehiiv/Loops/Buttondown importing the template).
2. Uploading `site/public/media/brand/icons/{phone,mail,web}.png` to the live webroot, which is
   the only thing blocking variant 2b. hPanel's session had expired on 2026-11-02 and the agent
   will not touch credentials, so this needs the owner logged in.

Closed 2026-11-02: `/brand`, `site/public/media/brand/`, the new `favicon.svg` and the three
`site/public/*.png` icons are live on hasanabbassorathiya.tech (owner-approved deploy), and
**SHIPPING NOTES** is confirmed as the masthead name. Also closed 2026-11-02: the phone numbers
went on file (`+971 58 960 2320`, `+91 7021707223`) and the Gmail "Brand" signature was rebuilt
with the designation and the M / E / W contact rows — installed and verified in a fresh compose
window (ink chips 20px at `rgb(20,17,13)` on `rgb(243,239,230)`, `tel:` links in ink, mailbox and
site in signal, GitHub in muted, no `<img>` in the block).
