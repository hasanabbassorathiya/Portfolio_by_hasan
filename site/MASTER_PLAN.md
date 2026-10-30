# Master Plan — hasanabbassorathiya.tech

Living plan and status. Canonical detail lives in the docs below; this page only records direction,
ownership and what is actually done.

| Concern | Canonical document |
|---|---|
| Current state, deliverables, verification | `DELIVERY.md` |
| Run, test, configure | `README.md` |
| Deploy, backup, rollback | `DEPLOY.md` |
| Design system | `DESIGN.md` |
| Component map | `COMPONENTS.md` |
| Enquiries, content, jobs, monitoring, reporting | `AUTOMATIONS.md` |
| Launch gates and owner approvals | `LAUNCH_CHECKLIST.md` |
| LinkedIn / GitHub / social drafts and content calendar | `LINKEDIN.md`, `GITHUB.md`, `SOCIAL.md`, `ASO.md` |

Last updated: 2026-10-29.

## Positioning (locked)

"Senior Software Engineer | Flutter & Mobile Products | AI Integration & Automation", Dubai.
Primary audiences: teams hiring senior mobile/AI ownership, clients commissioning builds or audits.
The site is a conversion surface for inbound roles, consulting and app users — not a link hub.

## Track status

| Track | State | Evidence |
|---|---|---|
| Engineering — React/Vite site, PHP/MySQL API, admin CRM, deploy scripts | Done | `DELIVERY.md` §10, §18 |
| Design — Bone & Ink system, self-hosted type, OG cards, full-colour imagery | Done | `DESIGN.md`, `COMPONENTS.md`, `evidence/2026-10-29/` |
| Content — 21-entry app catalogue (16 shipped), 3 client case studies, 9 essays, services, resources, résumé | Done | `src/content/`, `prerender.test.mjs` |
| Marketing — brag launch video, profile drafts, 4-week calendar, ASO plan | Drafted, not published | `../brag-output-2026-10-29-013040/`, `LINKEDIN.md`, `GITHUB.md`, `SOCIAL.md`, `ASO.md` |
| Automation — A–F workflows, enquiry worker dry-run | Documented and tested except live mail | `AUTOMATIONS.md` |
| QA — Node, PHP, hydration, axe, Playwright captures, Lighthouse | Done | `DELIVERY.md` §18 |

## Delivery phases (master prompt §15)

| Phase | State | Evidence |
|---|---|---|
| 1. Audit and discovery | Done | `DELIVERY.md` §2–§4; live site and references inspected in Playwright before changes |
| 2. Positioning and content verification | Done | Positioning above; `DELIVERY.md` §5 verified facts; `../hasan.md` |
| 3. Design exploration and approval | Done | `DESIGN.md`, `COMPONENTS.md`; direction iterated on owner feedback until the Bone & Ink build was adopted |
| 4. Website implementation | Done | `src/`, `dist/`, `DELIVERY.md` §18 |
| 5. Case studies and service pages | Done | Three `/work` case studies, six service routes, tests |
| 6. Contact forms and lead management | Done, live mail pending | Enquiry API, admin CRM, 195 PHP checks, CMS smoke; `DELIVERY.md` §13 items 4–5 |
| 7. Analytics, SEO and integrations | Done, two owner inputs pending | `DELIVERY.md` §8; GA4 ID and Cal.com URL in "Open decisions" |
| 8. Social profile assets and content calendar | Drafts done, publication owner-gated | `LINKEDIN.md`, `GITHUB.md`, `SOCIAL.md`, `ASO.md`, `DELIVERY.md` §14 |
| 9. Automation workflows | Documented, live cron owner-gated | `AUTOMATIONS.md`; worker dry-run only |
| 10. Testing, performance, accessibility and security | Done | `DELIVERY.md` §9–§11, §18; `evidence/2026-10-29/` |
| 11. Staging and deployment preparation | Done | `deploy-public_html.zip`, `DEPLOY.md`, rollback in `DELIVERY.md` §12 |
| 12. Production deployment after authorization | Blocked on owner approval | "Live deploy" in "Open decisions"; last approval covered only the 2026-10-28 build |

Priority order followed: P0 (broken CMS, contact failures, credibility) and P1 (positioning, homepage,
case studies, enquiry system, SEO) were completed first, P2 (service pages, analytics wiring, profiles,
core automation) followed, and P3 ideas were evaluated rather than assumed — the decisions and their
cost/benefit reasoning are in `DELIVERY.md` §20.

## Open decisions and blockers

1. **Cal.com** — booking URL not supplied; no booking UI is invented.
2. **Referral partners** — no partner URLs supplied; `/resources` currently lists only public packages and essays.
3. **GA4** — `VITE_GA4_ID` not set; telemetry is compiled out until it is.
4. **Mail** — `ENQUIRY_OWNER_EMAIL` / `ENQUIRY_FROM_EMAIL` unset; worker only dry-run.
5. **Store ratings** — refresh from the consoles before each launch push.
6. **Privacy wording** — owner review of `/privacy` pending.
7. **Publication** — LinkedIn/GitHub drafts not published; no external account is claimed as updated.
8. **Live deploy** — needs explicit approval; the last approval covered only the 2026-10-28 build.

## Working rules

- Verify with the commands in `README.md` §5; never claim a result that was not run.
- No invented metrics, testimonials, clients or ranking claims; verified facts only (`DELIVERY.md` §5).
- Never commit `api/config.php`, `.env*` or any secret; never overwrite them on the server.
- Keep `dist/` built from a minified `npm run build`; re-copy `.htaccess` before zipping.
- Every archive under `legacy/` or `ref/` is reference only — the live product is `site/`.
