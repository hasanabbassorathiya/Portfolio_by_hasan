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
| `activity` | — (written by `social.php`) | `social_posts` |

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
| `activity` | `published = 1` only | `posted_at DESC`, max 50 |

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

```json
{ "entity": "activity", "data": [
  { "id": 1, "external_id": "post-123", "provider": "linkedin",
    "channel": "Hasan on LinkedIn", "kind": "post", "text": "Shipped…",
    "url": "https://www.linkedin.com/posts/…", "image": "",
    "posted_at": "2026-10-31 09:00:00" }
] }
```

Notes that matter for the frontend:

- `profile` and `settings` are **not** row lists. `profile` is a list of `{k,v}` rows; `settings` is a flat map of public keys with empty values removed.
- An empty `apps`/`clients`/`posts` response is meaningful: the site treats it as "everything unpublished", so sections empty out. `experience`, `skills` and `profile` keep their built-in content when the table has no rows, so an unseeded install still renders a resume.
- `activity` is a live-only feed: it has no seed rows, so an empty (or failed) response simply shows the empty state on `/activity`. If the `social_posts` table has not been created yet, the endpoint still answers `200` with `data: []` instead of failing the page.
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
- `image` fields are text paths/URLs. Upload binary files through `/api/upload.php` first.
- Text length is capped at the **smaller** of the schema's declared `max` and the column's real `VARCHAR` width (see §4.1). A field that is too long answers:

```json
{ "error": "validation failed", "field": "grp", "detail": "Group: too long — 40 character limit, got 46" }
```

Before this was measured, `entity-schema.php` promised 255 characters for every plain text field while 30 of the columns are narrower, so a legal-looking save died as `{"error":"update failed"}` with no field named — from the CLI *and* from `/admin/edit.php`, which posts to the same endpoint and sets no `maxlength`. `crud.php` now reads the widths out of `information_schema` at request time, so the database, not the doc comment, is the limit.

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

### 4.1 Effective character limits

The schema default is 255 characters for `text` and `image`. These columns are narrower, so **this is the number that will reject your write**. Everything not listed here accepts its full declared `max`.

| Entity | Field | Real limit |
| --- | --- | --- |
| apps | `slug`, `name` | 190 |
| apps | `role` | 150 |
| apps | `genre` | 80 |
| apps | `year` | **40** |
| clients | `slug`, `name`, `kicker` | 190 |
| clients | `metric_label`, `type`, `location` | 120 |
| clients | `role` | 150 |
| clients | `period`, `metric` | **60** |
| posts | `slug` | 190 |
| posts | `category` | 80 |
| projects | `slug`, `title` | 190 |
| projects | `client`, `role` | 120 |
| projects | `category` | 60 |
| projects | `year` | **20** |
| experiences | `company`, `position` | 150 |
| experiences | `location` | 120 |
| experiences | `period` | **40** |
| skills | `name` | 80 |
| skills | `grp` | **40** |
| testimonials | `author`, `note` | 120 |

Fields with an explicit `max` in the schema already matched their column: `seo_description` 320, `aso_subtitle` 120, `aso_category` 60, `aso_age_rating` **20**. `posts.body` is `mediumtext`, `profile.v` is `text`, and the other `textarea`/`markdown` fields are not width-bound.

`apps.rating_value` is `decimal(2,1)`, so it tops out at **9.9** — a 10.0 rating is not storable.

Reproduce against any database (the local harness or the live one):

```bash
mysql <db> -e "SELECT table_name, column_name, character_maximum_length
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND data_type = 'varchar'
  ORDER BY table_name, character_maximum_length"
```

The same table, generated from the schema you are running against, is in the Postman collection under `4 · Field reference` — one request per entity.

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

Rejections, by status:

| Condition | Code | Body |
| --- | --- | --- |
| Missing/unreadable `file` | 400 | `no file uploaded` |
| `folder` outside `[a-z0-9][a-z0-9-]{0,59}` | 400 | `invalid folder` |
| 0 bytes or over 8 MB | 413 | `file must be between 1 byte and 8 MB` |
| MIME outside the five allowed | 415 | `only JPEG, PNG, WebP, AVIF or GIF images are allowed` |
| Bytes pass the MIME test but are not a decodable image | 415 | `file is not a readable image` |
| Directory or `move_uploaded_file` fails | 500 | `could not store the upload` |

Two gaps worth knowing before you plan work around this endpoint:

- **There is no read endpoint for media.** `upload.php` inserts into `media`, but `crud.php` has no `media` entity and `index.php` does not serve it, so the library is not queryable through the API and nothing will tell you which uploads are orphaned. The files on disk under `media/uploads/` are the source of truth.
- **It writes only inside `media/uploads/`.** The site's app icons and screenshots live at `media/apps/<slug>/`, which this endpoint cannot reach — putting a file there is a filesystem/deploy operation, not an API call. That is why the BlankSpace and BULB VPN artwork cannot be attached through the CMS today.

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

### 6.4 Social activity webhook — `POST /api/social.php`

Any publisher automation calls this after a post goes live; the site then serves the row through `?entity=activity`. The endpoint is **write-only and secret-gated**: there is no public way to add to the feed.

```http
POST /api/social.php
X-Webhook-Secret: <SOCIAL_WEBHOOK_SECRET>
Content-Type: application/json

{ "id": "post-123",
  "providerIdentifier": "linkedin",
  "integration": { "name": "Hasan on LinkedIn" },
  "post": { "id": "post-123", "content": "Shipped…",
            "releaseURL": "https://www.linkedin.com/posts/…",
            "publishedAt": "2026-10-31T10:30:00.000Z" } }
```

| Guard | Rule |
| --- | --- |
| Method | `POST` only; anything else `405` |
| Secret | `X-Webhook-Secret` header, or `?token=` for callers that cannot set headers. `hash_equals`, 32+ chars, placeholder `CHANGE_ME` treated as unset |
| Size | 64 KB body cap → `413` |
| JSON | Must decode to an object → `400` |
| Idempotency | `external_id` is unique; a retry answers `200 { "duplicate": true }` instead of inserting twice |
| Empty posts | A payload with neither text nor a safe `http(s)` URL is stored with `published = 0`, so nothing blank reaches the site |
| Storage | The raw JSON is kept in `raw_json` for auditing; normalized columns drive the feed |

Normalization accepts flat publisher payloads plus a `{ data: { post: … } }` envelope. Fields read, in order:

| Column | Source paths (first match wins) |
| --- | --- |
| `external_id` | `post.id`, `postId`, `id`, `eventId`, `data.post.id`, `data.id`; otherwise `hash-sha256(raw)` |
| `text` | `post.content`, `content`, `text`, `body`, `message`, nested `data.*`; arrays of blocks join with a blank line |
| `url` | `post.releaseURL`, `releaseURL`, `post.url`, `url`, `permalink`, `post.permalink`; only `http(s)` survives |
| `image` | `post.image`, `image`, `media.0.url`, `post.media.0.url` |
| `provider` | `providerIdentifier`, `integration.providerIdentifier`, `provider` |
| `channel` | `integration.name`, `channel.name`, `account.name` |
| `posted_at` | `post.publishedAt`, `publishedAt`, `post.createdAt`, `createdAt`, `date`; stored UTC |

Responses: `201 { "ok": true, "duplicate": false, "published": true, "external_id": "…" }` on the first write, `200` with `"duplicate": true` on a retry, `503` when the secret or table is not configured yet (fail closed).

Set `SOCIAL_WEBHOOK_SECRET` in `api/config.php`, or upload `api/social-secret.php` returning the same 32+ character string when the live `config.php` must not be edited. The placeholder in `config.sample.php` keeps the endpoint disabled. `php scripts/social-normalize-check.php` is a database-free contract check for the parser.

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

1. Copy `api/config.sample.php` → `api/config.php` and fill DB credentials, `AUTH_PEPPER`, optional `ANALYTICS_SALT` and `SOCIAL_WEBHOOK_SECRET`. Never commit `config.php`.
2. Import SQL in order: `schema.sql` → `v2-schema.sql` → `seed.sql` → `seed-content.sql` → `enquiries-schema.sql` → `migrate-2026-11-01-social-posts.sql`. Pass `--default-character-set=utf8mb4` on the client, and create the database with `CHARACTER SET utf8mb4`: some local MariaDB builds default `character_set_client` to `latin1`, which silently double-encodes the em dashes and curly quotes in the seed text (`—` becomes `â€”`) while still importing cleanly.
3. Create the first admin: `php scripts/create-admin.php you@example.com`.
4. Open `/admin/` and sign in.
5. Fill Settings → GA4, Discord, IndexNow, social URLs.
6. Build with `GSC_VERIFICATION=<token> npm run build` when Search Console verification is needed.
7. Run `POST /api/indexnow.php` once after the first deploy with content.

---

## 9. Postman

`postman/portfolio-api.postman_collection.json` — 80 requests in 10 folders. Folders 0–7 are **generated** from `api/entity-schema.php`, so a field added to the schema appears in its create body, its update body and its reference table without anyone remembering to document it. Folders 8–9 (intake, SEO) are carried over verbatim by the generator.

### Use it

1. Import `postman/portfolio-api.postman_collection.json`.
2. Import `postman/environment-local.json` and `postman/environment-production.json`; select one. The environment's `baseUrl` **and** `siteUrl` override the collection defaults — set both, or a local upload check silently targets the live site.
3. Fill `adminEmail` / `adminPassword` in the environment. They are never committed and must not go in a URL, where they would land in shell history and Postman sync.
4. Run **`1 · Auth → Login`**. Its test script writes `token` and `csrf` as collection variables for every request after it. Both are bound together (CSRF is an HMAC of the token), so take the pair from one response — mixing them gives `403`.
5. Read **`0 · Start here`** before writing anything. Read **`4 · Field reference`** for the per-field contract, including §4.1's real column widths.

Folders: `0 Start here · 1 Auth · 2 Public content · 3 Profile (key/value) · 4 Field reference · 5 Admin CRUD · 6 Media · 7 Recipes · 8 Intake & analytics · 9 SEO tools`.

`5 · Admin CRUD` runs List → **Create** (captures the id) → Get one → Update → Set media → Publish → **Delete** for each entity, in that order, so running a folder top to bottom leaves no row behind. `6 · Media → Recipe: upload → attach to an app` creates its own throwaway row and deletes it, so it cannot overwrite a real app.

### Regenerate it

```bash
cd site && npm run postman          # php scripts/gen-postman.php
```

The generator fails rather than shipping a hole: a schema field with no example value, or a `{{var}}` referenced but not declared, exits non-zero.

### Prove it

The collection ships JavaScript that has to work, so `scripts/verify-postman.mjs` runs it the way Postman's runner does — same phase order, same `pm.test`/`pm.expect`/`pm.response`/`pm.sendRequest`, `node:vm` sandboxes — against a real PHP + MySQL stack and reports every assertion.

```bash
cd site && CMS_VERIFY_BASE=http://127.0.0.1:8099/api CMS_VERIFY_SITE=http://127.0.0.1:8099 \
  CMS_VERIFY_EMAIL=… CMS_VERIFY_PASSWORD=… CMS_VERIFY_FILE=/tmp/probe.png \
  node scripts/verify-postman.mjs
```

It **refuses any non-loopback `CMS_VERIFY_BASE`** — the collection creates and deletes rows, so there is no way to aim it at production by accident. Folder `9 · SEO tools` is skipped because it calls indexnow.org. Current state: `79 requests · 53 scripted assertions · 0 failing` against a scratch `portfolio_cms_verify` database (80th request is the skipped IndexNow call).

