Startup time is the first performance number users feel. It is also the one teams optimize last, because it is invisible in day-to-day development — your debug build is warm, your phone is fast, and the app is already open from the last time you tested.

Here is the process I use to find real wins, and the things that turned out not to matter.

## Measure the cold start, not the warm one

A cold start is the only number that reflects a new user opening your app from the store. On Android:

```bash
adb shell am force-stop com.example.app
adb shell am start -W -n com.example.app/.MainActivity
```

`-W` gives you `TotalTime` and `WaitTime`. Run it ten times on a mid-range physical device, not an emulator, and take the median. On iOS, use Instruments' App Launch template or the Xcode organizer's launch metrics for release builds.

Then trace it in DevTools. Attach the profiler and look at what happens between process start and the first frame: plugin initialization, `main()` work, the first widget build, image decoding, font loading, network calls that block the first screen.

If you skip this step, you will optimize the thing that looks slow in the code instead of the thing that is slow on the device.

## Treat main() as a budget

`main()` runs before anything is visible, and every millisecond there is a millisecond of blank screen. The rule: **only initialize what the first frame needs.**

- Call `WidgetsFlutterBinding.ensureInitialized()` only if something before `runApp` needs bindings. Many apps call it out of habit.
- Do not `await` analytics, crash reporting, remote config, or ad SDKs before `runApp`. Start them after the first frame with `WidgetsBinding.instance.addPostFrameCallback`.
- Prefer lazy plugin initialization. Firebase, for example, can usually be initialized after the first frame unless the first screen depends on it.
- Move preference reads to a splash-level async gap, not a blocking await in `main`.

```dart
void main() {
  runApp(const App());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Firebase.initializeApp();
    await Analytics.start();
  });
}
```

If the first screen requires user state, show a deliberate skeleton instead of a blank launch screen. Perceived speed matters as much as measured speed.

## Defer what is not on screen one

Android deferred components let you split a Flutter library into a feature module downloaded on demand. For heavy flows — video players, editors, maps — this can meaningfully shrink the initial install and first launch. Two caveats: it is Android-only, and it adds build and QA complexity. Use it for genuinely large features, not for a settings screen.

For everything else, defer in Dart: lazy-load tabs, avoid constructing heavy controllers in the root widget, and do not parse large JSON payloads during the first build.

## Fonts and images are usually the quiet cost

Custom fonts are a common startup tax. Each weight is a file that must be loaded before text renders correctly.

- Subset fonts to the character sets you actually ship. A Gujarati-first app needs Gujarati glyphs; it does not need every Unicode block in the display font.
- Ship only the weights used on the first screen; load display weights for later screens lazily.
- Preload the one or two fonts needed for the first paint; let the rest swap in.
- For images, decode at display size with `cacheWidth`/`cacheHeight`. A 1200px image in a 120px thumbnail wastes memory and CPU on decode.
- Prefer WebP or AVIF for content images and verify with `flutter build --analyze-size`.

On one content-heavy app, resizing remote images at the CDN and decoding at display size did more for scroll smoothness than any widget refactor.

## Parse large JSON off the main isolate

If a screen waits for a large payload, parse it with `compute` so the UI thread stays free:

```dart
final loans = await compute(parseLoans, response.body);
```

For payloads under roughly 100 KB the overhead may not be worth it. Measure. The same goes for cryptography, image processing, and PDF generation — anything CPU-bound that runs while the user is looking at the screen.

## Build fewer widgets

The cheapest widget is the one you do not build. On first launch:

- Avoid `IndexedStack` with five heavy tabs that all build immediately. Use a lazy indexed stack or a `PageView` that constructs on demand.
- Do not put global listeners that rebuild the whole tree above the `MaterialApp`.
- Use `const` constructors where they are natural, but do not contort code for them. The compiler already handles most constant folding.
- Keep the first screen's widget tree shallow. A hero section with twelve nested wrappers is twelve rebuild scopes.

## What did not help

- **Shader warmup.** With Impeller on iOS and modern Android, the old Skia shader compilation advice is mostly obsolete. Test before adding complexity.
- **Aggressive `const` everywhere.** Marginal. Readability wins.
- **Splash screens held longer** to "hide" slow startup. Users notice; it just moves the wait.
- **Removing the debug banner.** Obviously.

## A checklist I run before release

1. Cold start measured on a mid-range Android device and a two-year-old iPhone.
2. `main()` contains no awaited third-party initialization.
3. First frame does not wait on network.
4. Fonts subset and weights limited.
5. Images decoded at display size.
6. Large payload parsing moved off the UI isolate.
7. Tabs and heavy controllers constructed lazily.
8. Release build size inspected with `--analyze-size`.

Startup work is unglamorous, but it compounds: every session starts faster, on every device, forever. If your Flutter app feels slow before the first screen, [I can help you profile it](mailto:hasanabbassorathiya12@gmail.com).
