# ASO Plan — Store Listings

Draft for the owner. Nothing in this file has been published to Google Play or the App Store.
Every number below is a character count, not a keyword volume. This plan does not promise
rankings, installs, or revenue, and it does not use purchased reviews, incentivised ratings,
or competitor names.

Sources: the five Play listings under the owner's developer account were enumerated in a real
browser on 2026-10-29 (`https://play.google.com/store/apps/dev?id=5895887615343030170`), and all
five already match `site/src/content/apps.js`. The owner's App Store roster was resolved the same
day through Apple's public lookup API for artist `1734376366` — Duas and Aamal, Hoda, Fragrance of
Mastership, and Lumio TV — and all four also match `apps.js`. The App Store developer web page
itself redirected to the CN storefront, so the API result is the evidence. Copy claims are limited
to the public listing summaries and the verified profiles in `apps.js`.

## 1. Scope and ownership

| App | Platforms | Owner's role | Listing copy may be edited by owner? |
|---|---|---|---|
| Duas and Aamal | iOS, Android | Creator | Yes |
| Lumio TV | iOS, Android, Web, Android TV | Lead developer | Yes, if the account is under the owner |
| Hoda | iOS, Android | Publisher | Copy only with the content owner's approval |
| WallMaster | Android | Store listing | Yes |
| Business Mind: Money Empire | Android | Store listing | Yes |
| Carvan-e-Hind | iOS, Android | Flutter developer & maintainer | With the trust's approval |
| 14 Stars | iOS | Contributing developer | No — not the owner's listing |
| Nutrabay | iOS, Android, Web | Contributing engineer | No — not the owner's listing |
| Pool Inspection | iOS | Mobile developer | No — not the owner's listing |
| Fragrance of Mastership | iOS | Publisher | With the author's approval |

Do not edit listings the owner does not control. For publisher-role apps, the app's content and
brand belong to someone else; publishing changes without their sign-off would misrepresent them.

## 2. Rules for every edit

- Copy must describe the shipped build. If a feature is not in the current release, it does not
  go in the listing.
- No "best", "#1", "top-rated", "world's leading", or competitor names.
- Ratings and counts are snapshots. Re-read them from the console before quoting them anywhere.
- No review incentives, no rating gates that only show happy users, no bought installs.
- One change at a time, measured in the console, so cause and effect stay legible.
- Character limits below are the public store limits as of this draft; confirm in Play Console
  and App Store Connect before saving.

## 3. Google Play copy (five verified listings)

Limits: title 30, short description 80, full description 4,000 characters. The full-description
skeletons below are structure, not final text; write the paragraphs from the app's real release.

### Duas and Aamal — `app.duasandaamal.com`

- Title (30): `Duas and Aamal: Shia Companion`
- Short description (75): `Quran, duas, aamal, ziyarats, Jafari prayer times. Gujarati-first, offline.`
- Full-description skeleton:
  1. What it is: a daily companion for Quran, duas, aamal, and ziyarats.
  2. Gujarati-first: Quran with Gujarati translation alongside Arabic text.
  3. Prayer: Jafari prayer times with moon-sighting adjustment, qibla, tasbih, widgets.
  4. Offline: content available without a connection; five languages.
  5. Widgets, notifications, bookmarks, and an Android TV layout.
  6. Close: who it is for; link to the portfolio app page.
- Screenshot captions to test: "Quran with Gujarati translation", "Jafari prayer times",
  "Duas and ziyarats offline", "Five languages".
- Languages in-app: English, Urdu, Gujarati, Swahili, Persian. Translate the listing only where a
  human reviewer can check the translation.

### Lumio TV — `app.lumio_iptv.com`

- Title (25): `Lumio TV: IPTV M3U Player`
- Short description (73): `IPTV player for M3U and Xtream playlists with EPG, search and Android TV.`
- Full-description skeleton:
  1. What it is: a multi-provider IPTV client for M3U and Xtream Codes playlists.
  2. Guide: live EPG with channel metadata; favorites, recents, search.
  3. Living-room use: Android TV focus navigation and remote support.
  4. Reliability: explicit playback states and stream recovery.
  5. Platforms: one Flutter core across iOS, Android, and web.
  6. Note: playback depends on the user's own provider and content rights.
- Screenshot captions to test: "M3U and Xtream playlists", "Live EPG guide", "Built for the remote".

### Hoda — `app.hoda.com`

- Title (22): `Hoda: Pilgrimage Guide`
- Short description (80): `Bilingual French and English guide to pilgrimage sites, Hajj, Umrah and Arbaeen.`
- Full-description skeleton:
  1. What it is: a French/English pilgrimage companion.
  2. Sites across Iran, Iraq, Syria, Lebanon, Egypt, and Saudi Arabia.
  3. Hajj and Umrah rituals explained; supplications with transliteration and translation.
  4. The spiritual meaning of the Ziyarat of Arbaeen.
  5. Attribution line naming the content author, if the content owner requires one.
- The owner is the publisher, not the author. Get written approval for every copy change.

### WallMaster — `com.hasanabbassorathiya.wallmaster`

- Title (30): `WallMaster Wallpapers & Videos`
- Short description (59): `Wallpapers and short videos to browse, download, and share.`
- Full-description skeleton:
  1. What it is: wallpaper and short-video discovery for Android.
  2. Search and popular tags; browse, download, share.
  3. Home-screen and lock-screen selection.
  4. Content source: the current listing identifies Pexels; keep that attribution and confirm the
     Pexels licence terms before changing any wording about the media.
- Do not claim "4K", "HD", or library size unless the listing and the app both support it.

### Business Mind: Money Empire — `game.businessmind.hasanabbas`

- Title (27): `Business Mind: Money Empire`
- Short description (68): `Idle business tycoon: run companies, upgrade staff, earn while away.`
- Full-description skeleton:
  1. What it is: an idle business simulation.
  2. Businesses, employees, and upgrades; offline earnings.
  3. Stock, crypto, and real-estate systems are simulated in-game.
  4. Daily challenges, login streaks, legacy prestige, cloud saves.
- Keep the word "simulated" wherever investing is mentioned. Never imply real trading, real money,
  financial advice, or income.

## 4. App Store copy (owner-controlled listings)

Limits: name 30, subtitle 30, keyword field 100 (comma-separated, no spaces), promotional text 170,
description 4,000.

| App | Name (≤30) | Subtitle (≤30) | Keyword field (≤100) |
|---|---|---|---|
| Duas and Aamal | `Duas and Aamal` (14) | `Quran, Duas & Prayer Times` (26) | `quran,dua,aamal,ziyarat,prayer times,qibla,tasbih,gujarati,urdu,shia,offline,islamic` (84) |
| Lumio TV | `Lumio TV: IPTV Player` (21) | `IPTV Player for M3U & Xtream` (28) | `iptv,m3u,xtream,epg,player,live tv,playlist,android tv,streaming,channels` (73) |
| Hoda | `Hoda — Pilgrimage Guide` (23) | `Hajj, Umrah & Ziyarat Guide` (27) | `hajj,umrah,ziyarat,pilgrimage,arbaeen,dua,french,english,guide,iraq,iran` (72) |
| Carvan-e-Hind | `Carvan-e-Hind` (13) | `Community events & updates` (26) | `community,events,announcements,trust,members,media` (50) |
| Fragrance of Mastership | `Fragrance of Mastership` (23) | `Traditions on Wilayat` (21) | `wilayat,traditions,islamic,books,shia,imam ali,fatima` (55) |

- Keyword fields must not repeat the app name or contain competitor brands, plurals of the same
  word, or spaces after commas.
- Carvan-e-Hind and Fragrance of Mastership need the trust's and author's approval respectively.
- Duas and Aamal's App Store subtitle may already be set; treat this as a proposal, not a fact.

## 5. Visual assets

Google Play:
- Icon 512×512, 32-bit PNG, no transparency, no rounded corners baked in.
- Feature graphic 1024×500; keep text inside the centre safe area, because the edges crop.
- Phone screenshots: 2–8, at least 1080 px on the short edge, real UI from the current build.
  Captions must name a feature that is visible in that screenshot.
- Tablet and Android TV screenshots only if the app genuinely supports them (Lumio and Duas do).

App Store:
- Icon 1024×1024, no alpha.
- 6.9" and 6.5" iPhone sets, plus iPad only if the app runs there; screenshots must show the
  current build, not mockups of planned features.
- App previews are optional; if used, they must show real footage and pass review.

Do not fabricate device chrome or fake notification text. Do not show a rating badge in a
screenshot unless it is a real, current rating.

## 6. Localisation

- Duas and Aamal: in-app English, Urdu, Gujarati, Swahili, Persian. Localise the Play listing for
  `en-US`, `gu-IN`, and `ur` first; add `fa` and `sw` after human review.
- Hoda: French and English, so localise both store listings for `fr-FR` and `en-US`.
- All others: English-first. Do not machine-translate a listing without a reviewer who speaks the
  language; bad translations read as spam to both users and store algorithms.

## 7. Measurement

Use the consoles, not guesses:

- Play Console → Store presence → Store listing experiments: one variable per test (icon, feature
  graphic, short description, screenshots). Run until the console reports a result; record the
  dates, variant, and outcome in this file.
- Play Console → Acquisition reports: store-listing visitors, installers, conversion rate, and
  search terms. These are the only legitimate keyword data available; there are no public volumes
  in this plan because none were measured.
- App Store Connect → Analytics: impressions, product page views, conversion rate; Product Page
  Optimization for A/B tests.
- Review ratings quarterly and update `apps.js` snapshots at the same time so the site never shows
  a stale count as current.

A useful baseline is a 7–14 day window per experiment. Do not change two assets at once, and do
not stop a test early because one variant looks better in the first two days.

## 8. Developer/brand surfaces

- Play developer page and App Store developer page: display name, icon, and website should point
  to `https://hasanabbassorathiya.tech` and match the LinkedIn/GitHub profile drafts.
- Each listing's website field should point to the matching `/apps/<slug>` page, not the homepage,
  so store visitors land on the exact case study.
- Keep the app name, icon, and screenshots consistent between the store, the portfolio app page,
  and `llms.txt`. Inconsistent naming splits recognition across search surfaces.

## 9. Owner checklist

1. Confirm which of the five Play listings and five App Store listings are under accounts the owner
   controls.
2. Apply one Play experiment: short description first, because it is the lowest-risk change.
3. Replace any screenshot that shows an older build; keep the caption matched to the visible UI.
4. Add the `/apps/<slug>` URL to each listing's website field.
5. Get written approval from the Hoda content owner, the Carvan-e-Hind trust, and the Fragrance
   author before touching those three listings.
6. Confirm Pexels attribution and licence wording for WallMaster.
7. Keep "simulated" in every Business Mind investing sentence.
8. Record every experiment and result in §7 with dates.
9. Re-check ratings/counts before any launch post and update `apps.js` if they moved.

## 10. What this plan deliberately does not do

- No invented keyword volumes, difficulty scores, or ranking predictions.
- No promises of top placement in Play, the App Store, Google, ChatGPT, Perplexity, Claude, or
  Grok. Those systems change constantly and cannot be guaranteed.
- No purchased installs, incentivised reviews, or review-swapping.
- No changes to listings the owner does not control.
- No publishing. Every line above is a draft until the owner applies it and confirms the result.
