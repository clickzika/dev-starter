# Go Coding Style

> Extends `rules/devstarter/go.md` with additional Go-specific conventions.

## Formatting
- `gofmt` and `goimports` are mandatory — no style debates; run in CI
- Line length: no hard limit, but prefer < 100 chars for readability

## Design Principles
- Accept interfaces, return structs — callers define the interface they need
- Keep interfaces small: 1-3 methods (io.Reader, io.Writer are the gold standard)
- Prefer composition over inheritance — embed types, don't inherit

## Error Handling
Always wrap errors with context:
```go
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
```
- Use `%w` (not `%s`) to wrap — allows `errors.Is()` and `errors.As()` to work
- Define sentinel errors as `var ErrNotFound = errors.New("not found")`
- Use `errors.Is(err, ErrNotFound)` to check — not string comparison

## Naming
- Unexported: `camelCase`; exported: `PascalCase`
- Acronyms: `userID`, `httpClient`, `parseURL` — not `userId`, `httpClient`, `parseUrl`
- Package names: short, lowercase, single word — `auth` not `authentication`
- Avoid stutter: `auth.AuthError` → `auth.Error`

## Concurrency
- Document goroutine ownership — who starts it, who stops it, when it exits
- Always pass `context.Context` as the first parameter of long-running functions
- Use `sync.WaitGroup` to wait for goroutine completion; `errgroup` for error propagation
