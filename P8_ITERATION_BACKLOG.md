# P8 — Iteration Backlog

Polish items to prioritize after initial launch. Each tracks a single, clearly bounded task.

| ID | Task | Priority | Notes |
|---|---|---|---|
| P8-1 | **Brag: replace ambient bed with curated track** | Medium | The synthetic brown-noise bed works; a real ambient track from Hyperframes registry or Artlist would elevate the video. Also add sfx (card ticks, key clicks) per brag-plan.md. |
| P8-2 | **Brag poster: human-select best frame** | Low | Currently auto-picked at 12.5s; let a human pick the most visually balanced frame for the thumbnail. |
| P8-3 | ~~**Add theme toggle (light/dark)**~~ | Done | `ThemeToggle` in the header with persisted light/dark palettes; both themes are covered by the 14 site-browser tests at 320–1440 px. |
| P8-4 | ~~**Wire frontend sections to API**~~ | Done | `src/lib/live-content.js` hydrates apps, clients, posts, experience, skills and profile from `/api/index.php`; malformed or failed responses keep the bundled seed content. |
| P8-5 | **Extend testimonials seed** | Medium | Only 2 testimonials in seed.sql — source more from LinkedIn recommendations or user's network. |
| P8-6 | ~~**Lighthouse CI budget**~~ | Done | `.github/workflows/site-ci.yml` + `site/lighthouserc.json` run build and Lighthouse budgets (perf ≥0.85, a11y ≥0.95, SEO ≥0.90) for `/`, `/services`, `/resume`, 2 runs each. The 0.85 perf floor absorbs the static-server/Lantern variance (local 92–95 vs live CDN 99–100); reports are uploaded as artifacts. Also fixed the live `label-content-name-mismatch` finding: header badge initials are CSS-generated, so visible text stays inside the aria-label. Commit `2a6048a`; axe-core 4.12 passes 38/38 route×width combos. |
| P8-7 | ~~**Open-source strip**~~ | Done | Footer colophon lists the stack with links: React, Vite, Tailwind CSS, PHP, MySQL, Directus. Commit `4822250`; verified 320–1440 px in both themes, 14/14 browser tests pass. Built but not deployed yet (deploy approval gated). |
| P8-8 | ~~**Page speed optimizations**~~ | Done | Hero fonts preloaded, GA4 idle-deferred, first-party beacon fire-and-forget, route-level lazy chunks. Live Lighthouse 99–100 performance, LCP 0.3–1.1 s (see DELIVERY.md §9). |