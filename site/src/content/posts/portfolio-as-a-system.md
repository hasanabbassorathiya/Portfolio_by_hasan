Most portfolios are pages. They get designed once, shipped, and then quietly rot: the resume link dies, a new app never gets added, the copy on the site drifts from the copy on LinkedIn. I know because mine did. The rebuild I just finished treats the portfolio as a system instead — one canonical source, generated outputs, and checks that fail loudly when something drifts.

This is the structure, and why each part earns its place.

## The problem with a page

A page has no memory. Every fact lives in the markup, so every change has to be made in every place that repeats it. When I shipped a new app, I had to remember to update the home page, the apps page, the store listing, the GitHub bio, and whichever document a recruiter happened to open. When a link broke, nothing told me. Earlier this year my own profile document still pointed at two store pages that had started returning 404 — and I only found out because I checked every link on purpose.

That is not a discipline problem. It is an architecture problem. Facts that are repeated in five places will diverge in five places.

## One canonical file, everything else derived

The system starts with a single profile file — plain markdown, versioned with the code. It holds identity, contact links, experience, education, certifications, skills, every app with its store IDs, every open-source repo, the blog plan, and the site architecture decisions. It is the only place a fact is allowed to originate.

Everything downstream reads from it or is checked against it:

- the site's content files (`apps.js`, `posts.js`) mirror the canonical lists;
- the blog metadata, sitemap, RSS feed, Open Graph cards, and JSON-LD all generate from the same post objects;
- store links are copied from the canonical table, so an app cannot exist on the site with a URL that was never verified.

The important part is not the markdown file. It is that the site is auditable against it. The last pass compared every canonical app, repo, certification, and link against what the site actually renders. It found two repos missing from the open-source section, and the two dead store links mentioned above. Both were fixed the same day. A page cannot do that; a system can.

## Content as data

Posts are data with a markdown body. A post is an object — slug, title, dek, category, date, tags — plus a `.md` file for the prose. Routes, the index list, reading time, related metadata, the RSS entry, the sitemap URL, the JSON-LD block, and the 1200×630 share card are all derived from that one object.

The practical effect: adding this essay required one markdown file and one entry in an array. The route, the meta tags, the feed item, the sitemap line, and the social card came out of the build.

That matters for a blog meant to compound. If publishing costs thirty minutes of plumbing, you publish less. If it costs one file, you publish on schedule.

## Static first, a server only where it earns it

The site is a static React build. Every public route is a real URL with prerendered metadata shells: `/blog/<slug>` serves a small HTML document with the correct title, description, canonical, Open Graph tags, and structured data before any JavaScript runs. The app hydrates over it and takes over navigation.

I did not reach for a full SSR framework. The public surface is a handful of routes that change when I deploy, not when a user acts. Prerendering at build time gives crawlers and link previews exactly what they need without a Node server to keep alive.

The server exists only where a static file cannot do the job:

- **The newsletter.** Signups POST to a small PHP endpoint backed by MySQL. It validates the address, ignores a hidden honeypot field, caps new addresses per IP per hour using a peppered hash (never the raw IP), and answers duplicates idempotently. Each subscriber gets a token that deletes their row.
- **The admin panel.** A cookie-guarded PHP dashboard for reading subscribers, exporting a CSV, and deleting rows, plus authenticated CRUD for the content I want to edit without a deploy.

Everything else — pages, essays, app case studies, the feed — is files on a CDN. Fewer moving parts, nothing to keep warm, and a fraction of the attack surface.

## Budgets as gates, not vibes

Performance and accessibility are easy to claim and hard to prove. So the system turns them into gates that a build has to pass:

- **JavaScript budget.** Route-level code splitting, plus a deferred chunk for the home page's essay list, cut the main bundle from 278 KB to 196 KB raw. The home page now transfers about 414 KB in total.
- **Lighthouse.** Mobile run: 91 performance, 100 accessibility, 100 best practices, 100 SEO. Largest Contentful Paint is 3.4 seconds under throttling — still above the 2-second target, and I would rather write that down than round it up.
- **axe, every route.** A WCAG 2.1 A/AA sweep across all 18 public routes returns zero violations. It caught two real problems the eye missed: a logo whose accessible name did not contain its visible text, and index numbers on the blog list sitting at 3.78:1 contrast. Both are fixed.
- **Behaviour, not screenshots.** Keyboard navigation is tested (28 focus stops, skip link, Escape closes the mobile menu and returns focus), overflow is checked at six widths, and the site is smoke-tested in Chromium, Firefox, and WebKit — routes, anchors, the mobile menu, and smooth scrolling.

None of this is glamorous. All of it is the difference between "it looked fine on my laptop" and "it works when a recruiter opens it on a phone in a hurry."

## What the system is for

A portfolio is not the deliverable. The deliverables are the conversations it starts: a senior role, a consulting engagement, a product collaboration, someone trying an app because a case study made it legible.

That is why the structure matters more than the design. Every essay ends with a next action. The writing section ends with an email form, not a dead end. The app case studies link to stores that were verified this week, not last year. The site is a funnel with a source of truth at the top and a working contact path at the bottom.

And it is a record. Google Developer Expert recognition is earned by sustained public work — talks, articles, open source, a body of evidence that can be inspected. A system that makes publishing cheap and drift visible is how that body of work gets built without heroics.

## The rule I would keep

If you are rebuilding a portfolio, spend less time on the hero section and more time on the structure behind it: one canonical source, generated metadata, and checks that fail when reality disagrees. The design will get you the first ten seconds. The system is what keeps the site true for the next two years.

If this is the kind of system you want built — or rescued — my email is on the contact section. If you want the longer version of the GDE plan, start with [From shipping apps to GDE](/blog/from-shipping-apps-to-gde). And if you just want the next essay, the subscribe form below is the cheapest way to keep in touch.
