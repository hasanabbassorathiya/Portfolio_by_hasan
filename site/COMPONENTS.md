# Component Inventory — site/src

Current as of 2026-10-29. Maps each shipped component to its file and the DESIGN.md rule it
implements. Anything marked **legacy** is still in the tree but imported by nothing; do not copy
patterns from it.

## Shell and chrome

| Component | Rule | File |
|---|---|---|
| App shell — skip link, header, `<main id="main">`, footer, easter egg | §8 skip link first tab stop | `App.jsx` |
| SiteHeader — floating 1180px pill, desktop nav, mobile sheet, theme toggle | §4 sticky nav, §5 buttons | `components/site-header.jsx` |
| SiteFooter — tight two-column footer, privacy link, mono legal line | §4 layout | `components/site-footer.jsx` |
| ThemeToggle — sun/moon, persists `hs-theme` | §7 themes | `components/theme-toggle.jsx`, `lib/theme.js` |
| Boot frame — inline "H S" monogram before JS, session-gated, fades on mount | §5 boot frame | `index.html` (#boot), `main.jsx` |
| HireEgg — word-triggered card, Esc dismisses, inert inside inputs | §6 motion restraint | `components/hire-egg.jsx` |
| Router + page registry — History API `Link`, `RouteProvider`, lazy page map | n/a | `lib/router.jsx`, `lib/pages.js` |

## Home sections (all imported by `pages/home.jsx`)

| Section | Rule | File |
|---|---|---|
| Hero — kicker row, serif H1 with italic accents, dual CTAs, portrait, app ticker | §3 type, §5 imagery, §6 rise | `sections/ref-hero.jsx` |
| Stats — mono figures with count-up | §3 mono, §6 count-up | `sections/ref-offer.jsx` |
| Services — hover-inverting service rows + secondary links | §5 service rows | `sections/ref-offer.jsx` |
| Work — dark band: featured case-study card, app/client grid, provenance line | §2 bands, §5 work | `sections/ref-work.jsx` |
| Process — numbered steps with hairlines | §4 layout | `sections/ref-offer.jsx` |
| AiWorkflow — AI-assisted delivery explanation | §10 verified claims only | `sections/ref-offer.jsx` |
| Receipts — named outcomes without invented metrics | §10 no fabricated numbers | `sections/ref-work.jsx` |
| About — "Who I am", portrait, verified timeline | §1 atmosphere | `sections/ref-about.jsx` |
| WritingSection — latest essays, links to `/blog` | §3 serif accent | `sections/ref-about.jsx` |
| Contact — "How to work with me / How to contact me", email CTA, optional Cal.com booking link (`VITE_CAL_URL`), enquiry form | §5 forms, §8 accessibility | `sections/ref-about.jsx` |

## UI primitives

| Primitive | Rule | File |
|---|---|---|
| `Kicker` — mono uppercase label, light/dark tone | §3 kickers | `sections/ref-ui.jsx` |
| `SectionHead` — kicker + serif headline + blurb + action | §5 section head | `sections/ref-ui.jsx` |
| `Arrow`, `ArrowBadge`, `Check` — inline icons in circular badges | §5 buttons | `sections/ref-ui.jsx` |

## Pages

| Page | Route | File |
|---|---|---|
| Home | `/` | `pages/home.jsx` |
| Work index | `/work` | `pages/work.jsx` |
| Case study | `/work/:slug` | `pages/case-study.jsx` |
| Apps index | `/apps` | `pages/apps.jsx` |
| App profile | `/apps/:slug` | `pages/app.jsx` |
| Services index | `/services` | `pages/services.jsx` |
| Service detail | `/services/:slug` | `pages/service.jsx` |
| Blog index | `/blog` | `pages/blog.jsx` |
| Essay | `/blog/:slug` | `pages/post.jsx` |
| Resources (referral-ready) | `/resources` | `pages/resources.jsx` |
| Résumé (print source for the PDF) | `/resume` | `pages/resume.jsx` |
| Privacy notice | `/privacy` | `pages/privacy.jsx` |
| 404 | any unmatched path | `pages/not-found.jsx` |

## Behaviour modules

| Module | Purpose | File |
|---|---|---|
| `useReveal`, `useCountUp` | IntersectionObserver reveal + count-up, both reduced-motion aware | `lib/motion.js` |
| Lenis | Smooth wheel scroll, anchor offset -84px, skipped under reduced motion | `lib/lenis.js` |
| Analytics | Deferred GA4, `page_view` (initial + client-side route changes), `cta_click`, `project_open`, `store_click`, `resume_open`, `outbound_click`, `newsletter_signup`, `enquiry_submit` | `lib/analytics.js`, `App.jsx` |
| Subscribe | Email capture with honeypot, three placements | `components/subscribe.jsx` |
| Markdown | Headings, lists, tables, code, links for essays | `components/markdown.jsx`, `lib/markdown.js` |
| SEO | Per-route metadata, JSON-LD, canonical/OG | `lib/seo.js` |
| Content | Apps, clients, posts, services, resources, résumé data | `content/*.js`, `content/posts/*.md` |

## Legacy — unreferenced, kept only for history

`sections/hero.jsx`, `contact.jsx`, `stats.jsx`, `skills.jsx`, `writing.jsx`, `writing-list.jsx`,
`speaking.jsx`, `credentials.jsx`, `experience.jsx`, `currently-building.jsx`, `open-source.jsx`,
`github-activity.jsx`, `featured-reel.jsx`, `story-film.jsx`.

They predate the Bone & Ink rebuild and are not imported anywhere, so they are not bundled. The
`hero`/`reel`/`skills` manual-chunk entries were removed from `vite.config.js` on 2026-10-29 —
while present, Vite emitted them as pseudo-entry chunks and injected two extra `<script>` tags into
every page. The build now ships a single entry chunk plus the per-route lazy chunks. Deleting the
legacy files themselves is optional cleanup, not a functional change.

## Backend (not part of the static bundle)

PHP API (`api/`), admin CRM (`admin/`), enquiry worker (`scripts/enquiry-worker.php`) and schema are
documented in README.md §3–4, AUTOMATIONS.md and DEPLOY.md.
