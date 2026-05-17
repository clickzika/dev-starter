# DevStarter Python Rules

Apply these rules to all Python files in the project.

## Style

- Follow PEP 8 — enforced via `ruff` or `flake8` in CI
- Max line length: 100 characters
- Use double quotes for strings consistently
- No trailing whitespace, no blank lines at end of file
- One blank line between methods; two blank lines between top-level definitions

## Type Hints

- All function signatures must have type annotations (parameters + return)
- Use `from __future__ import annotations` for forward references
- Prefer `X | None` over `Optional[X]` (Python 3.10+)
- Use `list[X]`, `dict[K, V]`, `tuple[X, ...]` not `List`, `Dict`, `Tuple` from `typing`
- Use `TypeVar` and `Generic` for reusable generic code

## Functions

- Max function length: 40 lines — extract helpers if longer
- No `*args, **kwargs` without explicit documentation of what is passed
- Default argument values must be immutable — no mutable defaults (`def f(x=[])`)
- Prefer keyword-only arguments for functions with 3+ parameters

## Classes

- Use `@dataclass` or `@attrs` for data-holder classes
- No bare `except:` — always catch specific exceptions
- Use `__slots__` for performance-critical data classes

## Async

- Use `async`/`await` consistently — no mixing sync/async in the same call chain
- Prefer `asyncio.gather()` over sequential `await` for independent coroutines
- Use `aiohttp` or `httpx` for HTTP (never `requests` in async context)

## Imports

- Use absolute imports; no relative imports in application code (only in packages)
- Group imports: stdlib → third-party → local — separated by blank lines (isort enforces this)
- No wildcard imports (`from x import *`)

## Error Handling

- Raise specific exceptions — no bare `raise Exception("msg")`
- Log errors with context before re-raising — include the original exception with `from e`
- Use custom exception classes for domain-specific errors

## Testing

- Use `pytest` — no `unittest` unless extending existing test suite
- Test file: `test_<module>.py` — one test file per module
- Use `pytest.fixture` for shared setup — no global state between tests
- Parametrize repeated test patterns with `@pytest.mark.parametrize`
