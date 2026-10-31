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

### 2. MySQL user

Hostinger's database users **cannot be granted on another database**: the account has no
`GRANT OPTION`, so a freshly created `u124239009_*` user cannot be attached to
`u124239009_portfolio`. Use the database's own user, `u124239009_portfolio`, instead. Its
password is the one already in `api/config.php` on the server — read it there, never commit it.
That user holds ALL PRIVILEGES on its database, which is exactly what Directus needs to create
and migrate its own `directus_*` tables.

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

**How the platform socket works (verified 2026-10-31):** Hostinger's LiteSpeed runtime sets
`LSNODE_SOCKET` (a unix socket path) and does **not** set `PORT`. `scripts/start.mjs` binds that
socket for its whole lifetime and proxies HTTP + websocket upgrades to Directus on a private
`$TMPDIR/directus-<pid>.sock`. Do not hand the platform socket to Directus: the supervisor
rebinds the path between the handoff's unlink and Directus's listen (~6s later), which surfaces
as `listen EADDRINUSE` and a crash loop. Never create extra files in
`/usr/local/lsws/extapp-sock/` either — a Directus boot that tried returned
`EACCES: permission denied`.

**Hostinger build image constraints (verified 2026-10-31):** CloudLinux 8 / glibc 2.28,
Node 22.23.4, `make` but **no C/C++ compiler**. Directus's default `argon2@0.44` and
`isolated-vm@5` both fail there: their prebuilt binaries need glibc 2.34 and 2.29+ respectively,
and without `cc` the fallback compile dies. This package therefore pins `argon2` to **0.41.1**
(prebuilt against glibc 2.25, API-compatible `hash`/`verify`) via `overrides`, and points
`isolated-vm` at `vendor/isolated-vm`, a shim that fails loudly only if sandboxed API
extensions or Flow "Exec" operations are used. Collection editing, auth, files and the REST API
are unaffected.

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
| `DB_USER` | `u124239009_portfolio` |
| `DB_PASSWORD` | that user's password (from `api/config.php` on the server) |
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

If you upload through Directus, `scripts/start.mjs` checks `STORAGE_LOCAL_ROOT` at boot and falls
back to the app's own `uploads/` folder when it is not writable (the
`/home/u124239009/directus-uploads` path turned out not writable in the verified deployment and
the app logged the fallback). Cloudlinux redeploys replace the app folder, so move
`STORAGE_LOCAL_ROOT` to a writable path outside it if uploaded files must survive deploys.

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
| 502/503 after deploy | Check Runtime logs under **Deployments → Runtime logs** (switch the range to **Last day**). A first boot runs `directus bootstrap`, which takes ~30–60s; meanwhile `scripts/start.mjs` already owns the platform socket and proxies every request, answering 503 until Directus accepts traffic on its loopback port. |
| Runtime log says `...sock is already in use` | Do not let Directus bind `LSNODE_SOCKET` directly. Closing and unlinking the startup placeholder leaves the path free only briefly, and LiteSpeed rebinds it before Directus listens. `scripts/start.mjs` keeps the platform socket for its whole lifetime and proxies to `$TMPDIR/directus-<pid>.sock`; `LSNODE_SOCKET` is mapped in this process only. |
| Directus crashes with `EACCES: permission denied /usr/local/lsws/extapp-sock/...` | The extapp-sock directory only permits the exact socket name the platform assigned. Never create extra files there; the internal proxy socket belongs in the temp dir. |
| Bootstrap stops halfway and `directus start` crashes with `Unknown column 'validation'` | A partial `directus_*` schema from an interrupted first boot. Drop only the `directus_*` tables, then redeploy (bootstrap rebuilds them). Never drop content tables. |
| Runtime log says `Error: spawn npx ENOENT` | Hostinger's app runtime PATH has no `npm`/`npx`. `scripts/start.mjs` runs `node_modules/directus/cli.js` with `process.execPath`; don't reintroduce `npx` calls in the start path. |
| Deployment shows "Entry file: none" and the domain serves a static 403/404 | Set **Entry file** to `scripts/start.mjs` in **Deployments → Settings and redeploy**. Without it the platform syncs `public_html` but never starts the Node process. |
| `npm install` fails with `make: cc: Command not found` | The build image cannot compile native modules. `package.json` already pins `argon2` 0.41.1 (prebuilt against glibc 2.25) and replaces `isolated-vm` with `vendor/isolated-vm`, so nothing needs compiling. Don't remove those two entries. |
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
