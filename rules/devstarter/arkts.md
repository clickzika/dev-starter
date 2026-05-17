# ArkTS Coding Rules (HarmonyOS)

## Type Safety
- Enable strict mode in all files — ArkTS enforces stricter typing than TypeScript
- No `any` type — use explicit types or `unknown` with type guards
- Use `@Observed` and `@ObjectLink` for reactive state in components; never mutate state directly
- Avoid dynamic property access (`obj[key]`) — use explicit property names for type safety

## State Management
- Use `@State` for local component state; `@Prop` for parent-to-child one-way binding
- Use `@Link` for bidirectional parent-child binding; use sparingly — prefer `@Prop` + event callback
- Use `@Provide` / `@Consume` for cross-component state; do not pass deeply nested props
- AppStorage and LocalStorage for global/persistent state — access via `AppStorage.SetOrCreate`

## Component Design
- Each component in its own file; name matches filename
- Keep `build()` methods under 50 lines — extract subcomponents
- Avoid business logic in `build()` — compute values in `aboutToAppear()` or computed properties
- Use `@Builder` for reusable UI fragments within a component

## Async & Threading
- Use `TaskPool` for CPU-heavy work; never block the main thread
- Use `async/await` for async operations; handle errors with try/catch
- Access UI only from the main thread; use `@ohos.taskpool` for worker threads

## Testing
- Unit test with `@ohos/hypium` framework
- Component tests: mount components and assert rendered output
- Avoid testing implementation details — test user-visible behavior
