# Needs candidate input

Updated: 2026-10-31
Status: open. Nothing in this file may be published, sent, or deployed until Hasan supplies the
value or confirms the claim. **Never replace a missing value with an invented one.**

This file is the working list behind the audit report at `site/AUDIT_2026-10-31.md`. It records what
the repository cannot resolve on its own: source evidence for owner-provided figures, one employment
overlap, credentials, and the integrations/approvals that are deliberately blocked.

## 1. Claims that need a source on file

| # | Claim | Where it appears | What is needed | Current handling |
|---|---|---|---|---|
| 1 | Good2Go Loans reached 50,000+ users in New Zealand | `site/src/content/resume.js`, `site/src/content/clients.js`, `/apps`, `/work` | A citable source (company statement, release, store copy, or written client confirmation) kept with the owner | Retained because the owner confirmed it; the site labels it as a client metric, not an audited figure |
| 2 | Nakheel Marinas reached 15,000+ downloads in its first month | `site/src/content/resume.js`, `/work` case study | Same as above, ideally a first-month report or store screenshot | Retained because the owner confirmed it |
| 3 | Masaar work contributed to roughly 25% better conversion | `site/src/content/resume.js` | A source or the owner's confirmation that this is safe to state in interviews | Kept as "contributed to roughly 25%"; soften or remove if it cannot be supported |
| 4 | Duas and Aamal: 4.9★, 1,058 Google Play reviews | `/apps`, home, `llms.txt` | Recheck the store listing before each external reuse | Snapshot taken 2026-10-31; CMS can update it without a code change |
| 5 | GitHub: 52 public repositories, 565 contributions | Not published on the site | Recheck the GitHub profile if these numbers are used in LinkedIn/GitHub drafts | Do not add to the site without a dated screenshot |
| 6 | Udemy certificate: exact course title and completion date | Résumé links to the public issuer PDF | The course title and date shown on the certificate | Only "Udemy course certificate" is claimed; no title is invented |
| 7 | PMP certification | Previously present in older drafts | Nothing — **PMP is not held** | Removed everywhere; do not reintroduce |
| 8 | BSc Information Technology, University of Mumbai, 2019 | Résumé, About facts | Confirm spelling and year if used in an official application | Retained as owner-provided |
| 9 | Kumite 1 League dates overlap Beedev Solutions | `site/src/content/resume.js`: Kumite 01/2019–08/2020; Beedev 08/2019–03/2021 | Confirm whether the Kumite work was concurrent/contract, or correct one of the date ranges | Both entries remain; the overlap is disclosed here rather than hidden |
| 10 | Chalhoub Group end date (01/2026) and all other end months | Résumé, case studies, `hasan.md` | Confirm each month against contracts or LinkedIn | Retained as supplied; no rounding into a higher year count |
| 11 | "100K+ users" aggregate | Removed from the site | An attributable source covering the named apps | Withdrawn; do not reinstate |
| 12 | Testimonials | None on the site | Real, attributable quotes with permission | None added; do not invent |

### Employment timeline used by the site

| Period | Company | Role |
|---|---|---|
| 07/2023 — 01/2026 | Chalhoub Group | Mobile Engineering Lead |
| 08/2022 — 06/2023 | Belong Interactive | Lead Senior Software Engineer — Mobile |
| 01/2022 — 08/2022 | Masaar | Senior Software Engineer — Mobile |
| 03/2021 — 11/2021 | Vervali Systems | Team Lead — Flutter |
| 08/2019 — 03/2021 | Beedev Solutions | Senior Flutter Developer |
| 01/2019 — 08/2020 | Kumite 1 League | Flutter Developer |

The earliest start (01/2019) is why the public figure is deliberately pinned to the owner-confirmed
`experience_years: 6` instead of letting the calendar round it up to 7+.

## 2. Owner-gated integrations

| Integration | Status | What is blocked |
|---|---|---|
| Cal.com | Not configured | `VITE_CAL_URL` is absent, so the booking link is not rendered at all; no placeholder URL exists |
| GA4 | Optional, not configured | A measurement ID and a consent decision are needed before enabling it |
| Referral links | Not configured | Real destination URLs and disclosure copy are needed; no placeholder links are shipped |
| Enquiry email worker | Implemented, dry-run by default | SMTP host/user/password and the sender/acknowledgement policy; no real mail has been sent |
| Newsletter sending | Storage and unsubscribe exist | A sending provider/credentials if delivery beyond storage is wanted |
| IndexNow / Search Console | Wiring exists | Owner confirmation that the production key/verification is in place |

Credentials live in `site/api/config.php` and `.env` on the server. They are never committed. The
sample file is `site/api/config.sample.php` / `site/.env.example`.

## 3. Approvals required before production

| Action | Why it needs explicit approval |
|---|---|
| Deploy this branch to Hostinger `public_html` | The live site currently serves the old copy; deployment is a production change |
| Apply `site/api/migrate-2026-10-31-profile-corrections.sql` | Deletes the stale `users_reached` key, sets `experience_years = 6`, and rewrites `sub`/`stats_json`; requires a database backup first |
| Edit CMS profile fields in Directus | The live read API returns the old headline, résumé link, and stats until the CMS rows change |
| Enable SMTP / send real email | Deliverability and consent implications |
| Enable GA4 | Requires the consent decision above |
| Change DNS, CDN, or Hostinger plan settings | No DNS change is planned; any change is outside this audit |

## 4. External accounts — drafts only

`site/LINKEDIN.md`, `site/GITHUB.md` and `site/SOCIAL.md` contain copy prepared for review. No
LinkedIn, GitHub, store listing, or other external account was modified during this audit. Publication
is the owner's action.

## 5. Rechecks before publishing

- Store ratings and download counts (they drift).
- Live-vs-local at 1440/1280/1024/768/390/320 after deployment.
- Enquiry form once against the production API (including a retry with the same `requestId`).
- Privacy page if analytics, consent, newsletter, or retention behaviour changes.
- Lighthouse on the live host, not only the local harness.

## 6. Known non-claims

- No testimonials exist and none were added.
- No "100K+ users" aggregate is claimed.
- No PMP certification is claimed.
- No AI accuracy, cost-saving, or revenue figure is claimed; the AI copy describes methods and
  boundaries, not invented outcomes.
