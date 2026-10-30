Riverpod is powerful enough to support almost any architecture, which is exactly why teams get lost in it. After shipping several Flutter apps with it — including an enterprise mobility platform with multiple squads — these are the patterns that survived contact with production, and the three I now avoid on purpose.

## Providers are wiring, not state containers

The healthiest Riverpod codebases use providers mainly to compose dependencies:

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: Env.apiBaseUrl);
  ref.onDispose(client.close);
  return client;
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return HttpLoanRepository(ref.watch(apiClientProvider));
});
```

Screens do not know how a repository is built. Tests override the provider. Swapping an implementation is a one-line change at the composition root.

The failure mode is turning every boolean into a provider. If a value belongs to one widget's local interaction — a password visibility toggle, a scroll position — keep it in `State`. Riverpod is for state that outlives a widget or is shared between them.

## AsyncNotifier for screen state

For anything asynchronous, `AsyncNotifier` gives you loading, error, and data states without inventing your own enum:

```dart
final loanListProvider =
    AsyncNotifierProvider.autoDispose<LoanList, List<Loan>>(LoanList.new);

class LoanList extends AutoDisposeAsyncNotifier<List<Loan>> {
  @override
  Future<List<Loan>> build() {
    return ref.watch(loanRepositoryProvider).activeLoans();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loanRepositoryProvider).activeLoans(),
    );
  }
}
```

`AsyncValue.guard` handles the try/catch and preserves the previous data while refreshing — which is exactly the behavior users expect when they pull to refresh.

## Scope by route, not by app

A checkout flow should not keep its state alive after checkout finishes. `autoDispose` plus a route-level `ProviderScope` override is the cleanest way I have found:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ProviderScope(
      overrides: [
        checkoutDraftProvider.overrideWith(CheckoutDraft.new),
      ],
      child: const CheckoutPage(),
    ),
  ),
);
```

Now the draft resets when the route is popped, without manual `ref.invalidate` calls scattered through the code.

Be careful with tab shells: if a tab's state must survive switching tabs, do **not** mark it `autoDispose`. I have seen users lose a half-filled form because a provider was disposed while the tab was off-screen.

## ref.listen for side effects, not build

Navigation, snackbars, and analytics belong in `ref.listen`, never inside `build`:

```dart
ref.listen(loanListProvider, (previous, next) {
  next.whenOrNull(
    error: (error, _) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$error'))),
  );
});
```

Side effects in `build` fire on every rebuild, including the ones caused by theme changes or keyboard insets. `ref.listen` fires when the value actually changes.

## Rebuild discipline with select

Watching a whole object rebuilds a widget when any field changes. `select` narrows the dependency:

```dart
final isVerified = ref.watch(
  profileProvider.select((profile) => profile.valueOrNull?.isVerified ?? false),
);
```

Use it where rebuilds are measurable — long lists, animated headers, chart widgets. Do not sprinkle `select` everywhere to feel productive; premature narrowing makes the data flow harder to read.

## Test the container, not the widget

Most of my Riverpod tests do not pump widgets at all:

```dart
test('returns network failure when the API is unreachable', () async {
  final container = ProviderContainer(
    overrides: [
      loanRepositoryProvider.overrideWithValue(FakeLoanRepository.offline()),
    ],
  );
  addTearDown(container.dispose);

  final result = await container.read(loanListProvider.future);
  expect(result, isEmpty);
});
```

Fast, deterministic, and it tests the part that actually breaks.

## Three patterns I avoid

**1. Providers for everything.** A provider per widget field creates a graph nobody can trace and rebuilds you cannot predict. Local widget state is not a code smell.

**2. Passing `ref` into domain code.** The domain should not know Riverpod exists. If a use case needs a dependency, pass it in the constructor; keep `ref` at the boundary.

**3. Global mutable singletons behind providers.** A provider that returns the same mutable object to everyone is a singleton with extra steps. It will eventually be mutated from two places at once. Prefer immutable state and explicit updates.

## The rule of thumb

If a new engineer can look at a screen, follow its provider to a repository, and understand where the data comes from without opening five other files, the Riverpod usage is healthy. The package is not the architecture — it is the wiring. Keep the wiring boring and the product logic obvious.

If your team is untangling a Riverpod codebase, [get in touch](mailto:hasanabbassorathiya12@gmail.com). I review Flutter architecture for teams and enjoy the messy ones.
