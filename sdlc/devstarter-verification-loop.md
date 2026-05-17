# devstarter-verification-loop.md — Verification Loop Workflow

> **TL;DR** — Run a full 6-phase verification pass after changes · **Lifecycle** Quality Gate · **Gates** 1

## Model: Sonnet (`claude-sonnet-4-6`)

---

## CRITICAL RULES

- Run all 6 phases in order — do not skip phases
- Fix failures before moving to next phase
- Gate 1: show VERIFICATION REPORT, wait for user confirmation
- Continuous mode: re-run every 15 min or after major changes (user opt-in only)

---

## FLOW

### Step 0 — Check for inline arg

If the user ran `/devstarter-verification-loop continuous`:
- Run phases 1-6, then schedule re-run every 15 minutes
- Print reminder: user must keep Claude Code session open

If no arg: run phases 1-6 once, show report, stop.

---

### Phase 1 — Build Verification

Detect project type and run build:

| Stack | Command |
|-------|---------|
| Node.js / TS | `npm run build` or `tsc --noEmit` |
| Go | `go build ./...` |
| Python | `python -m py_compile **/*.py` or `ruff check` |
| Rust | `cargo build` |
| Flutter | `flutter build` (dry run) |
| Java/Kotlin | `./gradlew build` or `mvn compile` |

**Pass**: exit 0, no errors.
**Fail**: capture error, attempt auto-fix if trivial (missing import, type mismatch), else report.

---

### Phase 2 — Type Check

| Stack | Command |
|-------|---------|
| TypeScript | `tsc --noEmit --skipLibCheck` |
| Python | `mypy . --ignore-missing-imports` |
| Go | `go vet ./...` |
| Rust | `cargo check` |
| Dart/Flutter | `dart analyze` |

**Pass**: 0 type errors.
**Fail**: list errors with file:line, attempt fix.

---

### Phase 3 — Lint Check

| Stack | Command |
|-------|---------|
| JS/TS | `eslint . --ext .ts,.tsx,.js,.jsx` or `biome check` |
| Python | `ruff check .` |
| Go | `golangci-lint run` (if installed) else `go vet ./...` |
| Rust | `cargo clippy -- -D warnings` |
| PHP | `./vendor/bin/phpstan analyse` |

**Pass**: 0 errors (warnings OK unless `--strict`).
**Fail**: list violations, fix auto-fixable ones.

---

### Phase 4 — Test Suite

Run full test suite with coverage:

| Stack | Command |
|-------|---------|
| Node.js | `npm test -- --coverage` |
| Go | `go test -race -coverprofile=cover.out ./...` |
| Python | `pytest --cov --cov-report=term-missing` |
| Rust | `cargo test` |
| Flutter | `flutter test` |
| PHP/Laravel | `php artisan test --coverage` |

**Pass threshold**: 80% coverage on service/business logic.
**Fail**: list failing tests + coverage gaps.

---

### Phase 5 — Security Scan

Check git-modified files for:
- Hardcoded secrets: API keys, passwords, tokens (regex patterns)
- Debug statements: `console.log`, `print()`, `fmt.Println`, `debugger`
- Dangerous patterns: `eval()`, `exec()`, `shell=True`, `innerHTML =`
- Known vulnerable packages: check `npm audit`, `pip-audit`, `cargo audit` if available

**Pass**: 0 critical findings.
**Fail**: list findings with severity.

---

### Phase 6 — Diff Review

Run `git diff HEAD` and review:
- Are all changes intentional?
- Any accidental file inclusions?
- Commit message ready? (suggest conventional commit)

---

### Gate 1 — Verification Report

Show structured report, wait for user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 VERIFICATION REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 1 — Build:      ✅ PASS | ❌ FAIL: [error summary]
Phase 2 — Type:       ✅ PASS | ❌ FAIL: [N errors]
Phase 3 — Lint:       ✅ PASS | ⚠️  WARN: [N warnings]
Phase 4 — Tests:      ✅ PASS | ❌ FAIL: [N failed, coverage: X%]
Phase 5 — Security:   ✅ PASS | ⚠️  WARN: [finding summary]
Phase 6 — Diff:       ✅ CLEAN | ⚠️  REVIEW: [N files changed]

Overall: ✅ READY TO COMMIT | ❌ FIX REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- question: "Verification complete. Next step?"
- options:
  - "Commit — everything looks good"
  - "Fix failures — show details"
  - "Ignore warnings — commit anyway"
  - "Run again after manual fix"
