Leading mobile delivery is not a bigger version of being a senior developer. The job changes shape: your output is no longer the code you write, it is the decisions the team can make without you.

I led mobile engineering for EVLAB at Chalhoub Group, an electric mobility platform spanning rentals, leasing, and marketplace operations. These are the three operating rules that made the biggest difference.

## Rule 1: Run a release train, not a hero sprint

Every team says they release continuously. In practice, releases cluster around a deadline, then stall for weeks while a dozen branches wait for a QA window. The cost is not just delayed features — it is that integration risk keeps growing while nobody is shipping.

We moved to a release train:

- A release candidate is cut on a fixed day, every week or two.
- Anything not ready waits for the next train. No exceptions for "small" changes.
- The train leaves even if it carries a light load. The cadence matters more than the cargo.
- Hotfixes are the only bypass, and they require a written reason.

The discipline is in the "no exceptions" part. Once the train leaves on schedule three times in a row, teams start planning around it instead of negotiating with it. QA gets a predictable window. Stakeholders stop asking for dates and start asking what is on the train.

## Rule 2: Own the device matrix, not just the latest phone

Enterprise and consumer apps live on a long tail of devices: older Android versions, budget hardware, tablets, and in the EV case, vehicle-adjacent experiences. A build that is smooth on a flagship can be unusable on the phone a customer actually owns.

We kept an explicit matrix:

- The oldest OS version we support.
- The lowest-memory device we can buy.
- One tablet or large-screen configuration.
- One device with an unusual aspect ratio.

Every release candidate ran on all four before the train left. Not a full regression suite — a fifteen-minute smoke path: launch, sign in, browse, complete the primary task, check notifications.

This is unglamorous and it caught more real bugs than any automated suite we had. It also changed design conversations: when a designer proposes an interaction, someone can say "that animation drops frames on the low-memory device" before it is built.

## Rule 3: One decision log, written in public

The most expensive mobile decisions are the ones made twice. Why did we choose Riverpod over BLoC? Why is this screen native? Why does this API call happen on app start? Six months later, nobody remembers, and the team relitigates it with less context.

We kept a decision log in the repo:

```text
docs/decisions/
  0001-state-management.md
  0002-auth-token-storage.md
  0003-offline-cache-strategy.md
```

Each entry had: context, decision, alternatives considered, consequences, date, and owner. Not a design doc — a page at most.

The rule was that any change to architecture required an entry. This did three things:

1. It forced the decision to be explicit.
2. It gave new engineers a shortcut to the reasoning.
3. It made revisiting a decision a deliberate act, not an accident.

Writing the consequence section was the most valuable part. "This adds a dependency on Codemagic" or "this makes testing auth flows harder" is the information that actually shapes future work.

## The metrics that mattered

We tracked four numbers in the mobile operating review:

- **Crash-free sessions.** The single best proxy for whether users can do the thing.
- **Release lead time.** From merge to production. If it grows, process is winning over product.
- **Rollback rate.** A high number means quality gates are theatre.
- **First-response time on production issues.** Users forgive a bug that is acknowledged quickly.

Notice what is missing: story points, velocity, and lines of code. They measure activity, not delivery.

## What I would do differently

I would have started the decision log on day one instead of month three. I would also have involved QA earlier in the design of test plans for new features — by the time a feature reached QA, the test plan was usually a list of scenarios rather than a hypothesis about what could fail.

The last thing: protect the team's focus. Every "quick sync" and "small change" has a context-switch cost that does not appear in any dashboard. The lead's job is to absorb that cost so the engineers can stay in the work.

## The through-line

None of this is mobile-specific. Release trains, a real device matrix, and written decisions work for any delivery team. What makes mobile different is the surface area: two platforms, thousands of devices, store review, and users who update when they feel like it. You cannot test your way out of that. You can only build a system that makes the right behavior the default.

If you are scaling a mobile team or stepping into a lead role, [I am happy to talk through what worked](mailto:hasanabbassorathiya12@gmail.com) — including the parts that did not.
