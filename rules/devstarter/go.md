# DevStarter Go Rules

Apply these rules to all Go files in the project.

## Formatting
- `gofmt` and `goimports` are mandatory — no style debates; run in CI
- Line length: no hard limit, prefer < 100 chars for readability

## Error Handling
- Every error must be handled — no `_` for errors unless the function is provably infallible
- Return errors, don't panic — panic only for programmer errors (invariant violations)
- Wrap with `%w` (not `%s`) to preserve chain: `fmt.Errorf("failed to create user: %w", err)`
- Use `errors.Is` / `errors.As` for checking — not string comparison
- Sentinel errors: `var ErrNotFound = errors.New("not found")` at package level

## Interfaces
- Define interfaces at the point of use (consumer), not definition (producer)
- Small interfaces win — prefer 1–3 method interfaces (io.Reader is the gold standard)
- Accept interfaces, return concrete types
- No embedding interfaces in structs to satisfy them without implementing — hides panics

## Packages
- Package name = directory name — one word, lowercase, no underscores
- No `util`, `helper`, `common`, `misc` — name by what they do
- Avoid circular imports — refactor shared types into a dedicated package
- Unexported identifiers are the default — only export what callers need

## Naming
- Short variable names in short scopes (`i`, `n`, `v`) — longer names in longer scopes
- Receiver names: 1–2 letters, consistent across all methods of a type
- Acronyms: all-caps or all-lower by position (`userID`, `HTTPSClient`, `parseURL`)
- No Hungarian notation or type suffixes (`userStr`, `countInt`)
- Avoid stutter: `auth.AuthError` → `auth.Error`; `http.HTTPError` → `http.Error`
- Package names: short, lowercase, single word — `auth` not `authentication`

## Structs
- No exported fields without `json`/`yaml` tags if the struct is serialized
- Use constructor functions for structs with required fields (`NewFoo(...)`)
- Zero value should be useful — design structs so the zero value is valid

## Concurrency
- Document goroutine ownership — who starts it, who stops it, when it exits
- No goroutine leaks — every goroutine must have a clear exit path (context cancel or channel close)
- Use `context.Context` as first argument in every function that does I/O or waits
- Protect shared state with `sync.Mutex` or channels — never access without synchronization
- Prefer channels for communication; prefer mutexes for protecting state
- Use `errgroup` for fan-out goroutines that need error propagation
- Use `sync.WaitGroup` to wait for goroutine completion

## Testing
- Table-driven tests are the default pattern
- Use `t.Run()` for subtests; `t.Parallel()` in each subtest for independent cases
- Use `testify/assert` for cleaner assertions
- File: `<file>_test.go` in same package (white-box) or `_test` suffix package (black-box)
- `TestMain` only for global setup/teardown (database containers)
- Mocking: define interfaces at call sites; mock with `mockery` or `testify/mock`
- HTTP mocks: prefer `httptest.NewServer` over custom mocks
- Coverage: `go test -coverprofile=cover.out ./... && go tool cover -html=cover.out`
- Target 80%+ for service/business logic; 50%+ for handlers and main (with integration tests)
- Race detection: `go test -race ./...`

## Patterns

### Functional Options (complex constructors)
```go
type Option func(*Server)
func WithPort(p int) Option { return func(s *Server) { s.port = p } }
func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080, timeout: 30 * time.Second}
    for _, o := range opts { o(s) }
    return s
}
```

### Repository Interface
```go
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}
// Define at the consumer (caller), not at the implementation
```

### Worker Pool
```go
func workerPool(ctx context.Context, jobs <-chan Job, n int) <-chan Result {
    results := make(chan Result, n)
    var wg sync.WaitGroup
    for i := 0; i < n; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range jobs { results <- process(ctx, j) }
        }()
    }
    go func() { wg.Wait(); close(results) }()
    return results
}
```

## Security
- Validate all inputs at HTTP handlers before passing to services
- SQL: never format strings with user input — use `db.QueryContext(ctx, "WHERE id = ?", id)`
- File paths: `filepath.Clean()` then check against allowed base dir
- Rate-limit all public endpoints: `golang.org/x/time/rate` or middleware
- Secrets: `os.Getenv()` only — never config files committed to git; never log secrets
- HTTP: set `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`; limit body: `http.MaxBytesReader(w, r.Body, 1<<20)`
- Crypto: `crypto/rand` for all RNG — never `math/rand`; bcrypt cost ≥ 12; TLS min version 1.2

## Hooks (Claude Code)

### PostToolUse — goimports after edits
```json
{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command", "command": "echo $CLAUDE_TOOL_OUTPUT | grep -q '\\.go$' && goimports -w $CLAUDE_TOOL_OUTPUT 2>/dev/null || true" }]
}
```

### PostToolUse — go vet after edits
```json
{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command", "command": "echo $CLAUDE_TOOL_OUTPUT | grep -q '\\.go$' && go vet ./... 2>&1 | tail -5 || true" }]
}
```

### PreToolUse — go mod tidy before commit
```json
{
  "matcher": "Bash",
  "hooks": [{ "type": "command", "command": "echo $CLAUDE_TOOL_INPUT | grep -q 'git commit' && go mod tidy && echo 'go mod tidy: done' || true" }]
}
```
