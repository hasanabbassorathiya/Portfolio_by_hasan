# Automations and Operating Routines

Status: this document describes what runs in code, what stays manual on purpose, and what the
owner still has to switch on. The site sends no outbound message, submits no job application, and
contacts no one automatically. Nothing here promises leads, rankings, or revenue.

## 1. Status at a glance

| ID | Workflow | Mode | Trigger | Hard guardrail |
|---|---|---|---|---|
| A | Enquiries | Implemented | Form submit + cron worker | Explicit `--send`; consent required; idempotent |
| B | Content | Implemented + human review | CMS edit → seed → build | Draft/publish flag; fact checks; no auto-generated claims |
| C | Job search | Manual by design | Weekly, 30–45 min | No auto-apply, no logged-in scraping |
| D | Outreach | Manual by design | Weekly, capped at five people | No bulk messages, no scraped emails |
| E | Monitoring | Semi-automated | Pre-deploy and weekly | Read-only checks; no external service |
| F | Reporting | Manual | Monthly | Measured data only; blanks where data is absent |

## 2. A — Enquiries

Flow:

1. The visitor submits `/contact` (or a service page CTA) with a stable `requestId`.
2. `site/api/enquiries.php` checks origin, payload size, honeypot, required fields, email shape,
   and consent; duplicate `requestId` values return the original result instead of a second lead.
3. One transaction writes the enquiry and its outbox rows: an owner notification and, when
   applicable, an acknowledgement to the sender.
4. `site/scripts/enquiry-worker.php`, run from cron, drains the outbox. It defaults to dry-run.

Commands:

```bash
php site/scripts/enquiry-worker.php                  # read-only dry run
php site/scripts/enquiry-worker.php --limit=25       # bounded dry run
ENQUIRY_OWNER_EMAIL=... ENQUIRY_FROM_EMAIL=... \
  php site/scripts/enquiry-worker.php --send         # real transport
php site/scripts/enquiry-worker.php --send --retry=123
php site/scripts/enquiry-worker.php --send --retry=123 --accept-duplicate-risk
```

Safeguards:

- Definite failures retry up to five attempts with 60/120/240/480-second backoff. An interrupted
  send is ambiguous, not a success; it needs `--accept-duplicate-risk` and a look at transport
  logs first.
- "Sent" means the local transport accepted the message, not that it reached an inbox.
- The worker never deletes enquiries and never sends marketing.
- Errors print controlled status codes only, so addresses and credentials do not leak into logs.

Owner setup: set `ENQUIRY_OWNER_EMAIL` and `ENQUIRY_FROM_EMAIL` in the server environment, run one
`--send` against an address the owner controls, confirm arrival, then add cron every 10–15 minutes.
No cron is configured by this repository.

## 3. B — Content

Three layers, deliberately separate:

- `site/src/content/*.js` — the source of truth for prerendered pages. Profile, projects,
  experience, skills, testimonials, clients, apps, and posts live here.
- MySQL via `site/api/index.php` — runtime content the SPA reads.
- `/admin` — the owner's editor. `edit.php` validates JSON columns, shows drafts, and toggles
  `published`; `site/scripts/seed-sql.mjs` regenerates `api/seed-content.sql` from
  `src/content/` so a fresh database matches the code.

Routine after a content edit:

1. Edit in `/admin` or in `src/content/`.
2. Save as unpublished first; preview the affected route.
3. Check facts, numbers, links, and dates at the source (store listing, LinkedIn, pub.dev).
4. Publish. If a prerendered page changed, rebuild and deploy with owner approval.
5. Run `node --test site/scripts/live-content.test.mjs` to confirm the API still returns the
   expected shapes and nothing is silently empty.

What is not automated: writing claims, generating testimonials, inventing metrics, or
auto-publishing edits. The pipeline is deterministic; the judgement stays human.

## 4. C — Job search

No code, on purpose. Auto-applying and scraping logged-in job boards break platform terms and
produce the exact spam behaviour this project avoids.

Weekly routine (30–45 minutes):

1. Run saved searches: senior Flutter engineer (Dubai and remote), mobile lead Flutter, AI
   engineer with RAG/agents, full-stack React/Node with AI. Treat these as queries, not claims
   about the market.
2. Read each posting before applying. Apply only where the role matches the verified profile in
   `hasan.md`; cap at five applications per week.
3. Tailor two sentences per application and link the closest case study (`/work/<slug>` or
   `/apps/<slug>`), not the homepage.
4. Track every application with the fields below; follow up once after 7–10 days, then stop.

| Date | Company | Role | Source | Fit (1–5) | Contact | Status | Next action |
|---|---|---|---|---|---|---|---|

No auto-apply, no résumé blasting, no invented experience, no fake referrals.

## 5. D — Outreach

Manual and capped at five specific people per week.

- Use the copy variants in `site/SOCIAL.md` and the profile drafts in `site/LINKEDIN.md`; personalise
  the first line with something real about their product or post.
- No bulk email tools, no purchased lists, no scraped addresses, no automated DMs or connection
  requests, no engagement pods.
- One follow-up after 7–10 days at most. If there is no reply, stop.
- Do not message anyone who has asked not to be contacted, and do not use the enquiry address for
  outreach.

The goal is a small number of relevant conversations, not volume.

## 6. E — Monitoring

Read-only checks that exist today:

| Check | Command | What it catches |
|---|---|---|
| Six-width capture | `node site/scripts/capture-evidence.mjs` | Overflow, missing fonts, console errors, unexpected failed requests |
| Route and metadata | `node --test site/scripts/seo-browser.test.mjs` | Broken routes, missing metadata, soft 404s |
| Content and catalogue | `node --test site/scripts/live-content.test.mjs site/scripts/app-catalog.test.mjs` | Empty API responses, drift between content and catalogue |
| Enquiry logic | `php site/scripts/enquiries.test.php` | Validation, idempotency, outbox state |
| Auth | `php site/scripts/auth.test.php` | Registration closed, throttling, CSRF |
| CMS end to end | `CMS_SMOKE_ALLOW=1 ./site/scripts/cms-smoke.sh` | Admin screens, intake, API, CSRF update |
| Lighthouse | `npx lighthouse <url> --only-categories=performance,accessibility,best-practices,seo` | Performance and accessibility regressions |
| Production uptime | Hostinger monitor or an external uptime check chosen by the owner | Downtime, TLS expiry |

Response rules:

- Unknown route returns 200 or any page returns 5xx → check `.htaccess` first, then roll back.
- LCP above 4 s on mobile → check font preloads and above-the-fold animations before touching
  content.
- Enquiry POST returns 5xx → check database connectivity and the API error log; do not switch the
  form to mailto as a silent fallback.
- Worker failures → inspect outbox rows and transport logs; use `--retry` only after reading them.

No paid monitoring service has been added. The owner's existing hosting monitor is enough at this
traffic level.

## 7. F — Reporting

Monthly, from the consoles, in one page. Use blanks where data does not exist — never estimates.

| Field | Source |
|---|---|
| Qualified enquiries | `/admin/enquiries.php` (read and classify; no auto-scoring) |
| Replies, calls booked | Owner's inbox and calendar |
| Page views and top pages | GA4, only when `VITE_GA4_ID` is set |
| Enquiries by type (project vs recruitment) | GA4 `enquiry_submit` (`category`, `type`) when configured; otherwise count the `type` column in `/admin/enquiries.php` |
| Service-page engagement | GA4 `page_view` (sent on the first load and on every client-side route change, with `page_path` and `page_title`) |
| Search clicks and impressions | Google Search Console |
| Store listing views and installs | Play Console, App Store Connect |
| Rating snapshot | Store consoles, with the date read |
| Test and Lighthouse status | This repository's commands, with the run date |

Rules: one row per month; label every store number as a snapshot; do not convert partial data into
a total; do not claim causation from a single change; do not publish revenue or ranking promises.
The report is for deciding what to change next, not for marketing.

## 8. Guardrails that apply to every workflow

- No unsolicited bulk messages, no auto-DMs, no purchased or scraped contact lists.
- No scraping behind authentication and no automated job applications.
- No publishing, deploying, or external profile change without the owner's explicit approval.
- Secrets live in server environment variables or `api/config.php` on the server only; never in
  Git, never in a build artifact.
- Rate limits and consent are enforced in code where a workflow can send something.
- Every number in a report or on the site must be traceable to a source, with a date.

## 9. Owner checklist

1. Set `ENQUIRY_OWNER_EMAIL` and `ENQUIRY_FROM_EMAIL`; send one test enquiry and one worker run.
2. Add the cron entry after the test send succeeds.
3. Set `VITE_GA4_ID` before the production build; confirm events in GA4 DebugView, then register `category` and `type` as event-scoped custom dimensions so `enquiry_submit` can be split into project and recruitment.
4. Choose the uptime monitor (Hostinger or external) and the alert address.
5. Create the four saved job searches and start the tracker table.
6. Put one monthly reporting slot on the calendar; use §7.
7. Re-read §8 before adding any new automation.
