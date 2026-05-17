# Coding Style Rules

## Naming
- Names should describe what, not how — `getUserOrders()` not `fetchFromDbAndReturn()`
- Boolean names: use `is`, `has`, `can`, `should` prefix — `isLoading`, `hasPermission`
- Avoid abbreviations except universally understood ones (`id`, `url`, `api`, `db`)
- Constants: SCREAMING_SNAKE_CASE; types/classes: PascalCase; everything else: camelCase or snake_case per language convention

## Functions
- One function, one responsibility — if the function name needs "and", split it
- Target < 20 lines per function; > 40 is a strong signal to refactor
- Parameters: 0-2 ideal, 3 acceptable, 4+ use an options object/struct
- Avoid boolean parameters that change behavior — split into two functions

## Comments
- Write comments for WHY, not WHAT — the code already shows what
- One short line maximum; never multi-paragraph comment blocks
- Do not comment out code — delete it; git history preserves it
- If you feel compelled to explain WHAT, the code needs better naming

## Files & Modules
- One primary concept per file; file name matches the primary export
- Keep files under 300 lines — larger usually means multiple responsibilities
- Import order: stdlib → third-party → local; separated by blank lines
- No circular imports — if you need A from B and B from A, extract C

## Consistency
- Follow whatever pattern the surrounding code uses — consistency beats personal preference
- If changing style, change the whole file, not just your addition
- Run the formatter before committing — never submit unformatted code
