# Changelog

Versions follow the `vX.Y.Z` git tags on this repository. The site package version lives in
`package.json`; every release records the deployed build so the live site can be traced back to a
commit.

## Unreleased — audit checkpoint, 2026-10-31

Not deployed. Corrects public claims and conversion paths after an independent live/local audit:

- 6+ years pinned to the owner-confirmed value; 100K+ aggregate withdrawn; named Good2Go (50K+) and
  Nakheel (15K+) figures retained; `/apps` distinguishes 15 profiles from the 21-entry catalogue.
- Résumé repositioned to Flutter & Dart / iOS and Android delivery / backend, API and full-stack
  integrations; PMP removed; Udemy certificate is the only credential claimed.
- "MERN & full-stack API development" renamed to "Backend, API & full-stack integrations".
- Recruiter path added; six-option enquiry selector; engineering decisions on EVLAB, Good2Go, Duas and
  Aamal, and Lumio TV.
- JS-off direct-email fallback; form state/idempotency review; accurate privacy copy; GST clock fallback.
- OG card generator repaired; stale template deleted; docs, seeds, Postman and tests aligned.
- Verified: 49 SSR/content + 76 browser tests, 86 PHP enquiry checks, 10 auth tests, axe 76/0,
  hydration 34/0, metadata 43/43, sitemap 42/42, Lighthouse 92–95/100/96/100.

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
