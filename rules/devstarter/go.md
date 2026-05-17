# DevStarter Go Rules

Apply these rules to all Go files in the project.

## Error Handling

- Every error must be handled — no `_` for errors unless the function is provably infallible
- Return errors, don't panic — panic only for programmer errors (invariant violations)
- Wrap errors with context: `fmt.Errorf("context: %w", err)`
- Define custom error types for domain errors; use `errors.Is` / `errors.As` for checking
- No sentinel errors (package-level `var ErrFoo = errors.New(...)`) for internal use — use types

## Interfaces

- Define interfaces at the point of use (consumer), not at the point of definition (producer)
- Small interfaces win — prefer 1–3 method interfaces
- Accept interfaces, return concrete types
- No embedding interfaces in structs to satisfy them without implementing — that hides panics

## Packages

- Package name = directory name — one word, lowercase, no underscores
- No `util`, `helper`, `common`, `misc` packages — name by what they do
- Avoid circular imports — refactor shared types into a dedicated package
- Unexported identifiers are the default — only export what callers need

## Concurrency

- No goroutine leaks — every goroutine must have a clear exit path (context cancellation or channel close)
- Use `context.Context` as first argument in every function that does I/O or waits
- Protect shared state with `sync.Mutex` or channels — never access shared state without synchronization
- Prefer channels for communication; prefer mutexes for protecting state
- Use `errgroup` for fan-out goroutines that need error propagation

## Naming

- Short variable names in short scopes (`i`, `n`, `v`) — longer names in longer scopes
- Receiver names: 1–2 letters, consistent across all methods of a type
- No Hungarian notation or type suffixes (`userStr`, `countInt`)
- Acronyms: all-caps or all-lower depending on position (`userID`, `HTTPSClient`, `parseURL`)

## Structs

- No exported fields without `json`/`yaml` tags if the struct is serialized
- Use constructor functions for structs with required fields (`NewFoo(...)`)
- Zero value should be useful — design structs so the zero value is valid

## Testing

- Table-driven tests are the default pattern
- Use `t.Helper()` in test helper functions
- Test file: `<file>_test.go` — same package for white-box, `_test` suffix package for black-box
- No `TestMain` unless absolutely necessary for global setup/teardown
