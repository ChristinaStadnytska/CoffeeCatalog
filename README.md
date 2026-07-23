# ☕ CoffeeCatalog

A small SwiftUI app that fetches a catalog of coffees from a REST API, lets you browse details, add and edit entries, mark favourites, and pick photos from the library. Built as a learning/portfolio project to practise modern iOS architecture and Swift concurrency.

## Features

- **Coffee list** loaded from a public REST API, rendered in a scrollable list.
- **Explicit UI states** — loading, loaded, error — driven by a `ViewState` enum, with a **Retry** action on failure.
- **Detail screen** via type-safe `NavigationStack` navigation.
- **Add & edit** coffees through a reusable form.
- **Favourites** — toggle directly from the list; state lives in the view model.
- **Remote images** loaded and cached with `AsyncImage`, wrapped in a reusable `CoffeeImageView` with loading/placeholder/failure states.
- **Photo picker** for local images via a `UIViewControllerRepresentable` bridge to `UIImagePickerController`.

## Architecture

The app follows **MVVM** with a clear separation between UI, presentation logic, and data access.

```
CoffeeCatalog/
├── Models/
│   └── CoffeeModel.swift          // Codable model with custom decoding
├── ViewModels/
│   └── CoffeeListViewModel.swift  // ObservableObject, owns state & business logic
├── Services/
│   └── NetworkService.swift       // Protocol-based networking (async/await)
├── Views/
│   ├── HomeCoffeeView.swift       // List + state switching
│   ├── HomeCoffeeDetailView.swift
│   ├── HomeCoffeeCell/
│   ├── AddCoffeeView.swift
│   ├── CoffeeImageView.swift      // Reusable AsyncImage wrapper
│   └── ImagePicker.swift
└── CoffeeCatalogTests/
    ├── MockNetworkService.swift   // Test double conforming to the service protocol
    └── CoffeeCatalogTests.swift   // Unit tests for the view model
```

### Key design decisions

- **Dependency injection via protocols.** `CoffeeListViewModel` depends on `NetworkServiceInterface`, not a concrete type. The real `NetworkService` is injected in the app; a `MockNetworkService` is injected in tests — enabling fast, deterministic unit tests with no network.
- **State as data.** Screen state is modelled explicitly with a `ViewState` enum (`default / loading / loaded / error(String)`) instead of scattered boolean flags, so the view simply renders the current state.
- **Single source of truth.** The coffee array lives in the view model as a `@Published` property. Mutations (favourite toggle, add, edit, remove) happen through the array, which drives SwiftUI updates via `objectWillChange`.
- **Reusable components.** Image loading is extracted into `CoffeeImageView`, keeping the list and detail screens clean and making styling changes a one-place edit.
- **`@MainActor`** on UI-mutating async work to keep state updates on the main thread.

## Tech stack

- Swift 6, SwiftUI
- Swift Concurrency (`async / await`, `@MainActor`, `Task`)
- `URLSession` + `Codable`
- Swift Testing (`@Test`, `#expect`)
- MVVM

## Testing

Unit tests cover both the success and failure paths of the list view model:

- `fetchCoffeeList_success_updatesCoffees` — verifies the model populates its list and reaches the `.loaded` state.
- `fetchCoffeeList_failure_setsErrorState` — verifies a thrown error leaves the list empty and moves the model into the `.error` state.

Run them in Xcode with **⌘U**.

## Getting started

1. Clone the repository.
2. Open `CoffeeCatalog.xcodeproj` in Xcode 16+.
3. Build & run (**⌘R**) on an iOS 17+ simulator.
