# Design Patterns Rules

## When to Use Patterns
- Use patterns to solve recurring problems — not to demonstrate knowledge
- Name the pattern explicitly in the code (naming it `UserRepository` signals the Repository pattern)
- Prefer simple code over pattern for one-off cases; extract the pattern when the same structure appears 3+ times

## Recommended Patterns by Context

### Data Access
- **Repository** — abstract storage behind an interface; enables mocking and storage swaps
- **Unit of Work** — group multiple operations into a single transaction boundary

### Business Logic
- **Service Layer** — stateless classes that orchestrate domain operations
- **Command/Query Separation** — commands mutate state; queries return data; never both
- **Strategy** — inject behavior as a function or interface; avoid long if/switch chains

### State & Events
- **State Machine** — model workflows as explicit states + transitions; use sealed types
- **Observer/Event Bus** — decouple publishers from subscribers; use for cross-cutting events
- **Saga** — coordinate multi-step distributed operations with compensation steps

### Async / Concurrent
- **Circuit Breaker** — fail fast when a downstream service is unhealthy
- **Retry with Backoff** — retry transient failures; cap retries; use exponential backoff + jitter
- **Bulkhead** — isolate resource pools to contain failure blast radius

## Anti-Patterns to Avoid
- **God Object** — one class that knows and does everything; split it
- **Anemic Domain Model** — domain objects with no behavior, just data bags; add logic to the model
- **Service Locator** — global registry for dependencies; use constructor injection instead
- **Premature Abstraction** — abstracting before you have two concrete implementations
