# Postiz → portfolio activity feed

Postiz is the scheduling/publishing front end for social accounts. The website only consumes its
webhook: a post published through Postiz is stored in `social_posts` and rendered at `/activity`.
This document covers the Postiz deployment that has to live outside the Hostinger **Business**
web-hosting plan, plus the values the site side needs.

```
Social accounts ←→ Postiz (VPS, Docker)  ──webhook──▶  /api/social.php  ──▶  MySQL social_posts
                                                                    │
                                                          /api/index.php?entity=activity
                                                                    │
                                                                 /activity
```

## Why not on the existing Business plan

Postiz's self-hosted stack is Docker Compose with **7 containers**: the app, PostgreSQL, Redis,
Temporal auto-setup, a Temporal PostgreSQL, Elasticsearch and the Temporal UI/admin tools. The
Hostinger Business plan offers one LiteSpeed Node.js app slot, MySQL only, no Docker, no
PostgreSQL/Redis, and a 2 GB-class memory ceiling. The CMS subdomain (`cms.…`) works because
Directus is a single Node process on MySQL; Postiz is not.

Use a **Hostinger VPS (KVM 2 or larger)** or any Ubuntu 24.04 VPS with **≥ 2 vCPU and ≥ 4 GB RAM**
(the upstream docs baseline is 2 GB; Temporal + Elasticsearch make 4 GB the comfortable floor).
The existing `hasanabbassorathiya.tech` DNS stays on Hostinger; only the new `social` record points
at the VPS.

## 1. DNS and firewall

| Record | Value |
| --- | --- |
| `social.hasanabbassorathiya.tech` | `A` → VPS IPv4 |
| `social.hasanabbassorathiya.tech` | `AAAA` → VPS IPv6 (if the VPS has one) |

Open only `22/tcp` (SSH), `80/tcp` and `443/tcp`. Do **not** publish Postiz's `5000`, Postgres,
Redis, Temporal or Elasticsearch ports; the compose stack keeps them on the internal network.

## 2. Docker host

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"   # log out/in once
docker compose version
```

Clone the upstream repository, then pin the newest release tag rather than tracking `main` in
production:

```bash
sudo mkdir -p /opt/postiz && sudo chown "$USER" /opt/postiz
git clone https://github.com/gitroomhq/postiz-app.git /opt/postiz
cd /opt/postiz
git tag --sort=-v:refname | head -5   # pick the newest release
git checkout <chosen-tag>
cp .env.example .env
```

Record the chosen tag in this file so upgrades are reproducible.

## 3. `.env` (server only — never commit)

Generate every secret on the VPS:

```bash
openssl rand -hex 32   # run separately for JWT_SECRET and each database password
```

```dotenv
# Public URLs
MAIN_URL=https://social.hasanabbassorathiya.tech
FRONTEND_URL=https://social.hasanabbassorathiya.tech
NEXT_PUBLIC_BACKEND_URL=https://social.hasanabbassorathiya.tech/api
BACKEND_INTERNAL_URL=http://127.0.0.1:3000

# Data stores (passwords must match the postgres service in compose)
DATABASE_URL=postgresql://postiz:<POSTGRES_PASSWORD>@postgres:5432/postiz
REDIS_URL=redis://redis:6379
JWT_SECRET=<64-hex>

# Temporal
TEMPORAL_ADDRESS=temporal:7233

# Single-tenant instance: no public sign-ups
IS_GENERAL=true
DISABLE_REGISTRATION=true

# Local uploads (inside the app volume)
STORAGE_PROVIDER=local
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads
```

Variable names follow the upstream `.env.example`; if `docker compose config` reports a missing
variable, reconcile against the compose file from the same tag before starting. Keep `.env` at
mode `600` and out of any backup that leaves the VPS unencrypted.

## 4. TLS reverse proxy

Caddy is the shortest path to automatic certificates:

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy
```

`/etc/caddy/Caddyfile`:

```caddyfile
social.hasanabbassorathiya.tech {
  encode zstd gzip
  reverse_proxy 127.0.0.1:5000
}
```

```bash
sudo systemctl reload caddy
```

The upstream compose publishes the app on `5000`; change the compose port mapping to
`127.0.0.1:5000:5000` so only Caddy can reach it.

## 5. Start and create the owner account

```bash
cd /opt/postiz
docker compose up -d
docker compose ps
docker compose logs -f postiz
```

Wait for the app to report healthy, then open `https://social.hasanabbassorathiya.tech`, register
the owner account immediately, and leave registration disabled afterwards.

## 6. Connect social accounts

In Postiz: **Settings → Integrations → Add channel**. Each provider needs its own developer app
and OAuth credentials (LinkedIn, X, Instagram/Facebook via Meta, YouTube via Google, Medium,
TikTok, …). Postiz shows the exact redirect/callback URL to paste into each provider console —
use that value; do not guess paths. Keep provider client IDs/secrets in Postiz's integration
settings or the server `.env`, never in the website repository.

Start with the accounts whose content should appear on the site. A channel can be connected
without being included in the public feed — the site renders whatever Postiz sends.

## 7. Point Postiz at the site

Postiz **Settings → Webhooks** (or the per-integration webhook field, depending on version):

| Field | Value |
| --- | --- |
| URL | `https://hasanabbassorathiya.tech/api/social.php` |
| Secret / token | the same value as the site's `SOCIAL_WEBHOOK_SECRET` (kept in `api/social-secret.php` on the server) |
| Header | `X-Webhook-Secret: <secret>` |
| Events | **post published** (and test) |
| Scope | all integrations, or only the channels that should be public |

If the webhook UI cannot send custom headers, use
`https://hasanabbassorathiya.tech/api/social.php?token=<secret>`. Prefer the header when available:
query strings end up in proxy logs.

The site endpoint requires a 32+ character `SOCIAL_WEBHOOK_SECRET`. It is defined in the live
`api/config.php`, or — when that file must not be edited — read from `api/social-secret.php`
returning the string; this deployment uses the latter. Without either, `/api/social.php` answers
`503` and nothing is written. Never overwrite the live `config.php`, which also holds the database
password and `AUTH_PEPPER`.

## 8. Verify the first post

1. Use Postiz's **Send test** on the webhook. The site answers
   `201 {"ok":true,"duplicate":false,"published":true,…}` for a payload with text or a URL.
2. Check the read path:
   `curl -s 'https://hasanabbassorathiya.tech/api/index.php?entity=activity' | head -c 600`
3. Open `https://hasanabbassorathiya.tech/activity` — the card appears newest first, and the
   footer gains an **Activity** link.
4. Publish one real post through Postiz and confirm it arrives within a few seconds.

If a provider's payload has an unexpected shape, the raw body is kept in `social_posts.raw_json`;
compare it with the source paths in `API.md` §6.4 and extend `api/social-lib.php`, then re-run
`php scripts/social-normalize-check.php`. The endpoint returns `2xx` for duplicates, so Postiz
retries are harmless.

## 9. Operations

| Task | Command / place |
| --- | --- |
| Update Postiz | bump the tag in `git fetch --tags`, `git checkout <tag>`, back up the Postgres volume, `docker compose pull && docker compose up -d` |
| Backups | nightly `pg_dump` of the `postiz` database plus the `uploads` volume; keep off-box |
| Logs | `docker compose logs --tail=200 postiz` |
| Restart | `docker compose restart postiz` |
| Health | `https://social.hasanabbassorathiya.tech/` and the site's `?entity=activity` |
| Public feed empty | check the webhook secret, the migration, and `social_posts.published` |
| Unwanted post | set `published = 0` for that row (site hides it immediately) |

## 10. What is intentionally not automated

- No public sign-up and no multi-tenant mode.
- No direct database access from the website to Postiz; the webhook is the only interface.
- No social credentials in the portfolio repo, the CMS database, or the static bundle.
- The site never calls back into Postiz; if Postiz is offline, `/activity` keeps serving the rows
  already stored.
