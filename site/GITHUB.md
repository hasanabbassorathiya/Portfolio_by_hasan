# GitHub profile plan — Hasan Abbas Sorathiya

Updated: 2026-11-03. The profile README, account metadata, and selected public repository metadata are published through `gh`. GitHub's available GraphQL schema does not expose a pinned-repository mutation for this token, so pin ordering remains a one-time profile UI step.

## 1. Profile README

Published in the repository named `hasanabbassorathiya` by `gh api` commit [`f40f1b7`](https://github.com/hasanabbassorathiya/hasanabbassorathiya/commit/f40f1b791fc6cb4ee55461af2a549ca1ce0f003c). The live README uses the supplied FlowCV résumé as its résumé link and keeps client code and private repository names out of the profile.

```markdown
See the live [profile README](https://github.com/hasanabbassorathiya/hasanabbassorathiya#readme) for the published copy.
```

Rules for this README:
- Keep the numbers to the verified set: 21 app profiles, 50,000+ Good2Go users, 15,000+ Nakheel first-month downloads, 4.9 Play rating. Do not use a cross-client user total.
- Do not add star counts, download badges or "trusted by" logos.
- Do not list client names that are not already published on the site.

## 2. Pinned repositories

Pin five, in this order. Each is public and already linked from the portfolio, so the site and GitHub stay consistent. Private repositories cannot be pinned and are not referenced from the site.

| # | Repository | Why it is pinned | Suggested description |
|---|---|---|---|
| 1 | `stoolap-flutter` | Published package; the strongest single proof of systems-level Flutter work | `Pure-Rust embedded SQL for Flutter — vector search, MVCC, reactive streams. Published on pub.dev.` |
| 2 | `wp-mcp-server` | Direct evidence for the AI integration and WordPress scopes | `TypeScript MCP server for the WordPress REST API — content operations for AI agents.` |
| 3 | `bridge-ai-agent` | AI agent integration work | `AI agent integration experiments for practical automation and product workflows.` |
| 4 | `duas-crm` | Backend/product tooling behind a live app | `Python and SQLite content operations tooling with search and structured workflows.` |
| 5 | `lumio_iptv` | Recent Flutter product work | `Flutter IPTV player for mobile, desktop, and Android TV experiences.` |

Do not pin forks, tutorial clones or repositories without a README. If a pinned repo has no description or README, fix that before pinning.

## 3. Repository metadata pass

For each pinned repository, in the About panel:

- Description: use the text in the table above; keep it under 120 characters.
- Website: point to the relevant portfolio page, for example `https://hasanabbassorathiya.tech/resources` for `stoolap-flutter`.
- Topics: 4–6 accurate ones, e.g. `flutter`, `dart`, `sql`, `sqlite`, `embedded-database` for `stoolap-flutter`; `mcp`, `wordpress`, `typescript`, `ai` for `wp-mcp-server`.
- Do not add "hirable" or availability badges to repos; the profile README carries that message once.

## 4. Profile settings

- Bio: `Senior Software & AI Engineer · Flutter / Mobile · AI & Automation` — published through `gh`.
- Location: `Dubai, UAE` — published through `gh`.
- Website: `https://hasanabbassorathiya.tech` — published through `gh`.
- Company: leave empty unless the current arrangement is confirmed.
- Social links: LinkedIn, portfolio.
- "Available for hire": already enabled per `hasan.md`; keep it.

## 5. What not to do

- Do not publish client code, EVLAB or Chalhoub assets, credentials, or private repository names.
- Do not add contribution graphs, streaks or metrics as images; GitHub already shows real activity.
- Do not create new repositories just to fill a pinned grid.
- Do not mass-follow, star-swap or join engagement groups.

## 6. Owner checklist

1. **Done:** publish §1 in the `hasanabbassorathiya` profile repo.
2. Pin the five repositories from §2 in order through the GitHub profile UI.
3. **Done:** apply the descriptions, homepages and topics from §3 through `gh repo edit`.
4. **Done:** confirm the bio, location and website in §4 through `gh api`.
5. Recheck every pinned link returns 200 and the README renders without broken images.

This file records a draft only. The profile will not be reported as updated until the owner publishes it.
