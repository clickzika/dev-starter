# DevStarter Flutter / Dart Rules

Apply these rules to all Dart files in the project.

## Dart Language

- Enable sound null safety — no `!` operator without a comment explaining why it's safe
- Prefer `final` over `var` for variables that don't reassign
- Use `const` wherever possible — reduces widget rebuilds
- No `dynamic` type — use generics or `Object?` with type checks
- Use `late` only when initialization is guaranteed before first use

## Widgets

- Prefer `StatelessWidget` — use `StatefulWidget` only when local mutable state is required
- Split large `build()` methods into private helper widgets or methods — max 60 lines
- Extract repeated widget subtrees into `const` widgets for rebuild optimization
- No business logic in `build()` — compute values before returning widget tree
- Use `const` constructor on leaf widgets that never change

## State Management

- Use a consistent state management approach across the project (Riverpod / Bloc / Provider)
- No `setState()` for state shared between screens — use a state management layer
- Riverpod: use `ref.watch()` for reactive state; `ref.read()` in callbacks only
- Bloc: one event per user action; one state class per feature; no logic in UI
- Avoid rebuilding the entire screen on partial state changes — use granular providers/blocs

## Navigation

- Use named routes or go_router — no `Navigator.push(context, MaterialPageRoute(...))` for app navigation
- Pass only IDs between routes — fetch data in destination screen/bloc
- Handle deep links and back navigation explicitly

## Async

- Always `await` Futures — no `.then()` chains when `async/await` is available
- Use `AsyncValue` (Riverpod) or `BlocBuilder` — no raw `FutureBuilder` for data fetching
- Cancel streams in `dispose()` — no stream subscription leaks

## Performance

- Use `ListView.builder` / `GridView.builder` for long lists — never `Column` with unbounded children
- Profile before optimizing — use Flutter DevTools before adding `const` everywhere
- No `print()` in production code — use `debugPrint()` or a logging package
- Images: use `cached_network_image` for remote images; specify `width`/`height`

## Platform Code

- Separate platform-specific code into platform channels — no platform checks scattered in UI
- Use `Platform.isAndroid` / `Platform.isIOS` only in platform-channel wrappers, not in widgets

## Testing

- Unit tests for business logic (blocs, repositories, use cases)
- Widget tests for individual widget behavior
- Integration tests for full user flows
- Use `flutter_test` + `mockito` or `mocktail` for mocking
- No `sleep()` in tests — use `pumpAndSettle()` or fake async

## Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention, not SCREAMING_SNAKE)
- Private members: prefix `_`

## Project Structure

```
lib/
├── core/           ← shared utilities, constants, extensions
├── features/       ← one folder per feature
│   └── [feature]/
│       ├── data/   ← repositories, data sources, models
│       ├── domain/ ← entities, use cases, repository interfaces
│       └── ui/     ← screens, widgets, blocs/providers
└── main.dart
```
