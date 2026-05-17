# F# Coding Rules

## Functional Style
- Prefer pure functions; isolate side effects at the boundary
- Use immutable records and discriminated unions (DU) for domain modeling
- Use `|>` (pipe) to compose operations; avoid deeply nested function calls
- Prefer `let` bindings over mutable variables; use `mutable` only when performance demands

## Types & Domain Modeling
- Model domain with discriminated unions — make illegal states unrepresentable
- Use `Option<T>` (not null) for optional values; `Result<T,E>` for operations that can fail
- Use record types with `with` syntax for updates — never mutate records
- Use type aliases (`type UserId = UserId of Guid`) for newtype pattern

## Error Handling
- Use `Result<T,E>` with `bind`/`map` for railway-oriented programming
- Use the `result { }` computation expression for sequential Result operations
- Never raise exceptions in library code — reserve `failwith` for programmer errors
- Return `Result` at system boundaries; let the caller decide how to handle failure

## Modules & Organization
- Organize by feature, not by layer — keep related types, functions, and tests together
- Use signature files (`.fsi`) for public API of libraries
- Mark implementation details with `internal` or `private`
- Avoid `open` of multiple modules that export conflicting names

## Testing
- Use Expecto or xUnit with FsUnit for assertions
- Use FsCheck for property-based tests on domain invariants
- Structure tests as plain `let` functions in a module — no class ceremony
- Test DU exhaustiveness: add new cases, see what breaks
