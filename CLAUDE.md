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
- `NetworkService` itself has no dedicated tests yet (no `URLProtocol` stub
  in place) — see "Known gaps" below before assuming its request/decoding
  logic is covered.

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
- `NetworkService` itself (as opposed to the ViewModel layer that wraps it)
  has no test coverage yet — treat any change there as untested until proven
  otherwise.

## Spec format for new feature requests

When asked to implement a feature from a written spec, expect (and ask for,
if missing): the user-facing behavior, which existing screen/ViewModel it
touches, and what "done" looks like in terms of a test that would fail before
the change and pass after. A spec without a stated done-condition is
incomplete — say so instead of guessing.
