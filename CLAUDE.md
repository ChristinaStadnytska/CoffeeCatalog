# CoffeeCatalog — agent-readable project guide

This file documents conventions for AI coding assistants (and humans) working
in this repository. Read it before generating new code, so generated code
matches what's already here instead of introducing a second style.

## Architecture

MVVM. Every screen consists of:

- A **View** (SwiftUI) — declarative, no business logic, no direct networking
  or persistence calls.
- A **ViewModel** using `@Observable` (this project uses the modern
  observation framework, not `ObservableObject`/`@Published` — don't mix the
  two styles in new code).
- Dependencies injected through the initializer as **protocols**
  (see `NetworkServiceInterface`), never instantiated directly inside a
  ViewModel. This is what makes `MockNetworkService`-based testing possible —
  breaking this pattern breaks testability.

Reference implementation to copy the shape of: `CoffeeListViewModel` +
`HomeCoffeeView`.

## Networking

- All network calls go through `NetworkService`, which conforms to
  `NetworkServiceInterface`.
- Errors are typed via `NetworkError`, never raw `Error`.
- Tests must never hit the real network. For ViewModel-level tests, inject
  `MockNetworkService` (see `CoffeeCatalogTests/MockNetworkService.swift`) —
  this is the current pattern, used in `CoffeeCatalogTests.swift`.
- `NetworkService`'s own request/decoding logic (as opposed to the ViewModel
  layer) is covered via a `URLProtocol` stub — see
  `CoffeeCatalogTests/StubURLProtocol.swift` and `NetworkServiceTests.swift`.
  Because `NetworkService` calls `URLSession.shared` directly instead of an
  injected session, the stub registers globally, which is why that suite is
  `@Suite(.serialized)`. If `NetworkService` ever takes an injected
  `URLSession`, the stub can move to a per-test `URLSessionConfiguration` and
  the suite can go back to running in parallel.
- Success range for HTTP responses is `200...299` (fixed from a previous
  `200...209` typo that silently rejected valid 2xx responses above 209 —
  harmless today since this API always returns exactly 200, but worth
  knowing if a status code ever changes).

## When generating a new screen

1. Create `<Name>ViewModel.swift` using `@Observable`, with dependencies
   injected as protocols in the initializer.
2. Create `<Name>View.swift` — SwiftUI only.
3. If the ViewModel takes a new protocol dependency, add a corresponding
   `Mock<Name>Service` so it stays testable.
4. Do not fetch data in `init()` — use `.task {}` in the View, matching the
   existing pattern in `HomeCoffeeView`.

## When generating tests

- Use **Swift Testing** (`@Test`, `#expect`), not XCTest — that's what the
  rest of the suite uses.
- Mock dependencies through existing protocols; don't introduce a new mocking
  approach for a single test file.

## Known gaps — don't assume these are finished

- Favourites are currently stored in memory only, no persistence yet.
- `NetworkError.invalidURL` and the non-`HTTPURLResponse` branch of
  `badResponse(statusCode: -1)` are unreachable with the current
  `CoffeeCategory`/URL construction and are intentionally left untested —
  covering them would mean faking behavior that can't happen in production
  rather than testing real logic. Revisit only if `NetworkService` starts
  accepting an injected/configurable base URL.
- The Combine-based `fetchOnePublisher` path does not validate the HTTP
  status code at all (only the async and GCD paths do) — not currently
  exercised by the app's UI, but worth knowing if it's ever wired up.

## Spec format for new feature requests

When asked to implement a feature from a written spec, expect (and ask for,
if missing): the user-facing behavior, which existing screen/ViewModel it
touches, and what "done" looks like in terms of a test that would fail before
the change and pass after. A spec without a stated done-condition is
incomplete — say so instead of guessing.
