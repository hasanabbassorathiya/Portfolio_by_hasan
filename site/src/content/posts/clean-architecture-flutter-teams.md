Most Flutter "Clean Architecture" posts show the same diagram: presentation, domain, data, arrows pointing inward. The diagram is fine. The problem is that a diagram is not an architecture. Architecture is what happens when a new engineer joins, opens the repo, and tries to change one screen without breaking three others.

I have shipped Flutter apps in fintech, e-commerce, mobility, and consumer apps used daily by thousands of people. The codebases that survived were not the ones with the most folders. They were the ones with clear seams. Here is the version I keep coming back to.

## Start with features, not layers

The classic layout gives you `data/`, `domain/`, and `presentation/` at the top level. Six months later, every one of those folders contains fifty files from eight unrelated product areas, and nobody can tell what depends on what.

I organize by feature first, then by layer inside the feature:

```text
lib/
  features/
    loans/
      domain/        loan.dart, loan_repository.dart, failure.dart
      data/          http_loan_repository.dart, loan_dto.dart
      presentation/  loan_list_page.dart, loan_list_controller.dart
    onboarding/
    profile/
  core/
    network/  storage/  analytics/  design/
```

The rule is simple: **a feature may depend on `core` and on its own domain, never on another feature's internals.** If loans and onboarding need to talk, they agree on a small interface in `core` or through the router — not by importing each other's widgets.

This one change removes most of the "where does this file go" debates. The answer is almost always "inside the feature that owns the concept."

## Make failure a type

Exceptions are invisible in a signature. A repository that returns `Future<List<Loan>>` can fail in five ways, and the compiler will not remind anyone. In production apps I use an explicit result type for anything that crosses a boundary:

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your connection.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Your session expired.']);
}
```

Now the UI has to handle both branches, and analytics can count failures by type instead of parsing strings. It also forces a decision I care about: **what does the user actually see when this fails?** "Something went wrong" is not an error strategy.

## Repositories are interfaces owned by the domain

The domain defines the contract; the data layer implements it:

```dart
abstract interface class LoanRepository {
  Future<Result<List<Loan>>> activeLoans();
  Future<Result<void>> repay(String loanId, Money amount);
}
```

The HTTP implementation lives in `data/`, and it is the only place that knows about endpoints, JSON keys, or retry policy. Swapping REST for GraphQL, or adding a cache in front, does not touch a single widget.

A practical test: if I delete the `data` folder, the domain and presentation should still compile (minus the wiring). If they do not, the dependency arrow is pointing the wrong way.

## One composition root

Dependency injection does not need a framework. Riverpod providers are my composition root:

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

Widgets ask for a repository; they never construct one. That keeps tests honest — a widget test can override the provider with a fake in one line, and an integration test can point the same provider at a staging base URL.

The anti-pattern I see most often is a global service locator that quietly becomes a second, undocumented dependency graph. Pick one container and use it everywhere.

## Tests that earn their keep

I do not chase coverage percentages. I test three kinds of things:

1. **Domain rules** — money math, date boundaries, eligibility. Pure Dart, fast, no mocks.
2. **Mapping** — DTO to entity, including malformed payloads. These catch backend drift early.
3. **The critical path in the UI** — login, checkout, submit. One integration test per path, not per widget.

Widget tests for every padding change are theatre. A failing mapping test on a Monday morning is money.

## The migration path

You rarely get to start clean. On an existing codebase, I migrate in this order:

1. Add the result type and use it for **new** endpoints only.
2. Move one vertical slice (a single screen plus its data access) behind a repository interface.
3. Put that repository behind a provider.
4. Repeat for the next most-changed screen, not the most-shared one.

Never do the big-bang rewrite. The teams that rewrite "properly" usually ship late and reintroduce the same coupling under new folder names.

## What I skip

- **A use case class for every repository method.** Use cases earn their place when they orchestrate multiple repositories or contain real policy. `GetLoansUseCase` that just forwards a call is noise.
- **A dependency injection package on day one.** Start with providers; add codegen when the graph genuinely hurts.
- **Layers for their own sake.** If a feature has one screen and one endpoint, it still gets `domain/` and `data/`, but it might be three small files — that is fine.

## The test of a good architecture

Six months from now, someone should be able to answer three questions in under a minute: where does this screen live, where does its data come from, and what happens when the network fails. If the repo answers those, the diagram does not matter.

If you are rebuilding a Flutter codebase or hiring someone to do it, [send me a note](mailto:hasanabbassorathiya12@gmail.com). I have done this migration in production more than once, and I am happy to compare notes.
