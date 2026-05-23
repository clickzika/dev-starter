# Performance Rules

## Measure First
- Profile before optimizing — never guess where the bottleneck is
- Establish a baseline metric before changing anything
- Set a target (e.g. p95 < 200ms, LCP < 2.5s) — "faster" is not a target

## Common Bottlenecks
- **N+1 queries** — loading a list then fetching related data per item; use eager loading
- **Missing indexes** — check EXPLAIN on slow queries; index join columns and filter columns
- **Synchronous blocking** — network or disk I/O on the main thread or request handler
- **Unbounded result sets** — queries without LIMIT; APIs without pagination
- **Over-fetching** — loading 50 columns when you need 3; select only what you use

## Caching Rules
- Cache at the correct layer: HTTP caching, application cache, DB query cache
- Set explicit TTLs — cache without expiry is a bug waiting to happen
- Cache invalidation: prefer short TTLs over complex invalidation logic
- Do not cache non-idempotent operations; do not cache user-specific data in shared cache

## Frontend Performance
- Lazy-load routes and heavy components
- Keep bundle size in check: run `bundle analyzer` before shipping new deps
- Optimize images: use WebP/AVIF, `srcset`, and `loading="lazy"`
- Minimize main-thread work: defer analytics, third-party scripts

## Load Testing
- Test under realistic concurrency before launch — not just happy-path single-user
- Include warmup phase in benchmarks; discard first 10% of samples
- Test the failure mode: what happens when the system is saturated?
