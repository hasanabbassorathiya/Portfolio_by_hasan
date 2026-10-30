# Changelog

Versions follow the `vX.Y.Z` git tags on this repository. The site package version lives in
`package.json`; every release records the deployed build so the live site can be traced back to a
commit.

## 2.0.0 — 2026-10-30

First versioned release: the React 18 + Vite portfolio site with its PHP/MariaDB growth platform.

- **Public site** — Bone & Ink design system, prerendered routes with hydration, light/dark themes,
  `/apps` catalogue with 15 app profiles (including Klix under Masaar and Urban Ledger under Vervali
  Systems), client case studies, nine essays, services, resources, résumé page + PDF, and `/community`.
- **CMS** — schema-driven CRUD for apps, clients, posts and profile fields; media uploads; admin
  dashboard.
- **Growth platform** — first-party analytics (`/admin/analytics.php`), visitor beacon with bot and
  cross-origin filters, per-item SEO/ASO fields, settings page for GA4/Cal.com/GSC/IndexNow/Discord,
  UTM builder, RSS and sitemap generation, `llms.txt`.
- **Delivery** — `deploy-public_html.zip` (static only; never touches `api/config.php`), CMS smoke
  harness, 123 Node tests, axe sweep (76 checks, 0 violations), hydration sweep (34 checks),
  Apache harness route checks (42/42 sitemap URLs return 200).
