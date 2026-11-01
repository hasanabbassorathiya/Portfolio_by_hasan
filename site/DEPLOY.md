# Deploying to Hostinger — hasanabbassorathiya.tech

## One-time prep
1. **MySQL DB** (cPanel → MySQL Databases): create DB + user, then import, in this order:
   `api/schema.sql`, `api/v2-schema.sql`, `api/seed.sql`, `api/seed-content.sql`,
   `api/enquiries-schema.sql`, `api/migrate-2026-11-01-social-posts.sql` (via phpMyAdmin Import).
   Every statement is `CREATE TABLE IF NOT
   EXISTS` / nullable `ALTER`, so re-importing later only adds what is missing — including
   `settings`, `media`, `analytics_events`, `analytics_daily`, the flattened `seo_*`/`aso_*`
   columns, and the `subscribers`/`clients`/`apps`/`posts`/`social_posts` tables. `seed-content.sql`
   is generated from the site content with `npm run seed:sql` and upserts by slug; re-import it
   after content changes (that is also how the "Shia" wording fix reaches an existing database).
2. **Uploads directory**: create `public_html/media/uploads/` and make it writable by PHP
   (0755 is enough on Hostinger; 0775 if the API runs as a different user). `api/upload.php`
   writes library images here and records them in `media`.
3. **First admin** (CLI on the server over SSH, once): `php site/scripts/create-admin.php` —
   interactive email prompt, then a hidden password prompt, or pipe exactly two lines (email,
   password) from a secret manager. Web registration returns `403` by design, so the old
   `auth.php?action=register` call no longer works. Do this **before** exposing the site publicly.
4. **API config**: copy `api/config.sample.php` → `api/config.php`, fill DB creds + `AUTH_PEPPER` (`php -r "echo bin2hex(random_bytes(32));"`). Add `SOCIAL_WEBHOOK_SECRET` (another 32+ byte secret) when the social feed should accept writes; leave the placeholder and `/api/social.php` stays disabled. `config.php` is gitignored — never commit it and never overwrite the live copy when uploading.
5. **GA4**: create property → copy the Measurement ID. Either paste it into **Admin → Settings → GA4 measurement ID** (applies on the next page load, no rebuild) or set `VITE_GA4_ID=G-XXXXXXX` in `site/.env.production` for the build-time default.
6. **Cal.com** (optional): paste the booking URL in **Admin → Settings → Cal.com booking URL**; the booking CTA appears only when it is set.
7. **Search Console**: put the verification token in **Admin → Settings**, then set `GSC_VERIFICATION` in `site/.env.production` and rebuild — the meta tag has to be in the raw HTML.
8. **IndexNow**: generate 64 hex characters in **Admin → Settings**; the key file `/<key>.txt` is written automatically and "Submit sitemap" pushes the URL list to Bing/Yandex/Seznam.
9. **Discord community**: paste the invite in **Admin → Settings → Discord invite URL**; without it `/community` shows the newsletter fallback.

Build-time variables are listed with empty placeholders in `site/.env.example`; copy it to `site/.env.production` and fill only what you have. Everything in Admin → Settings is stored in the `settings` table and needs no rebuild (except the Search Console token).

## Upload layout (public_html)
```
public_html/
├── .htaccess                ← from site/ (SPA fallback + route shells + cache + security headers)
├── index.html, blog.html    ← from site/dist/
├── apps.html                ← pre-rendered /apps index shell (title/OG/JSON-LD)
├── work.html                ← pre-rendered /work index shell (clients + case studies)
├── activity.html            ← pre-rendered /activity shell (noindex social feed; not in sitemap)
├── resume.html              ← pre-rendered /resume shell (web résumé)
├── hasan-abbas-sorathiya-resume.pdf  ← from `npm run resume:pdf`, generated from /resume
├── _views/blog/*.html       ← pre-rendered post shells; deliberately outside /blog and /apps
├── _views/apps/*.html       ← per-app shells; kept off /apps/<slug> so the public URL has no
│                              matching directory (avoids mod_dir 301s)
├── _views/work/*.html       ← per-client shells (EVLAB, Good2Go Loans, Nakheel Marinas)
├── assets/                  ← hashed JS/CSS from site/dist/
├── fonts/                   ← from site/public/
├── media/apps/              ← icons/screenshots (from site/public/media/apps/)
├── og/                      ← 1200×630 share cards per essay/app (`npm run og`)
├── api/                     ← site/api/  (php files only)
│   ├── bootstrap.php, config.php, index.php, auth.php, crud.php, entity-schema.php,
│   │   subscribe.php, enquiries.php, enquiry-store.php, upload.php, track.php, indexnow.php,
│   │   social.php, social-lib.php
│   └── schema.sql, v2-schema.sql, seed.sql, seed-content.sql, enquiries-schema.sql,
│       migrate-2026-10-31-live.sql, migrate-2026-11-01-app-catalogue.sql,
│       migrate-2026-11-01-social-posts.sql
├── media/uploads/           ← created by the owner, writable by PHP (upload library)
└── admin/                   ← site/admin/ (PHP dashboard, served outside the SPA)
    └── index.php, dashboard.php, edit.php, subscribers.php, enquiries.php,
        analytics.php, settings.php, guard.php, logout.php, admin.css
```
`/blog` is served from `blog.html`, `/apps` from `apps.html`, `/work` from `work.html`, and
`/apps/<slug>` / `/work/<slug>` from `_views/apps/…` and `_views/work/…`. `/activity` is served
from `activity.html`; it is `noindex` and deliberately absent from `sitemap.xml`. App images live
under `/media/apps/…`, client logos under `/media/clients/…`. No physical route directories
exist, so Apache never issues a directory-slash 301.

## Fastest path — File Manager (no SSH)
`site/deploy-public_html.zip` is built from `dist/` **plus `site/.htaccess`** and contains no
`api/` or `admin/` files, so the live PHP panel and `config.php` are untouched. Current bundle
(2026-11-01, incl. the six new app profiles): 196 files (8,804,777 bytes / 8,599 KB uncompressed; 7,060,573 bytes / 6.9 MB zip), SHA-256 `7ef121cbb6c52888dba2fec7ea350b21bc8187b693c533be7f8b253eb89ab022`.
Because the zip is static-only, the newsletter forms need the two PHP files and one table
described under **Newsletter** below; until those exist they fall back to a mailto message.
1. hPanel → **Files → File Manager** → open `public_html`.
2. **Upload** `deploy-public_html.zip`, then right-click → **Extract** → overwrite existing files.
3. Delete the zip afterwards, then hard-refresh. `/blog`, `/blog/<slug>`, `/apps`, and
   `/apps/<slug>` should all return 200 instead of the old 404.

## CMS (all site content)
`/apps`, `/work` and `/blog` render from `src/content/*` at build time and then replace those
seeds with rows from `/api/index.php` at runtime. A catalogue entry that exists only in the
content files therefore disappears from the live page after hydration. When an app or post is
added, run `npm run seed:sql` and import the regenerated `api/seed-content.sql` (upsert on
`slug`) so the API returns the same rows the static HTML was built from.
`/admin` edits every content entity — profile, projects, experience, skills, testimonials,
clients, apps, and posts — through `api/crud.php` behind token auth. The editor at
`admin/edit.php` renders the right fields per entity, validates JSON columns, toggles
`published`, and deletes with confirmation. Upload `api/crud.php`, `api/index.php`,
`admin/edit.php`, and `admin/admin.css` alongside the schema, then re-import
`api/seed-content.sql` so the three client case studies, twenty-one apps, and nine
essays appear in the admin lists. `npm run seed:sql` regenerates that file from
`src/content/` after content edits.

## Catalogue migration (2026-11-01)
`api/migrate-2026-11-01-app-catalogue.sql` inserts the six app rows that previously
existed only in `src/content/apps.js` — EVLAB, Good2Go Loans, Nakheel Marinas,
Automover TMS, Kokoro Michi, ChucklePlay — and updates `profile.stats_json` to
21 app profiles. It upserts on `slug`, leaves the existing fifteen rows' ids alone,
and is safe to re-run. Apply it before deploying the 2026-11-01 bundle: without the
rows, runtime hydration replaces the seed catalogue with the fifteen CMS rows and
the six new profiles disappear from `/apps`.

## Social activity feed (2026-11-01)
`/activity` shows posts sent to the site's signed webhook. The site side ships in this branch:
`api/migrate-2026-11-01-social-posts.sql` creates `social_posts`; `api/social.php` accepts the
webhook (POST only, `SOCIAL_WEBHOOK_SECRET`, dedupes on `external_id`); `api/index.php?entity=activity`
serves the newest 50 published rows; the React build ships `/activity` and `activity.html`. The
footer link appears only after at least one row is live.

Deploy order: apply the migration → upload `api/social.php` + `api/social-lib.php` → provide
`SOCIAL_WEBHOOK_SECRET` in the live `api/config.php` (edit in place; never replace it) or upload
`api/social-secret.php` returning the same 32+ character string → upload the rebuild → send one test
POST → check `?entity=activity` and `/activity`. Keep the secret file out of git and the static bundle.

No scheduler is hosted on this plan. Any tool that can send JSON — curl, n8n, Make, Zapier, or a
cron script — can publish with the shared secret; the feed stays empty until the first signed POST
arrives.

## Newsletter (email capture)
Signup forms on the home Writing section, `/blog`, and every essay post to `/api/subscribe.php`
and store one row per address in `subscribers`. To turn them on:
1. Re-import `api/schema.sql` (safe: `CREATE TABLE IF NOT EXISTS`) so the `subscribers` table exists.
2. Upload `api/subscribe.php` next to the other API files.
3. Upload `admin/subscribers.php`, `admin/dashboard.php`, and `admin/admin.css` to see the list,
   copy all emails, download a CSV, copy each reader's unsubscribe link, or delete a row.

The endpoint validates the address, ignores a hidden honeypot field, caps new addresses at
five per IP per hour (peppered hash, never the raw IP), and answers duplicates idempotently.
`/api/subscribe.php?unsubscribe=<token>` deletes that row. Nothing is sent automatically — email
subscribers yourself (BCC) and include their unsubscribe link.

All of the above was exercised on 2026-10-28 against PHP 8.5 + MariaDB 11.4 on a scratch database:
signup 201, duplicate idempotent, invalid email 422, honeypot ignored, 5/IP/hour cap, unsubscribe
deletes the row, and the admin list/CSV/delete work. The 2026-10-29 auth suite adds closed web
registration and CLI-only first-admin provisioning.

## Enquiries (lead capture)
The contact form and service CTAs post a durable enquiry; the site never sends mail from a web
request. To turn the workflow on:
1. Import `api/enquiries-schema.sql` (safe to re-run).
2. Upload `api/enquiries.php` and `api/enquiry-store.php` with the other API files, and
   `admin/enquiries.php` with the admin pages.
3. Upload `scripts/enquiry-worker.php` **outside** `public_html` (for example `~/portfolio/site/scripts/`),
   or keep `/scripts` denied by `.htaccess`.
4. Set `ENQUIRY_OWNER_EMAIL` and `ENQUIRY_FROM_EMAIL` in the server environment, then run
   `php site/scripts/enquiry-worker.php` once as a dry run and once with `--send` to an address you
   control. Confirm arrival before adding cron.
5. Add the cron entry every 10–15 minutes:
   `ENQUIRY_OWNER_EMAIL=... ENQUIRY_FROM_EMAIL=... php site/scripts/enquiry-worker.php --send`

Details, retry rules, and the response contract are in `AUTOMATIONS.md` §2. Admin responses carry
`no-store`, `noindex`, `nosniff`, `Referrer-Policy: no-referrer`, and a restrictive CSP.

## Growth platform (v2)
1. Import `api/v2-schema.sql` (settings, media, analytics tables, SEO/ASO columns). Safe to re-run.
2. Upload the new/updated API files: `bootstrap.php`, `auth.php`, `index.php`, `crud.php`,
   `entity-schema.php`, `upload.php`, `track.php`, `indexnow.php`.
3. Upload the new/updated admin pages: `dashboard.php`, `edit.php`, `analytics.php`,
   `settings.php`, `admin.css`.
4. Create `public_html/media/uploads/` and make it writable by PHP.
5. Open `/admin/settings.php` and fill only what you own (GA4, Search Console, IndexNow, Cal.com,
   Discord, social profiles). Blank means the feature is off — never a broken link.
6. Build campaign links under **Settings → UTM campaign builder**; they show up under Campaigns in
   `/admin/analytics.php`.

`api/track.php` keeps a salted per-day visitor hash (no cookies, no raw IPs), ignores bots and admin
sessions, rate-limits 120 events/minute per visitor, and prunes raw events after 180 days
(`analytics_daily` keeps the totals). Nothing leaves the server unless a GA4 ID is set.

## Production API repair (2026-10-31)
The live install predates the growth-platform and enquiry migrations, so the public site's
contact form, newsletter, and analytics calls returned 404/400 while the API code on disk was
still the older build. Repair an existing install in this order:
1. Import `api/migrate-2026-10-31-live.sql` via phpMyAdmin. It is additive and idempotent:
   creates only missing tables (`settings`, `login_throttles`, `media`, `analytics_events`,
   `analytics_daily`, `subscribers`, `enquiries`, `enquiry_outbox`, `enquiry_ip_locks`) and adds only missing
   `seo_*`/`aso_*`, `experiences.summary/points` columns and the `uq_experience`/`uq_skill`
   indexes after checking `information_schema`. It never drops columns or rows; if duplicate
   rows exist the unique index is skipped with a warning instead of deleting data. Re-running it
   is safe, and it works on both a fresh database and an install that already has part of v2.
2. Upload the PHP files from `site/deploy-api-2026-10-31.zip` into `public_html/api/`
   (11 files: `bootstrap.php`, `auth.php`, `index.php`, `crud.php`, `entity-schema.php`,
   `subscribe.php`, `enquiries.php`, `enquiry-store.php`, `upload.php`, `track.php`,
   `indexnow.php`; SHA-256 `95df8bd9b7d4f6701587d9d8092666faee671528399eae9b07d7c0f3955bb378`).
   The bundle contains no `config.php`, no `.htaccess`, and no SQL — the live `config.php` must
   never be overwritten, and the existing `.htaccess` denies `config.php`/`*.sql`/`*.zip`.
3. Verify over HTTPS: `/api/index.php?entity=settings` returns 200 JSON, `/api/track.php` answers
   204, `GET /api/enquiries.php` answers 405, and a real contact submission returns 201 with a
   32-hex reference (it also needs `enquiries` imported first). Mail delivery still requires the
   worker cron from **Enquiries** above; the API only queues outbox rows.
4. Newsletter, analytics, and admin pages then work without a rebuild — the deployed bundle
   already calls these endpoints. No `config.php` edit and no `AUTH_PEPPER` rotation are involved.

The migration and API code were exercised on 2026-10-31 against MariaDB 11.4.13 on a scratch
database (simulated live schema twice, fresh install twice, duplicate-row guard, settings/apps
reads, enquiry 201 + owner/ack outbox rows, cross-origin 403, GET 405, subscribe/unsubscribe,
analytics insert), with `php -l` clean on every file. Applying it to production changes schema
and code only; it sends no mail and invents no settings values.

## Steps
```bash
npm run build                        # in site/ — also emits per-route meta shells
npm run resume:pdf                   # regenerate the PDF from the fresh build (writes public/ and dist/)
cp .htaccess dist/.htaccess          # vite build empties dist/, so the htaccess must be re-copied
rm -f deploy-public_html.zip && (cd dist && zip -qr ../deploy-public_html.zip .)
# Before uploading, confirm `dist/assets/index-*.js` is about 384 kB and that `dist/index.html`
# references exactly one entry script. A ~660 kB chunk means dist/ holds an unminified build, and
# extra hero-/reel- script tags mean the stale manualChunks config is back — rebuild before zipping.
# Order matters: `npm test` includes prerender.test.mjs, which runs `npm run build` unminified and
# leaves a ~600 kB dist/. Run the tests first, then a final `npm run build`, then copy `.htaccess`
# and zip. Zipping straight after `npm test` ships the unminified bundle.
# SFTP upload (FileZilla / cPanel File Manager / rsync):
rsync -avz dist/ user@host:~/public_html/            # no --delete: keeps api/, admin/, config.php
rsync -avz api/ user@host:~/public_html/api/ --exclude 'config.php' --exclude 'config.sample.php'
rsync -avz admin/ user@host:~/public_html/admin/
rsync -avz .htaccess user@host:~/public_html/
```
The `.htaccess` upload is required: it serves `/blog`, `/blog/<slug>`, `/apps`, `/apps/<slug>`,
`/work`, `/services`, `/resources` and `/resume` through their pre-rendered shells and falls back
to `index.html` for the SPA. Skip the `/resume` rewrite and that URL 404s, because the PDF lives at
the site root while the page URL has no matching directory.

Or use cPanel **Git™ Version Control**: push this repo to GitHub, pull on server, then
`cd ~/portfolio/site && npm ci && npm run build && rsync...` (Node available on most Hostinger Node tiers).

## Post-deploy verification (LAUNCH_CHECKLIST.md)
- [ ] `https://hasanabbassorathiya.tech` loads, force-HTTPS works
- [ ] `/api/index.php?entity=profile` and `?entity=clients` return JSON
- [ ] `/work` and `/work/evlab` load with the case-study shell (view source shows the right title/OG)
- [ ] Admin login via `/admin` works (token calls to crud.php)
- [ ] `/admin/analytics.php` renders; opening the site in a normal browser adds one visitor and one
      `/` pageview; a bot user-agent and an admin session add nothing
- [ ] `/admin/settings.php` saves; `/api/index.php?entity=settings` reflects the same values
- [ ] `/community` shows the Discord CTA, or the newsletter fallback while the invite is blank
- [ ] IndexNow: "Submit sitemap" reports HTTP 200/202 and `/<key>.txt` resolves over HTTPS
- [ ] Upload an image from `admin/edit.php`; the file lands in `/media/uploads/<folder>/` and the
      editor shows the thumbnail
- [ ] `admin/subscribers.php` loads; a test signup appears there and its unsubscribe link removes it
- [ ] `admin/enquiries.php` loads; a test enquiry returns a 32-hex reference and appears in the list
- [ ] `php site/scripts/enquiry-worker.php` dry run exits `dry_run_complete`; one `--send` reaches the owner inbox
- [ ] GA4 DebugView shows `section_view` / `cta_click` / `enquiry_submit` / `newsletter_signup` events; register `category` and `type` as event-scoped custom dimensions to split project from recruitment enquiries
- [ ] Search Console: submit `sitemap.xml`
