# P8 — Iteration Backlog

Polish items to prioritize after initial launch. Each tracks a single, clearly bounded task.

| ID | Task | Priority | Notes |
|---|---|---|---|
| P8-1 | **Brag: replace ambient bed with curated track** | Medium | The synthetic brown-noise bed works; a real ambient track from Hyperframes registry or Artlist would elevate the video. Also add sfx (card ticks, key clicks) per brag-plan.md. |
| P8-2 | **Brag poster: human-select best frame** | Low | Currently auto-picked at 12.5s; let a human pick the most visually balanced frame for the thumbnail. |
| P8-3 | **Add theme toggle (light/dark)** | Low | CSS-only light palette preset + toggle. Requires extending most sections (grain on light? Keep). Trade-off: DESIGN.md stipulates dark-only. |
| P8-4 | **Wire frontend sections to API** | Medium | Replace hardcoded JSX arrays with `fetch('/api/index.php?entity=...')` — graceful fallback to static data so API outage doesn't break the site. |
| P8-5 | **Extend testimonials seed** | Medium | Only 2 testimonials in seed.sql — source more from LinkedIn recommendations or user's network. |
| P8-6 | ~~**Lighthouse CI budget**~~ | Done | `.github/workflows/site-ci.yml` + `site/lighthouserc.json` run build and Lighthouse budgets (perf ≥0.85, a11y ≥0.95, SEO ≥0.90) for `/`, `/services`, `/resume`, 2 runs each. The 0.85 perf floor absorbs the static-server/Lantern variance (local 92–95 vs live CDN 99–100); reports are uploaded as artifacts. |
| P8-7 | **Open-source strip** | Low | Add a "Built with" credits section listing the stack with links (Vite, React, Tailwind, Hyperframes, etc.). |
| P8-8 | **Page speed optimizations** | Low | Preload hero font, defer GA4, inline critical CSS, serve WebP images. Many already done; audit via Lighthouse. |