# C++ Coding Style

## Modern C++ (C++17/20)
- Use `nullptr` not `NULL`; `auto` where type is obvious from context
- Use `static_cast<T>` / `dynamic_cast<T>` — never C-style casts `(T)x`
- Use `constexpr` for compile-time constants; `const` for runtime constants
- Use structured bindings: `auto [key, val] = map.find(k)->second`

## Memory Management (RAII)
- No raw `new`/`delete` — use `std::unique_ptr<T>` (sole ownership), `std::shared_ptr<T>` (shared)
- Use `std::make_unique<T>` and `std::make_shared<T>` — never `new` directly
- RAII for all resources: files, mutexes, connections — wrap in RAII types

## Naming
- Classes/structs: `PascalCase`
- Functions/variables: `snake_case`
- Constants/macros: `ALL_CAPS` (prefer `constexpr` over macros)
- Member variables: `m_name` or `name_` (pick one, be consistent)
- Templates: `T`, `TKey`, `TValue` for single-letter; descriptive for multi

## Functions
- Keep under 40 lines; extract helpers aggressively
- Pass by `const &` for read-only objects; by value for primitives and movable types
- Return by value — let NRVO/move semantics optimize; avoid output parameters
- Use `[[nodiscard]]` on functions returning error codes or owning resources

## Error Handling
- For recoverable errors: return `std::expected<T, E>` (C++23) or `std::optional<T>`
- For unrecoverable errors: throw typed exceptions derived from `std::exception`
- Never use exceptions for control flow; never catch and ignore exceptions
- Mark functions that never throw: `noexcept`
