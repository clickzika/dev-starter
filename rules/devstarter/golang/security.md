# Go Security Rules

## Input Validation
- Validate all inputs at HTTP handlers before passing to services
- Use `strconv.Atoi()`, `time.Parse()` etc — never trust string inputs as valid types
- Sanitize file paths: `filepath.Clean()` then check against allowed base dir
- Rate-limit all public endpoints: use `golang.org/x/time/rate` or middleware

## SQL
- Never format SQL strings with user input — use `db.QueryContext(ctx, "WHERE id = ?", id)`
- Use `sqlx` or `pgx` parameterized queries; avoid raw `database/sql` string building
- Limit result sets: always add `LIMIT` clauses

## Secrets
- Never log secrets, tokens, or credentials — mask with `[REDACTED]` in error messages
- Use `os.Getenv()` for secrets, not config files committed to git
- Clear sensitive byte slices after use: `for i := range secret { secret[i] = 0 }`

## HTTP
- Set security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`
- Validate `Content-Type` on POST/PUT requests
- Limit request body size: `http.MaxBytesReader(w, r.Body, 1<<20)`
- Use `net/http`'s built-in timeouts: `ReadTimeout`, `WriteTimeout`, `IdleTimeout`

## Crypto
- Use `crypto/rand` for all random number generation — never `math/rand` for security
- Hash passwords with `golang.org/x/crypto/bcrypt` (cost ≥ 12)
- TLS: always use `tls.Config` with `MinVersion: tls.VersionTLS12`
