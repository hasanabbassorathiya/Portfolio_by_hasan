# Launch & Digital Marketing Checklist — hasanabbassorathiya.tech
Owner: Hasan Abbas Sorathiya · Reference craft: pawan.app · Stack: Vite+React static + PHP/MySQL API on Hostinger
Legend: ⬜ todo · ✅ done · N/A not applicable

## 1. Analytics & Tracking
- ⬜ Google Analytics 4 property + data stream (web) for hasanabbassorathiya.tech
- ⬜ If GA4 is enabled and you serve visitors in jurisdictions that require prior consent (EU/UK), decide on a consent gate before launch; none is implemented, and GA4 stays absent from the build while `VITE_GA4_ID` is unset
- ✅ GA4 via `gtag.js` loaded **deferred/after first paint** — `initAnalytics()` paints first, appends gtag on idle (`src/lib/analytics.js`)
- ✅ Consent-aware: `anonymize_ip: true` in gtag config
- ✅ Custom events wired and click-verified in-browser: `page_view` on the initial load and every client-side route change (GA4 does not see SPA navigation on its own), `cta_click` (header/hero/contact/speaking/post/blog/apps/booking), `project_open`, `store_click`, `resume_open`, `outbound_click`, and `enquiry_submit` (`category`: `project` / `recruitment`, plus the selected `type`, no personal data) (`src/lib/analytics.js`, `src/App.jsx`)
- ✅ `newsletter_signup` fires from the signup component on success (`source`: `home-writing` / `blog-index` / `post:<slug>`); ⬜ confirm in DebugView once the real GA4 ID is set
- ⬜ Funnel definition: visit → hero read → project chapter opened → CTA → contact/book
- ✅ `section_view` scroll milestones via IntersectionObserver on home sections (about/apps/writing/work/speaking/contact), once per session
- ⬜ Microsoft Clarity (heatmaps/session replay, privacy-friendly) or PostHog alternative
- ✅ `robots.txt` + `sitemap.xml` submitted to Google Search Console — URL-prefix property `https://hasanabbassorathiya.tech/` verified 2026-11-03 by HTML file (`google9d7e6a4ddebdf66b.html`, 53 bytes, served 200 with a 404 control on a guessed sibling name), `/sitemap.xml` submitted same day → status Success, 49 discovered pages (`evidence/2026-11-03/live/gsc-verification.txt`). ✅ Bing Webmaster Tools opened through Google SSO as the site-owning account `hasanabbassorathiya12@gmail.com` (the identity question is resolved) and the site was imported from Search Console with the read-only `webmasters.readonly` scope — "Site addition successful, imported 1 sites"; `/sitemap.xml` came across with it and shows Imported / Processing, 1 known sitemap, 0 errors, 0 warnings (`evidence/2026-11-03/live/bing-webmaster-import.txt`). ⬜ re-check Bing sitemap status after processing finishes (this is signed-in account state, so it needs a browser, not curl)
- ✅ `robots.txt` disallows `/admin/` + `/api/`, points to the sitemap; `sitemap.xml` lists all 42 routes, every one returns 200 on the harness, and `sitemap.xml` + `rss.xml` (9 items) are now generated from the post/app content at build time and well-formed XML
- ⬜ GA filters: exclude own devices (or use `debug_mode` only locally)
- ⬜ UTM conventions documented for future campaigns (`utm_source=<platform>&utm_campaign=launch2026`)

## 2. SEO & Metadata
- ✅ Title/meta description per page — `useSeo` + prerendered shells for blog posts, apps, `/blog`, `/apps`
- ✅ JSON-LD: `Person` + `WebSite` on home, `BlogPosting`, `MobileApplication`, `CollectionPage`/`ItemList`, `Blog` on their routes
- ✅ OG image 1200×630 + twitter `summary_large_image` — 27 generated cards in `public/og/`
- ✅ Canonical URL, favicon set (SVG + 192/512 PNG + apple-touch, ico redirected), manifest.webmanifest served as `application/manifest+json`
- ✅ Exactly one `h1` per route and alt text on every image — `npm run a11y` (axe-core, 19 routes × 1440/390 × light/dark) reports 0 violations against WCAG 2.0/2.1/2.2 A+AA, and the same run fails on a missing/duplicate `h1` or a skipped heading level inside `main` (0 such issues in all 76 checks)
- ✅ Core Web Vitals budget (local harness, 2026-10-29): LCP 0.9 s, TBT 0 ms, CLS 0.001 under Lighthouse mobile simulated throttling, reproduced twice; CDP-throttled observation puts the real `h1` LCP at ~1.1 s; total home weight 414 KB (was 1.6 MB before webp art and bundle splitting); ⬜ field data re-check in Search Console after launch

## 3. Content & Conversion
- ⬜ Hero one-liner matches positioning (Flutter & Dart + AI + backend/API integrations)
- ✅ Every featured app: store deep-links, feature bullets, screenshots — all 24 external app/repo/store links return 200 (incl. the App Store developer page and Google Play publisher page, whose URLs in hasan.md were dead and got corrected)
- ✅ Résumé lives on the site: `/resume` (web version, Person JSON-LD, sitemap + llms.txt) plus a 3-page A4 PDF generated from the same page by `npm run resume:pdf`; PDF opens over HTTPS, link annotations verified, `resume.test.mjs` green
- ✅ Contact CTA (mailto + LinkedIn) on CTA section, hero, header, and footer
- ✅ Email capture on home Writing, `/blog`, and every essay → `POST /api/subscribe.php` (honeypot, 5/IP/hour, peppered IP hash, per-reader unsubscribe). Success, failure-fallback, label wiring, and payload verified locally against mocked 201/500 responses; production insert still unverified — needs a real address against a live `subscribers` table (not written with a fake address). The PHP itself is now proven deployed: 2026-11-16, `GET /api/subscribe.php` renders the unsubscribe view ("Link not recognised — Hasan Abbas Sorathiya", 200, and distinct from the SPA's own 404 control), and `POST` with an invalid address returns the same `422 {"error":"valid email required"}` the local source emits before any DB write
- ✅ Subscriber admin: list, copy all, CSV export, per-reader unsubscribe link, delete (`admin/subscribers.php`); email sending stays manual (BCC + unsubscribe link)
- ⬜ Testimonials (2–3 real quotes) + stats with real numbers only

## 4. Digital Marketing
- ✅ Launch campaign rendered 2026-11-03 via OpenMontage (not the brag skill): 45s master reel in 16:9/1:1/9:16, four 9:16 project clips, 20s consulting cut in 1:1/9:16 — nine silent caption-led files in `marketing/2026-11-03/out/`, evidence and defects in [../marketing/2026-11-03/DELIVERY.md](../marketing/2026-11-03/DELIVERY.md). ✅ week-1 distribution published: LinkedIn post (2026-11-14, edited in place to the marketing-psychology rewrite) + LinkedIn Featured order, X (`2121673169467580557`), GitHub profile README with the re-made 24-second master, and YouTube (`p0KscFpmSGg`, https://youtu.be/p0KscFpmSGg, 2026-11-15) — verified live from outside each session; the YouTube custom thumbnail stays unset behind YouTube's phone-verification gate, see `SOCIAL.md`
- ✅ LinkedIn launch post (story format: problem → craft → link) + personal profile update w/ site URL — published 2026-11-14 09:00 Dubai with the reel attached, then edited in place to the marketing-psychology rewrite in `SOCIAL.md` §1A (LinkedIn marks the post "Edited"; impressions were preserved). The Featured ordering per `LINKEDIN.md` §5 is live and verified.
- ✅ GitHub profile README links the site — `https://raw.githubusercontent.com/hasanabbassorathiya/hasanabbassorathiya/main/README.md` returns 200 and line 41 is `- [Portfolio](https://hasanabbassorathiya.tech)`; the same URL also renders on the profile page. ✅ the "Resume" link now points at `https://hasanabbassorathiya.tech/resume`, not FlowCV — profile-repo commit `1c1ad35`; the reel embedded above it is the re-made 24-second master (commit `ca65548`), byte-identical to the local `brag-output-2026-11-14-004922/brag.mp4` (sha256 `7b1381e630b477b335862edcfb40925c80f664e05a309a59f49630dcb0b310e7`, 5,213,047 B), and both the asset and `/resume` return 200. Verified 2026-11-15.
- ⬜ OG preview tested (LinkedIn Post Inspector / Twitter card validator) — the tags themselves are verified live 2026-11-16 on 5 routes (`/`, `/apps`, `/resume`, `/blog`, `/community`: `og:title`, `og:description`, `og:url`, `og:image` all present and route-specific); the Post Inspector render itself needs a signed-in browser
- ✅ Share copy: 3 launch variants + 8 essay cross-posts + X versions in `site/SOCIAL.md`
- ✅ BuyMeACoffee kept as support CTA (secondary, not primary): `buymeacoffee.com/hasanabbassorathiya` verified real (200 + `og:title` "HASAN ABBAS SORATHIYA"), rendered only in the footer "Elsewhere" list, now CMS-overridable via `profile.buymeacoffee`
- ✅ Every advertised profile link checked to exist — 8 `sameAs` entries (LinkedIn, GitHub, YouTube, Instagram, Medium, Buy Me a Coffee, Play developer page, App Store developer page) return 200, with a fabricated-handle control returning 404 so the 200 means "exists"; Instagram and Medium needed a signed-in browser because curl only sees a login wall / Cloudflare challenge. Instagram already lists `hasanabbassorathiya.tech` in the profile bio (`evidence/2026-11-03/live/digital-marketing-links.txt`)
- ⬜ Search Console has no social-channel switch: Settings → Associations offers **Google Analytics only** ("No associated services"), and that needs the GA4 measurement ID the owner has not supplied. X / Discord / Reddit / Dev.to / Product Hunt handles were never provided and are not invented

## 5. Technical / Hosting (Hostinger)
- ⬜ HTTPS forced (SSL active, .htaccess redirect), www→apex redirect decided
- ✅ `.htaccess` SPA fallback + prerendered shells + `/api` and `/admin` excluded (verified on local Apache harness)
- ✅ Dependency audit: `npm audit --omit=dev` = 0 production vulnerabilities; full audit's Vite/esbuild advisories affect the local dev server only (static `dist/` is what ships)
- ✅ Gzip/brotli + cache headers: JS 280,996 → 86,745 bytes on the wire; hashed assets immutable
- ✅ `theme-color` meta set (dark default); boot frame now matches the page background exactly
- ✅ 404 page branded (client-side NotFound on unknown routes)
- ✅ Privacy notice at `/privacy` (canonical, sitemap entry, footer + form-consent links) describes exactly what enquiries and newsletter sign-ups store, GA4 anonymisation, retention and the removal path; ⬜ owner reads and approves the wording before launch
- ✅ Newsletter backend verified locally (PHP 8.5 + MariaDB 11.4, scratch DB): signup 201, duplicate idempotent + source update, invalid email 422, honeypot silent, 5/IP/hour cap, unsubscribe deletes the row, admin list/CSV/delete OK, CLI-only first-admin provisioning + Argon2id login + token guard OK
- ⬜ Newsletter live: re-import `api/schema.sql` (adds `subscribers`), upload `api/subscribe.php` + the admin files, then submit a real address
- ⬜ Uptime check (hostinger monitor or external)

## 7. Growth platform (2026-10-30)
- ✅ First-party analytics: `POST /api/track.php` — salted per-day visitor hash, no cookies or raw
  IPs; bot/cross-origin/admin events rejected, `dwell_ms` clamped to 30 min, 120 events/min per
  visitor, 180-day retention; verified against a disposable MariaDB + PHP harness
- ✅ `/admin/analytics.php`: visitors, pageviews, store clicks, enquiries, funnel, top pages,
  referrers, campaigns, devices/browsers, countries, recent events, 7/30/90-day ranges
- ✅ `/admin/settings.php`: GA4, Search Console, IndexNow, Cal.com, Discord, social profiles, OG
  image, announcement, community toggle + UTM campaign builder; secrets stay in `api/config.php`
- ✅ Schema-driven CRUD (`api/entity-schema.php` → `api/crud.php` + `admin/edit.php`) for apps,
  clients, posts, projects, experience, skills, testimonials and profile key/values; media upload
  with MIME sniffing; harness covers create/read/update/delete, CSRF rejection, slug validation,
  publish visibility, ASO persistence
- ✅ Per-item SEO: `seo_title`, `seo_description`, `seo_image`, `noindex` feed app, case-study and
  post metadata; absolute CMS image URLs are normalized
- ✅ IndexNow: key file served at `/<key>.txt`, guarded submit (405 on GET, 422 without key/dotted
  host), sitemap URLs posted to the IndexNow endpoint
- ✅ `/community` page with Discord CTA and newsletter fallback (invite still ⬜ owner input)
- ✅ `site/API.md` + `site/postman/` collection (56 requests, local + production environments) —
  request shapes exercised with curl; the collection has not been run through Newman
- ⬜ Owner-blocked inputs: GA4 measurement ID, Discord invite, Cal.com URL (Search Console no longer needs a token — the URL-prefix property is verified by HTML file)
- ⬜ Deploy of the v2 build (awaiting owner approval; never overwrite `api/config.php`)

## 6. Pre-launch QA
- ✅ Keyboard navigation (headless Chrome, 1440px + 390px): 28/28 home stops show a visible ring and stay in view, skip link focuses `#main`, subscribe input is labelled and submits with Enter, mobile menu traps nothing, closes on Escape, and returns focus to the toggle
- ✅ Color contrast AA — Lighthouse accessibility 100 after fixing muted-text opacity and link underlines
- ✅ axe-core WCAG 2.1 A/AA sweep (headless Chrome, local harness, 2026-10-28): 0 violations across all 18 sitemap routes; fixed `label-content-name-mismatch` on the header logo (all routes) and `color-contrast` on `/blog` index numbers; per-route title, description, canonical, OG tags, single h1, `lang`, and JSON-LD valid on every route; 0 console errors
- ✅ axe re-run after the 2026-10-29 contrast and LCP fixes: 64 checks (16 routes × 1440/390 × light/dark), 0 violations; artifact refreshed at `evidence/2026-10-29/a11y.json`
- ✅ axe re-run on the 2026-10-30 build after `/community` landed and Klix/Urban Ledger were added: 76 checks (19 routes × 1440/390 × light/dark), 0 violations; artifact at `evidence/2026-10-30/a11y.json`
- ✅ Hydration sweep on the 2026-10-30 build: 34 checks across 17 routes × light/dark, 0 failures; artifact at `evidence/2026-10-30/hydration.json`
- ✅ Firefox 143 + WebKit 26.5 (Safari engine) smoke suite on the local harness: home, `/blog`, essay, `/apps`, app case study, and 404 all render; 0 console/page errors; 0 horizontal overflow at 1440px and 390px; Lenis wheel scroll and anchor nav to `#about` work; deferred essay list loads; mobile menu opens, locks body scroll, closes on Escape, and returns focus
- ⬜ Real-device pass on iOS Safari and Android Chrome (WebKit/Firefox engines are covered; an actual phone check is still worth one minute before launch)
- ✅ No horizontal scroll — 5 routes × 6 widths (360/390/414/768/1024/1440), 30/30 clean
- ✅ Reduced motion: with `prefers-reduced-motion: reduce` emulated at 1440 px, `/`, `/services` and `/privacy` show no marquee animation, `0s` transitions, no hidden-opacity content, no boot overlay and no overflow
- ✅ Lighthouse (mobile, local harness, 2026-10-29, two consecutive runs): 100 performance · 100 accessibility · 96 best practices · 100 SEO — FCP=LCP 0.9 s, TBT 0 ms, CLS 0.001; the static harness has no PHP API, so three content 404s lower best practices; production serves them
- ✅ Event payloads verified locally against `window.dataLayer` with a test ID (`cta_click`, `project_open`, `store_click`); ⬜ DebugView re-check after the real `VITE_GA4_ID` is set
- ✅ pawan.app-parity pass: boot frame paints "H S" before JS and fades out after load (verified with JS disabled and enabled); staggered reveals confirmed (16 wrappers start at opacity 0 below the fold, 0 remain hidden in view after scrolling); easter egg live — typing `hire` anywhere opens a dismissible hire card (Escape closes, never triggers inside inputs, fires `cta_click` with `meta: easter-egg`)
