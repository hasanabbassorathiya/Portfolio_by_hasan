# LinkedIn profile draft — Hasan Abbas Sorathiya

Updated: 2026-11-12 (second pass). The profile is published and now **AI-first** per the owner's pivot to AI Software Engineer / FDE roles: headline and About rewritten through the owner's logged-in session and verified live; the banner (§7) is live; the owner added the LangChain Academy certification themselves (Introduction to LangChain - Python, ID 6k7ynqplb8, issued 2026-11-12, expires 2028-11-11, credential URL on the entry). The About names that course as **certified** and the remaining LCAE prerequisites plus the Udemy AI Engineer Core Track as **in progress** — never claim them completed. Experience entries, skills and Featured from §3–§5 remain owner-only follow-ups. No claim goes beyond `hasan.md` or the live site. The launch posts and essay cross-posts live in `SOCIAL.md`; this file covers the profile itself.

## 1. Headline

Published 2026-11-12 (AI-first pivot):

`AI Software Engineer · Forward Deployed Engineer · RAG & Agents · Flutter`

Previous (superseded): `Senior Software & AI Engineer · Flutter Specialist · RAG & Agents`

## 2. About

Published 2026-11-12, AI-first rewrite. The LangChain course is named as certified (certificate 6k7ynqplb8, verified live at academy.langchain.com/certificates/6k7ynqplb8); everything else in the training sentence is in progress.

```text
I'm a Dubai-based engineer building AI systems that hold up after the demo — and the mobile products they ship inside.

For 7+ years I've delivered across fintech, e-commerce, mobility and community apps: RAG pipelines with retrieval and citations, agents and MCP servers, n8n automation, and the Flutter/iOS/Android delivery around them. Twenty-one app profiles, including Good2Go Loans (50,000+ users in New Zealand) and Nakheel Marinas (15,000+ first-month downloads). Most recently I led mobile engineering at Chalhoub Group for EVLAB, an electric mobility platform.

I care about the unglamorous parts of AI — evaluation, failure states, cost and reliability — and I'm formalising the agent side now: certified in LangChain Academy's Introduction to LangChain – Python, working through the remaining LCAE prerequisites (Deep Agents, LangSmith) toward the LangChain Certified Agent Engineer credential, alongside Udemy's AI Engineer Core Track (LLM engineering, RAG, QLoRA, agents).

What I do:
• AI engineering — RAG, agents, MCP, evaluation, automation
• Forward-deployed delivery — from architecture to production support
• Flutter and mobile product engineering — iOS, Android, releases
• App audits, performance reviews and technical consulting

I write production notes at hasanabbassorathiya.tech/blog and maintain stoolap_flutter, a pure-Rust embedded SQL package for Flutter, on pub.dev.

Open to AI software engineer and forward-deployed roles, plus consulting engagements.
hasanabbassorathiya12@gmail.com · hasanabbassorathiya.tech
```

Length is under LinkedIn's 2,600-character limit. Keep the blank lines; they survive LinkedIn's plain-text editor.

## 3. Experience entries

Use the same dates and titles as the résumé and the site. Keep each entry short; the portfolio carries the detail.

| Role | Company | Dates | Draft summary |
|---|---|---|---|
| Mobile Engineering Lead | Chalhoub Group · Dubai | 07/2023 – 01/2026 | Led mobile engineering for EVLAB, an electric mobility platform covering rentals, leasing and marketplace journeys. Owned architecture, delivery planning, releases and production support across mobile, backend, product, UX, QA and DevOps. Flutter with Clean Architecture and Riverpod; Codemagic CI/CD; Crashlytics and performance work. |
| Lead Senior Software Engineer (Mobile) | Belong Interactive · Dubai | 08/2022 – 06/2023 | Delivered enterprise mobile apps across hospitality, lifestyle and retail. Led Flutter teams, set architecture and review standards, and ran sprint planning. Shipped the Nakheel Marinas app to 15,000+ downloads in its first month. |
| Senior Software Engineer (Mobile) | Masaar · Dubai | 01/2022 – 08/2022 | Re-architected a cross-border e-commerce Flutter app for scalability, with secure auth, API integrations and a rebuilt purchase journey contributing ~25% conversion improvement. |
| Team Lead (Flutter) | Vervali Systems · USA (remote) | 03/2021 – 11/2021 | Led Flutter teams delivering fintech mobile solutions, including the Urban Ledger financial management app: transactions, payments, secure APIs and validation. |
| Senior Flutter Developer | Beedev Solutions · Australia (remote) | 08/2019 – 03/2021 | Led Good2Go Loans, a digital lending app serving 50,000+ users across New Zealand: onboarding, authentication, account journeys and notifications on a Clean Architecture codebase. |
| Flutter Developer | Kumite 1 League | 01/2019 – 08/2020 | Early Flutter delivery across combat-sports media and league operations. |

Do not add clients, team sizes or revenue that are not already in `hasan.md`.

## 4. Skills

Order matters on LinkedIn; put the three positioning pillars first.

1. Flutter, Dart
2. Mobile Application Development, iOS, Android, Android TV
3. AI Integration, Large Language Models (LLM), Retrieval-Augmented Generation (RAG), AI Agents, Model Context Protocol (MCP), n8n
4. Clean Architecture, Riverpod, MVVM, REST APIs
5. Firebase, AWS, CI/CD, Codemagic, Crashlytics
6. TypeScript, React, Node.js, PHP, MySQL
7. Technical Consulting, Application Audits, Performance Optimization

Remove skills you cannot defend in an interview; a shorter, accurate list converts better than a long one.

## 5. Featured section

In this order:

1. Portfolio — `https://hasanabbassorathiya.tech`
2. `stoolap_flutter` on pub.dev — `https://pub.dev/packages/stoolap_flutter`
3. The RAG essay — `https://hasanabbassorathiya.tech/blog/rag-that-survives-real-users`
4. Apps index — `https://hasanabbassorathiya.tech/apps`
5. Résumé — `https://hasanabbassorathiya.tech/resume` (PDF one click away, no FlowCV dependency)

## 6. Services section

If LinkedIn Services is available on the profile, list only what the site already scopes:

- Mobile Application Development
- AI Consulting and Automation
- Software Development
- IT Consulting and Technical Audits

Do not promise response times, prices or availability guarantees.

## 7. Banner specification (live 2026-11-12)

Generated by `scripts/linkedin-cover.mjs` → `public/media/brand/linkedin-cover.png`, uploaded through the owner's session and verified live.

- Size: 1584 × 396 logical, exported at 2× (3168 × 792).
- Ground: paper `#F3EFE6`; ink text `#16130F`; cobalt `#1D3CFF` on "AI systems"; rust `#A33F1C` italic on "people keep using."
- Brand block: HS monogram + `Hasan Abbas Sorathiya` (Geist 600) over `SENIOR AI SOFTWARE ENGINEER · FDE · DUBAI` (Geist Mono, letter-spaced).
- Headline, **one line** (Instrument Serif, 64 px): `I build AI systems and Flutter apps people keep using.` — one line is mandatory: LinkedIn's avatar overlays the bottom-left ~45% of the banner on desktop, and a two-line headline lost its second line under the photo.
- Footer: `hasanabbassorathiya.tech` (Geist Mono) with a cobalt dot.
- Regenerate with `node scripts/linkedin-cover.mjs`; the Instrument Serif files in `public/fonts/` were un-swapped on 2026-11-12 (Regular now upright, Italic now italic) — keep names and content aligned.

## 8. Contact and profile settings

- Custom URL: `linkedin.com/in/hasanabbassorathiya` (already in use).
- Website: `https://hasanabbassorathiya.tech` (label: Portfolio).
- Location: Dubai, United Arab Emirates.
- Open to work: senior Flutter, mobile lead, AI engineer; on-site Dubai or remote.
- Creator mode: optional; only enable if posting weekly is realistic.

## 9. Owner checklist

1. **Done:** AI-first headline and About published and verified live (2026-11-12, second pass). Experience entries (§3) still to apply.
2. Trim the skills list to §4 and reorder it.
3. Set Featured items in the §5 order.
4. **Done:** banner from §7 live (single-line AI-first cover).
5. **Done:** website (Portfolio) and location confirmed live; open-to-work already set to recruiters-only for AI/full-stack/prompt/lead/senior roles.
6. **Done:** portfolio is live, so the featured link is current.
7. **Done (owner):** LangChain Academy certification added — Introduction to LangChain - Python, credential ID 6k7ynqplb8, issued Nov 2026, expires Nov 2028, credential URL attached. Remaining LCAE prerequisites and the Udemy track stay "in progress" everywhere until certified.

### Experience-figure note (resolved 2026-11-12)

The owner chose **"7+ years"** everywhere. `src/content/profile.js` now sets `experience_years: 7` (owner override 2026-11-12), the site, the reel and the profiles all read 7+. The old disagreement note is superseded.
