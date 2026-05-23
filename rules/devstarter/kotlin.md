# Kotlin Coding Rules

## Null Safety
- Never use `!!` (non-null assertion) — handle nullable types explicitly
- Use `?.let`, `?: return`, or `requireNotNull()` instead of `!!`
- Model optional values as `T?` at API boundaries; keep internal types non-nullable
- Use `lateinit var` only for DI-injected fields that are always set before use

## Coroutines
- Use `suspend` functions for all async operations; avoid `runBlocking` except in `main` and tests
- Use structured concurrency: launch from a `CoroutineScope`, not `GlobalScope`
- Prefer `withContext(Dispatchers.IO)` for blocking I/O; do not block on `Dispatchers.Main`
- Use `flow { }` for streams; `StateFlow`/`SharedFlow` for state and events

## Style
- Use data classes for value objects; `copy()` for mutation
- Prefer `when` over `if-else` chains for exhaustive matching
- Use extension functions for utility behavior on existing types
- Avoid `companion object` with `@JvmStatic` unless interop with Java is required

## Classes & Design
- Default to `val` (immutable); use `var` only when mutation is truly needed
- Prefer sealed classes for sum types (state machines, result types)
- Use constructor injection for dependencies; avoid `object` singletons for stateful code
- Mark base classes `open` explicitly — Kotlin defaults to `final`

## Testing
- Use JUnit 5 + Kotest matchers for assertions
- Test coroutines with `runTest { }` from `kotlinx-coroutines-test`
- Mock with MockK; avoid Mockito for Kotlin (poor null safety)
- Use `@TestInstance(Lifecycle.PER_CLASS)` to share setup across tests in a class
