# PHP Coding Rules

## Types & Null Safety
- Declare strict types in every file: `declare(strict_types=1);`
- Use typed properties, parameter types, and return types everywhere — no untyped code
- Use `?Type` for nullable; never pass `null` where a value is expected without explicit nullable typing
- Use enums (PHP 8.1+) for fixed value sets; avoid string/int magic constants

## Error Handling
- Throw specific exception classes (extend `RuntimeException` or domain-specific base)
- Never catch `Throwable` silently — log or re-throw
- Use `finally` only for cleanup, not for control flow
- Validate at system boundaries (HTTP input, CLI args); trust typed internal data

## Architecture
- Use constructor injection for all dependencies — no `new` inside services
- Follow PSR-4 autoloading: one class per file, namespace matches directory structure
- Keep controllers thin — delegate to services/use-cases; controllers only parse input and return response
- Use repository pattern for data access; never raw SQL in controllers

## Laravel-Specific (when applicable)
- Use Eloquent accessors/mutators via `Attribute` casts (Laravel 9+)
- Define `$fillable` or `$guarded` on every model — never `$guarded = []` in production
- Use form request classes for validation — never `$request->validate()` in controllers
- Queue long-running work with Jobs; never block HTTP requests

## Testing
- Use PestPHP for test syntax; PHPUnit as the runner
- Mock with Mockery or Laravel's `$this->mock()`
- Test boundaries: HTTP feature tests for controllers, unit tests for services
- Use factories for test data; never seed production data in tests
