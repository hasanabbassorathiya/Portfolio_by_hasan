Duas and Aamal ships in five languages — English, Urdu, Gujarati, Swahili, and Persian — with Arabic content at its core. It holds a 4.6-star rating, and the reviews that matter most are not about features. They are from people who finally have an app that speaks their language properly.

Localization is usually treated as a translation task at the end of a project. It is actually an architecture and product decision that starts on day one. These are the lessons I keep applying.

## Pick the language that gets forgotten

Every app translates English into the "big" languages first. For Duas and Aamal, the primary audience reads Gujarati, so Gujarati came first — not as a translation of an English interface, but as the language the interface was designed in.

That changes everything downstream:

- Buttons are sized for Gujarati string lengths, not English ones.
- The typography supports Gujarati script shaping and line height from the start.
- Content editors write in Gujarati, so the app sounds like the community, not like a translated product page.

If your product has a core audience whose language is an afterthought, flip the order. Design for them first; English will survive the adjustment.

## Script support is more than a font file

Arabic and Urdu are right-to-left, and Gujarati has its own shaping rules. A font that renders Latin perfectly can fail badly here.

What I check:

- **Shaping:** conjuncts and ligatures render correctly, not as disconnected glyphs.
- **Line height:** scripts with ascenders and descenders need more leading than Latin.
- **Font fallback:** a missing glyph should fall back to a font that has it, not show a tofu box.
- **Numerals:** decide whether to show Latin, Arabic-Indic, or Gujarati digits, and make it a user setting where it matters.

Test on the oldest supported OS version. Font fallback differences between iOS and Android are real and easy to miss on a new flagship.

## RTL is not a mirror

Flipping the whole layout with `Directionality` is a start, not a finish. These need explicit decisions:

- Icons that imply direction (back arrows, progress chevrons) should flip.
- Icons that represent objects (a clock, a book) should not.
- Numbers, phone numbers, and code stay left-to-right even inside an RTL layout.
- Charts and timelines need a deliberate reading direction.
- Text alignment inside forms should follow the field's language, not the app's locale.

The bug I see most often is a mirrored back arrow that now points forward while still navigating back. It looks minor until a user is lost.

## Plan for text expansion

German and Urdu strings can be 30% longer than English. A layout that only works in English will break the moment it is translated. Practical rules:

- Never fix the width of a button that contains a label.
- Let text wrap to two lines and design for it.
- Use `Flexible` and `softWrap` deliberately.
- Test with a pseudo-locale that adds padding characters to every string.

I add a pseudo-locale build to CI for exactly this reason. It catches truncation before a translator ever sees the app.

## Pluralization and dates are where translations go wrong

English has two plural forms. Arabic has six. Gujarati has its own rules. Hand-rolled string concatenation cannot express this.

Use ICU message format through `intl`:

```dart
final message = Intl.plural(
  count,
  zero: 'No duas saved',
  one: 'One dua saved',
  other: '$count duas saved',
  locale: localeName,
);
```

Dates are just as cultural. A prayer app needs both Hijri and Gregorian dates, local time zones, and prayer calculations that respect the user's school of thought. "July 14" is not a universal representation of a day. I keep date formatting in one service with tests per locale, because scattered `DateFormat` calls become inconsistent fast.

## Content operations are part of localization

The app's content changes weekly: new duas, corrections, seasonal material. If every content update requires an app release, the translation pipeline becomes a bottleneck.

We solved this with a small CMS (`duas-crm`) that stores content per language, tracks review status, and pushes updates to the app. The rules:

- Every content item has a language, a source, and a reviewer.
- Translations can ship independently of the binary.
- Nothing goes live without review by someone qualified in that language and subject.
- The app caches content for offline use and shows the last good version when offline.

This is not glamorous engineering, but it is why the app can respond to the community in days instead of months.

## Store metadata is localization too

The App Store and Play Store listings are the first screen most users see. Translate:

- App name and subtitle (within character limits).
- Screenshot captions, not just the screenshots.
- The description's first two lines, which are what search results show.
- Keywords, researched per market rather than machine-translated.

A great app with an English-only listing is invisible to the audience that needs it most.

## The review that taught me the most

The most useful feedback was not a feature request. It was a one-star review from someone who could not find a setting because the label was translated literally and made no sense in their dialect. We fixed the wording and added a glossary so translators use consistent terms across the app.

Localization quality is not measured by the number of languages in the settings screen. It is measured by whether a user forgets they are using a translated app.

If you are building for a community whose language is underserved, [I would like to hear about it](mailto:hasanabbassorathiya12@gmail.com). Duas and Aamal is proof that this market rewards care.
