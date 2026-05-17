# Testing Rules

## Testing Philosophy
- Test behavior, not implementation — tests should survive refactoring
- Test the public interface; do not test private methods directly
- One assertion per test is a goal, not a rule — test one scenario per test
- Tests are documentation — a well-named test describes expected behavior

## Test Pyramid
- **Unit tests** (70%): fast, isolated, no I/O — test individual functions and classes
- **Integration tests** (20%): test real interactions between components (DB, API, queue)
- **E2E tests** (10%): test critical user flows in a real browser/environment

## What to Test
- Happy path: the expected successful flow
- Boundary conditions: empty lists, zero, max values, single items
- Error paths: what happens when dependencies fail
- Authorization: ensure unauthorized users can't access protected resources

## Test Quality
- Tests must be deterministic — no random data without seeding, no time-dependent logic
- Tests must be independent — no shared mutable state between tests
- Tests must be fast — unit tests < 10ms each; the full suite should run in < 5 minutes
- Flaky tests must be fixed immediately — a flaky test is worse than no test

## Naming
- Test names describe the scenario: `should_return_404_when_user_not_found`
- Group related tests in a describe/context block named after the function or scenario
- Use AAA structure: Arrange (setup) → Act (call) → Assert (verify)

## Mocking
- Mock external systems (HTTP, email, payment), not internal logic
- Use real databases for integration tests when possible — mocked DB tests miss query bugs
- Reset mocks between tests; never share mock state
- Verify mock interactions only when the interaction IS the behavior being tested
