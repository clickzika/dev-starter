# Dart Coding Style

## Null Safety
- Enable sound null safety: `dart pub upgrade --null-safety`
- Use `?` for nullable types, `!` only when null is truly impossible and you can prove it
- Use `??` for defaults, `?.` for safe calls, `late` for fields guaranteed to initialize before use
- Avoid `dynamic` — use specific types or generics

## Naming
- Classes and enums: `PascalCase`
- Variables, methods, parameters: `camelCase`
- Constants: `camelCase` (Dart convention, not SCREAMING_SNAKE)
- Private members: `_camelCase` (underscore prefix)
- Files: `snake_case.dart`

## Code Organization
- One primary class per file; filename matches the class name in snake_case
- Import order: dart: → package: → relative; separate each group with blank line
- Use `part`/`part of` only for generated code (build_runner output)

## Functions & Methods
- Prefer `=>` for single-expression functions: `int double(int x) => x * 2;`
- Use named parameters for 3+ parameters: `void send({required String to, String? cc})`
- Mark required parameters with `required`; give defaults where sensible
- Avoid positional optional parameters `[x]` for public APIs — use named

## Classes
- Prefer `const` constructors for immutable classes
- Use factory constructors for named constructors that return subtypes
- Override `==` and `hashCode` together; use `Object.hash()` for `hashCode`
- Prefer `@immutable` on value objects

## Flutter-Specific
- `const` on widgets where possible — prevents unnecessary rebuilds
- Extract large `build()` methods into smaller widget methods or classes
- Avoid side effects in `build()` — use `initState`, `didChangeDependencies`
