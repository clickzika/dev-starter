# Go Testing Rules

## Framework
- Use standard `testing` package; `testify/assert` for cleaner assertions
- File naming: `*_test.go` in same package (white-box) or `*_test` package (black-box)
- Run: `go test ./...`; with race: `go test -race ./...`

## Table-Driven Tests
Always use table-driven format for functions with multiple input/output cases:
```go
func TestParseDate(t *testing.T) {
    cases := []struct {
        name  string
        input string
        want  time.Time
        err   bool
    }{
        {"valid", "2024-01-15", time.Date(2024,1,15,0,0,0,0,time.UTC), false},
        {"invalid", "not-a-date", time.Time{}, true},
    }
    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            got, err := ParseDate(tc.input)
            if tc.err { assert.Error(t, err); return }
            assert.NoError(t, err)
            assert.Equal(t, tc.want, got)
        })
    }
}
```

## Subtests & Parallelism
- Use `t.Run()` for subtests; call `t.Parallel()` in each subtest for independent cases
- `TestMain` for global setup/teardown (database containers, etc.)

## Mocking
- Define interfaces at call sites; mock with `mockery` or `testify/mock`
- Prefer `httptest.NewServer` for HTTP dependency mocks over custom mocks

## Coverage
- Run: `go test -coverprofile=cover.out ./... && go tool cover -html=cover.out`
- Target 80%+ for service/business logic; handlers and main: 50%+ with integration tests
