# Swift Coding Rules

## Optionals
- Never force-unwrap (`!`) outside of tests and IBOutlets — use `guard let` or `if let`
- Use `guard let` at function entry for early exit; `if let` for branching logic
- Use `??` for default values on optionals; avoid chained `??` deeper than two levels
- Implicitly unwrapped optionals (`T!`) only for IBOutlets and DI properties set in `viewDidLoad`

## Concurrency (Swift Concurrency)
- Use `async/await` for all asynchronous code; avoid completion-handler style for new code
- Mark actor-isolated state with `@MainActor` for UI updates
- Use `Task { }` to bridge sync → async contexts; always cancel tasks in `deinit` or `onDisappear`
- Prefer structured concurrency (`async let`, `TaskGroup`) over unstructured `Task.detached`

## Types
- Prefer `struct` for value semantics; use `class` only when identity or inheritance is needed
- Use `enum` with associated values for sum types; conform to `Equatable` and `Hashable`
- Conform to `Codable` for all DTO types; use `CodingKeys` enum when property names differ
- Use `typealias` to give domain meaning to primitive types (e.g. `typealias UserId = UUID`)

## SwiftUI
- Keep `View` bodies declarative and free of business logic — bind to `@StateObject` / `@ObservableObject`
- Extract subviews into named `View` structs when body exceeds ~30 lines
- Use `@Environment` for dependency injection in SwiftUI; avoid singletons
- Prefer `PreviewProvider` with multiple preview variants for each view

## Testing
- Unit tests: XCTest; UI tests: XCUITest
- Use `XCTAssertEqual`, `XCTAssertThrowsError` — not print assertions
- Test async code with `await fulfillment(of:)` or `async` test methods
- Mock protocols, not concrete types
