# Portfolio API — complete reference

Everything the site and the admin CMS talk to lives under `/api`. Every endpoint is plain PHP + JSON, same-origin, with no framework and no build step.

- Production base URL: `https://hasanabbassorathiya.tech/api`
- Local base URL (Apache harness): `http://localhost:8099/api`
- Postman: `postman/portfolio-api.postman_collection.json` + `postman/environment-local.json` / `postman/environment-production.json`

---

## 1. Conventions

| Topic | Rule |
| --- | --- |
| Content type | JSON endpoints require `Content-Type: application/json` on writes. Wrong type → `415`. |
| Encoding | UTF-8 in, UTF-8 out (`JSON_UNESCAPED_SLASHES \| JSON_UNESCAPED_UNICODE`). |
| Auth | Cookie `admin_token` (browser) or header `X-Auth-Token: <token>` (API clients). |
| CSRF | Every authenticated write needs `X-CSRF-Token: <csrf>` (or form field `csrf_token`). |
| CORS | None. The API is same-origin by design; Postman/curl are unaffected. |
| Caching | Admin endpoints send `Cache-Control: no-store` and `X-Robots-Tag: noindex, nofollow`. |
| Errors | `{ "error": "human readable", "field": "optional", "detail": "optional" }` |
| Status codes | `200` ok · `201` created · `204` beacon accepted · `400` bad request · `401` unauthenticated · `403` origin/CSRF rejected · `404` not found · `405` method · `409` conflict (slug, requestId, version) · `413` body/file too large · `415` wrong content type · `422` validation · `429` rate limited · `503` setup/transport unavailable |

### Authentication flow

```http
POST /api/auth.php?action=login
Content-Type: application/json

{ "email": "you@example.com", "password": "…" }
```

```json
{
  "token": "64 hex chars",
  "csrf": "64 hex chars",
  "expires_in": 604800
}
```

The response also sets `admin_token` as an `HttpOnly; SameSite=Lax` cookie, so the admin UI needs nothing else. API clients keep `token` and `csrf` as variables and send them as headers on every call.

- `csrf` is derived server-side: `HMAC-SHA256("admin-csrf\0" + token, AUTH_PEPPER)`.
- Tokens live 7 days in `auth_tokens`; delete a row (or add an expiry) to revoke one.
- Login throttling: 30 attempts / 15 min per IP and 5 / 15 min per IP+account. Both buckets return `401` or `429` without revealing which limit tripped.
- `?action=register` always answers `403 registration disabled`; create the first admin with `php scripts/create-admin.php`.

### Entity names

| Public name (`index.php`) | Admin name (`crud.php`) | Table |
| --- | --- | --- |
| `profile` | `profile` | `profile` (key/value) |
| `projects` | `projects` | `projects` |
| `experience` | `experiences` (or `experience`) | `experiences` |
| `skills` | `skills` | `skills` |
| `testimonials` | `testimonials` | `testimonials` |
| `clients` | `clients` | `clients` |
| `apps` | `apps` | `apps` |
| `posts` | `posts` | `posts` |
| `settings` | — (admin Settings page) | `settings` |

---

## 2. Public content API

`GET /api/index.php?entity=<name>` — read-only, no auth, no CSRF. This is what the React site hydrates from.

| Entity | Filtering | Order |
| --- | --- | --- |
| `apps`, `clients`, `posts` | `published = 1` only | `sort_order, id` (posts: `post_date DESC`) |
| `posts` | also `post_date <= CURDATE()` | future-dated posts stay hidden |
| `projects`, `experience`, `skills`, `testimonials` | all rows | `sort_order, id` |
| `profile` | all rows | `k` |
| `settings` | `is_public = 1 AND v <> ''` | `k` |

Response shapes:

```json
{ "entity": "apps", "data": [ { "id": 1, "slug": "…", "seo_title": "…", "aso_keywords": "…" } ] }
```

```json
{ "entity": "profile", "data": [ { "k": "email", "v": "…" } ] }
```

```json
{ "entity": "settings", "data": { "ga4_id": "G-XXXXXXX", "community_enabled": "1" } }
```

Notes that matter for the frontend:

- `profile` and `settings` are **not** row lists. `profile` is a list of `{k,v}` rows; `settings` is a flat map of public keys with empty values removed.
- An empty `apps`/`clients`/`posts` response is meaningful: the site treats it as "everything unpublished", so sections empty out. `experience`, `skills` and `profile` keep their built-in content when the table has no rows, so an unseeded install still renders a resume.
- Runtime SEO fields (`seo_title`, `seo_description`, `seo_image`, `noindex`) are consumed by the SPA per item; `seo_image` may be a site path or an absolute `https://` URL.
- ASO fields (`aso_*`) are store-listing metadata edited in the CMS. They are served but never rendered on the website.

Example rows per entity (abridged — full field lists in §4):

```json
{
  "id": 3, "slug": "bulb-vpn", "name": "BULB VPN",
  "tagline": "Private browsing…", "role": "Creator", "year": "2025",
  "genre": "Utilities", "platforms": "[\"iOS\",\"Android\"]",
  "icon": "/apps/bulb-vpn.webp", "screenshots": "[]",
  "rating_value": "4.6", "rating_count": "128", "stack": "[\"Flutter\"]",
  "links": "{\"ios\":\"https://…\",\"android\":\"https://…\"}",
  "metrics": "[]", "features": "[\"…\"]", "summary": "…", "story": "…",
  "published": 1, "sort_order": 3,
  "seo_title": "", "seo_description": "", "seo_image": "", "noindex": 0,
  "aso_subtitle": "", "aso_keywords": "", "aso_category": "",
  "aso_age_rating": "", "aso_promo_text": ""
}
```

JSON-typed columns (`platforms`, `screenshots`, `stack`, `links`, `metrics`, `features`, `tags`, `what_i_did`, `facts`, `store_urls`, `points`, `utm`, `props`) are returned as **strings** by MySQL; the site mapper (`src/lib/content-mappers.js`) is the place that decodes them.

---

## 3. Admin CRUD API

All endpoints below require `X-Auth-Token` (or the admin cookie). `POST`, `PUT`, `DELETE` additionally require `X-CSRF-Token`.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/crud.php?entity=apps` | list all rows, including unpublished |
| `GET` | `/api/crud.php?entity=apps&id=12` | one row, raw columns |
| `POST` | `/api/crud.php?entity=apps` | create, JSON body, returns `{ "id": 13 }` with `201` |
| `PUT` | `/api/crud.php?entity=apps&id=12` | partial update; only supplied fields change |
| `DELETE` | `/api/crud.php?entity=apps&id=12` | delete, `404` if the id does not exist |

Behaviour:

- Fields not declared in `api/entity-schema.php` are ignored (whitelist).
- Required fields are enforced on create only. An empty string clears an optional field.
- `slug` must match `[a-z0-9][a-z0-9-]{0,189}` and is unique per table → `409` on conflict.
- `number` fields accept numbers or numeric strings; `0` is stored, empty becomes `NULL`.
- `date` fields must be real `YYYY-MM-DD` dates.
- `checkbox` accepts `true`, `"true"`, `1`, `"1"`, `"on"` → `1`, anything else → `0`.
- `json` fields accept an array/object or a JSON string, validated against the field shape (`list`, `pairs`, `object`) before storage.
- `image` fields are text paths/URLs (≤255). Upload binary files through `/api/upload.php` first.

### Profile (key/value)

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/crud.php?entity=profile` | all `{k,v}` rows ordered by key |
| `GET` | `/api/crud.php?entity=profile&k=email` | one entry (or `404`) |
| `POST` | `/api/crud.php?entity=profile` | `{ "k": "email", "v": "…" }` |
| `PUT` | `/api/crud.php?entity=profile` | `{ "k": "email", "v": "…", "previous_k": "old_key" }` — renames when `previous_k` differs |
| `DELETE` | `/api/crud.php?entity=profile&k=email` | delete one key |

Keys must match `[a-z0-9_]{1,60}`. `v` is free text. `PUT` is implemented as `REPLACE INTO`, so it works whether or not the key exists.

### Example — create an app

```bash
TOKEN=…; CSRF=…

curl -X POST "https://hasanabbassorathiya.tech/api/crud.php?entity=apps" \
  -H "X-Auth-Token: $TOKEN" -H "X-CSRF-Token: $CSRF" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "api-sample-app",
    "name": "API Sample App",
    "tagline": "Created from the API guide",
    "platforms": ["iOS", "Android"],
    "links": {},
    "published": 0
  }'
# 201 {"id": 14}
```

### Example — update and delete

```bash
curl -X PUT "https://hasanabbassorathiya.tech/api/crud.php?entity=apps&id=14" \
  -H "X-Auth-Token: $TOKEN" -H "X-CSRF-Token: $CSRF" \
  -H "Content-Type: application/json" \
  -d '{"tagline": "Updated via API", "published": 1}'
# 200 {"ok": true}

curl -X DELETE "https://hasanabbassorathiya.tech/api/crud.php?entity=apps&id=14" \
  -H "X-Auth-Token: $TOKEN" -H "X-CSRF-Token: $CSRF"
# 200 {"ok": true}
```

---

## 4. Field reference

Types: `text`, `textarea`, `markdown`, `number`, `date`, `checkbox`, `json` (shape `list` / `pairs` / `object`), `image`.
`*` = required on create.

**SEO block** (apps, clients, posts): `seo_title` (text ≤255), `seo_description` (textarea ≤320), `seo_image` (image ≤255), `noindex` (checkbox).

**ASO block** (apps only): `aso_subtitle` (≤120), `aso_keywords` (≤255), `aso_category` (≤60), `aso_age_rating` (≤20), `aso_promo_text` (≤255).

### apps
`slug*` · `name*` · `tagline*` · `role` · `year` · `genre` · `platforms` (list) · `icon` (image) · `screenshots` (list) · `rating_value` (number) · `rating_count` (number) · `stack` (list) · `links` (object: `ios`, `android`, `web`, `github`) · `metrics` (pairs) · `features` (list) · `summary` · `story` · `published` · `sort_order` · SEO · ASO

### clients
`slug*` · `name*` · `kicker` · `type` · `role` · `period` · `location` · `website` · `logo` (image) · `metric` · `metric_label` · `what_i_did` (list) · `stack` (list) · `facts` (pairs) · `summary` · `challenge` · `outcome` · `store_url` · `published` · `sort_order` · SEO

### posts
`slug*` · `title*` · `dek` · `post_date` (date) · `category` · `tags` (list) · `minutes` (number) · `body` (markdown ≤200 000) · `published` · SEO

### projects
`slug*` · `title*` · `category` · `year` · `client` · `role` · `description` · `stack` (list) · `store_urls` (object) · `is_featured` · `sort_order`

### experiences
`company*` · `position*` · `period*` · `location` · `summary` · `points` (list) · `highlight` (legacy single line) · `sort_order`
Unique key: `(company, position)` — safe to upsert from seeds.

### skills
`grp*` · `name*` · `sort_order`
Unique key: `(grp, name)`.

### testimonials
`quote*` · `author*` · `note` · `sort_order`

### profile
`k` / `v` pairs (see §3).

Seeded profile keys: `name`, `kicker`, `sub`, `availability`, `open_to`, `location`, `email`, `phone`, `linkedin`, `github`, `instagram`, `play_store`, `app_store`, `summary`.

---

## 5. Media uploads

```http
POST /api/upload.php
X-Auth-Token: <token>
X-CSRF-Token: <csrf>
Content-Type: multipart/form-data

file=<binary>   folder=apps
```

| Rule | Value |
| --- | --- |
| Max size | 8 MB |
| MIME (sniffed, not trusted from filename) | `image/jpeg`, `image/png`, `image/webp`, `image/avif`, `image/gif` |
| `folder` | `[a-z0-9][a-z0-9-]{0,59}` — creates `media/uploads/<folder>/` |
| Downscale | Raster images > 2400 px on the long edge are resized with GD when available |
| Output name | `<folder>-<8 hex>.<ext>` |

```json
{
  "path": "/media/uploads/apps/apps-1a2b3c4d.webp",
  "url": "/media/uploads/apps/apps-1a2b3c4d.webp",
  "mime": "image/webp",
  "bytes": 48213,
  "width": 1200,
  "height": 630
}
```

The row in `media` is best-effort: the file is already served from disk even if the audit insert fails because `v2-schema.sql` has not been imported.

---

## 6. Public intake endpoints

### 6.1 Enquiries — `POST /api/enquiries.php`

Strict, write-only intake. No lookup, no email sending in the request path.

```json
{
  "name": "Sara Ahmed",
  "email": "sara@example.com",
  "type": "New application",
  "message": "We need a Flutter + FastAPI app for field inspections…",
  "website": "",
  "consent": true,
  "requestId": "0f8fad5b-d9cb-469f-a165-70867728950e"
}
```

| Field | Rule |
| --- | --- |
| `name` | 1–120 chars |
| `email` | valid address, ≤190 chars |
| `type` | one of `Employment`, `New application`, `Existing improvement`, `AI integration`, `Technical consultation`, `Other` |
| `message` | 20–10 000 chars |
| `website` | honeypot — must be `""` |
| `consent` | must be exactly `true` |
| `requestId` | UUID v1–v8; retries with the same id are idempotent, a changed payload under the same id returns `409` |

Guards: `Content-Type: application/json`, body ≤20 KB, `Origin` must equal the request host (`403 origin_not_allowed`), 5 submissions / hour / hashed IP (`429 rate_limited`), control characters rejected.

```json
{ "ok": true, "reference": "9f2c…32 hex" }
```

Enquiries are triaged in `/admin/enquiries.php` (status, notes, next action, follow-up date, optimistic `version` locking) — that screen is HTML, not part of this JSON API.

### 6.2 Newsletter — `POST /api/subscribe.php`

```json
{ "email": "reader@example.com", "source": "post:rag-in-production", "website": "" }
```

- `201 { "ok": true }`; duplicates update `source`.
- Honeypot: any `website` value returns `200 { "ok": true }` so bots learn nothing.
- 5 new addresses / hour / IP, then silent success.
- Unsubscribe: `GET /api/subscribe.php?unsubscribe=<32 hex token>` returns a small HTML page. List and export subscribers in `/admin/subscribers.php`.

### 6.3 Analytics beacon — `POST /api/track.php`

Always answers `204`, with no body — success and rejection are indistinguishable on purpose.

```json
{
  "event": "page_view",
  "path": "/blog/rag-in-production",
  "session": "0123456789abcdef0123456789abcdef",
  "props": { "title": "RAG in production" },
  "utm": { "source": "linkedin", "medium": "social", "campaign": "launch" },
  "referrer": "www.linkedin.com"
}
```

| Event | Allowed props |
| --- | --- |
| `page_view` | `title` |
| `page_leave` | `dwell_ms` (clamped 0–1 800 000) |
| `cta_click` | `kind`, `meta` |
| `store_click` | `app`, `platform` |
| `app_open` | `app`, `slug` |
| `section_view` | `section` |
| `outbound_click` | `label`, `href` |
| `resume_open` | `location` |
| `newsletter_signup` | `source` |
| `enquiry_submit` | `type`, `category` |
| `project_open` | `entity` |
| `community_join` | `target` |

| Guard | Rule |
| --- | --- |
| Same origin | `Origin` host must equal `HTTP_HOST`, or `Sec-Fetch-Site` must not be `cross-site` |
| Admin excluded | Signed-in admins are never counted |
| Bots | UA matching `bot\|crawl\|spider\|slurp\|headless\|puppeteer\|playwright\|lighthouse\|pingdom\|uptime\|monitor\|preview\|curl\|wget\|…` is dropped |
| Path | `/…`, `[A-Za-z0-9._~\-/]`, ≤255, `/admin*` rejected |
| Session | 32 lowercase hex |
| Rate limit | 120 events / minute / visitor |
| Retention | Prune `analytics_events` older than 180 days (sampled 1-in-200 writes) |

Privacy: there is **no raw IP column**. `visitor` is `HMAC-SHA256(ANALYTICS_SALT|day|IP|UA)` truncated to 32 hex, so it rotates daily and cannot be reversed. `analytics_daily` keeps aggregate counters for long-term charts after raw events are pruned.

Where to read it: `/admin/analytics.php` (7/30/90-day visitors, sessions, page views, CTAs, store clicks, funnel, sources, campaigns, devices, browsers, countries, recent events, per-app clicks).

---

## 7. SEO toolkit

### 7.1 Settings — admin UI, `settings` table

`/admin/settings.php` edits 15 public keys: `ga4_id`, `gsc_verification`, `indexnow_key`, `calcom_url`, `discord_invite`, `community_enabled`, `announcement`, `default_og_image`, `linkedin_url`, `github_url`, `x_url`, `instagram_url`, `play_dev_url`, `appstore_dev_url`, `contact_email`.

- `ga4_id` is read at runtime: the SPA loads `gtag` only after consent checks and only if the key (or `VITE_GA4_ID`) is present.
- `discord_invite` + `community_enabled` drive `/community`; without an invite the page falls back to an email CTA.
- `gsc_verification` is consumed at **build time** by `scripts/prerender-meta.mjs` from the `GSC_VERIFICATION` environment variable; editing the setting alone does not add the meta tag.

### 7.2 IndexNow — `POST /api/indexnow.php`

Auth + CSRF required. Reads `indexnow_key` (lowercase hex 8–128), writes `/<key>.txt` at the site root, reads `sitemap.xml`, and submits up to 10 000 `https://` URLs to `https://api.indexnow.org/indexnow` (Bing, Yandex, Seznam).

```json
{ "ok": true, "submitted": 39, "status": 200, "keyFile": "/a1b2c3d4e5f6.txt" }
```

| Failure | Status | `error` |
| --- | --- | --- |
| settings table missing | `503` | `settings unavailable` |
| key missing/invalid | `422` | `invalid key` |
| key file not writable | `500` | `key file not writable` |
| sitemap missing or empty | `422` | `no urls` |

### 7.3 Sitemap and prerendering

`npm run build` runs Vite and then `scripts/prerender-meta.mjs`, which renders every route (home, services, resources, resume, privacy, apps, work, blog, community, each service/app/case-study/post, 404) with its own `<title>`, description, canonical, Open Graph, Twitter and JSON-LD, and writes `sitemap.xml` + `rss.xml`. New content created through the CMS appears at runtime; run a build to add it to the prerendered HTML and sitemap.

---

## 8. Setup checklist (new environment)

1. Copy `api/config.sample.php` → `api/config.php` and fill DB credentials, `AUTH_PEPPER`, optional `ANALYTICS_SALT`. Never commit `config.php`.
2. Import SQL in order: `schema.sql` → `v2-schema.sql` → `seed.sql` → `seed-content.sql`.
3. Create the first admin: `php scripts/create-admin.php you@example.com`.
4. Open `/admin/` and sign in.
5. Fill Settings → GA4, Discord, IndexNow, social URLs.
6. Build with `GSC_VERIFICATION=<token> npm run build` when Search Console verification is needed.
7. Run `POST /api/indexnow.php` once after the first deploy with content.

---

## 9. Postman

1. Import `postman/portfolio-api.postman_collection.json`.
2. Import `postman/environment-local.json` (or `environment-production.json`) and select it.
3. Set `adminEmail` / `adminPassword` in the environment.
4. Run **Auth → Login**. The test script stores `token` and `csrf` as collection variables.
5. Call anything. Create requests keep `published: 0`, save the new `id` into its variable (`appId`, `postId`, …), and Delete requests clean up after themselves.

The collection mirrors the sections above: Auth, Public content (9 entities), Admin CRUD (8 entity folders × list/get/create/update/delete), Media, Intake & analytics, SEO tools.
