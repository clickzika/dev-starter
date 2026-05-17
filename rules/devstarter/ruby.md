# Ruby Coding Rules

## Style
- Follow the Ruby Style Guide (rubocop defaults); run `rubocop -a` in CI
- Use `frozen_string_literal: true` magic comment in all files
- Prefer `symbol` keys in hashes over string keys for internal data
- Use `do...end` for multi-line blocks, `{ }` for single-line

## Null & Conditionals
- Use `&.` (safe navigation) for optional method chains; avoid `try` from ActiveSupport in pure Ruby
- Use guard clauses with `return if condition` rather than deep nesting
- Prefer `fetch` over `[]` on hashes when key must exist (raises `KeyError` on miss)

## Classes & Modules
- Keep classes under 100 lines; extract concerns to modules when behavior is reusable
- Use `attr_reader` (not `attr_accessor`) for encapsulated state — expose writers only when needed
- Use `Struct` or `Data` (Ruby 3.2+) for simple value objects
- Avoid `method_missing` — use explicit method definitions or `define_method`

## Rails-Specific (when applicable)
- Keep controllers RESTful — 7 actions max; add new controllers rather than extra actions
- Use `before_action` only for authentication/authorization, not for complex setup
- Prefer service objects or interactors for business logic over fat models
- Use `scope` with lambdas in models; never chain scopes with `.where` in controllers

## Testing
- Use RSpec with `expect` syntax; avoid `should` style
- Use FactoryBot for fixtures; minimize `create` vs `build` (prefer `build` for unit tests)
- Mock external services with VCR or WebMock
- Test behavior, not implementation: test public API, not private methods
