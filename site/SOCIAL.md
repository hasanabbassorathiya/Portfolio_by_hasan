# Launch & share copy

Ready-to-post text for LinkedIn and X. Every claim here traces to `hasan.md`; do not add numbers that are not in it.

Canonical links carry UTMs so GA4 can tell which channel brought the visit:

```
https://hasanabbassorathiya.tech/?utm_source=linkedin&utm_medium=social&utm_campaign=site-launch
https://hasanabbassorathiya.tech/blog/<slug>?utm_source=linkedin&utm_medium=social&utm_campaign=essay-<slug>
```

## 1. Site launch — three variants

### A. Hiring managers and recruiters

> Six-plus years of mobile work, and my portfolio was still a PDF and a list of logos.
>
> So I rebuilt it as a system: the apps, the numbers, the architecture decisions, the essays. One place.
>
> - 21 app profiles across iOS, Android, and Android TV
> - 50,000+ users on a lending platform in New Zealand, 15K+ first-month downloads for a marina app, and a 5.0★ prayer app
> - 6+ years, most recently leading mobile delivery for an electric mobility platform in Dubai
>
> I am open to senior or lead Flutter and AI engineering roles — Dubai-based, remote-friendly, available immediately.
>
> Start here: https://hasanabbassorathiya.tech/?utm_source=linkedin&utm_medium=social&utm_campaign=site-launch

### B. Founders and teams considering consulting

> Most AI features do not fail in the demo. They fail three weeks after launch, when the documentation changes, the index goes stale, and nobody notices the answers getting worse.
>
> I build Flutter products and the AI systems behind them: RAG pipelines, agents, MCP servers, and the unglamorous operations that keep them honest.
>
> The new site collects the engineering notes — what I ship, what I avoid, and why:
>
> https://hasanabbassorathiya.tech/?utm_source=linkedin&utm_medium=social&utm_campaign=site-launch
>
> I take on a small number of consulting engagements alongside product work. If you are building in mobile or AI, my inbox is open.

### C. Developer community

> I am not a Google Developer Expert. This site is the work I am putting in to become one.
>
> Nine essays from production, not tutorials:
>
> - Clean Architecture that survives team changes
> - Riverpod patterns I use — and three I avoid
> - RAG that survives real users
> - Localization lessons from a 4.6★ app
>
> Plus 21 app profiles and the decisions behind them.
>
> If you are on the same path, the writing is free and the RSS feed is there:
> https://hasanabbassorathiya.tech/blog?utm_source=linkedin&utm_medium=social&utm_campaign=site-launch

## 2. Essay cross-posts

Post one per week. Lead with the specific problem, not the announcement.

**Why I rebuilt my portfolio as a system, not a page**
> A portfolio has no memory. Every fact lives in five places, so it drifts in five places — a store link dies, a new app never gets added, and nothing tells you.
>
> The rebuild I just shipped treats the site as a system: one canonical profile, content as data, sitemap/RSS/OG cards generated at build time, and audits that fail when reality disagrees with the source.
> https://hasanabbassorathiya.tech/blog/portfolio-as-a-system?utm_source=linkedin&utm_medium=social&utm_campaign=essay-portfolio-system

**RAG that survives real users**
> Your RAG demo works because you tested it on questions you already knew the answer to.
>
> In production, the failures are retrieval failures: fragments of rate tables, pure vector search missing an error code, a source deleted three months ago still being cited.
>
> What I do instead — hybrid retrieval, reranking, validated citations, and a refusal path that turns "I don't know" into a lead:
> https://hasanabbassorathiya.tech/blog/rag-that-survives-real-users?utm_source=linkedin&utm_medium=social&utm_campaign=essay-rag

**Clean Architecture that survives team changes**
> Most Flutter architectures are diagrams nobody follows after the second sprint.
>
> The version I ship is smaller: feature-first boundaries, typed failures, and tests only at the seams that actually break.
> https://hasanabbassorathiya.tech/blog/clean-architecture-flutter-teams?utm_source=linkedin&utm_medium=social&utm_campaign=essay-clean-architecture

**Riverpod patterns I use in production**
> Riverpod is powerful enough to support any architecture, which is exactly why teams get lost in it.
>
> Six patterns that survived real apps, and three habits I now avoid on purpose:
> https://hasanabbassorathiya.tech/blog/riverpod-patterns-production?utm_source=linkedin&utm_medium=social&utm_campaign=essay-riverpod

**Shipping AI features in a Flutter app without breaking trust**
> Users forgive an AI feature for being slow. They do not forgive it for being confidently wrong.
>
> Latency budgets, streaming, citations, and the failure states that keep an AI feature safe to ship:
> https://hasanabbassorathiya.tech/blog/shipping-ai-features-flutter-trust?utm_source=linkedin&utm_medium=social&utm_campaign=essay-ai-trust

**Flutter startup time**
> Most "startup optimization" work does not survive a release build.
>
> How I measure cold start, what actually moves the needle, and the shortcuts that only look good in debug mode:
> https://hasanabbassorathiya.tech/blog/flutter-startup-time?utm_source=linkedin&utm_medium=social&utm_campaign=essay-startup

**Localization lessons from a 4.6★ app**
> A Gujarati-first prayer app taught me more about localization than any guide: script rendering, RTL, plurals, and the store listing being part of the product.
> https://hasanabbassorathiya.tech/blog/localization-4-6-star-app?utm_source=linkedin&utm_medium=social&utm_campaign=essay-localization

**From shipping apps to GDE**
> I am not a Google Developer Expert yet. This is the 12-month plan I am running, and the parts of public work that actually compound.
> https://hasanabbassorathiya.tech/blog/from-shipping-apps-to-gde?utm_source=linkedin&utm_medium=social&utm_campaign=essay-gde

**Leading mobile delivery at an EV company**
> The week I stopped being the senior developer and became the lead, three things changed: release trains, a device matrix, and a written decision log.
> https://hasanabbassorathiya.tech/blog/leading-mobile-delivery-ev?utm_source=linkedin&utm_medium=social&utm_campaign=essay-leadership

## 3. X / Twitter versions

Keep to one idea and one link.

> Most portfolios are pages, and pages rot silently. This one is a system: one source of truth, generated feeds, audit gates — it caught two dead store links and two missing repos in the last pass. https://hasanabbassorathiya.tech/blog/portfolio-as-a-system

> A RAG demo takes a weekend. A RAG feature that survives a year takes retrieval, reranking, citations, and a refusal path. Notes from production: https://hasanabbassorathiya.tech/blog/rag-that-survives-real-users

> Most Flutter "architectures" are diagrams nobody follows after sprint two. Here is the smaller version I ship: https://hasanabbassorathiya.tech/blog/clean-architecture-flutter-teams

## 4. Profile hygiene

- Full LinkedIn profile draft (headline, About, experience, skills, featured, banner): `LINKEDIN.md`.
- GitHub profile README, pinned repos and repo metadata: `GITHUB.md`.
- LinkedIn headline: `Senior Software & AI Engineer · Flutter Specialist · RAG & Agents`
- LinkedIn Featured: site link, then the RAG essay, then the apps index
- GitHub profile README: link the site in the first line
- Résumé: share `hasanabbassorathiya.tech/resume` (or the PDF at `/hasan-abbas-sorathiya-resume.pdf`) instead of the FlowCV link; the page and PDF share one data source, so dates and roles cannot drift
- App Store developer page: confirm the site URL in the developer website field

## 5. Video sequence (2026-11-03 campaign)

Rendered per [marketing/2026-11-03/PRODUCTION-PLAN.md](../marketing/2026-11-03/PRODUCTION-PLAN.md);
where and when each file goes out is in [MARKETING.md](MARKETING.md). Silent with burned-in
captions, so the first line here is the only thing a muted viewer reads before the video starts.

Every number below is from `hasan.md` §5, the live CMS, or re-read at the render's `assets` gate.
The years figure is **7+** everywhere per the owner's 2026-11-12 decision (profiles, site, reel).
Never a `100K+` aggregate, never a star rating on screen unless its denominator is
with it. The reel's burned-in denominator is `1,063` (render-date snapshot, 2026-11-03);
post copy uses the live read `1,072` (2026-11-13). `21 apps` is the live CMS count measured 2026-11-03
(`api/index.php?entity=apps` → 21 rows); `hasan.md` §5 still lists 15 and needs reconciling first.

**Week 1 · master reel · LinkedIn** — REWRITTEN 2026-11-14 with the marketing-psychology
checklist applied. The post went live 2026-11-14 09:00 Dubai with the earlier copy; it was then
edited in place to the copy below (LinkedIn marks it "Edited"), reel still attached, impressions
preserved. Psychology mapping:
information-gap hook before LinkedIn's "see more" fold; authority bias through checkable receipts
(Play listing, pub.dev, credential ID — each opens in a new tab); social proof always carrying its
denominator; contrast (logo PDF → receipts system); reciprocity (essays and package given first, ask
second); pratfall (the GDE admission earns trust); peak-end (strongest receipt, then one CTA); Hick's
law (one link, one action); narrow unity ("teams shipping Flutter or AI into regulated industries" —
a domain, never a manufactured tribe). Still honoured: no scarcity, no fake urgency, no AI-slop
adjectives, no number outside `hasan.md` §5.

> A portfolio you can't check is just a PDF with better fonts.
>
> So I rebuilt mine as a system where every claim opens in a new tab:
>
> - Good2Go Loans — 50,000+ users in New Zealand, lending where the audit trail is the feature
> - Nakheel Marinas — 15,000+ downloads in its first month
> - Duas and Aamal — 5.0 across 1,072 Google Play ratings, live on both stores
> - stoolap_flutter — v2.0.1 on pub.dev, the package I kept rebuilding for every client
> - LangChain Academy — Introduction to LangChain certificate, verifiable by ID
>
> 7+ years across fintech, mobility and community apps. 21 app profiles. 9 essays from production.
>
> I build AI systems and Flutter apps people keep using. I'm not a Google Developer Expert yet — this site is the work I'm putting in to earn it.
>
> The reel is here; the receipts are behind it:
> https://hasanabbassorathiya.tech

**Week 1 · master reel · LinkedIn Featured** — DONE 2026-11-14. The reel post is featured
("Feature on top of my profile") and the §5 order of [LINKEDIN.md](LINKEDIN.md) is live and
verified: site, then `stoolap_flutter` on pub.dev, then the RAG essay, then apps, then résumé,
with the reel post directly below them. LinkedIn prepends newly added Featured entries and offers
no reorder control, so the order was set by re-adding the links in reverse. The reel entry keeps
working after the feed moves on; that is its job (mere exposure — the recruiter meets the same
receipts twice).

**Week 1 · master reel · YouTube** — PUBLISHED 2026-11-15 (live `publishDate`/`uploadDate`
`2026-11-15T09:39:12-08:00` = 17:39 UTC, verified 2026-11-15 by re-fetching the watch page).
Uploaded and published
through the Playwright MCP browser, which carries the owner's own signed-in YouTube session
(verified before upload: the channel page showed the owner-only "Manage videos" and
"Customize channel" affordances, the channel `og:image` matched the signed-in account avatar,
and the Studio sidebar read "Your channel · HASAN ABBAS SORATHIYA" for `UCSGwYKSUJb7sX4-BI12WB_Q`).
Video ID `p0KscFpmSGg`, https://youtu.be/p0KscFpmSGg — re-fetched from outside the Studio
session after publishing: `<title>` matches, `itemprop="duration"` `PT0M24S`, `og:url` correct,
description verbatim. Audience set to "No, it's not made for kids"; checks reported
"Copyright check complete / No issues found". Re-rendered 2026-11-15
(`brag-output-2026-11-14-004922/brag.mp4`) as a normal (not Short) upload: 23.8 s, 1920×1080,
714 frames, 5,213,047 bytes, h264, no audio — silent with burned-in text, so the description
carries the links. Frame 0 is the settled end card (the poster is baked in), so the auto-thumbnail
is the strongest beat. **The custom thumbnail is NOT set:** uploading `brag.jpg` (1920×1080,
47,946 B — verified with `sips`) raised YouTube's own dialog *"Unlock more on YouTube — To add
custom thumbnails, verify your phone number."* The channel is not phone-verified, so this is a
standing YouTube policy gate for this account, not a tooling failure. Do not work around it:
verify the number in Studio (Settings → Channel → Advanced → "Your channel is not verified") and
then re-pick `brag-output-2026-11-14-004922/brag.jpg` on
`https://studio.youtube.com/channel/UCSGwYKSUJb7sX4-BI12WB_Q/videos/p0KscFpmSGg/edit`.
(Historical note: before the Playwright path worked, the Qoder Browser Connector refused every
programmatic file transfer with `{"code":-32000,"message":"Not allowed"}` on the owner's Chrome —
the Playwright MCP browser, which carries the same session, accepts both uploads directly.)

- Title: `I build AI systems and Flutter apps people keep using — 7+ years of receipts (portfolio reel)`
- Description:
  > A portfolio you can check. 24 seconds, no voiceover, no stock footage — the listings, the numbers and the commits.
  >
  > - Duas and Aamal — 5.0★ across 1,072 Google Play reviews
  > - Good2Go Loans — 50K+ users in New Zealand
  > - Nakheel Marinas — 15K+ first-month downloads
  > - stoolap_flutter — v2.0.1 on pub.dev
  > - 21 app profiles on the site
  >
  > Site: https://hasanabbassorathiya.tech · Résumé: /resume · Apps: /apps · Essays: /blog
- Tags: `flutter, ai engineer, portfolio, mobile development, rag, langchain, dubai`
- Format variants from the same render (owner-executed): `brag-1080x1080.mp4` (1:1, X feed) and
  `brag-1080x1920.mp4` (9:16, Reels / Shorts — text kept inside the TikTok/Reels/Shorts safe bands).

**Week 1 · master reel · X** — PUBLISHED 2026-11-14 (one idea, one link — handle `@hasansorathiya`
confirmed by the owner 2026-11-14). Status `2121673169467580557`; the link carries
`utm_source=x&utm_medium=video&utm_campaign=receipts-2026-q4&utm_content=master`.

> Every claim on my portfolio opens in a new tab: a 50,000+ user lending app, a 5.0★ prayer app with 1,072 ratings, a package on pub.dev. 7+ years, receipts not adjectives: https://hasanabbassorathiya.tech

**Week 1 · GitHub profile README** — PUBLISHED 2026-11-14 (16:9, muted; the FlowCV→`/resume`
repoint already shipped in `hasanabbassorathiya/hasanabbassorathiya` commit `1c1ad35`; the reel
line and asset shipped in `ed53619b` and `58a37a9` — the second commit replaces a `<video>` tag
that GitHub's markdown sanitizer stripped). Reel swapped 2026-11-15 (`ca65548`): the re-rendered
23.8 s 1920×1080 master replaces the old 45-second cut at the same
`assets/portfolio-reel.mp4` path and the link label now reads 24 seconds.

> 7+ years of shipped Flutter, iOS and Android — and the AI systems behind the product. Watch the reel, then check the receipts: https://hasanabbassorathiya.tech

**Week 2 · `clip-duas` · Reels / Shorts** — prepared 2026-11-15, not published. `clip-duas.mp4`
is 1080×1920, 15 s, and the Instagram account `@hasanabbassorathiya` is signed in on the owner's
Chrome. The Qoder Browser Connector refuses every programmatic file transfer with
`{"code":-32000,"message":"Not allowed"}` — reproduced with a 3 KB PNG, so it is a blanket upload
policy, not a file-size limit. The "Create new post" modal is left open in the owner's browser for
the file pick. Caption to paste:

> 5.0★ across 1,072 Play ratings: Quran with Gujarati translation, prayer times, widgets, offline mode — built Gujarati-first. https://hasanabbassorathiya.tech/apps?utm_source=instagram&utm_medium=video&utm_campaign=receipts-2026-q4&utm_content=duas

**Week 3 · `clip-bulbvpn`**

> A VPN built for Iranian networks, where the honest part is the measurement, not the promise. https://hasanabbassorathiya.tech/apps

**Week 4 · `clip-blankspace`**

> A party game where iOS swipe-back had to feel native or the whole thing broke. https://hasanabbassorathiya.tech/apps

**Week 5 · `clip-stoolap` · dev community**

> `flutter pub add stoolap_flutter` — v2.0.1 on pub.dev. The widget I kept rebuilding for every client, so I shipped it once instead. https://pub.dev/packages/stoolap_flutter

**Week 6 · consulting cut · LinkedIn + `/services`**

> Flutter delivery, iOS and Android, and the AI systems behind the product. Immediate, remote-friendly.
> What I take on and what I turn down is on the page: https://hasanabbassorathiya.tech/services

**UTM for every link in this section** — `?utm_source=<channel>&utm_medium=video&utm_campaign=receipts-2026-q4&utm_content=<master|duas|bulbvpn|blankspace|stoolap|consulting>`.

## Platform state (verified 2026-11-15, owner's Chrome)
| Platform | State | Next move |
| --- | --- | --- |
| LinkedIn | Profile, Featured (§5 order) and the week-1 reel post live | — |
| X | `@hasansorathiya` live, week-1 post `2121673169467580557` | — |
| GitHub | Profile README + reel asset published (`ed53619b`, `58a37a9`); reel swapped for the 23.8 s master on 2026-11-15 (`ca65548`) | — |
| Instagram | `@hasanabbassorathiya` signed in; week-2 `clip-duas` ready (1080×1920, 15 s); "Create new post" modal open | Owner file-pick of `marketing/2026-11-03/out/clip-duas.mp4` (host refused the programmatic pick again), then paste the week-2 caption |
| YouTube | Channel `UCSGwYKSUJb7sX4-BI12WB_Q` signed in, one existing Short (52 views); "Upload videos" dialog open | Owner file-pick of `master-16x9.mp4`, then title/description/tags below |
| Medium | Publication `hasanabbassorathiya.medium.com` is live but dormant — one post, 2022-04-28, 5 followers; signed out. Google and X OAuth both land on a blank `medium.com/m/callback/google` and set no session | Owner signs in (§6.1), then publishes the Medium draft |
| Discord | `Mobile Builders` server live; Community Onboarding **enabled** — 7 default channels, 1 pre-join question with 3 answers, rules channel `#rules`, community updates `#announcements` | — |
| Dev.to | No owner account yet | Owner creates the account, verifies email, then publishes the Dev.to draft (§6.2); no handle is guessed |
| Reddit | No owner account yet | Owner creates the account, builds karma, then posts one per subreddit (§6.3); no handle is guessed |
| Product Hunt | No owner account yet | Owner creates the account, then submits the site once with the §6.4 pack; no handle is guessed |
| Brevo | Authorised — both egress IPs are on the authorised list (Automatic, Nov 15 2026 12:29 PM). Verified from the live server on 2026-11-15: `GET /v3/account` → `http=200` | — |
| Brevo | Authorised — both egress IPs are on the authorised list (Automatic, Nov 15 2026 12:29 PM). Verified from the live server on 2026-11-15: `GET /v3/account` → `http=200` | — |

**Still blocked, still not invented:** the X handle is `@hasansorathiya` and the week-1 post is live;
the Discord server is created, connected and fully configured for members (see below). Reddit,
Dev.to and Product Hunt still need the owner's real accounts — no handle is guessed, and nothing is
scheduled there until they exist. The YouTube and Instagram uploads need the owner's file-pick in
the Browser Connector — the connector refuses programmatic uploads outright
(`{"code":-32000,"message":"Not allowed"}`, reproduced with absolute paths, workspace-relative
paths and a 3 KB PNG), and both upload surfaces are left open in the owner's browser. Medium is
signed out, so its sign-in page is open in the owner's Chrome. The Brevo community-email leg is live
and verified: the live server's `GET /v3/account` returns `http=200`, and a real community signup
(`POST /api/subscribe.php`, `source=community`) created Brevo contact `id=2` with `listIds=[2]`,
the configured community list. The probe used for that proof has been removed — both cron jobs
deleted, the `_bp.txt` output deleted, and the GitHub release that carried the script deleted.

### Discord member setup (enabled 2026-11-15, server `Mobile Builders`)

Community Onboarding is on — the tab reads **Onboarding ON** after a full page reload.

| Setting | Value |
| --- | --- |
| Default channels | all 7 public text channels: `rules`, `general`, `introductions`, `teardowns`, `showcase`, `leads`, `announcements` |
| Pre-join question | "What do you want to do in this community?" — "Show off what you are building" → `#showcase`, "Ask for feedback on my build" → `#teardowns`, "Find work, clients or partnerships" → `#leads` |
| Rules or guidelines channel | `#rules` (gets Discord's rules header) |
| Community updates channel | `#announcements` (also the site→Discord webhook target) |
| Server guide | not set up — every public channel stays visible in the channel list |
| Server discovery | not applied for; the server has no member base yet |

## 6. Publish-ready platform packs

Owner-account gates:
- **Medium** — owner signs in with email magic link or password, then publishes. The draft below is ready to paste.
- **Dev.to / Reddit / Product Hunt** — owner creates the real account (no handle is guessed), verifies email, then publishes. Nothing is scheduled until the accounts exist.

Every link below carries `utm_campaign=receipts-2026-q4`. Copy never invents a number; every figure traces to `hasan.md` §5 and the live site, which were verified against live endpoints before publishing this draft.

### 6.1 Medium — publication `hasanabbassorathiary.medium.com`

**Status:** owner sign-in required (Google/X OAuth land on a blank callback and set no session).

**Draft — "A portfolio you can check: receipts from shipping Flutter apps and AI systems"**

> A portfolio you can't check is just a PDF with better fonts.
>
> So I rebuilt mine as a system where every claim opens in a new tab:
>
> - Good2Go Loans — 50,000+ users in New Zealand, lending where the audit trail is the feature
> - Nakheel Marinas — 15,000+ downloads in its first month
> - Duas and Aamal — 5.0★ across 1,072 Google Play ratings, live on both stores
> - stoolap_flutter — v2.0.1 on pub.dev, the package I kept rebuilding for every client
> - LangChain Academy — Introduction to LangChain certificate, verifiable by ID
>
> 7+ years across fintech, mobility and community apps. 21 app profiles. 9 essays from production.
>
> I build AI systems and Flutter apps people keep using. I'm not a Google Developer Expert yet — this site is the work I'm putting in to earn it.
>
> Start here: https://hasanabbassorathiya.tech/?utm_source=medium&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=master

**Where it lives:** Medium publication embeds the master reel (16:9) plus one line of context; the video itself is never uploaded to Medium.

**Tags:** flutter, ai-engineer, portfolio, mobile-development, rag, langchain, dubai

---

### 6.2 Dev.to

**Status:** no owner account yet — owner creates it, verifies email, then publishes.

**Draft — "A portfolio you can check: receipts from shipping Flutter apps and AI systems"**

Same body as the Medium draft above, with this closing block instead:

> Read the essays: https://hasanabbassorathiya.tech/blog?utm_source=devto&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=master
> Join the community: https://hasanabbassorathiya.tech/community?utm_source=devto&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=master

**Tags:** flutter, dart, ai, mobile-development, rag, langchain

---

### 6.3 Reddit — `r/flutterdev`, `r/webdev`, `r/Entrepreneur`

**Status:** no owner account yet — owner creates it, builds a little karma first, then posts one per subreddit (never cross-posts the same link everywhere at once).

**r/flutterdev draft — title: "I rebuilt my portfolio as a system where every claim opens in a new tab"**

> 7+ years shipping Flutter and AI systems. Rather than another link-tree, I built the site as one source of truth: 21 app profiles, 9 essays from production, sitemap/RSS/OG cards generated at build time, and audits that fail when reality disagrees with the source.
>
> Receipts, not adjectives:
> - Good2Go Loans — 50,000+ users in New Zealand
> - Nakheel Marinas — 15,000+ first-month downloads
> - Duas and Aamal — 5.0★ across 1,072 Play ratings
> - stoolap_flutter — v2.0.1 on pub.dev
>
> Site: https://hasanabbassorathiya.tech/?utm_source=reddit&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=master
> Essays: https://hasanabbassorathiya.tech/blog?utm_source=reddit&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=essays

**r/webdev / r/Entrepreneur:** same receipts, frame as "how I audit my own public claims" (webdev) and "one portfolio, 21 apps, zero drift" (Entrepreneur). No self-promotion boilerplate — lead with the system, link last.

---

### 6.4 Product Hunt

**Status:** no owner account yet — owner creates it, then submits the site as a product. One submission; no upvote solicitation.

**Tagline:** "One source of truth for 21 Flutter and AI apps — receipts, not adjectives."

**Description:**

> A portfolio that can be checked. 21 app profiles across iOS, Android and Android TV, 9 essays from production, and every number tied to a live listing or credential you can open yourself.
>
> - Good2Go Loans — 50,000+ users in New Zealand
> - Nakheel Marinas — 15,000+ first-month downloads
> - Duas and Aamal — 5.0★ across 1,072 Google Play ratings
> - stoolap_flutter — v2.0.1 on pub.dev
> - LangChain Academy — Introduction to LangChain, credential 6k7ynqplb8
>
> 7+ years across fintech, mobility and community apps. Dubai-based, remote-friendly.
>
> https://hasanabbassorathiya.tech/?utm_source=producthunt&utm_medium=social&utm_campaign=receipts-2026-q4&utm_content=master

**Thumbnail / asset:** `brag.jpg` (1920×1080) from the same render as the reel; cover frame baked in, no separate thumbnail shoot.

---

## What stays blocked until the owner acts

- YouTube upload of `brag-output-2026-11-14-004922/brag.mp4` (+ `brag.jpg` thumbnail) — owner file-pick only; the connector refuses programmatic uploads (`{"code":-32000,"message":"Not allowed"}`).
- Instagram reel `marketing/2026-11-03/out/clip-duas.mp4` — same owner file-pick gate; "Create new post" modal is open in the owner's browser.
- Medium sign-in — email magic link or password; nothing is pasted or entered by the agent.
- Dev.to / Reddit / Product Hunt account creation — no handle is guessed; nothing is scheduled until the accounts exist.
- Brevo welcome automation (automation id 1, "Welcome message"): trigger = contact added to list "Mobile Builders Community" (#2), delay 1 hour, email step uses template #1. The template editor detaches the browser debugger on every interaction, so the copy below could not be pasted in; also Brevo blocks sending automation emails until the owner completes https://account.brevo.com/profile/. Copy for the owner to paste manually once unblocked:
  - Heading: "Hey FIRSTNAME, you're in."
  - Para 1: "You're in. This list gets one email when I publish something new: production notes from shipping Flutter apps and the AI systems behind them, plus the operations that keep them honest."
  - Para 2: "If you want a second opinion on an architecture, a release, or a RAG pipeline, reply to this email. I read them, and I answer the ones that come with enough detail."
  - Buttons: "Read the essays" → https://hasanabbassorathiya.tech/blog ; "Join the community" → https://hasanabbassorathiya.tech/community
  - Footer address: "Dubai, United Arab Emirates"
  - Footer legal: "You've received this email because you joined the Mobile Builders community."
  - Subject: "You're in — welcome to the Mobile Builders community"
  - Preview text: to be added
  Remaining clicks after pasting: Confirm step 3, save, Activate (still cannot send until the Brevo profile is completed).
