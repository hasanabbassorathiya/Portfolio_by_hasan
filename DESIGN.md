# Design System: Hasan Abbas Sorathiya · pawan.app Exact Replica

> Generated via `stitch-design-taste` skill for the hasanabbassorathiya.tech portfolio.
> Based on a full analysis of pawan.app (fetched 2026-10-21).

## 1. Visual Theme & Atmosphere

A cockpit-dense, offset-asymmetric interface with fluid spring-physics motion and a devotional dark-plum atmosphere. The mood is like a midnight archive — confidential, weighty, and sharply detailed. Density is high (9/10): every section packs information, not whitespace. Variance is pronounced (8/10): asymmetric splits, irregular grids, and intentional negative space keep the eye moving. Motion is choreographed (7/10): per-section stagger reveals, count-up animations, and scroll-triggered choreography create a sense of narrative progression without being cinematic.

The interface is dark by default, following system preference with a manual toggle (no timed auto-switch). The palette draws from plum, lavender, and gold — a devotional color LC inspired by illuminated manuscripts — with no traces of teal, emerald, or any "AI purple/blue neon" aesthetic.

## 2. Color Palette & Roles

| Name | Hex | Role |
|------|-----|------|
| **Deep Plum** | `#14101f` | Boot-frame background; deepest surface for footer and utility bars |
| **Dark Plum** | `#201c2a` | Primary canvas — main page background, `--canvas` |
| **Medium Plum** | `#1a1629` | Card and panel surface, secondary containers, `--surface` |
| **Monogram Indigo** | `#1b1131` | Boot monogram block background |
| **Lavender Text** | `#ede8f6` | Primary text, `--text` — lavender-tinted white |
| **Light Lavender** | `#f5f1fb` | Light-theme canvas; container background in light mode |
| **Muted Lavender** | `#9d94b8` | Secondary text, descriptions, metadata, `--text-muted` |
| **Gold Accent** | `#f1cf78` | Single accent — CTAs, active states, focus rings, `--accent` |
| **Bright Gold** | `#fbbf24` | Bright accent — buttons hover-states, glow highlights |
| **Lavender Border** | `rgb(237, 232, 246, 0.08)` | Card borders, 1px structural lines, `--border` |

**Constraint:** Exactly one accent color (gold). Saturation below 80%. No purple button glows, no neon gradients, no teal/cyan/emerald.

## 3. Typography Architecture

| Hierarchy | Font | Weight | Role |
|-----------|------|--------|------|
| **Display** | **Bricolage Grotesque** (VF) | 500–800 wght | Hero name, section headings, boot monogram; track-tight, controlled scale |
| **Body** | **Geist** | 400–600 | All paragraph and list text — relaxed leading, 65ch measure |
| **Mono** | **Geist Mono** | 400–600 | Code, metadata, timestamps, high-density numbers, stats |
| **Accent Serif** | **Instrument Serif** | Regular + Italic | Editorial accent, pull quotes, italic emphasis within headlines |

**Font delivery:** Self-hosted woff2 under `/fonts/`, preloaded for first-screen files. No Inter, no generic system serif (Times/Georgia/Garamond), no system-ui fallback for display text.

**Boot screen typography:** Monogram uses Bricolage Grotesque (700/800), letter-spaced. Below it: small muted text in Geist Mono.

## 4. Component Stylings

### 4.1 Buttons
- **Flat** — no outer glow, no neon borders
- **Primary:** Gold fill (`#f1cf78`), dark text (`#1a1629` for contrast)
- **Secondary:** Ghost — 1px gold border (`rgba(241, 207, 120, 0.5)`) on transparent — text gold
- **Tactile feedback:** `-1px` translateY on `:active`; spring-physics bounce on press
- **Border-radius:** `clamp(6px, 0.5vw, 10px)`, not pill-shaped

### 4.2 Cards & Containers
- Used ONLY when elevation communicates hierarchy
- Surface: `var(--surface)` / `#1a1629` — 1px border `var(--border)`
- Border-radius: `1rem` (16px) for feature cards
- **High-density overflow** (>9 sections): replace cards with `border-top: 1px solid var(--border)` dividers + generous padding
- **Shadows:** None — flat containers with border separation only

### 4.3 Featured App Cards (Reel)
- Asymmetric two-column grid (text left, thumbnail right) on desktop
- App icon (48×48 rounded) in gold border circle (`1px solid var(--accent)`)
- Title: Bricolage Grotesque 700, `var(--text)`
- Role/Stack: Geist Mono 400, `var(--text-muted)`
- Store buttons: Two gold-bordered pills ("iOS" / "Android") at bottom-right of card
- **Live indicator badge:** Gold `text-accent-bright` ("LIVE" or "BETA"), floating at top-right corner

### 4.4 GitHub Activity Section
- **Heatmap strip:** 7×52 grid (days × weeks) — plum (`#14101f`) base, lavender (`#ede8f6`) for high-contribution days, gold (`#f1cf78`) for streak days
- **Stat counters:** 3–4 number-clusters (Stars, Commits, PRs, Streak) — Geist Mono 700, large size (`clamp(2rem, 4vw, 3.5rem)`), promoted to gold on milestone thresholds
- **Streak highlight:** Gold underline pulse animation on active streak day

### 4.5 Skills Grid
- 3-column asymmetric: each category gets a full-width header (Geist, `var(--accent)` underline) then tags in Geist Mono, `var(--text-muted)`, comma-separated with `1px var(--accent)` separator dots
- No progress bars, no pie charts, no "expert" badges

### 4.6 Testimonials
- Blockquote style: `1px var(--accent)` left border, `var(--text)` body in Geist, attribution in Geist Mono `var(--text-muted)`

### 4.7 Boot Frame
- Fixed overlay, `var(--deep)`/`#14101f` background (or `var(--monogram)`/`#1b1131` on first-ever visit)
- Content: static monogram ("HS") painted in Bricolage Grotesque 700, gold (`var(--accent)`), tint small (`clamp(1.6rem, 4vw, 3rem)`)
- Session-gated: shown once per browser session (sessionStorage flag), not shown after first dismiss
- Fade-out: `opacity` transition 0.6s → `display:none`
- **No white flash:** CSS paints background BEFORE JS runs; `html` background always matches canvas

### 4.8 Navigation
- **Desktop:** Fixed top bar, `1px` lavender bottom border. Left: name in Geist Mono `var(--accent)`. Right: section links in Geist `var(--text-muted)` — hover to `var(--text)`.
- **Mobile:** Same top bar collapses to hamburger/backlit drawer. Links animate in with staggered cascade.
- No scroll-to-top FAB, no progress bar on page scroll

### 4.9 Loading & Empty States
- **Loaders:** Skeletal shimmer in `var(--surface)` matching exact layout dimensions — no circular spinners for page-level loads
- **Empty states:** Composed compositions — not just "No data" text. Example: empty GitHub section shows a gold-bordered "Connect GitHub" CTA

## 5. Layout Principles

- **Grid-first** — CSS Grid, not flexbox `calc()` mathematics
- **Max-width containment:** `1280px` centered page. No full-bleed content on desktop
- **Section spacing:** `clamp(3rem, 6vw, 5rem)` between sections
- **Asymmetric splits:** Desktop hero uses left-aligned text block (75% width) + empty decorative zone (25%). Multi-column sections use 2-column zig-zag patterns
- **Ban:** 3-column equal card rows; centered hero layouts; overlapping/absolute-positioned elements
- **Section min-height:** `min-h-[100dvh]` (never `h-screen`) — iOS Safari compatibility
- **Typography scale:** Headlines via `clamp()`. Body text minimum `1rem`. Touch targets minimum `44px`

## 6. Responsive Architecture

| Breakpoint | Behavior |
|------------|----------|
| **≥1024px** | Desktop: multi-column, fixed nav, asymmetric splits |
| **<1024px** | Tablet: 2-column collapse, hamburger nav |
| **<768px** | Mobile-first: single column, stacked layouts, compressed spacing |
| **Typography** | Heading `clamp()` contraction. Body text never below `14px`/`1rem` |
| **Touch targets** | All interactive elements ≥44px. Cards remain tap-padded |
| **Horizontal scroll** | BANNED entirely |

## 7. Motion & Interaction

- **Engine:** Dedicated animations module (not inline JS) — section-based: `RevealText`, scroll choreography, count-up, marquee
- **Spring physics (default):** `stiffness: 100, damping: 20` for interactive bounces
- **Perpetual micro-loops:** Active component infinite states — pulse on CTA outlines, typewriter on role taglines, subtle float on inactive cards
- **Staggered cascade:** Lists/arrays animate entry with `n × 60ms` cascade delays — never mount all at once
- **Scroll triggers:** Count-ups fire on first scroll pass; section transitions use `IntersectionObserver` + `opacity`/`transform` transitions
- **Performance constraint:** Animate exclusively via `transform` and `opacity`. Never animate `top`, `left`, `width`, `height`
- **Boot intro:** Plays once per session (sessionStorage gate). Bricolage monogram fades in → pauses → fades out to hero. No repeat
- **Motion ban:** No parallax backgrounds, no particle effects, no animated underlines on hover

## 8. Section Order & Structure

```
1.  Boot intro — static monogram (session-gated)
2.  Hero — name, roles, CTAs (left-aligned, no inline images)
3.  Story Film — about + values
4.  Featured Reel — 4 apps with store CTAs (asymmetric grid)
5.  Currently Building — active projects + "ships weekly" tag
6.  GitHub Activity — heatmap, streaks, star counter (HTML-fe generated, not API-live)
7.  Skills — 3 categories, comma-tags, no bars
8.  Open Source — key repos, contributions
9.  Experience — 6 positions, left-align timeline
10. Community & Conference Map — events, talks, certifications
11. Testimonials — 2+ blockquotes
12. CTA — "Let's make it together" + contact channels
13. Extras Dock — easter eggs (Wordle, Snake, typing challenge), Konami code listener
```

## 9. Conversion Architecture

The funnel follows: credibility → proof → depth → community → contact

- **Top (Hero → Story Film):** Establishes who and why
- **Middle (Reel → Currently Building → GitHub → Skills → OpenSource → Experience):** Shows proof and depth through apps, activity, and history
- **Community section:** Social proof — conference appearances, certifications, testimonials
- **CTA:** Single action — contact / book / BuyMeACoffee. No secondary "Learn More" links
- **Extras Dock:** Delight after conversion — easter eggs as reward, not distraction

## 10. Performance & SEO

- **Boot frame:** Pre-paint (no JS required for background), session-gated, one-shot-per-session
- **Font preloading:** Only first-screen fonts (Bricolage Grotesque, Geist-400) in `<head>`. Secondary weights lazy-loaded
- **Chunk strategy:** Per-section lazy chunks deferred after fold — no SSR, full client
- **JSON-LD:** `Person` schema (name, jobTitle, sameAs: GitHub/LinkedIn/Play/App Store), `WebSite` schema
- **OG / Twitter cards:** Open Graph + Twitter meta tags for every section
- **PWA manifest:** `theme-color` = `#201c2a` (updates with theme toggle), full icon set (192, 512)
- **Canonical:** `https://hasanabbassorathiya.tech/`
- **Google site verification:** Meta tag from Webmaster Tools

## 11. Anti-Patterns (Banned)

- ❌ No emojis anywhere in UI
- ❌ No `Inter` font
- ❌ No generic serif fonts (`Times New Roman`, `Georgia`, `Garamond`, `Palatino`)
- ❌ No pure black (`#000000`) — use Deep Plum `#14101f`
- ❌ No neon / outer glow shadows
- ❌ No oversaturated accents (no HSL saturation > 80%)
- ❌ No "AI purple/blue neon" aesthetic — no teal, cyan, or sky-blue accents
- ❌ No 3-column equal card rows — use zig-zag or asymmetric grid
- ❌ No overlapping elements — every element occupies its own spatial zone
- ❌ No centered hero sections (variance > 4 → asymmetric always)
- ❌ No `calc()` percentage hacks — use CSS Grid
- ❌ No filler UI text: "Scroll to explore", "Swipe down", bouncing chevrons, scroll arrows
- ❌ No custom mouse cursors
- ❌ No parallax backgrounds, no particle effects
- ❌ No generic names ("John Doe", "Acme", "Nexus")
- ❌ No fake round numbers ("99.99%", "50%")
- ❌ No AI copywriting clichés ("Elevate", "Seamless", "Unleash", "Next-Gen", "Revolutionize")
- ❌ No broken Unsplash links — use SVG or `picsum.photos` only
- ❌ No horizontal scroll on mobile