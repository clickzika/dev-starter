# /devstarter-verification-loop — Verification Loop

Run a full 6-phase quality gate on current changes before committing.

## What it runs

1. **Build** — compile/build check
2. **Type** — tsc / mypy / go vet / cargo check
3. **Lint** — eslint / ruff / golangci-lint / clippy
4. **Tests** — full suite + coverage (80% threshold)
5. **Security** — secrets scan + debug statement check
6. **Diff** — review what changed

## Inline args

```
/devstarter-verification-loop              # run once
/devstarter-verification-loop continuous   # re-run every 15 min
```

## Supported stacks

Node.js/TS · Go · Python · Rust · Flutter/Dart · Java/Kotlin · PHP/Laravel

Read `~/.claude/sdlc/devstarter-verification-loop.md` and run the full workflow.
