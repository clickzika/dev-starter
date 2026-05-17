# Go Design Patterns

## Functional Options (for complex constructors)
```go
type Server struct { port int; timeout time.Duration }

type Option func(*Server)

func WithPort(p int) Option { return func(s *Server) { s.port = p } }
func WithTimeout(d time.Duration) Option { return func(s *Server) { s.timeout = d } }

func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080, timeout: 30 * time.Second}
    for _, o := range opts { o(s) }
    return s
}
// Usage: NewServer(WithPort(9090), WithTimeout(60*time.Second))
```

## Repository Interface
```go
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}
// Define interface where it's used (the consumer), not where it's implemented
```

## Worker Pool
```go
func workerPool(ctx context.Context, jobs <-chan Job, n int) <-chan Result {
    results := make(chan Result, n)
    var wg sync.WaitGroup
    for i := 0; i < n; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range jobs {
                results <- process(ctx, j)
            }
        }()
    }
    go func() { wg.Wait(); close(results) }()
    return results
}
```

## Table-Driven Tests
```go
func TestAdd(t *testing.T) {
    cases := []struct{ a, b, want int }{
        {1, 2, 3}, {0, 0, 0}, {-1, 1, 0},
    }
    for _, tc := range cases {
        t.Run(fmt.Sprintf("%d+%d", tc.a, tc.b), func(t *testing.T) {
            if got := Add(tc.a, tc.b); got != tc.want {
                t.Errorf("Add(%d,%d) = %d, want %d", tc.a, tc.b, got, tc.want)
            }
        })
    }
}
```
