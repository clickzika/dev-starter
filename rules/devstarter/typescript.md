# DevStarter TypeScript Rules

Apply these rules to all TypeScript files in the project.

## Types

- Enable `strict: true` in tsconfig — no exceptions
- No `any` type — use `unknown` + type guard, or narrow properly
- No type assertions (`as X`) without a comment explaining why it's safe
- Prefer `interface` over `type` for object shapes; use `type` for unions/intersections
- Export types alongside the code that uses them — no separate `types.ts` dumping grounds
- Use `readonly` on object properties that should not mutate

## Functions

- Return types must be explicit on all exported functions
- Prefer named functions over anonymous arrow functions for stack traces
- Max function length: 40 lines — extract if longer
- No implicit returns in functions with complex control flow

## Imports

- Use absolute imports (path aliases) over deep relative paths (`../../..`)
- Group imports: external packages → internal modules → types — separated by blank lines
- No default exports from library-style modules — named exports only
- No barrel files (`index.ts` re-exporting everything) in feature modules

## Null Safety

- Never use `!` (non-null assertion) — handle the null case explicitly
- Prefer optional chaining (`?.`) over null checks for nested access
- Use nullish coalescing (`??`) not logical OR (`||`) for default values

## Async

- Always `await` Promises — no floating Promises
- Wrap `async` function bodies in try/catch at call boundaries (not in every helper)
- Prefer `Promise.all` over sequential `await` when calls are independent

## Classes

- Prefer plain functions and modules over classes unless stateful lifecycle is needed
- No public fields without `readonly` — use accessors if mutation is controlled

## Enums

- Prefer `const` enums or plain object literals (`as const`) over `enum`
- Never use numeric enums — string enums only for debuggability
