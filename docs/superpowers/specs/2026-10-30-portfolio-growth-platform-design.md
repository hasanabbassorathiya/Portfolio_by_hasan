# Portfolio growth platform — design

Date: 2026-10-30
Status: approved direction (owner answered 4 architecture questions); implementation follows
Owner: Hasan Abbas Sorathiya
Repo: `portfolio` (branch `v2`), web app in `site/`

## Goal

Turn the portfolio into a self-serve growth platform:

1. **CMS that actually covers everything** — full create/read/update/delete for all eight entities, media uploads, publish/order controls, CSRF on every admin write.
2. **First-party analytics + visitor dashboard** — cookieless, no raw IP, bot-filtered, funnel from visit → app view → store click → enquiry.
3. **Digital marketing, SEO and ASO plumbing** — admin-managed settings for GA4 / Search Console / IndexNow / Discord / Cal.com / socials, per-item SEO + ASO metadata, UTM builder.
4. **Complete API guide + importable Postman collection.**
5. **Developer community** — `/community` page backed by a Discord invite from settings, with a newsletter fallback when no invite is set.
6. **Content fixes** — remove "Shia" from Duas & Aamal, reposition from "I build Flutter apps" to mobile engineering (native iOS/Android first, Flutter highlighted), new BULB VPN icon.

## Non-negotiables

- No fake numbers, ratings, testimonials or member counts. Every statistic shown comes from the database or existing verified content.
- Never commit `api/config.php`, `.env`, or any secret. Secrets stay in server env/config; the admin Settings page only stores non-secret IDs.
- Never upload or overwrite `api/config.php` on the live host.
- No live deploy, DB migration on production, DNS change or credential change without explicit owner approval at that moment.
- Don't disturb the owner's Hostinger / Play Console browser tabs.
- Owner-blocked inputs (never invent): Cal.com URL, GA4 measurement ID + consent decision, Discord invite URL, referral URLs, mail credentials, publication/deploy approval.
- All public copy keeps existing verified claims only (7+ years, 15 apps, 100K+ users).

## Approved decisions

| Question | Decision |
|---|---|
| Analytics | First-party (MySQL) **plus** GA4-ready dual-send, inert until an ID is configured |
| Community | Discord server + `/community` page (invite stored in admin settings) |
| Platform keys | Admin Settings page for non-secret IDs; secrets only in `api/config.php` |
| BULB VPN logo | Bulb fused with shield, cobalt `#1d3cff` on ink `#12100c` |

## Current state (verified 2026-10-30)

- Public API `site/api/index.php` serves `profile, projects, experience(s), skills, testimonials, clients, apps, posts`; only `apps/clients/posts` are consumed by the front end.
- Admin `site/admin/edit.php` edits only `apps`, `clients`, `posts`. `api/crud.php` already speaks all 8 entities but has no CSRF check (only `enquiries.php` / `subscribers.php` enforce it), no JSON validation, no slug-collision handling, and no media upload.
- Front end hydrates only `apps/clients/posts` (`src/lib/live-content.jsx`); profile/projects/experience/skills/testimonials remain static seeds.
- Auth supports `X-Auth-Token` header or `admin_token` cookie. CSRF = `HMAC-SHA256(pepper, "admin-csrf\0" + token)`.
- No analytics storage, no dashboard, no settings table, no API docs, no Postman collection, no community page.
- Local test rig exists: Apache on `:8099` with real `.htaccess`, PHP 8.5, MySQL/MariaDB binaries installed.
- Site builds as a prerendered SPA: 40 HTML pages, 39 sitemap URLs, hydration via `hydrateRoot`.

## Architecture

```
browser ── /api/index.php (public reads, settings, feed)
        ├─ /api/track.php   (write-only beacon, no cookies)
        └─ /api/*           (admin: auth, crud, upload, enquiries, analytics, indexnow)

/admin/  dashboard · edit (all entities) · analytics · settings · enquiries · subscribers
         └─ shared entity-schema.php  →  drives both edit.php UI and crud.php whitelists
```

### Single source of truth: `site/admin/entity-schema.php`

A PHP array describing every entity — table, label, public view URL, list columns, and fields
(`name, label, type, required, example, group`). Types: `text, textarea, markdown, number, date,
checkbox, json, select, image`. Derived automatically:

- `crud.php` column whitelist, JSON columns, required fields
- `edit.php` list table + editor form (including image picker and JSON validation)
- Field-level validation (types, max length, select options)

Adding a field becomes: one schema entry + one `ALTER TABLE` in the migration file.

### Data model changes — `site/api/v2-schema.sql`

New tables:

- `settings (k VARCHAR(60) PK, v TEXT, is_public TINYINT, updated_at TIMESTAMP)`
- `media (id, path, folder, mime, bytes, width, height, created_at)`
- `analytics_events (id BIGINT PK, ts DATETIME(3), day DATE, visitor CHAR(32), session CHAR(32),
  path VARCHAR(255), event VARCHAR(40), referrer_host VARCHAR(120), utm JSON, device VARCHAR(12),
  browser VARCHAR(24), os VARCHAR(24), country CHAR(2), props JSON,
  KEY(day,event), KEY(day,path), KEY(visitor,day))`
- `analytics_daily (day DATE, path VARCHAR(255), event VARCHAR(40), device VARCHAR(12),
  device_events INT, PRIMARY KEY(day,path,event,device))` — long-term counters after raw rows expire.

Column additions (nullable, no data rewrite):

- `apps.seo JSON`, `apps.aso JSON`
- `clients.seo JSON`, `posts.seo JSON`

Seed (empty values) settings keys: `ga4_id, gsc_verification, indexnow_key, calcom_url,
discord_invite, linkedin_url, github_url, x_url, instagram_url, play_dev_url, appstore_dev_url,
contact_email, default_og_image, community_enabled, announcement`.

### Public API additions

- `GET /api/index.php?entity=settings` → `{entity:"settings", data:{k:v}}`, only rows with
  `is_public = 1`; never secrets.
- Existing entities unchanged; `apps/clients/posts` gain `seo` (object) and `apps` gains `aso`
  (object) in their row payloads.

### Admin API hardening

- `crud.php`: require admin + **CSRF on POST/PUT/DELETE**; validate JSON columns parse; enforce
  required fields and max lengths; return `409` with the conflicting slug on duplicate; `422` with
  field-level detail on validation failure; `profile` supports upsert and delete-by-key.
- `auth.php`: login response includes `csrf` so API clients can perform writes without knowing the
  pepper. Existing cookie flow unchanged.
- `upload.php` (new): multipart, admin + CSRF, ≤8 MB, mime sniffed with `finfo`, raster images only
  (JPEG/PNG/WebP/AVIF/GIF — **no SVG**), optional downscale to 2400 px via GD, unique filename,
  writes to `../media/uploads/<folder>/`, inserts `media` row, returns `{path,width,height,bytes}`.
- All admin responses keep `no-store` + `X-Robots-Tag: noindex`.

### First-party analytics

Client (`src/lib/analytics.js`, extended):

- Startup: read public settings → if `ga4_id`, boot deferred GA4 (build-time `VITE_GA4_ID` still wins).
- Always (unless DNT/GPC): `POST /api/track.php` beacon via `sendBeacon`/`fetch(keepalive)`.
- Session id = random 16-byte hex in `sessionStorage` (ephemeral, no cookie, not persistent).
- Events: `page_view`, `page_leave` (dwell ms, capped 30 min), plus existing hooks
  (`cta_click`, `store_click`, `app_open`, `section_view`, `outbound_click`, `resume_open`,
  `newsletter_signup`, `enquiry_submit`, `project_open`, `community_join`).
- Honor `navigator.doNotTrack === "1"` and `navigator.globalPrivacyControl` → disable both trackers.

Server (`api/track.php`, new):

- POST JSON only; same-origin check (`Origin`/`Sec-Fetch-Site`); 204 always (never leaks internals).
- Visitor id = first 32 chars of `HMAC-SHA256(ANALYTICS_SALT, day|ip|ua)`; salt falls back to the
  auth pepper. **Raw IP is never stored.** Referrer reduced to hostname; `direct` when absent.
- Bot filter (UA patterns incl. headless/crawler/uptime monitors) and per-IP-hash rate limit
  (120 events/min) → silently dropped.
- Event + path allowlists; props whitelisted per event, strings ≤120 chars, no PII keys.
- Writes `analytics_events` + upserts `analytics_daily`. 1-in-200 requests prunes raw rows older
  than 180 days (≤5 000 per pass).
- Skips events from authenticated admins and `/admin/*` paths.

Dashboard (`admin/analytics.php`, new — linked from `dashboard.php`):

- Range 7/30/90 days. KPI cards: visitors, pageviews, top page, store clicks, enquiries, newsletter
  signups. Inline SVG sparkline (no chart library).
- Tables: top pages, top referrers, campaigns (UTM), devices/browsers, countries (only when a
  geo header is present), recent events feed.
- Funnel: visit → app detail → store click → enquiry (per range, per app).
- All queries prepared statements; no `SELECT *` on raw events in loops.

### Settings + growth integrations (`admin/settings.php`)

- Grouped form (Analytics / Search & indexing / Booking / Community / Social / Contact) writing to
  `settings`; URL/ID validation; "used on the live site immediately" notes.
- **IndexNow** button → `api/indexnow.php` (admin + CSRF): ensures `<key>.txt` at web root,
  submits the sitemap URL list to `api.indexnow.org`, returns the HTTP status.
- **Search Console**: meta verification must exist in raw HTML, so the token is injected at build
  time by `scripts/prerender-meta.mjs` from `GSC_VERIFICATION` env. Settings page shows the value to
  paste into `.env.production` and states the rebuild requirement (no false promise of live effect).
- **GA4**: injected at runtime from settings (works without rebuild).
- **UTM builder**: small form composing campaign URLs with copy button.
- Secrets (DB, pepper, SMTP) remain in `api/config.php` and are never rendered in admin.

### Per-item SEO / ASO

- `seo` JSON (`title, description, image, noindex`) editable for apps, clients, posts; consumed by
  `useSeo()` at runtime and by prerender when `CONTENT_SOURCE=live`.
- `aso` JSON on apps: `subtitle, keywords, category, age_rating, promo_text` — the App Store /
  Play listing fields the owner can copy into the consoles; shown in the app editor.
- `scripts/prerender-meta.mjs` gains optional live-content mode:
  `CONTENT_SOURCE=live npm run build` fetches the public API, maps rows through the shared mappers,
  and prerenders real CMS content (SEO for crawlers). Falls back to seeds with a warning.
  Default build stays seed-based (no surprise network dependency).

### Shared mappers

Extract `mapApp/mapClient/mapPost` (+ new `mapProject/mapExperience/mapSkill/mapTestimonial/
mapProfile`) into `src/lib/content-mappers.js`, consumed by both `live-content.jsx` and the
prerender script — one mapping implementation, no drift.

### Full hydration

`live-content.jsx` hydrates all entities:

- `profile` (k/v → hero name, headline, stats, about copy, contact links)
- `projects`, `experience`, `skills`, `testimonials` (sections switch to hooks with seed fallback)
- `apps`, `clients`, `posts` (existing)

Failure of any one entity keeps its seeds; the page never blocks on the API (5 s abort).

### Community

- `src/pages/community.jsx` + route `/community` in `src/lib/pages.js` and the prerender route
  list (sitemap grows to 40 URLs). Nav + footer links.
- Content: who it's for (mobile engineers, Flutter/native devs, AI builders), what happens there
  (code review threads, architecture Q&A, job leads), three rules, one primary CTA.
- CTA target = `discord_invite` from settings. If empty or `community_enabled = 0`: show
  "Opening soon — get notified" with the existing newsletter form. Never a dead or invented link.
- JSON-LD `Organization` with `sameAs` only when the invite exists.

### Content and positioning

- `src/content/apps.js:19` — drop "Shia": "A complete Quran companion app: …".
- Hero / About / services / meta / JSON-LD repositioned to **mobile engineering**: native iOS and
  Android delivery, Flutter as the highlighted cross-platform stack, AI systems behind the product.
  Exact copy written with the copywriting + storybrand-messaging skills; no new claims.
- Files touched: `src/sections/hero.jsx`, `src/lib/seo.js` (title/description/knowsAbout),
  `index.html`, about/services sections, `scripts/prerender-meta.mjs` defaults.
- BULB VPN icon: generate a 1024 master (bulb fused with shield, cobalt on ink), export
  `public/media/apps/bulbvpn/icon-shield.webp` (512) + keep the master in `site/media-src/`.
  Update seed `apps.js` and the production DB row at deploy time.

### API guide + Postman

- `docs/api/API.md`: base URL, auth (cookie **or** `X-Auth-Token`), CSRF flow, every endpoint with
  method/path/params/body/response/error codes, entity field reference, rate limits, examples.
- `docs/api/portfolio.postman_collection.json`: folders Public, Auth, Apps, Clients, Posts,
  Projects, Experience, Skills, Testimonials, Profile, Media, Enquiries, Subscribers, Analytics,
  Settings, IndexNow. Login test script saves `token` + `csrf` into collection variables.
- `docs/api/portfolio.postman_environment.json`: `baseUrl`, `token`, `csrf`, `slug`.

## Security

- Every admin write: cookie/header token **and** CSRF. Fixes the current `edit.php` gap.
- Upload: auth, CSRF, size, mime sniff, extension allowlist, random filename, no SVG, no path
  traversal (`folder` slug-sanitized).
- Output escaping in admin (`htmlspecialchars`), prepared statements everywhere, no user HTML in
  admin tables.
- Analytics ingest: no PII, hashed ids, silent drops, rate limit, same-origin check.
- Public settings entity is whitelist-based (`is_public`), so an accidental secret row cannot leak.
- Postman collection contains no real token or secret; variables only.

## Testing

Local only; production untouched until deploy approval.

1. `php -l` on every PHP file.
2. Local MySQL database + Apache harness on `:8099`: run `schema.sql`, `enquiries-schema.sql`,
   `v2-schema.sql`; verify CRUD for all 8 entities (create → read → update → delete), duplicate slug
   409, bad JSON 422, unauth 401, bad CSRF 403, upload happy path + rejected SVG/oversize.
3. `api/track.php`: valid event stores a row; bot UA / DNT / unknown event / cross-origin are dropped;
   visitor hash is stable within a day and differs across days; no raw IP in the table.
4. Dashboard queries return correct counts for seeded events; funnel math checked by hand.
5. `npm run build` (seeds) and `CONTENT_SOURCE=live npm run build` against the local API; verify 41
   pages (40 + community), sitemap, JSON-LD, hydration check, axe.
6. Newman/Postman run against the local harness (collection imported headlessly).
7. Browser pass on `/community`, `/admin/settings`, `/admin/analytics`, app editor with image upload
   — using a separate Playwright browser context, never the owner's MCP session.

## Rollout (phases)

1. **CMS core** — entity-schema, crud hardening + CSRF, admin editors for all entities, upload,
   shared mappers, full hydration.
2. **Analytics** — track.php + tables, tracker wiring, privacy copy, `/admin/analytics.php`.
3. **Growth plumbing** — settings table/page, public settings, IndexNow, GA4 runtime, SEO/ASO fields,
   UTM builder, API guide + Postman.
4. **Brand & content** — community page, "Shia" removal, mobile-engineering repositioning, BULB icon.
5. **Verification & delivery** — full local test pass, evidence bundle, deploy checklist.
   Production migration (v2-schema + new icon + content rows) happens only after explicit approval.

## Owner-blocked (ship inert, prompt when relevant)

- Discord invite URL (community CTA falls back to newsletter)
- GA4 measurement ID + consent decision
- GSC verification token
- Cal.com booking URL (existing task #17)
- Referral URLs, mail/SMTP credentials
- Deploy approval for this build

## Out of scope

- Server-rendered site (stays prerendered SPA).
- Real-time chat inside the site (Discord owns that).
- A/B testing runtime, popups, paid-ad integrations.
- Rewriting historical posts or client case studies.
