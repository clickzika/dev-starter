# Node.js Rules

## Stack Defaults
- Runtime: Node.js >=18; CommonJS (`require`/`module.exports`) unless file ends in `.mjs`
- No TypeScript in scripts — plain `.js`; use `tsc --noEmit` for type-checking adjacent TS
- Linter: ESLint flat config; Markdown: markdownlint-cli
- Test runner: project-defined (jest/vitest/node:test); mirror `scripts/` structure in `tests/`

## Code Style
- `const` over `let`; never `var`
- File naming: lowercase-with-hyphens (`session-start.js`, `post-edit-format.js`)
- Keep individual scripts under 200 lines — extract helpers to `lib/`
- Prefer relative imports within a package; named exports over `module.exports = function`

## Hook Script Rules
- Always `exit 0` on non-critical errors — never block tool execution unexpectedly
- Log errors to stderr with a `[HookName]` prefix; never swallow silently
- Blocking hooks (PreToolUse, Stop): keep under 200ms — no network calls
- Async/long-running hooks: set `"timeout"` in settings.json; default max 30s
- Parse stdin defensively — guard against empty input and malformed JSON:
  ```js
  process.stdin.on('end', () => {
    try { const input = JSON.parse(data); /* ... */ } catch {}
    process.stdout.write(data); // always pass through
    process.exit(0);
  });
  ```

## Error Handling
- Wrap main in try/catch; exit 0 on unexpected errors (hooks must not crash Claude Code)
- Use `process.stderr.write()` for diagnostics — do not use `console.error` in hooks (adds newline formatting differences)
- Never throw from a PostToolUse or Stop hook — warn and continue

## Testing
- New `scripts/lib/` helpers → matching test in `tests/lib/`
- New hooks → at least one integration test
- Run full test suite before committing: `node tests/run-all.js` or project equivalent
- Use `node --test` (Node 18+) for lightweight tests without a test framework

## Security
- Treat stdin content as untrusted — validate before acting on file paths or commands
- Never pass stdin content directly to `exec()` or `shell: true`
- See also: `rules/devstarter/common/security.md` § Injection Prevention
