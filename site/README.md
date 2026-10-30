# hasanabbassorathiya.tech — operations README

The public site is a React 18 + Vite 5 + Tailwind 3 single-page app with server-rendered route
shells, a PHP 8 JSON API over MySQL/MariaDB, and a token-authenticated PHP CMS. Everything in this
directory ships to Hostinger Business shared hosting; there is no Node server in production.

This README is the entry point. Deeper records live in:

| Document | Purpose |
|---|---|
| `DELIVERY.md` | What was built, verified, measured, and what remains for the owner |
| `DEPLOY.md` | Deployment steps, package contents, and the static-only zip |
| `AUTOMATIONS.md` | Enquiry worker, content pipeline, job-search/outreach routines, monitoring, reporting |
| `ASO.md` | Store-listing drafts and measurement rules |
| `LINKEDIN.md`, `GITHUB.md`, `SOCIAL.md` | Profile and launch copy |
| `DESIGN.md`, `COMPONENTS.md` | Design tokens and component inventory |
| `LAUNCH_CHECKLIST.md` | Pre-launch checks |
| `evidence/2026-10-29/README.md` | Screenshot capture method and harness limitations |

## 1. Requirements

- Node.js 20 or newer (built and tested on Node 26) and npm.
- PHP 8.1+ with PDO MySQL, for the API, CMS, and CLI tests (verified on PHP 8.5).
- MySQL 8 or MariaDB 10.6+ for the full CMS test.
- Google Chrome installed, for the Playwright-based checks. No browser download step is needed;
  scripts launch `channel: 'chrome'`.

## 2. Install and run

```bash
cd site
npm install
npm run dev          # Vite at http://127.0.0.1:5173
```

The Vite dev server renders the SPA and seeds content from `src/content/`. It does not run PHP, so
API-backed features (live content, enquiries, admin) need the PHP API and a database, and the
production-like route behaviour needs Apache with `.htaccess`.

```bash
npm run build        # vite build, then prerender every route into dist/ + sitemap/rss/llms.txt
npm run resume:pdf   # print /resume from dist/ into public/ and dist/ (needs a build first)
npm run a11y         # axe-core sweep over 14 routes × 1440/390 × light/dark + heading-outline guard (needs the Apache harness)
npm run hydration    # hydration + LCP regression sweep over 15 routes × light/dark (needs the Apache harness)
npm run preview      # serve dist/ for a quick look (SPA fallback only, no .htaccess)
```

Route shells, real 404s, `/scripts` denial, and the `_views` statics require Apache. The project's
evidence harness uses an Apache docroot at `/tmp/hasan-httpd/public_html` on port 8099:

```bash
rsync -a --delete site/dist/ /tmp/hasan-httpd/public_html/
cp site/.htaccess /tmp/hasan-httpd/public_html/.htaccess
node site/scripts/capture-evidence.mjs
```

## 3. Configuration

### Server secrets — never committed

Copy `api/config.sample.php` to `api/config.php` on the server and fill in:

- `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`
- `AUTH_PEPPER` — 32-byte hex secret; generate with
  `php -r "echo bin2hex(random_bytes(32));"`

`site/api/config.php` is gitignored. Never commit it, never upload it inside a build zip, and never
overwrite the live copy during a deploy.

### Environment variables

| Variable | Where | Purpose |
|---|---|---|
| `ENQUIRY_OWNER_EMAIL` | Server env / cron | Recipient for the owner notification |
| `ENQUIRY_FROM_EMAIL` | Server env / cron | From address for the enquiry worker |
| `VITE_GA4_ID` | Build environment | Enables GA4; analytics stays inert when unset |
| `VITE_CAL_URL` | Build environment | Adds the Cal.com "Prefer a call?" link to the contact area; must be `https://`; link and string are absent when unset |
| `SITE_TEST_URL` | Test shell | Target for the browser UX suites (`site-browser`, `conversion`, `interaction-qa`) and the dev-server half of `seo-browser.test.mjs` (default `http://127.0.0.1:5173`; the built site on the Apache harness also works) |
| `SITE_APACHE_URL` | Test shell | Apache harness for captures, a11y, hydration and the Apache half of `seo-browser.test.mjs` (default `http://127.0.0.1:8099`) |

Build-time variables have a template at `site/.env.example`; copy it to `site/.env.production`
(gitignored) and fill only what you have.

The enquiry worker reads only the two `ENQUIRY_*` variables; it does not load `.env` files.

## 4. Database and content

- `api/schema.sql` — core tables.
- `api/seed.sql` — baseline rows.
- `api/seed-content.sql` — generated from `src/content/` by `npm run seed:sql`.
- `api/enquiries-schema.sql` — enquiries, outbox, and rate-limit tables.

Content has two sources of truth by design:

1. `src/content/*.js` feeds prerendered pages, the sitemap, RSS, JSON-LD, and the seed SQL.
2. The database feeds runtime API reads and the CMS.

After editing `src/content/`, run `npm run seed:sql`, re-import `api/seed-content.sql` where the
site reads from the API, and rebuild so static pages match. Edits made only in `/admin` are live
for API-driven views immediately but need a rebuild for prerendered pages. See `AUTOMATIONS.md` §3.

## 5. Tests and checks

Run from the repository root unless noted.

```bash
# Content, catalogue, prerender, services, conversion, enquiry logic (Node)
# Runs in site/: resume.test.mjs reads public/ and dist/ relative to the working directory.
(cd site && node --test scripts/live-content.test.mjs scripts/app-catalog.test.mjs \
  scripts/prerender.test.mjs scripts/services.test.mjs \
  scripts/conversion.test.mjs scripts/contact-enquiry.test.mjs \
  scripts/resume.test.mjs)

# Browser UX: menu keyboard, skip link/focus, reduced motion, résumé PDF, form states
SITE_TEST_URL=http://127.0.0.1:8099 node --test site/scripts/site-browser.test.mjs \
  site/scripts/conversion.test.mjs site/scripts/interaction-qa.test.mjs

# Browser routing, metadata, client navigation (needs dev server + Apache harness + Chrome)
node --test site/scripts/seo-browser.test.mjs

# Hydration: no markup replacement, no React warnings, correct theme/h1, LCP measured
node site/scripts/hydration-check.mjs

# PHP logic and admin auth
php site/scripts/auth.test.php
php site/scripts/enquiries.test.php
# Optional: run the real MariaDB/HTTP integration half against a disposable socket
# ENQUIRY_TEST_SOCKET=/tmp/enquiry-<name>.sock php site/scripts/enquiries.test.php

# Full CMS, API, intake, newsletter and CSRF smoke test (starts disposable MariaDB and PHP servers)
CMS_SMOKE_ALLOW=1 ./site/scripts/cms-smoke.sh

# Six-width screenshots, overflow/font/console checks against the Apache build
node site/scripts/capture-evidence.mjs

# Lighthouse, against the Apache build
npx lighthouse http://127.0.0.1:8099/ --only-categories=performance,accessibility,best-practices,seo
```

The browser tests and capture script need the dev server and the Apache harness running, plus
Google Chrome. The static harness has no PHP, so its three content-API 404s are expected and
recorded; any other console error or unexpected failed request fails the capture.

Current results are recorded in `DELIVERY.md` §10 and §18.

## 6. Maintain

- Update verified facts at the source (`hasan.md`, LinkedIn, store consoles, pub.dev), then the
  site content, then `ASO.md`/`LINKEDIN.md`/`GITHUB.md` if the same fact appears there.
- Re-check store ratings and counts before quoting them; they are snapshots.
- Keep `llms.txt` aligned with the public pages and verified facts.
- Run the test suite after content or template changes; rebuild and recapture evidence after visual
  changes.
- See `AUTOMATIONS.md` §6 for monitoring and §7 for the monthly report.

## 7. Deploy

Follow `DEPLOY.md`. The short version:

```bash
cd site
npm run build
cp .htaccess dist/.htaccess
rm -f deploy-public_html.zip && (cd dist && zip -qr ../deploy-public_html.zip .)
```

Build after testing, not before: `prerender.test.mjs` runs `npm run build` itself, and under the
Node test runner that build is unminified (~600 kB entry chunk instead of ~359 kB). Run
`npm test` first, then the final `npm run build`, then copy `.htaccess` and zip.

The zip contains static files, `.htaccess`, and `llms.txt` only — no `api/`, `admin/`, or
`config.php`. Uploading the zip does not touch the live PHP panel or its config. PHP changes must be
uploaded separately, and never overwrite the server's `api/config.php`.

Live deployment requires the owner's explicit approval. Do not deploy, and do not modify DNS,
credentials, or production data, without it.

## 8. Directory map

```
src/                React app, sections, pages, content, styles
public/             static assets copied into dist/ (llms.txt, robots.txt, fonts, media)
api/                PHP JSON API, enquiry intake, auth, schema and seed SQL
admin/              PHP CMS (login, dashboard, editors, enquiries, subscribers)
scripts/            build, prerender, seed, test, capture, and worker CLIs
evidence/           dated screenshots and machine-readable capture reports
dist/               production build output (generated; not the deployment package by itself)
```

## 9. Known limitations

- PHP mail is used for the worker; real inbox delivery depends on the host's mail configuration
  and has not been exercised against a live relay.
- The CMS edits runtime data; prerendered pages still need a rebuild.
- No external monitoring, booking, or referral integration is enabled until the owner supplies
  credentials or URLs.
- Lighthouse numbers in `DELIVERY.md` are local-harness measurements with simulated throttling,
  not live-host field data. INP is not claimed before launch: it needs CrUX/field data; TBT (0 ms)
  is the lab proxy.
- `npm audit --omit=dev` is clean; the full audit reports dev-only Vite/esbuild advisories. The dev
  server stays on `127.0.0.1` and is not part of the deployed static build.
