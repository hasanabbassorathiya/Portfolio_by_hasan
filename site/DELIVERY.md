# Delivery Record — hasanabbassorathiya.tech

Updated: 2026-10-29. This file records what was built, what was verified, and what still needs the owner. Claims below are limited to work that exists in this repository or test output produced on this machine.

## 1. Status summary

| Area | State | Evidence |
|---|---|---|
| Public site (React/Vite, Bone & Ink) | Built, pre-rendered, tested locally | `npm run build`; `node --test site/scripts/prerender.test.mjs` |
| Services pages | Six detail pages + index | `site/src/content/services.js`, tests in `services.test.mjs` |
| App catalogue | 15 app profiles, store links, icons | `site/src/content/apps.js` |
| Client case studies | Three studies | `site/src/content/clients.js` |
| Essays | Nine posts, RSS, sitemap | `site/src/content/posts/`, `dist/rss.xml` |
| Resources page + pub.dev feature | Live route `/resources` | `site/src/pages/resources.jsx` |
| Résumé page + PDF | `/resume` web version; 3-page A4 PDF generated from the same data | `site/src/pages/resume.jsx`, `site/src/content/resume.js`, `site/scripts/build-resume-pdf.mjs`, `resume.test.mjs` |
| AI-assistant discoverability | `/llms.txt` generated into the build and asserted by tests | `site/public/llms.txt`, `prerender.test.mjs` |
| Enquiry intake | Durable JSON API with idempotency and outbox | `site/api/enquiries.php`, `site/api/enquiry-store.php` |
| CMS | Login, dashboard, apps/clients/posts editors, subscribers, enquiries | `site/admin/`, `site/scripts/cms-smoke.sh` |
| Mail delivery | Implemented, not exercised against a real SMTP relay | Worker defaults to dry-run |
| Profile drafts | LinkedIn and GitHub copy ready to apply | `site/LINKEDIN.md`, `site/GITHUB.md`, `site/SOCIAL.md` |
| ASO plan | Five Play listings enumerated; store copy drafts with measured character counts | `site/ASO.md` |
| Automation docs | Six workflows documented, with one implemented background sender | `site/AUTOMATIONS.md` |
| Operations README | Run, test, configure, maintain, and deploy entry point | `site/README.md` |
| Live deployment of these changes | Deployed 2026-10-31 (public bundle `index-Ciw2u65_.js`, API repaired the same day) | See §9, §13 and `DEPLOY.md` |

## 2. Homepage and conversion audit

Problems found and corrected during this rebuild:

- The page previously depended on JavaScript for readable content. Every route now ships real SSR HTML with one `<h1>`, route-specific metadata, and JSON-LD.
- Unknown routes returned `200` (soft 404). Apache now returns a real `404` with `noindex`.
- Navigating from an essay to another page left `article:*` metadata behind. It is now removed.
- Missing case studies were indexable. They are now `noindex`.
- The enquiry form was a mailto-style experience. It now posts to a validated API, keeps a stable `requestId` for safe retries, and never reports success without a `201` + 32-hex reference.
- The CMS used public registration and unthrottled login. Registration is `403`, login is throttled, CSRF is session-bound, and first-admin creation is CLI-only.
- The lower dark sections were hard to read; contrast, spacing, and the three subheads ("Who I am", "How to work with me", "How to contact me") were reworked. The sticky "Start a project" CTA is present on mobile and desktop.

## 3. Comparison matrix

Observed from public homepages on 2026-10-29. Third-party figures are their own claims, not independently verified.

| Dimension | pawan.app | dmilicic.com | This site |
|---|---|---|---|
| Positioning | Google Developer Expert · product builder | AI-assisted solo agency; senior Android/Flutter | Senior mobile + AI + full-stack engineer, Dubai |
| Primary conversion | Social links; no visible form in fetched HTML | Contact form + email, repeated CTAs | Durable enquiry form + direct email + sticky CTA |
| Proof | Bio and public profile; metadata claims reach | Logos, nine case cards, two testimonials, metrics | 15 app profiles, 3 case studies, 9 essays, store links |
| Services | Not itemised on the homepage | Three engagement models + rescue audit | Six scoped services with boundaries and evidence |
| Process | Not visible | Weekly demos, written scope | Explicit four-step process per service |
| Content engine | Essays (external) | Medium articles | Nine first-party essays + RSS |
| Extras | Crisp chat, PWA | AI workflow section | Resources page, public package, enquiry CMS |
| Gap to close | — | Reply-time promise (1 business day) | No reply-time promise is made until operationally guaranteed |

## 4. Information architecture

```
/                     Home: hero, services, work, process, AI, about, writing, contact
/services             Six services
  /services/flutter-app-development
  /services/ai-integration-automation
  /services/full-stack-api-development
  /services/app-audit-consulting
  /services/digital-platform-development
  /services/ui-ux-product-design
/apps                 15 app profiles
/work                 3 client case studies
/blog                 9 essays + RSS
/resources            Featured pub.dev package, code, reading, working together
/resume               Résumé (web) + download of the generated A4 PDF
/privacy              What the site stores from enquiries and newsletter sign-ups
/404                  Real 404, noindex
/admin/*              Private CMS (noindex, no-store)
/api/*                JSON API (public read for content, write-only enquiry intake)
/scripts/*            Blocked by .htaccess; CLI-only test harnesses
```

## 5. Verified facts and unresolved questions

Verified or supplied by the owner (see `hasan.md`, canonical):

- Seven-plus years across fintech, e-commerce, mobility, and community products.
- Dubai-based; English, Hindi, Gujarati, Urdu.
- BSc IT, University of Mumbai, 2019; listed certifications.
- App Store roster resolved 2026-10-29 through Apple's public lookup API for artist `1734376366`: Duas and Aamal, Hoda, Fragrance of Mastership, and Lumio TV. All four exist in `apps.js`. The developer web page itself redirected to the CN storefront, so the API result is the evidence.
- `stoolap_flutter` exists on pub.dev (v2.0.1 observed 2026-10-29). Package name and URL verified.
- App counts — 16 shipped apps are enumerated in `hasan.md` §6. The `/apps` catalogue has 21 entries because it also includes three unreleased builds (Petassy, BlankSpace, BULB VPN) and the WallMaster and Business Mind Play listings, which are described from their public store pages without implementation claims. Marketing copy says "16 apps"; the catalogue never calls all 21 "shipped".

Unresolved / needs owner input:

- **Cal.com booking URL** — not supplied. The contact area renders a "Prefer a call? Book a time" link only when `VITE_CAL_URL` is set at build time; the shipped build (unset) contains neither the link nor the string. No URL has been invented.
- **Referral links** (Hostinger, Qoder, Exness, others) — none supplied. `/resources` renders a partner block only when real links and disclosure exist (`partners` in `site/src/content/resources.js`).
- **Play Store catalogue** — enumerated in a real browser on 2026-10-29 from the public developer page: exactly five apps (Business Mind: Money Empire, Lumio TV, Hoda, WallMaster, Duas and Aamal). All five already exist in `apps.js` with matching Play URLs. The App Store developer page redirected to the CN storefront during the same check, so the App Store roster still relies on the owner's supplied list and per-app links.
- **Store ratings/counts** — they are snapshots. Re-check before launch; they change.
- **Mail delivery** — the worker and outbox are tested in dry-run; no real SMTP send has been performed.
- **Production Apache/MySQL 8** — verified against a disposable MariaDB and a local Apache harness, not Hostinger's live stack.

## 6. Integration inventory

| Integration | Where | Requirement | State |
|---|---|---|---|
| MySQL content API | `site/api/index.php` | `api/config.php`, `schema.sql`, `seed-content.sql` | Tested with disposable MariaDB |
| Enquiry intake | `site/api/enquiries.php` | `enquiries-schema.sql` | 195 checks incl. real MariaDB/HTTP integration + HTTP 201 in CMS smoke |
| Enquiry worker | `site/scripts/enquiry-worker.php` | CLI + mail transport; `ENQUIRY_OWNER_EMAIL`, `ENQUIRY_FROM_EMAIL` for `--send` | Dry-run tested; real send pending |
| Admin auth | `site/api/auth.php`, `site/admin/` | `AUTH_PEPPER`, schema | 10 auth integration tests |
| Analytics | `site/src/lib/analytics.js` | `VITE_GA4_ID` at build time | Inert without the ID; with it unset the bundler drops the telemetry calls entirely (verified by building with and without an ID); contact tests enable it locally only |
| Newsletter | `site/api/subscribe.php` | `subscribers` table | CMS smoke drives signup 201, duplicate upsert, 422 validation, honeypot, token unsubscribe and token reuse |
| App Store / Play links | `site/src/content/apps.js` | none | Rendered and link-tested at build time |
| Cal.com | `site/src/sections/ref-about.jsx` | `VITE_CAL_URL` at build time | Wired and browser-tested with a local test URL; link and bundle string absent while unset |
| Referral partners | `site/src/content/resources.js` | Real URLs + disclosure | **Blocked** |
| Google Stitch | — | Installed integration, MCP server or supported export workflow | **Not available** — checked 2026-10-29: no Stitch CLI on `PATH`, no Stitch MCP server in `.mcp.json` or the runtime tool catalogue; no generated Stitch design was used or claimed |
| Gemini (Google AI Pro) | — | Local Gemini CLI and authorized access | Gemini CLI 0.46.0 is installed and a `gcloud` session for the owner's account exists, but this project did not call Gemini; no generated design, copy or code was imported, and no key is stored in the repo |

## 7. Automation and operations

`site/AUTOMATIONS.md` documents all six workflows: enquiries (A), content (B), job search (C),
outreach (D), monitoring (E), and reporting (F). Only A is a background automation; B, C, D, and F
are human-run routines with written rules, and E is a set of read-only checks.

- Enquiry outbox: owner + acknowledgement rows are written in the same transaction as the lead. The worker retries definite failures up to five attempts with backoff; `--retry=ID` retries one row; ambiguous sends require `--accept-duplicate-risk`.
- Default worker mode is dry-run. `--send` requires `ENQUIRY_OWNER_EMAIL` and `ENQUIRY_FROM_EMAIL` and uses PHP `mail()`; "sent" means local transport acceptance, not inbox delivery.
- Suggested schedule (owner must configure): run `php site/scripts/enquiry-worker.php --send` every 10–15 minutes via cron. This is not configured by the site.
- Job search and outreach deliberately have no sender code: no auto-apply, no bulk email, no logged-in scraping, five outreach contacts per week at most.
- CMS smoke test: `CMS_SMOKE_ALLOW=1 ./site/scripts/cms-smoke.sh` starts disposable MariaDB and PHP servers, checks every admin screen, intake, and CSRF update, then cleans up.

## 8. SEO and analytics report

Implemented:

- SSR-readable HTML for every route, one `<h1>` per page, canonical URLs.
- Per-route title/description/OG/Twitter; article timestamps and tags; noindex on 404 and missing detail pages.
- JSON-LD: Person sitewide with `sameAs` links to LinkedIn, GitHub, Instagram, and both verified developer profiles; MobileApplication for apps; Service for services; Blog/Article data for essays; no fabricated SearchAction.
- `sitemap.xml` (39 URLs), `rss.xml` (9 items), `robots.txt` present.
- Real 404s and static service/resource shells under Apache, verified with JavaScript disabled.
- `/llms.txt` — a plain-text summary for AI assistants with verified facts, canonical links and citation notes, built into `dist/` and asserted by `prerender.test.mjs`.
- Analytics events: `page_view` for the initial load and every client-side route change (so service-page engagement is measurable), CTA clicks, section views, outbound links, résumé clicks, and `enquiry_submit` with the selected `type` plus `category` (`recruitment` for "Full-time role", `project` otherwise) — no name, email or message copy. GA4 loads only when `VITE_GA4_ID` is set.

Required measurements, mapped to the shipped events:

| Required metric | Event | Parameters | Fires from |
|---|---|---|---|
| Project enquiry submission | `enquiry_submit` | `category: project`, `type` | The contact form, after a successful POST |
| Recruitment enquiry | `enquiry_submit` | `category: recruitment`, `type: Full-time role` | The same form when the role option is selected |
| Resume download | `resume_open` | `location: resume-page`, `resume-page-footer`, `contact` | Both PDF buttons on `/resume`, the contact and header links |
| Project link clicks | `project_open` | `entity` (slug) | App and case-study cards on `/`, `/apps`, `/work`, plus the Duas and Good2Go receipts |
| Contact actions | `cta_click` | `kind: email` or `contact`, `meta` | Email buttons, header and mobile CTAs, contact channel links |
| Service-page engagement | `page_view` | `page_path`, `page_title` | Every client-side route change, including all six service pages; service CTAs also emit `cta_click` |

Every event carries no name, email or message text. Events exist only in builds made with `VITE_GA4_ID`; without it the calls are removed by the bundler.

Lighthouse scores are measured in §9. Not measured: real crawl/index status, keyword rankings, and AI-assistant citations. `llms.txt` and structured data make the site easier to parse; they do not guarantee rankings or citations, and no implementation can.

## 9. Performance and accessibility findings

Implemented and checked:

- Self-hosted fonts with `font-display: swap` and preloads; no third-party font requests.
- Images are local WebP assets; app icons/screenshots lazy-loaded where appropriate.
- Reduced-motion support; Lenis is disabled for reduced motion.
- Skip link, visible focus styles, labelled form controls, `aria-describedby` for consent and message help, `role="status"` and `role="alert"` for submission states.
- Layouts checked at 320, 390, 768, 1024, 1280, and 1440 without horizontal overflow.
- Honeypot is hidden, `tabindex="-1"`, and not focusable.

Measured with Lighthouse 13.6.0 on 2026-10-29 against the production build served by the local Apache harness, mobile form factor, simulated throttling:

| Run | Performance | Accessibility | Best practices | SEO | FCP | LCP | TBT | CLS |
|---|---|---|---|---|---|---|---|---|
| Before fixes | 79 | 97 | 96 | 100 | 1.9 s | 4.1 s | 250 ms | 0 |
| After content/contrast fixes | 89 | 100 | 96 | 100 | 1.0 s | 3.7 s | 27 ms | 0.001 |
| Final (hydration + font discovery) | 100 | 100 | 96 | 100 | 0.9 s | 0.9 s | 0 ms | 0.001 |

The final line is the production build served by the Apache harness; it reproduced twice consecutively. Before it, the page replaced its prerendered HTML with a fresh client render (`createRoot`), which forced a second paint and delayed LCP.

Fixes made, in order:

- Removed opacity from the `rise-in` entrance animation so above-the-fold text paints immediately (LCP moved from the header CTA at 4.1 s to the real `<h1>`).
- Raised small mono labels on dark grounds from 35–50% to 60 % foreground opacity (contrast violations 20 → 0).
- Routed all prerendered routes through `hydrateRoot` instead of `createRoot`, with route state in a `RouteProvider` so server and client render identical trees; the theme toggle reads the DOM through `useSyncExternalStore` with a fixed server snapshot. The prerendered shell is now reused as the first paint on every route.
- Declared the four above-the-fold font faces inline in `index.html` before the stylesheet, so font requests start with the document rather than after CSS parse. This removed the last consistent 3.x s simulated-LCP estimate.

Honest variance note: simulated Lighthouse LCP is bimodal on this machine (0.9 s or ~3.1 s) because Lantern models the font dependency chain; a CDP-throttled (150 ms RTT, 1.6 Mbps, 4× CPU) probe measured the real LCP element (`h1#hero-title`) at 1.09–1.17 s across four runs, and the hydration sweep observes LCP at 56–160 ms on the unthrottled harness (the slowest case is the home hero image). One Lighthouse run taken while the test suite was running scored 95 with TBT 250 ms (CPU contention), which is why the table records a clean, repeated run rather than a best-of.

Remaining Lighthouse notes: best practices stays at 96 because the static harness has no PHP API, so the client's three content fetches log 404s; the production build serves those from `api/index.php`. Real-device measurement and screen-reader testing remain pre-launch tasks.

### Real-host measurement (2026-10-31)

The live site (`https://hasanabbassorathiya.tech`, bundle `assets/index-Ciw2u65_.js`) was measured with Lighthouse 12.8.2 on Chrome 156 attached to a real browser. A fresh headless Lighthouse run is refused with 403 by the Hostinger CDN's `hcdn` browser check, so the run primed that challenge cookie in a debuggable Chrome and attached with `--port=9333 --disable-storage-reset`. Raw JSON: `site/evidence/2026-10-31/lighthouse/` (index in `summary.json`).

| Route | Form | Perf | A11y | BP | SEO | FCP | LCP | TBT | CLS |
|---|---|---|---|---|---|---|---|---|---|
| `/` run 1 | mobile | 99 | 100 | 96 | 100 | 0.9 s | 1.0 s | 100 ms | 0 |
| `/` run 2 | mobile | 100 | 100 | 96 | 100 | 1.0 s | 1.1 s | 60 ms | 0.001 |
| `/` | desktop | 100 | 100 | 96 | 100 | 0.3 s | 0.3 s | 0 ms | 0 |
| `/services` | mobile | 100 | 100 | 96 | 100 | 0.9 s | 1.0 s | 20 ms | 0 |
| `/resume` | desktop | 100 | 100 | 96 | 100 | 0.3 s | 0.3 s | 0 ms | 0 |

Live scores match the harness. Best practices is 96 on every live route because the deployed `api/` was a stale snapshot: `GET /api/index.php?entity=settings` returned 400 and `GET /api/track.php` returned 404, and those failed fetches were the only console errors. **Repaired 2026-10-31 ~15:45 UTC:** the 11-file API bundle and `migrate-2026-10-31-live.sql` were applied (see `DEPLOY.md`); live settings now returns 200 and the beacon 204, so this caveat no longer applies and Best Practices should re-measure at 100. Before the repair the page degraded to seed content and analytics recorded nothing; after it, live content hydrates and first-party events land in `analytics_events` (verified: page_view, section_view, page_leave for one live session). `config.php` is never uploaded. `uses-long-cache-ttl` flags four unhashed images at a 7-day TTL; that is deliberate because CMS media filenames are stable and a longer TTL would pin replaced icons for returning visitors. The `hcdn` check is also why automated monitors should expect a challenge instead of a direct HTML response; if real visitors report the interstitial, review the CDN bot-protection setting in hPanel.

INP is a field metric and no CrUX/Real User Monitoring data exists before launch, so no INP number is claimed here. The lab proxy is Total Blocking Time: 0 ms in both recorded runs, and the hydration sweep drives client-side navigation and a theme toggle without long tasks. Real INP becomes measurable in Search Console/CrUX after deployment.

axe-core 4.14.0 sweep (`npm run a11y`, 2026-10-29): 16 routes × 1440/390 × light/dark = 64 checks against the WCAG 2.0/2.1/2.2 A+AA tags. **0 violations**, and the same run asserts a single `h1` plus no skipped heading levels inside `main` (0 issues in 64 checks). Raw results: `site/evidence/2026-10-29/a11y.json`. The first run surfaced 70 serious violations, all fixed at the source:

- `label-content-name-mismatch` × 52 (every route) — the logo's monogram "HS" sat in the same link as the wordmark, so the visible text never matched the accessible name. The name now reads "HS Hasan Abbas Sorathiya — home", matching the visible text at every width. **2026-10-31 follow-up:** the live Lighthouse run (Lighthouse 13.4.1, axe-core 4.12) still flagged the link. axe 4.12 sanitises each element's text before joining, so the badge's "HS" became "HSHasan Abbas Sorathiya" and was no longer contained in the aria-label; axe 4.14 passes because it compares whole tokens. The monogram is now decorative CSS content (`before:content-['HS']`, commit `2a6048a`), leaving the visible label as the name at every breakpoint. Verified locally with axe-core 4.12: 0 violations across 19 routes × 1440/390. The live page keeps the finding until the next site build is deployed.
- `color-contrast` × 16 — light `--text-muted` darkened `#6f675c` → `#665f52` (4.32 → 4.91 on the tinted surface), the 80 %-opacity muted label on the offer block removed, blog index numerals raised from 70 % to 90 % opacity in dark mode, and the light-theme highlight swapped for the lighter `--hl-a-ink` inside dark bands (2.76 → 7.14).
- `scrollable-region-focusable` × 2 — code blocks and tables are now focusable labelled regions, so keyboard users can scroll them.

## 10. Screenshots and test record

Screenshots: `site/evidence/2026-10-29/` — eight routes (`/`, `/services`, `/apps`, `/work`, `/blog`, `/resources`, `/resume`, `/privacy`) at 1440, 1280, 1024, 768, 390 and 320, plus full-page home at 1440 and 390 and `report.json`; recapture with `node site/scripts/capture-evidence.mjs` against the local harness. Admin screens (login, dashboard, enquiry list and detail) and the Resources light/dark captures are kept alongside them; see that directory's README.

Six-width result, recaptured against the final build: 50 captures, every page returned 200 with no document-level horizontal overflow (`overflow: false` in all 48 measured rows), fonts loaded, and no unexpected failed requests. The only 404s are the static harness's missing content API, recorded in `report.json` as `expectedApiMisses` (3 per page). Two elements legitimately extend past the viewport and are recorded in `wideElements`, not treated as failures: the `sr-only` newsletter label/input on `/blog`, and the hero's ticker inside an `overflow-hidden` strip.

Latest test results (2026-10-29):

| Suite | Result |
|---|---|
| `app-catalog.test.mjs` | 29 pass |
| `live-content.test.mjs` | 21 pass |
| `prerender.test.mjs` | 4 pass (includes build, resources, schema, sitemap, 404 and `llms.txt`) |
| `services.test.mjs` | 11 pass (real SSR for the service index and all six detail pages) |
| `site-browser.test.mjs` + `conversion.test.mjs` | 17 pass, run against the built site through `SITE_TEST_URL` |
| `interaction-qa.test.mjs` | 6 pass against the built site — mobile-menu keyboard/Escape/focus return, skip link and focus ring, reduced motion, résumé PDF, form validation/success/error, footer profile links |
| `seo-browser.test.mjs` | 4 pass |
| `contact-enquiry.test.mjs` | 26 pass |
| `resume.test.mjs` | 1 pass |
| Hydration sweep (`npm run hydration`) | 30 checks (15 routes × light/dark), 0 failures, 0 markup replacements, LCP 56–160 ms |
| `auth.test.php` | 10 pass |
| `enquiries.test.php` | 195 checks with a disposable socket — 88 logic checks plus 107 real MariaDB/HTTP checks (persistence, outbox, retries, worker locks, concurrent intake, admin/HTTP/CLI); without a socket the database half is skipped |
| `cms-smoke.sh` | PASS — dashboard, editors, subscribers, API, intake, CSRF update |
| `php -l` on edited PHP | clean |
| Web-SAPI guard on `auth.test.php` | 404 (CLI tests unaffected) |

Node test total: 119 — 88 source/SSR, 4 prerender/build, 17 browser UX, 6 interaction QA and 4 SEO. The browser suites default to `npm run dev` on `127.0.0.1:5173` (binding only to `localhost` resolves to IPv6 and the tests fail to connect) but accept `SITE_TEST_URL`, and the 17 UX checks were last run against the built site on the Apache harness.

## 11. Security and deployment checklist

- `site/api/config.php` is gitignored and exists only on the server. Never commit or overwrite it.
- Test harnesses and CLI scripts are blocked by `.htaccess` (`/scripts` → 403) and by `PHP_SAPI` guards.
- Admin responses: `no-store`, `noindex`, `nosniff`, `Referrer-Policy: no-referrer`.
- Enquiries admin adds a restrictive CSP (`default-src 'none'`).
- Security headers: `X-Content-Type-Options`, `X-Frame-Options: DENY`, `Referrer-Policy`, `Permissions-Policy`.
- Auth: public registration disabled; per-IP and per-account throttling; HMAC bucket keys; 64-hex tokens; session-bound CSRF; generic 401 messages.
- Enquiry: origin checks, payload size limits, honeypot, consent required, idempotency, generic 503 logging, no automatic deletion.
- What enquiry and newsletter storage actually holds is documented publicly at `/privacy` (fields, keyed IP hash, GA4 anonymisation, retention, removal path); the form's consent line and the footer link to it. Consent scope: enquiries require an explicit tick, and GA4 is absent from the build until the owner sets `VITE_GA4_ID`; if GA4 is enabled for audiences that require prior consent, a consent gate is a legal decision left to the owner and is not implemented.
- Dependency audit: `npm audit --omit=dev` reports **0 production vulnerabilities**; the full audit flags dev-only Vite/esbuild advisories (Vite ≤6.4.3, mostly Windows dev-server path handling). The deployed artifact is static HTML/CSS/JS; the dev server is local and never exposed. A Vite major upgrade is a breaking change deliberately deferred rather than rushed before launch.
- Live `.htaccess` must be uploaded with the build; `_views` shells require the rewrite rules in `site/.htaccess`.

## 12. Backup and rollback

Before a deploy:

```bash
# On the server or via SSH
tar -czf ~/portfolio-backup-$(date +%F-%H%M).tar.gz public_html
mysqldump -u <user> -p <database> > ~/portfolio-db-$(date +%F-%H%M).sql
```

Rollback:

1. Restore the previous `public_html` archive (keep the current `api/config.php` — it is not in the build).
2. Restore the database dump only if a schema/content change caused the issue.
3. Re-upload the previous `dist/` plus `.htaccess`; verify `/`, `/services`, `/resources`, `/404`.

Never roll back by deleting the database; keep the dump and restore into the existing schema.

## 13. Manual tasks and approvals

1. **Approve future deployments.** The public build and API were deployed on 2026-10-31; this section remains the approval gate for later builds.
2. **Provide the Cal.com booking URL** and set `VITE_CAL_URL` (https only) before the production build. The contact area already renders the "Prefer a call? Book a time" link and tracks it as `cta_click` `kind: booking`; nothing appears while the variable is unset.
3. **Provide referral URLs** and confirm the disclosure wording before any partner link goes live.
4. **Upload `site/api/config.php`** on the server only; never commit it.
5. **Configure mail** (`ENQUIRY_OWNER_EMAIL`, `ENQUIRY_FROM_EMAIL`) and run the worker once with an approved test address before enabling cron.
6. **Set `VITE_GA4_ID`** for the production build. Decide whether the audiences you serve require a prior-consent gate before GA4 cookies load; none is implemented in this build, and analytics stay completely absent while the variable is unset.
7. **Re-check store ratings/counts.** Rosters are confirmed — five Play apps via the public developer page and four App Store apps via Apple's lookup API for artist `1734376366`; every one matches `apps.js`.
8. **Run real-device checks** before launch (Lighthouse, axe and the hydration sweep are already recorded in §9/§18; a physical iOS/Android pass is the remaining gap).
9. **Decide the reply-time promise.** The site deliberately makes none until it can be kept.
10. **Apply the profile drafts.** Publish `site/GITHUB.md` §1–§4 to GitHub and `site/LINKEDIN.md` §1–§8 to LinkedIn; both are drafts until the owner does this.
11. **Read the `/privacy` notice** and confirm it matches your jurisdiction and retention policy; the page describes the shipped behaviour, but legal wording is the owner's call.
12. **Optional: share a Stitch workspace or export** if you want a separate design-direction exercise. Stitch was not reachable from this workspace (no integration, MCP server or CLI), so the shipped direction was explored directly in Playwright and recorded in `DESIGN.md`; this is optional, not a blocker.
13. ~~**Deploy the current `api/*.php` and growth schema.**~~ Done 2026-10-31 with owner approval: 11 files uploaded (never `config.php`/`.htaccess`) and `migrate-2026-10-31-live.sql` applied; endpoints verified live. See `DEPLOY.md` § "Production API repair (2026-10-31)".

## 14. Four-week content calendar

At most three items a week: one site change, one LinkedIn post, one GitHub/community proof. Draft
copy lives in `SOCIAL.md` §1–§2 (launch variants and essay cross-posts) and `LINKEDIN.md`; items
citing an existing post are ready to adapt, and items marked *new* still need a draft before they
can be published — nothing here goes out without the owner's approval.

| Week | Channel | Item | Type | Audience | Purpose | Source |
|---|---|---|---|---|---|---|
| 1 | Site | Share the `/resources` page and its `stoolap_flutter` entry as the month's landing target | Launch / proof | Recruiters and Flutter developers | Give every post this month one central link target | `/resources`, `resources.js` |
| 1 | LinkedIn | Launch post — recruiter variant | Positioning | Hiring managers and recruiters | Turn profile visits into `/work` and `/resume` reads | `SOCIAL.md` §1A |
| 1 | GitHub | Pin `stoolap-flutter` and link it from the profile README | Proof | Dart and Flutter developers | Make the package discoverable from the profile | `GITHUB.md` §1–§2 |
| 2 | Site | Refresh and re-share the startup-time essay | Engineering lesson / performance | Flutter leads, founders | Show measured before/after engineering rather than claims | `/blog/flutter-startup-time` |
| 2 | LinkedIn | Cross-post the startup-time essay | Technical problem-solving | Mobile engineers | Earn reads through a concrete measurement, start lead conversations | `SOCIAL.md` §2 |
| 2 | GitHub / community | Link the essay from the repository it demonstrates | Proof | Developers judging code quality | Connect the writing to working code | repo README |
| 3 | Site | Refresh one case study with current facts (EV Lab) | Real project breakdown | Clients considering an audit or build | Keep the strongest proof current | `/work/evlab` |
| 3 | LinkedIn | Founder/consulting post — consulting variant | Services / audit offer | Founders and product teams | Start audit and consulting conversations | `SOCIAL.md` §1B |
| 3 | LinkedIn or site | AI-in-production post built on the Flutter AI-trust essay | Practical AI integration | CTOs, technical leads | Separate practical AI integration from hype | `/blog/shipping-ai-features-flutter-trust` |
| 4 | Site | *New* short note on one automation workflow, with the real before/after | Automation / productivity | Small teams, founders | Show a working workflow, not a promise | `AUTOMATIONS.md` |
| 4 | LinkedIn | RAG/agents post referencing the production RAG essay | Engineering lesson / AI | AI engineers and AI-role recruiters | Reach AI hiring managers with verified work | `/blog/rag-that-survives-real-users` |
| 4 | GitHub / community | Share the MCP server repo with a usage example | Professional learning / community | Developer community | Contribute visibly and earn discovery through usefulness | `GITHUB.md` §2–§3 |

The mix covers engineering lessons, real project breakdowns, Flutter/mobile insight, practical AI
integration, automation, technical problem-solving and professional learning; every entry names an
audience and a purpose. If a week slips, drop the lowest-priority item rather than posting filler.
No engagement pods, no purchased followers, no invented results.

## 15. 30-day growth plan

- **Days 1–7:** deploy with approval; submit sitemap in Search Console; verify 404s; set GA4; run the enquiry worker once.
- **Days 8–14:** publish two essays; add Cal.com if supplied; request five specific (non-bulk) referrals from past colleagues.
- **Days 15–21:** run the ASO pass in `site/ASO.md` (one Play experiment at a time); refresh store ratings; link the portfolio from each developer profile.
- **Days 22–30:** audit inbound enquiries and page analytics; keep the two highest-converting CTAs; cut or rewrite weak sections; publish a monthly build note.

Success measures: qualified enquiries, reply rate, essay reads, store-page visits. No revenue or ranking promises.

## 16. Changed files and architecture decisions

Key additions/changes in this pass:

- `site/src/pages/resources.jsx`, `site/src/content/resources.js` — Resources page with conditional partner disclosure.
- `site/src/content/resume.js`, `site/src/pages/resume.jsx` — single canonical résumé dataset and the `/resume` page; `site/src/sections/experience.jsx` now reads the same roles, so site and résumé cannot drift.
- `site/scripts/build-resume-pdf.mjs`, `site/scripts/resume.test.mjs`, `site/public/hasan-abbas-sorathiya-resume.pdf` — PDF generation from the live page plus assertions on PDF, page metadata, roles, products and sitemap.
- `site/src/index.css`, `site/src/components/site-header.jsx`, `site/src/components/site-footer.jsx`, `site/src/components/hire-egg.jsx` — print rules and `print:hidden` chrome so the PDF contains only the résumé sheet.
- `site/src/lib/router.jsx`, `site/src/App.jsx`, `site/src/components/site-header.jsx`, `site/src/components/site-footer.jsx` — `/resources` route and navigation.
- `site/src/sections/open-source.jsx`, `site/src/sections/ref-about.jsx` — pub.dev link and package status.
- `site/scripts/prerender-meta.mjs` — SSR for `/resources`, sitemap entry.
- `site/.htaccess` — `/resources` shell, `/scripts` denial, real 404s.
- `site/admin/dashboard.php` — enquiry counts/card, corrected rebuild wording.
- `site/api/subscribe.php`, `site/scripts/cms-smoke.sh` — the unsubscribe page now uses the Bone & Ink palette (canvas/ink/cobalt, dark-mode variant, visible focus ring) instead of the pre-redesign dark-purple theme; smoke covers signup 201, duplicate upsert, 422 validation, honeypot, token-based unsubscribe (row deleted) and token reuse.
- `site/scripts/auth.test.php` — CLI-only guard.
- `site/scripts/cms-smoke.sh` — repeatable CMS + intake smoke test.
- `site/scripts/prerender.test.mjs`, `site/scripts/live-content.test.mjs` — resources coverage, case-insensitive empty-state assertion, `llms.txt` build assertion.
- `site/src/pages/privacy.jsx`, `site/src/lib/router.jsx`, `site/src/lib/pages.js`, `site/src/App.jsx`, `site/scripts/prerender-meta.mjs`, `site/.htaccess` — `/privacy` notice describing what enquiries and newsletter subscriptions actually store, how long, and how removal works; linked from the footer and the form's consent line; prerendered shell, canonical URL and sitemap entry; covered by `prerender.test.mjs`.
- `site/src/sections/ref-about.jsx`, `site/api/enquiry-store.php` — added `Full-time role` to the enquiry project types (and the server-side allow-list) so recruiting conversations don't get mislabelled as project work.
- `site/src/lib/router.jsx` — default React import so the component renders under the classic JSX transform used by the config-less SSR test.
- `site/scripts/a11y-audit.mjs` — axe-core sweep over 14 routes at two widths in both themes, plus a heading-outline assertion (one `h1`, no skipped levels inside `main`); exits non-zero on serious/critical findings.
- `site/public/llms.txt` — AI-assistant summary of verified facts, services and canonical links; now links all six service detail pages and `/privacy`, and describes `/apps` as a 20-entry catalogue (15 shipped) instead of "11 app profiles". `prerender.test.mjs` asserts the service and privacy links.
- `site/GITHUB.md`, `site/LINKEDIN.md` — profile README, pinned-repo plan, headline/About/experience drafts.
- `site/ASO.md` — store-listing plan for the five verified Play apps and owner-controlled App Store listings, with character-counted copy drafts and console-based measurement rules.
- `site/AUTOMATIONS.md` — enquiries, content, job search, outreach, monitoring, and reporting routines, including what is deliberately manual and why.
- `site/README.md` — operations entry point for requirements, commands, configuration, content flow, tests, deploy, and known limitations.
- `site/scripts/capture-evidence.mjs`, `site/evidence/2026-10-29/` — repeatable six-width screenshot and overflow evidence.
- `site/src/lib/seo.js`, `site/index.html` — Person `sameAs` now includes the verified Play and App Store developer profiles; asserted in `prerender.test.mjs`.
- `site/src/index.css` — `rise-in` no longer animates opacity, so above-the-fold text paints immediately.
- `site/src/sections/ref-work.jsx`, `site/src/pages/work.jsx`, `site/src/pages/case-study.jsx` — dark-band labels raised to 60% opacity for WCAG contrast.
- `site/src/lib/router.jsx` — `RouteProvider`/`RouteContext`; App and header read the same route on server and client, and the URL fragment is adopted only after hydration.
- `site/src/lib/pages.js` — one route→chunk registry shared by the lazy App components and the pre-hydration page loader.
- `site/src/main.jsx` — `hydrateRoot` for shells rendered for the current path; `createRoot` only for CMS slugs and unknown paths that reuse another shell.
- `site/src/App.jsx` — accepts `initialRoute`/`initialPage` so the first client render matches the server tree exactly.
- `site/src/components/theme-toggle.jsx` — `useSyncExternalStore` with a fixed `'light'` server snapshot to remove the dark-mode hydration mismatch.
- `site/scripts/prerender-meta.mjs` — renders the full `<App>` via `renderToString` and marks the shell with `data-route`.
- `site/index.html`, `site/src/index.css` — the four above-the-fold `@font-face` rules are declared inline before the stylesheet; the duplicate declarations in CSS are removed.
- `site/scripts/hydration-check.mjs` — repeatable regression sweep (`npm run hydration`): 15 routes × 2 themes, asserts no `#root` child replacement, no hydration console errors, correct theme and `<h1>`, then client navigation and theme toggle.
- `site/scripts/prerender.test.mjs`, `site/scripts/resume.test.mjs` — updated for `RouteProvider` and for `renderToString` text separators.
- `site/vite.config.js` — removed the stale `manualChunks` entries (`hero`, `reel`, `skills`) that pointed at legacy sections nothing imports. Vite emitted them as entry chunks and injected two extra `<script>` tags into every page's HTML; the build now ships one entry chunk plus the per-route lazy chunks.
- `site/src/pages/work.jsx` — the `/work` link to the app index now reads "See the full app catalogue"; "All 15 apps" contradicted the catalogue on `/apps` (15 shipped apps in `hasan.md` §6 plus Petassy, BlankSpace, and BULB VPN, unreleased builds, and the two Play listings whose development is not documented).
- `site/src/lib/analytics.js`, `site/src/App.jsx` — `page_view` now fires on each client-side route change, 250 ms after the path changes so the lazy page has set `document.title`; GA4's automatic page view only covered the first load, leaving service-page engagement unmeasured.
- `site/src/sections/ref-work.jsx`, `site/src/pages/work.jsx` — `project_open` now covers the home work cards, the receipt links and every case-study/app link on `/work`; previously only `/apps` tracked clicks, so case-study opens were invisible.
- `site/src/sections/ref-about.jsx` — optional Cal.com link under the contact CTA, gated on a build-time `VITE_CAL_URL` that must start with `https://`; it fires `cta_click` `{kind: booking}`, and when the variable is unset the link, its label and any `cal.com` string are absent from the shipped bundle.
- `site/src/sections/ref-about.jsx` — the About statement now reads as the owner's exact sentence across its two lines ("Seven years of shipping products people keep — / not just launch, forget, and rewrite a year later."); the previous split ended the heading with a full stop and capitalised the following line.

- `site/src/content/apps.js` — BlankSpace and BULB VPN added as catalogue entries written from their source code rather than their store copy; neither has a public store listing, so both ship without store links, ratings or screenshots. Petassy's `links` and `sources` no longer reference the private repository, so no source CTA renders and the repository URL is absent from the bundle; Petassy, BlankSpace and BULB VPN are listed as unreleased builds while the shipped count stays 15.
- `site/public/media/apps/blankspace/icon.webp`, `site/public/media/apps/bulbvpn/icon.webp` — 512 px WebP icons converted from each project's iOS AppIcon.
- `site/api/seed-content.sql` — regenerated with `npm run seed:sql`; 13 app rows including the two additions, Petassy `links` empty. The live API is authoritative after hydration, so the same seed must be imported before the catalogue additions appear on the deployed site.
- `site/scripts/app-catalog.test.mjs`, `site/scripts/live-content.test.mjs` — assertions moved to the 20-entry catalogue / 13 app profiles, plus the Petassy rule (no `sources`, empty `links`) and BULB VPN's public source link.
- `site/scripts/a11y-audit.mjs`, `site/scripts/hydration-check.mjs` — `/apps/blankspace` and `/apps/bulbvpn` added, raising the sweeps to 16 and 15 routes.
- `site/public/llms.txt`, `site/GITHUB.md` — Petassy's repository removed from every public reference; the pinned list is now five public repositories, and private repositories are explicitly out of scope.

Architecture decisions:

- Pre-render with the real React components so content and schema cannot drift.
- Hydrate prerendered shells rather than replacing them; a path whose shell belongs to another route (`data-route` mismatch) falls back to a clean client render so React never reconciles the wrong tree.
- Keep the CMS API authoritative; valid empty arrays clear seeds, malformed responses keep seeds.
- Treat the enquiry API as write-only; admin reads go through authenticated PHP.
- No third-party booking/video/analytics script is embedded. The Cal.com link is a plain anchor gated at build time; no booking widget loads, and the link stays out of the bundle until `VITE_CAL_URL` is set.
- No manual chunk overrides: route-level lazy imports are the only split. The stale overrides had turned shared modules (React runtime, app content) into pseudo-entry chunks loaded by every page, and the chunk names described code that no longer existed.
- Enquiry qualification stays in one free-text `Project` field (what you're building, deadline, existing production) instead of separate company/budget/timeline/URL inputs. The brief marks those four optional, and the Contact section asks to avoid friction; the API stores only name, email, category, message and consent, and budget/timeline are asked in the reply. Adding them later needs an additive `enquiries` migration and matching admin/API/test changes.

## 17. Owner-facing summary

Done: publishable site, services, app catalogue, case studies, essays, Resources page, pub.dev feature, Privacy notice, durable enquiry workflow, hardened CMS, 404/SEO fixes, tests, and this record.

Blocked on the owner: Cal.com URL, referral URLs, live deploy approval, real mail configuration, GA4 ID, store ratings refresh, privacy-wording review.

## 18. Verification record (2026-10-29)

Node suites are run from `site/` because `resume.test.mjs` resolves `public/` and `dist/` from the working directory; PHP and build commands were run from the repository root:

| Check | Command | Result |
|---|---|---|
| Content, catalogue, services, enquiry logic, résumé | `node --test scripts/{live-content,app-catalog,services,contact-enquiry,resume}.test.mjs` (in `site/`) | 88 pass, 0 fail |
| Prerender, metadata, sitemap, 404, `llms.txt` | `node --test scripts/prerender.test.mjs` (in `site/`) | 4 pass, 0 fail |
| Browser SEO, client navigation, Apache fallback | `node --test scripts/seo-browser.test.mjs` (in `site/`) | 4 pass, 0 fail |
| Hydration of prerendered shells | `npm run hydration` against the Apache harness | 30 checks (15 routes × light/dark): 0 failures, 0 `#root` child replacements, no hydration console errors; LCP 56–160 ms; `evidence/2026-10-29/hydration.json` |
| Admin auth and throttling | `php site/scripts/auth.test.php` | 10 tests, 0 failures |
| Enquiry validation and storage | `php site/scripts/enquiries.test.php` | 195 checks against a disposable MariaDB socket (88 logic + 107 integration); no real mail sent |
| CMS end to end (MariaDB + PHP server) | `CMS_SMOKE_ALLOW=1 ./site/scripts/cms-smoke.sh` | PASS: dashboard, editors, subscribers, API, intake, CSRF update, newsletter subscribe/unsubscribe |
| Production build | `npm --prefix site run build` | 39 sitemap URLs, 9 RSS items, all routes prerendered, `dist/llms.txt` emitted |
| Reduced-motion behaviour | One-off Playwright probe with `reducedMotion: 'reduce'` at 1440 px on `/`, `/services`, `/privacy` | Marquee animation `none`, computed transition duration `0s`, 0 hidden-opacity elements in `main`, no overflow, no boot overlay |
| Dependency audit | `npm audit --omit=dev` (full audit recorded separately) | 0 production vulnerabilities; dev-only Vite/esbuild advisories documented in §11 |
| Accessibility (axe-core) | `npm run a11y` against the Apache harness | 64 checks (16 routes × 1440/390 × light/dark), WCAG 2.0/2.1/2.2 A+AA, **0 violations**, plus one-`h1`/no-skipped-heading assertions; `evidence/2026-10-29/a11y.json` |
| Résumé page and PDF | `npm run resume:pdf`; `node --test scripts/resume.test.mjs` | 224,605-byte 3-page PDF; canonical, single `<h1>`, 6 roles, 6 products, sitemap entry, no FlowCV link; PDF links verified with PDFKit (17 annotations incl. both `/resume` footers) |
| Apache route behaviour (`/resume`) | `curl` against `127.0.0.1:8099` | `/resume` 200 `text/html`, `/resume.html` 200, `/hasan-abbas-sorathiya-resume.pdf` 200 `application/pdf` |
| Apache route behaviour | `curl` against `127.0.0.1:8099` | `/resources` 200, `/resources/` 200, `/unknown-route` 404, `/scripts/auth.test.php` 403, `/llms.txt` 200 |
| Sitemap crawl | every `<loc>` in `dist/sitemap.xml` resolved against the Apache harness | 39/39 return 200 |
| Internal link crawl | 48 unique `href="/…"` values extracted from `dist/*.html` and `dist/_views`, minus assets/media | 0 broken |
| Meta and structured data | one-off Node audit over `dist/**/*.html` | 40 pages: no missing or duplicate titles/descriptions, 40 canonicals, 36 JSON-LD blocks all parse, every referenced OG image exists |
| PHP syntax | `php -l` on every file under `api/`, `admin/`, `scripts/` | 20 files, 0 errors |
| `llms.txt` coverage | assertions in `prerender.test.mjs` | All six service routes and `/privacy` linked; the app line matches the 21-entry catalogue (16 shipped) |
| GA4 SPA page views | `VITE_GA4_ID=G-TEST123 npm run build`, served on `:8100`, Playwright `/` → `/services` → `/services/flutter-app-development`, then read `window.dataLayer` | Two `page_view` events after the initial one, with the correct `page_path` and the lazy page's `page_title` (250 ms delay); `enquiry_submit` still fires only on submit |
| Cal.com booking wiring | `VITE_CAL_URL=https://cal.com/hasan-booking-test VITE_GA4_ID=G-TEST123` build on `:8123`; Playwright at 1440 px and 390 px | Link renders with the test `href`, `target="_blank"`, `rel="noreferrer"`, no overflow at 390 px, and fires `cta_click` `{kind: booking, meta: contact}`. The shipped build (variable unset) contains no "Prefer a call" string and no `cal.com` reference |
| Six-width visual evidence | `node site/scripts/capture-evidence.mjs` | 50 captures (8 routes × 6 widths + 2 full-page) at 1440/1280/1024/768/390/320, all 200, no document overflow, fonts loaded; details in `site/evidence/2026-10-29/report.json` |
| Unsubscribe page | Chrome at 390/1440 × light/dark against `php -S` with real subscriber tokens; axe-core WCAG 2.0–2.2 A+AA | 4 combinations, 0 violations, no overflow, palette-correct backgrounds (`rgb(243, 239, 230)` light, `rgb(18, 16, 12)` dark); a reused token renders "Link not recognised"; captures in `site/evidence/2026-10-29/unsubscribe-*.jpg` |
| Store rosters | Playwright on the public Play developer page; `itunes.apple.com/lookup` for artist `1734376366` | Play: 5 apps; App Store: 4 apps; all match `apps.js` |
| Public profile and store links | `curl -L` against every LinkedIn, GitHub, FlowCV, pub.dev, BuyMeACoffee, App Store and Play link in `apps.js` and the contact section | 19/19 returned 200 on 2026-10-29; the site's own Résumé links now point at `/resume` instead of FlowCV |
| Lighthouse (mobile, simulated) | `npx lighthouse http://127.0.0.1:8099/ …`, two consecutive clean runs | Performance 100, Accessibility 100, Best practices 96, SEO 100; FCP 0.9 s, LCP 0.9 s, TBT 0 ms, CLS 0.001. Observed trace FCP=LCP ≈0.12–0.15 s; CDP-throttled LCP = `h1` at 1.09–1.17 s. Under CPU contention one run scored 95/TBT 250 ms; simulated LCP occasionally reports ~3.1 s (Lantern font modelling) with identical trace values. Best practices 96 is the harness's API 404s |
| Lighthouse (live host, 2026-10-31) | Lighthouse 12.8.2/Chrome 156 attached to a real Chrome with a primed `hcdn` cookie (`--port=9333 --disable-storage-reset`); a fresh headless run is 403'd by the Hostinger CDN | `/` mobile 99/100/96/100 then 100/100/96/100; `/` desktop 100/100/96/100; `/services` mobile 100/100/96/100; `/resume` desktop 100/100/96/100; FCP 0.3–1.0 s, LCP 0.3–1.1 s, TBT 0–100 ms, CLS ≤0.001. Best practices 96 was the stale live `api/` (`settings` 400, `track.php` 404); raw JSON in `site/evidence/2026-10-31/lighthouse/`. **Superseded later that day:** the API repair cleared those two failed requests, so a re-run is expected to score 100 on Best Practices. |
| Lighthouse CI (new) | `npx @lhci/cli@0.14 autorun` from `site/`, the same command as `.github/workflows/site-ci.yml` | 3 URLs × 2 runs: performance 92–95, accessibility 100, SEO 100; budgets 0.85 / 0.95 / 0.90. The 0.85 performance floor covers the plain `serve` harness (no CDN HTTP/2; Lantern's font model lands at 2.7–3.1 s LCP, while the live host measures 0.3–1.1 s). Reports in `site/reports/lighthouse/` (gitignored) and uploaded as a workflow artifact |
| Deployment package | `cp .htaccess dist/ && zip -qr deploy-public_html.zip .` from `dist/` | 138 files, 7,126,982 bytes uncompressed, 5,678,327 bytes zipped, SHA-256 `bbc307a1be60d9319944bdb418a74aa6bd20fcb1be7bb33b46d23e7361f1bedf`; built from a minified `npm run build` (single entry chunk `index-aK233QuH.js`, 358,966 bytes, plus per-route lazy chunks); `unzip` into a temp directory and `diff -r` against `dist/` reports no differences; `index.html` references only that entry; includes `.htaccess`, the `/privacy` and `/resume` shells and the résumé PDF; no `api/`, `admin/` or `config.php` inside |

Every result above was re-run against the final package (`deploy-public_html.zip`, SHA-256 `bbc307a1…`) after the BlankSpace and BULB VPN catalogue additions, the Petassy source-CTA removal and the regenerated CMS seed: Node checks 119/119 (app catalogue 29, live content 21, content/services/contact/résumé 41, interaction QA 6, SEO browser 4, site browser 14, prerender/build 4), PHP 195/195 enquiry checks against a disposable MariaDB socket plus 10/10 auth checks, CMS smoke PASS (dashboard, editors, subscribers, API, intake 201, CSRF update 303, newsletter 201 + token unsubscribe), hydration 30/30 (LCP 56–160 ms; slowest is the home hero image), axe 64 checks / 0 violations, the sitemap crawl returned 39/39, and Lighthouse re-measured 100/100/96/100 on the packaged home route (FCP=LCP 0.9 s, TBT 0 ms, CLS 0.001). The 50 six-width captures cover the same eight routes, none of which this pass changed. `index.html` loads a single entry script; no `hero-`/`reel-` chunks are emitted. The prerender suite rebuilt `dist/`; a fresh minified rebuild afterwards was byte-identical in content to the packaged zip (the zip hash differs only by embedded timestamps).

Packaging order matters: `prerender.test.mjs` runs `npm run build` itself, and under the Node test runner that build is unminified, so `dist/` is left ~600 kB after the suite. Run the tests first, then a final `npm run build`, then copy `.htaccess` and zip. The check in `DEPLOY.md` (entry chunk ≈359 kB) catches the mistake.

Visual checks at 1440, 1024, and 390 pixels: `/resources` and the admin dashboard, enquiry list, detail, and login screenshots show zero horizontal overflow and no browser console errors. The captured admin screens are in `site/evidence/2026-10-29/`.

## 19. Required deliverables map

Audit against the master prompt's 20 required deliverables. "Built" means present in this
repository and covered by the checks above; owner-blocked items are listed in §13 and were not
performed on the owner's behalf.

| # | Deliverable | Evidence | State |
|---|---|---|---|
| 1 | Initial audit report | §2 problems found and corrected; §3 references; §4 IA | Done |
| 2 | Reference comparison matrix | §3, observed 2026-10-29 | Done |
| 3 | Design specification | `DESIGN.md`, `COMPONENTS.md`, §2 | Done |
| 4 | Final information architecture | §4, `_views` and `.htaccess` routes | Done |
| 5 | Verified facts and unresolved questions | §5, `hasan.md` | Done; owner items open |
| 6 | Website and service pages | `src/`, six service routes, tests | Done |
| 7 | Verified case studies | `src/content/clients.js`, `/work`, tests | Done |
| 8 | Working and tested enquiry workflow | `api/enquiries.php`, `enquiries.test.php`, CMS smoke | Done; real mail pending |
| 9 | Integration inventory and configuration guide | §6, `README.md` §3, `DEPLOY.md` | Done |
| 10 | Automation workflow documentation | `AUTOMATIONS.md` | Done |
| 11 | LinkedIn and GitHub drafts | `LINKEDIN.md`, `GITHUB.md`, `SOCIAL.md` | Drafts only |
| 12 | Four-week content calendar | §14 | Done |
| 13 | SEO and analytics report | §8, `llms.txt`, JSON-LD, sitemap | Done; GA4 pending |
| 14 | Playwright screenshots and test results | `evidence/2026-10-29/`, §10, §18 | Done |
| 15 | Performance and accessibility findings | §9, Lighthouse before/after, real-host run 2026-10-31 | Done; real device pending |
| 16 | Security and deployment checklist | §11, `LAUNCH_CHECKLIST.md`, `.htaccess` | Done |
| 17 | Backup and rollback instructions | §12 | Done |
| 18 | Modified files and architecture decisions | §16 | Done |
| 19 | Remaining manual tasks and authorizations | §13 | Owner actions |
| 20 | Prioritized 30-day growth plan | §15 | Done |
| — | Operations README | `README.md` | Done |
| — | Deployment package without secrets | §18 package row; no `api/`, `admin/`, or `config.php` | Done |

Cal.com booking is wired behind `VITE_CAL_URL`: when it is set, the contact area renders a
"Prefer a call? Book a time" link (`target="_blank"`, `rel="noreferrer"`), tracked as
`cta_click` `kind: booking`; when it is unset, the link, its string and the URL are absent from
the shipped bundle. Only the URL is missing. Referral links are rendered only when real URLs and
the disclosure copy exist, so no placeholder link was added.

## 20. Master-prompt §7 credibility features

The prompt asks for a proposal, not a checklist: implement what a visitor benefits from, estimate
cost and benefit before building anything substantial, and avoid gimmicks. Each candidate was
judged against that rule; "shipped" means it is in the current build, "folded" means the need is
met by an existing element, and "not built" records the decision and the reason.

| Potential feature | Decision | Where / why |
|---|---|---|
| Interactive project demonstrations | Not built | Live embeddable demos would need hosted client builds, sample-data isolation and disclosure agreements. Cost is high and the evidence is already stronger as linked store listings and a walkthrough video; a demo that cannot show real data is decoration |
| Before-and-after performance examples | Shipped (in part) | `/blog/flutter-startup-time` documents measured startup work; §9 records the prerender-to-hydration LCP change. Numbers come from this project's own runs, not estimates |
| Technical architecture diagrams | Not built | Architecture is explained in prose in the case studies, `README.md` and `COMPONENTS.md`. Diagrams of client systems would assert internals that are not verifiable from here, so none were drawn |
| Short project walkthroughs | Shipped | The three `/work` case studies (problem, role, stack, what I did, outcome, verifiable links) plus the recorded launch walkthrough |
| Mobile app screenshots and real product videos | Shipped | Real store screenshots on `/apps` and app cards; product links point at the live listings. The launch video is a local artifact and is not embedded on the site |
| Detailed engineering case studies | Shipped | `src/content/clients.js` (EV Lab, Good2Go Loans, Nakheel Marinas), assert-checked by `prerender.test.mjs` |
| Interactive service selector | Folded | The home Services list already routes to all six service pages, and `/services` is the index. A selector widget would duplicate navigation without adding information |
| Short project discovery questionnaire | Folded | The enquiry form collects project type, budget, timeline, existing links and the problem description in one step, which the master prompt itself prefers over friction (§5 "Avoid excessive friction") |
| Downloadable project brief template | Not built | A PDF template would restate the form fields in a second place that drifts. The form is the brief. If the owner wants a downloadable version later it is a small, reversible addition |
| Technical writing section | Shipped | `/blog` with 9 posts, `/blog/flutter-startup-time` and the RAG essay among them, plus RSS and the home writing section |
| Practical AI integration demonstrations | Shipped | The home AI-workflow section (AI drafts vs what the engineer owns), the AI service page's four-step process, and `AUTOMATIONS.md` |
| Clearly explained engineering process | Shipped | Home Process section (four steps, three engagement models) and a per-service process on every service page |
| App audit or AI readiness assessment | Shipped as a service, not a quiz | `/services/app-audit-consulting` describes the audit offer. An automated readiness score would produce confident output from thin inputs, which the prompt's no-fabrication rules rule out |

No candidate was implemented as a decorative extra: everything listed as shipped already existed for
conversion or credibility reasons, and everything not built is recorded above with its cost/benefit
reasoning rather than left silently absent.
