On November 12 and into November 13, a large slice of the working world lost access to Outlook, Teams, Word and Excel. Reporting from the [Guardian](https://www.theguardian.com/technology/2026/nov/13/microsoft-outage-outlook-teams-word-excel-reports), [DW](https://www.dw.com/en/microsoft-works-to-restore-outlook-and-teams-after-global-outage/a-79935611) and [ABC](https://www.abc.net.au/news/2026-11-13/microsoft-outlook-outage/107380958) describes businesses, schools and government offices unable to send mail or join meetings. Microsoft's own account, as relayed in that coverage, is that a significant number of its servers became unavailable and failed automated checks — and that it ruled out a cyberattack.

I am not writing this to pile on. I am writing it because I have shipped products that lean on exactly these services, and an outage like this is the cheapest possible reminder of a lesson that is expensive to learn in production: **a dependency you do not control is a failure mode you do not control.**

## What actually happened, briefly

The confirmed shape, from the reporting above:

- Microsoft 365 services — Outlook, Teams, Word, Excel — were disrupted across multiple regions, starting November 12 and continuing into November 13.
- Microsoft attributed it to servers becoming unavailable, not an attack.
- Early fixes did not fully restore service, which is why it dragged on rather than resolving in minutes.

That last point is the one engineers should sit with. A failure that is detected quickly but *fixed slowly* is its own category of problem, and it is the one that hurts most, because every downstream system sits in a degraded state for hours.

## The lesson is not "avoid the cloud"

The lazy takeaway is "don't depend on Microsoft." That is not realistic — these tools are embedded in how organizations work, and ripping them out is not a resilience strategy. The real lesson is about how your own product behaves when a dependency it cannot control goes down.

Here is the checklist I keep coming back to, and that this outage re-validated:

### Degrade, don't cascade

When a downstream service fails, your product should lose a feature, not its life. If auth, mail, or a document store is unreachable, the rest of the app should keep working. That means timeouts on every external call, circuit breakers so you stop hammering a dead service, and a UI that says "this is temporarily unavailable" instead of spinning forever or crashing.

### Cache what you can, and say how old it is

A lot of outage pain is read-path pain. If your product reads from a service, a stale-but-labeled cache turns a hard outage into a soft one. The key is honesty: show the data and show its age, so a user knows they are looking at yesterday's snapshot rather than assuming it is live.

### Make the dependency visible

If your product depends on a third party, surface that dependency's status somewhere a human can find it. A status link, a banner, or a clear error message beats a support queue full of "is it just me?" During this outage, the teams that communicated "this is a Microsoft-side issue, here is their status page" looked competent; the ones that went silent looked broken.

### Decide, in advance, what truly needs a fallback

Not every dependency deserves a second provider. The discipline is triaging: which ones, if they fail, stop the business? For those, you either build a fallback or you accept the risk explicitly and write it down. For everything else, graceful degradation is enough. Multi-vendor everything is a cost, not a virtue.

## Why this is a mobile and AI problem too

The products I build are mobile-first, and mobile makes this worse in one specific way: the device is often offline or on a flaky network *before* any cloud outage happens. So the habits above — local caches, optimistic UI, honest error states — are not outage-only features. They are the baseline for a mobile app that feels reliable. An outage just removes the illusion that the network is always there.

For AI features the same logic applies with higher stakes. If your feature calls a hosted model and that provider has a bad day, do you have a smaller local fallback, a queued retry, or at least a clean "try again shortly"? The rise of capable local models — I wrote about running a 27B model on a laptop recently — makes a local fallback more realistic than it used to be.

## The takeaway

You cannot prevent a hyperscaler outage, and you should not try. What you can do is make sure that when it happens, your product bends instead of breaks, tells the user the truth, and recovers without a human babysitting it. That is not glamorous work. It is the difference between a product people trust and one they abandon the first time a dependency sneezes.

If you are auditing your own product's failure paths and want a second pair of eyes on the dependency map, [send me the details](mailto:hasanabbassorathiya12@gmail.com?subject=Resilience%20review). This is the kind of review that pays for itself the first time something upstream goes down.