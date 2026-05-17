# DevStarter Hooks — Installation & Usage

DevStarter ships 5 Node.js lifecycle hooks that add memory persistence, batch formatting, and debug-log detection to Claude Code.

## Quick Install

```bash
bash install.sh --hooks
```

Or on an existing install:

```bash
node ~/.claude/scripts/install-hooks.js \
  ~/.claude/scripts/hooks \
  ~/.claude/settings.json \
  ~/.claude/templates/hooks/hooks.json
```

Requires **Node.js 18+**. Safe to re-run — duplicate hooks are skipped.

---

## Hooks Included

| Hook | Event | What it does |
|------|-------|-------------|
| `session-start.js` | SessionStart | Reads `memory/progress.json` + MEMORY.md, injects up to 4000 chars of context |
| `pre-compact.js` | PreCompact | Logs compaction event to `memory/compaction-log.txt` |
| `post-edit-accumulator.js` | PostToolUse Edit\|Write | Tracks edited JS/TS/Go/Python/Rust files in temp file for batch Stop processing |
| `stop-format-typecheck.js` | Stop | Batch format (prettier/biome/black/ruff/gofmt/rustfmt) + tsc --noEmit |
| `stop-check-console-log.js` | Stop | Warns on `console.log` / `print()` / `fmt.Println` in git-modified files |

---

## Manual Setup (no installer)

1. Copy scripts:
   ```bash
   cp -r scripts/hooks/ ~/.claude/scripts/hooks/
   ```

2. Merge into `~/.claude/settings.json` manually — add the `"hooks"` block from `templates/hooks/hooks.json`, replacing `${DEVSTARTER_HOOKS_DIR}` with the actual path to `~/.claude/scripts/hooks`.

---

## Formatter Detection (stop-format-typecheck)

| Stack | Detected by | Command |
|-------|------------|---------|
| JS/TS (Prettier) | `.prettierrc*` or `prettier.config.js` | `prettier --write` |
| JS/TS (Biome) | `biome.json` | `biome check --write` |
| TypeScript check | `tsconfig.json` | `tsc --noEmit --skipLibCheck` |
| Python | always tried | `ruff format` then `black` |
| Go | always tried | `gofmt -w` |
| Rust | always tried | `rustfmt` |

Formatters that are not installed are silently skipped.

---

## Debug Log Detection (stop-check-console-log)

Checks git-modified files only. Excluded: `*.test.*`, `*.spec.*`, `*.config.*`, `scripts/`, `__tests__/`, `__mocks__/`.

| Language | Pattern detected |
|----------|----------------|
| JS/TS | `console.log(` |
| Python | `print(` (top-level, not in classes) |
| Go | `fmt.Println(` or `fmt.Printf(` |

Warning only — never blocks the response.

---

## Disabling a Hook

Remove the corresponding entry from `~/.claude/settings.json` under the relevant event key.

---

## Adding Custom Hooks

Write a Node.js script in `~/.claude/scripts/hooks/` following these rules:
- Read JSON from stdin, write it back to stdout unchanged (pass-through)
- Log diagnostics to stderr with `[HookName]` prefix
- Always `exit 0` — never crash Claude Code
- Keep blocking hooks (PreToolUse, Stop) under 200ms — no network calls
