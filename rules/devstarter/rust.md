# Rust Coding Rules

## Ownership & Borrowing
- Prefer references over cloning; clone only when ownership transfer is needed
- Use `Cow<str>` for functions that may or may not own strings
- Prefer `&str` over `String` in function parameters; return `String` when allocating
- Use `Arc<T>` for shared ownership across threads, `Rc<T>` for single-thread

## Error Handling
- Define custom error types with `thiserror`; propagate with `?`
- Never use `.unwrap()` or `.expect()` in library code — return `Result`
- In binaries, `.expect("reason")` is acceptable at startup; never in hot paths
- Use `anyhow::Result` in application code for ergonomic error context

## Types & Traits
- Implement `Debug` on all public types; `Display` on user-facing types
- Use newtypes to enforce domain invariants (e.g. `struct UserId(Uuid)`)
- Prefer `impl Trait` in function arguments; `Box<dyn Trait>` for dynamic dispatch when necessary
- Derive `Default` explicitly; do not rely on zero-initialization assumptions

## Async
- Use `tokio` as the async runtime; annotate entrypoints with `#[tokio::main]`
- Avoid `.await` inside closures passed to non-async contexts — use `tokio::task::spawn_blocking`
- Prefer `tokio::select!` over nested futures for concurrent branches
- Do not `block_on` inside async context

## Safety
- No `unsafe` without a `// SAFETY:` comment explaining every invariant upheld
- Minimize `unsafe` surface — encapsulate in a single module with a safe API wrapper
- Run `cargo clippy --all-targets -- -D warnings` in CI; fix all warnings

## Testing
- Unit tests in `#[cfg(test)] mod tests` in the same file
- Integration tests in `tests/` directory at crate root
- Use `tokio::test` for async tests
- Property-based tests with `proptest` for complex invariants
