# Launch & share copy

Ready-to-post text for LinkedIn and X. Every claim here traces to `hasan.md`; do not add numbers that are not in it.

Canonical links carry UTMs so GA4 can tell which channel brought the visit:

```
https://hasanabbassorathiya.tech/?utm_source=linkedin&utm_medium=social&utm_campaign=site-launch
https://hasanabbassorathiya.tech/blog/<slug>?utm_source=linkedin&utm_medium=social&utm_campaign=essay-<slug>
```

## 1. Site launch — three variants

### A. Hiring managers and recruiters

> Seven years of mobile work, and my portfolio was still a PDF and a list of logos.
>
> So I rebuilt it as a system: the apps, the numbers, the architecture decisions, the essays. One place.
>
> - 16 apps shipped across iOS, Android, web, and Android TV
> - 100K+ users, including a 4.6★ prayer app and a TV-first IPTV player
> - 7+ years, most recently leading mobile delivery for an electric mobility platform in Dubai
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
> Eight essays from production, not tutorials:
>
> - Clean Architecture that survives team changes
> - Riverpod patterns I use — and three I avoid
> - RAG that survives real users
> - Localization lessons from a 4.6★ app
>
> Plus 16 shipped apps and the decisions behind them.
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
