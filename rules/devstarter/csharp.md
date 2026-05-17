# DevStarter C# Rules

Apply these rules to all C# files in the project.

## Nullability

- Enable `<Nullable>enable</Nullable>` in every .csproj — no exceptions
- No `#nullable disable` pragmas without a comment explaining why
- Use `?` suffix for nullable reference types; never assume non-null from external input
- Use `ArgumentNullException.ThrowIfNull()` at method entry for required parameters (.NET 6+)
- Prefer `??` and `?.` over null checks for chained access

## Types and Records

- Use `record` for immutable data transfer objects — no mutable DTOs
- Use `readonly struct` for small value types that don't change
- Prefer `sealed` classes unless explicitly designed for inheritance
- No `dynamic` type — use generics or interfaces
- Use `required` keyword for mandatory init-only properties (.NET 7+)

## Async

- All I/O methods must be `async Task` or `async Task<T>` — no `async void` except event handlers
- Always `await` Tasks — no `.Result` or `.Wait()` (causes deadlocks in ASP.NET)
- Pass `CancellationToken` through every async call chain — no ignoring cancellation
- Prefer `ConfigureAwait(false)` in library code; not needed in ASP.NET Core controllers
- Use `ValueTask` only for hot paths that frequently return synchronously

## LINQ

- Prefer method syntax over query syntax for single-operation chains
- No LINQ in tight loops — materialize with `.ToList()` / `.ToArray()` before iterating
- Never call `.Count()` when `.Any()` suffices
- No side effects in LINQ predicates (no database calls inside `.Where()` lambdas)

## ASP.NET Core (if used)

- Inject dependencies via constructor — no `ServiceLocator` pattern
- Validate models with Data Annotations or FluentValidation — not manual null checks in controllers
- Use `IOptions<T>` for configuration — no `IConfiguration` injected directly into services
- Return `IActionResult` / `ActionResult<T>` — never raw objects from controllers
- Use `[ApiController]` attribute — enables automatic model validation

## Entity Framework Core (if used)

- No lazy loading — use explicit `.Include()` for eager loading
- All DbContext operations must be async (`.ToListAsync()`, `.SaveChangesAsync()`)
- Use migrations — never `EnsureCreated()` in production
- One DbContext per request (scoped lifetime)

## Error Handling

- Use `ProblemDetails` (RFC 7807) for API error responses — no raw exception messages
- Catch specific exceptions — no bare `catch (Exception e)` unless logging + rethrowing
- Use `ILogger<T>` — no `Console.WriteLine` or `Debug.WriteLine` in production code

## Naming

- Interfaces: prefix `I` (`IUserRepository`)
- Private fields: prefix `_` (`_userService`)
- Constants: PascalCase (`MaxRetryCount`)
- Async methods: suffix `Async` (`GetUserAsync`)
- No Hungarian notation in modern C# (no `strName`, `intCount`)

## Testing

- Use xUnit — preferred over NUnit/MSTest for new projects
- Use FluentAssertions for readable assertions
- Use Moq or NSubstitute for mocking interfaces
- Test class: `[ClassName]Tests` — method: `MethodName_Scenario_ExpectedBehavior`
- No `Thread.Sleep` in tests — use `Task.Delay` or mock time
