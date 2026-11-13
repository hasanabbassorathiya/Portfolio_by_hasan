# Distribution plan — what happens to the video files

Written 2026-11-03 alongside [marketing/2026-11-03/PRODUCTION-PLAN.md](../marketing/2026-11-03/PRODUCTION-PLAN.md).
This file covers **shipping and posting**. It does not cover rendering — that is the production plan.

Caption copy for every post lives in [SOCIAL.md](SOCIAL.md). Claim wording lives in
§8 of the production plan. If a number is not in `hasan.md`, it does not go on screen or in a caption.

---

## 1. The inventory

Rendered 2026-11-03 through OpenMontage; all nine files are in
[`marketing/2026-11-03/out/`](../marketing/2026-11-03/out/) with their verification and known limits in
[DELIVERY.md](../marketing/2026-11-03/DELIVERY.md). Nothing has been posted yet.

| File | Aspect | Made for | Reused on |
|---|---|---|---|
| `master-16x9.mp4` (45s) | 16:9 | LinkedIn, YouTube, GitHub README | Medium embed |
| `master-1x1.mp4` (45s) | 1:1 | X feed, Instagram grid, Buy Me a Coffee | LinkedIn preview |
| `master-9x16.mp4` (45s) | 9:16 | Instagram Reels, YouTube Shorts, TikTok | — |
| `clip-duas.mp4` · `clip-bulbvpn.mp4` · `clip-blankspace.mp4` · `clip-stoolap.mp4` (12–18s) | 9:16 | Reels / Shorts / X | one per week, §4 |
| `consulting-1x1.mp4` · `consulting-9x16.mp4` (20s) | 1:1, 9:16 | services path: LinkedIn, /services, newsletter header | — |

All seven are silent with burned-in captions, so every one of them reads correctly on a muted feed.
Cover frames come from the same compositions — no separate thumbnail shoot.

---

## 2. Where each one goes

**LinkedIn** — the master reel is the recruiter surface. Post natively, put the link in the first
comment and the post body, then add it to the profile's Featured section, where it keeps working
after the feed moves on. The consulting cut goes on the Services page section, not the feed.

**GitHub** — profile README, 16:9, autoplay-muted loop, one line under it. The README currently
links a FlowCV resume URL instead of this site's own `/resume`; fix that in the same pass
(otherwise the video and the CV disagree about who you are).

**YouTube** — the master reel as a normal video with the full caption as description; each 9:16
clip as a Short. Shorts carry a link to the channel's own site.

**Instagram** — Reels for the clips and `master-9x16`; `master-1x1` as a grid post with a 1:1 cover.
The bio already carries `hasanabbassorathiya.tech` (verified signed-in, 2026-11-03).

**X** — `master-1x1`, then the clips over the following weeks. No handle exists on file for X,
so the account must be yours before anything is scheduled there.

**Medium** — no upload. Each essay gets the reel embedded plus one line of context. The publication
already exists and is reachable.

**Buy Me a Coffee** — `master-1x1` on the page. It is a support surface, not a reach engine: keep it
secondary, never the primary CTA.

**Email / newsletter (SHIPPING NOTES)** — the consulting cut as the header for one issue; the master
reel in the next. Nothing in the template asserts a subscriber count.

**Search** — the reel earns its place on the site itself: `og:video` on the home page, the
`/resume` page linking it, and the video kept out of the sitemap unless it has a real hosted URL.

Not touched: **Discord, Reddit, Dev.to, Product Hunt** — no verified accounts exist for them, and
nothing gets invented to fill a channel.

---

## 3. Why this is built to receive offers instead of request them

The mechanism, and the psychology behind each move — with the two principles we deliberately refuse.

**Authority, earned by artifacts, not adjectives.** Credentials persuade when they are checkable.
Every beat is a document a viewer can open themselves: a Play listing with 1,063 ratings, a
`pub.dev` package at v2.0.1, a NZ fintech with 50,000+ users. This is also why the reel never says
"passionate" — the receipt argues the case, and adjectives would weaken it.

**Social proof, receipts only.** Ratings carry their denominator or they do not appear. That rule
cuts both ways: it forbids "100K+ users" (never substantiated, already removed from the site once)
and it forbids a 5.0★ that rests on four ratings. A viewer who checks and finds the number real
trusts everything else on screen.

**Liking through similarity and specificity.** People say yes to those who sound like them. The
copy names the stack, the decision, and the consequence — the exact register a Flutter lead or a
fintech CTO recognises as one of their own. First person for stories, third person for facts.

**Commitment, in both directions.** Small consistent asks compound: follow, watch the next clip,
read the essay. On our side, a visible weekly shipping streak is a public commitment — and public,
consistent signals are the ones recruiters remember.

**Reciprocity that is already real.** Before asking for anything, give something useful: nine
essays, an open-source package, a CMS API guide with a Postman collection. The ask afterwards
lands as a conversation, not a pitch.

**Unity, stated narrowly.** "For teams shipping Flutter into regulated fintech and mobility" is a
real in-group. "For everyone" is not a tribe, so the reel names the domain rather than the vibe.

**What we refuse.** *Scarcity* — no countdowns, no "two slots left this quarter", no invented
deadlines; you are genuinely available, and fake urgency is both untrue and the kind of thing that
gets spotted. *Manufactured unity* — no manufactured movement language.

And the honest limit: a reel does not generate offers on its own. It converts attention you already
have and makes a cold profile legible in 45 seconds. The offers come from being findable
(GSC and Bing verified, sitemap submitted), being reachable (working enquiry form, phone, mail),
and being seen repeatedly. This plan is the second and third of those.

---

## 4. Cadence

Six weeks, one post per channel per week, no stacking.

| Week | Headline | Supporting |
|---|---|---|
| 1 | `master-16x9` on LinkedIn + Featured; same file on YouTube | `master-1x1` on X · GitHub README video + `/resume` link fix |
| 2 | `clip-duas` Reel + Short | grid post `master-1x1` · one Medium essay embeds the reel |
| 3 | `clip-bulbvpn` Reel + Short | X · newsletter issue with the master reel |
| 4 | `clip-blankspace` Reel + Short | X · Buy Me a Coffee page gets `master-1x1` |
| 5 | `clip-stoolap` Reel + Short (the dev-community one; also cross-post where Flutter devs actually are, once those accounts exist) | X · second Medium embed |
| 6 | `consulting-1x1` on LinkedIn, wired into `/services` | `consulting-9x16` on Reels/Shorts · newsletter header |

Weeks 2–5 exist so the streak, not a single launch spike, is what registers.

---

## 5. Measurement

- **Inbound** — the enquiry form's source field, the opportunities table, and `/resume` + `/services`
  visits. First-party beacon plus GA4 (measurement ID `G-6W9FY8CEE5`, live via CMS settings). Both
  sinks are consent-gated: a cookie banner asks before anything loads, and DNT/GPC declines by
  default. The banner went live with the 2026-11-12 consent build (owner-approved) and is verified
  in production: no beacon or GA4 before consent, GA4 boots only after Accept, Decline stays off.
- **Reach** — per-channel views and profile clicks, recorded by hand in `marketing/<date>/metrics.csv`
  on day 3 and day 14 after each post.
- **Search** — Google Search Console and Bing Webmaster Tools are verified; sitemap submitted,
  IndexNow live. Watch queries hitting `/resume` and `/work`.
- **UTM** — `utm_source=<linkedin|instagram|x|youtube|medium|github|bmc>`, `utm_medium=video`,
  `utm_campaign=receipts-2026-q4`, `utm_content=<master|duas|bulbvpn|blankspace|stoolap|consulting>`.

Read the numbers before writing about them. If a clip underperforms, that goes in this file too —
the honest version of a result is the only version that helps the next one.

---

## 6. Owner-blocked, unchanged

Publishing to any account (every post needs its own approval) · X, Discord, Reddit, Dev.to,
Product Hunt handles · referral URLs · mail credentials. Nothing here invents any of them.

**Resolved since 2026-11-03:** GA4 is live (`G-6W9FY8CEE5` via CMS) and the Cal.com booking URL is
set (`https://cal.com/hasanabbassorathiya`). GitHub profile (README, pins, metadata) and LinkedIn
profile (headline, About, location, website) are published. The consent build (cookie banner,
AI-first headline, corrected Instrument Serif) deployed to the live docroot on 2026-11-12 with
owner approval; `api/config.php` was preserved byte-for-byte and a pre-deploy backup is kept on-box.

**Resolved — the experience figure.** The owner chose **"7+ years"** everywhere. The master and
consulting reels were re-rendered with "7+ years" captions (2026-11-12), the site's `profile.js`
and the live CMS `profile.experience_years` both read `7`, and the LinkedIn/GitHub profiles say 7+.
One figure across profile + reel + site; the launch post can ship against it.
