# Directus admin for the portfolio

Directus 11.17.4 attached to the **existing** MySQL content tables. It replaces the broken
hand-written admin (`site/admin/`) with a mature Studio UI. The public React site keeps reading
through the PHP API (`/api/index.php`); Directus only writes to the same database, so nothing on
the live site changes.

```
Browser (owner)  ->  cms.hasanabbassorathiya.tech (Directus Studio)
                            |
                            v
                  MySQL u124239009_portfolio  <-  PHP API /api/index.php  <-  React site
```

## Requirements

- Hostinger **Business** or **Cloud** plan (Node.js web apps; Node 18/20/22/24 — use **22**).
- A subdomain: `cms.hasanabbassorathiya.tech`.
- The existing database `u124239009_portfolio` and its credentials from hPanel.

## One-time setup

### 1. Subdomain

hPanel -> **Websites** -> `hasanabbassorathiya.tech` -> **Subdomains** -> create `cms`.
Any document root is fine; the Node app takes over the domain.

### 2. Dedicated MySQL user

hPanel -> **Databases** -> **MySQL Databases**:

1. Create user, e.g. `u124239009_cms`, with a strong password.
2. Add it to `u124239009_portfolio` and grant **ALL PRIVILEGES** on that database.
   Directus creates and migrates its own `directus_*` tables, so it needs CREATE/ALTER/INDEX/DROP.

### 3. Node.js web app

hPanel -> **Websites** -> **Create site** -> **Web App** (or **Advanced -> Node.js** on older panels):

| Setting | Value |
| --- | --- |
| Source | upload a zip of this `site/directus` folder, or connect the GitHub repo and set the app root to `site/directus` |
| Node version | 22 |
| Install command | `npm install` (default) |
| Start command | `npm start` |
| Application URL | `cms.hasanabbassorathiya.tech` |

`npm start` runs `scripts/start.mjs`, which bootstraps Directus once (first run only) and then
starts the server. Do not commit or upload a `.env`; set the variables below in the app panel.

### 4. Environment variables

Set these in the web app's **Environment Variables** panel (see `.env.example`):

| Variable | Value |
| --- | --- |
| `KEY` | random string, 32+ chars (`openssl rand -hex 32`) |
| `SECRET` | random string, 32+ chars (`openssl rand -hex 32`) |
| `DB_CLIENT` | `mysql` |
| `DB_HOST` | `127.0.0.1` (same host as MySQL) |
| `DB_PORT` | `3306` |
| `DB_DATABASE` | `u124239009_portfolio` |
| `DB_USER` | `u124239009_cms` |
| `DB_PASSWORD` | that user's password |
| `ADMIN_EMAIL` | `hasanabbassorathiya12@gmail.com` |
| `ADMIN_PASSWORD` | strong password for the Directus admin (store it in a password manager) |
| `PUBLIC_URL` | `https://cms.hasanabbassorathiya.tech` |
| `HOST` | `0.0.0.0` |
| `IP_TRUST_PROXY` | `true` (Hostinger terminates TLS in front of the app) |
| `LOG_LEVEL` | `info` |

Deploy/restart the app. First boot runs `directus bootstrap` automatically (the log prints
`Directus is not installed yet; bootstrapping.`). Later boots go straight to `directus start`.

### 5. Log in

Open `https://cms.hasanabbassorathiya.tech/admin` and sign in with `ADMIN_EMAIL` /
`ADMIN_PASSWORD`.

### 6. Link the content tables as collections

Directus needs collection metadata for the existing tables. Generate a static token:
**User Directory -> admin user -> Token -> generate -> save**, copy it, then from your machine:

```bash
cd site/directus
DIRECTUS_URL=https://cms.hasanabbassorathiya.tech \
DIRECTUS_TOKEN=<the token> \
node scripts/collections.mjs
```

The script is idempotent. It links `apps`, `clients`, `posts`, `projects`, `experiences`,
`skills`, `testimonials`, `profile`, `settings`, and applies readable interfaces (toggles for
`published`/`noindex`, markdown for post bodies, tag inputs for JSON string arrays, JSON code
editors for objects).

Then verify the whole path (read, prefill, write, restore):

```bash
DIRECTUS_URL=https://cms.hasanabbassorathiya.tech \
DIRECTUS_TOKEN=<the token> \
node scripts/verify.mjs
```

If the API refuses to link a table, check that the table exists and the DB user can read it; the
script patches collection metadata, which is how Directus attaches to an existing table.

## Editing content

- **Content -> Apps** etc. lists rows straight from MySQL. Opening a row shows every column
  prefilled — the behaviour the old admin lost.
- `published` = off hides the row from the public site immediately (the PHP API filters on it).
  Directus's archive filter hides unpublished rows by default; switch the filter to "All" if you
  need to see them.
- **Posts -> body** is Markdown (headings, lists, tables, code blocks).
- Profile values (`Content -> Profile`) are key/value rows; the site merges them over the seeds.
  Keys such as `youtube`, `instagram`, `medium`, `certificate`, `email`, `linkedin`, `github` are
  used by the hero, footer, contact page and schema.org `sameAs`.
- `settings` rows stay authoritative for GA4, IndexNow, announcements, community toggles, etc.
  An empty value disables that feature.

### Images

Image columns (`icon`, `logo`, `seo_image`, screenshots) store a path or URL, not a Directus file
relation. Two options:

1. Keep using the existing media paths (`/media/apps/<slug>/icon.webp`) and upload files through
   the site's media tooling / File Manager.
2. Upload in Directus, open the file, click **Copy URL**, and paste the full
   `https://cms.hasanabbassorathiya.tech/assets/<id>` URL into the field. The site renders absolute
   URLs fine.

If you upload through Directus, point `STORAGE_LOCAL_ROOT` at a directory outside the deployment
folder (for example `/home/u124239009/directus-uploads`) so files survive redeploys.

## Verification (do this once after setup)

Run `node scripts/verify.mjs` (step 6). It checks authentication, all nine collections, the app
list, a fully prefilled item, UTF-8 integrity, a write round-trip, and restores the original value.
The manual equivalent:

1. **Content -> Apps** shows the 15 existing apps with names and years.
2. Open one app: slug, name, tagline, platforms, links, metrics are all prefilled.
3. Change the tagline, save, reload — the value persists.
4. `https://hasanabbassorathiya.tech/api/index.php?entity=apps` returns the new tagline.
5. Restore the original tagline.

## Local test against the live database (optional)

hPanel -> **Databases -> Remote MySQL** -> allow your IP, then:

```bash
cd site/directus
cp .env.example .env      # fill in DB_HOST from hPanel, DB_USER, DB_PASSWORD
npm install
npm run directus -- bootstrap
npm run directus -- start
```

Studio runs at `http://127.0.0.1:8055`. Delete `.env` afterwards; never commit it.

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| `Access denied for user` | Wrong DB user/password, or the user is not attached to `u124239009_portfolio` with all privileges. Keep `DB_HOST=127.0.0.1` on the server. |
| App fails to boot with `EADDRNOTAVAIL` | Hostinger did not inject `PORT`; remove a hardcoded port and let the platform pass it, or set `PORT=8055`. |
| 502 after deploy | Check the deployment log: usually missing env vars, or the first bootstrap is still running (it takes ~30–60s). |
| `npm install` fails compiling `isolated-vm` | The app is on an unsupported Node version. Switch to **Node 22**; Directus 11.17.4 also fails to install on Node 26. |
| Garbled characters (`â€”`) in content | Content was imported through a latin1 MySQL client. Re-import SQL with `mysql --default-character-set=utf8mb4 ...`. Directus reads/writes UTF-8 correctly. |
| "You have not set a project owner" on first login | Directus BSL license prompt. Enter the owner email and usage, or click **Remind Later**; it does not block editing. |
| Studio loads but no collections | Run step 6 (`scripts/collections.mjs`). |
| Collections linked but rows look read-only | Log in as the bootstrap admin, or grant the editor role permissions under **Settings -> Access Policies**. |
| Uploads vanish after redeploy | `STORAGE_LOCAL_ROOT` pointed inside the deployment folder; move it outside. |

## Rollback

Stop the Node app. The PHP API and the existing `site/admin` keep working against the same
database; `directus_*` tables are inert and can stay. No content tables are altered by Directus
apart from rows you edit.

## Security notes

- Never commit `.env` or real credentials; `.gitignore` already excludes it.
- The Directus `Public` role has no permissions by default — keep it that way; the API is for the
  admin only.
- Use a unique, strong `ADMIN_PASSWORD`, and a dedicated MySQL user limited to this database.
- Do not expose the Directus port directly; always go through the HTTPS subdomain.
