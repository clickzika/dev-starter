# Fitness Functions — Setup Guide

> **Why:** Top-1% engineering teams (Stripe, Google, Spotify) automate
> architectural quality checks in CI. They catch ~80% of architectural
> regressions before code review, freeing humans to focus on judgment calls.
> DevStarter ships this as a copy-paste template.

## What ships

`templates/github/fitness-functions.yml` — a GitHub Actions workflow with
four checks that run on every PR:

| # | Check               | Fails when                                          |
|---|---------------------|-----------------------------------------------------|
| 1 | Bundle budget       | Frontend `dist/` exceeds size threshold (default 500 KB) |
| 2 | Dependency rules    | Module-boundary violations (depcruise / import-linter) |
| 3 | Coverage gate       | Test coverage drops below threshold (default 80%)   |
| 4 | Complexity ceiling  | Any function exceeds cyclomatic complexity ceiling (default 10) |

Stack-aware: each check auto-detects Node / Python / Go and runs only what
applies. Skip individual checks via repo-level vars (see Tuning below).

## Install (3 minutes)

1. Copy the workflow into your repo:
   ```bash
   mkdir -p .github/workflows
   cp ~/.claude/templates/github/fitness-functions.yml .github/workflows/
   git add .github/workflows/fitness-functions.yml
   git commit -m "ci: add fitness-functions quality gates"
   git push
   ```

2. Open a draft PR and verify all 4 checks appear under "Checks" tab.

3. Make the roll-up status required for merge:
   - GitHub repo → Settings → Branches → Branch protection rule for `main`
     and `develop` (and `uat` if used)
   - Under "Require status checks to pass before merging," add:
     - `Fitness Functions / All checks`
   - Save.

That's it — no PR can merge to a protected branch with a failing fitness
function.

## Tuning thresholds

Set repository-level variables (Settings → Secrets and variables → Actions →
Variables) to override defaults without editing the workflow:

| Variable               | Default | Notes                                    |
|------------------------|---------|------------------------------------------|
| `BUNDLE_BUDGET_KB`     | `500`   | Total bytes (KB) of `dist/` after build |
| `BUNDLE_DIST_DIR`      | `dist`  | Build output directory                  |
| `COVERAGE_THRESHOLD`   | `80`    | Minimum line coverage %                 |
| `COMPLEXITY_CEILING`   | `10`    | Max cyclomatic complexity per function  |
| `SKIP_BUNDLE`          | `0`     | Set `1` to skip bundle check            |
| `SKIP_DEPS`            | `0`     | Set `1` to skip dependency-rule check   |
| `SKIP_COVERAGE`        | `0`     | Set `1` to skip coverage gate           |
| `SKIP_COMPLEXITY`      | `0`     | Set `1` to skip complexity ceiling      |

## Per-check setup

### 1. Bundle budget (Node only)

Works out of the box if `npm run build` produces output in `dist/`. If your
build directory is different (e.g. `build/`, `out/`, `.next/`), set
`BUNDLE_DIST_DIR` accordingly.

**Tightening:** start at 500 KB, then ratchet down toward the actual size
your app needs. A budget you never approach is theatre — set it ~10–20%
above current size and tighten quarterly.

### 2. Dependency rules

This check is opt-in — it only runs if a config file exists.

**Node — install dependency-cruiser:**
```bash
npm i -D dependency-cruiser
npx depcruise --init
```

Edit the generated `.dependency-cruiser.cjs` — common rules to add:

```js
forbidden: [
  {
    name: 'no-frontend-from-backend',
    severity: 'error',
    from: { path: '^backend/' },
    to:   { path: '^frontend/' }
  },
  {
    name: 'no-circular',
    severity: 'error',
    from: {},
    to: { circular: true }
  },
  {
    name: 'no-orphans',
    severity: 'warn',
    from: { orphan: true, pathNot: '\\.(test|spec)\\.[jt]sx?$' },
    to: {}
  }
]
```

**Python — install import-linter:**
```bash
pip install import-linter
```

Create `.importlinter`:

```ini
[importlinter]
root_package = your_package

[importlinter:contract:1]
name = Layered architecture
type = layers
layers =
    your_package.api
    your_package.services
    your_package.repositories
    your_package.models
```

### 3. Coverage gate

Works out of the box if your test runner emits a coverage report.

**Node (vitest):**
```js
// vitest.config.ts
test: {
  coverage: {
    provider: 'v8',
    reporter: ['text', 'json-summary'],
    thresholds: { lines: 80, functions: 80, branches: 70, statements: 80 }
  }
}
```

**Node (jest):** Add to `package.json`:
```json
"jest": {
  "coverageReporters": ["text", "json-summary"]
}
```

**Python:** No setup needed — pytest-cov is auto-installed by the workflow.

**Go:** No setup needed — uses standard `go test -cover`.

**Tightening:** business logic should target ≥80% line coverage. UI glue
code can be lower (≥60%). Don't chase 100% — the marginal tests are usually
the brittle ones.

### 4. Complexity ceiling

Works out of the box. Default ceiling is 10 (industry standard for "this
function is starting to get hard to test").

**Node:** Uses ESLint's built-in `complexity` rule. No config needed.

**Python:** Uses radon. No config needed. Maps `COMPLEXITY_CEILING` to
radon ranks: ≤10=B, ≤20=C, ≤30=D.

**Go:** Uses [gocyclo](https://github.com/fzipp/gocyclo). No config needed.

**Tightening:** start at 10. If you can't get under it, the function
probably has too many responsibilities — refactor, don't raise the ceiling.

## When to use vs alternatives

- **Use fitness-functions.yml** when: you want automated, language-aware
  quality gates that fail builds (the bar this PR establishes)
- **Use claude-pr-review.yml** in addition when: you also want narrative
  AI review on the diff (different concern — judgment, not metrics)
- Both can run in parallel; they complement each other.

## When a check fires unexpectedly

1. **Bundle exceeded:** Run `npm run build && du -sh dist/` locally to
   confirm. Likely a new dependency. Either trim, or raise budget after
   discussing with TechLead (don't silently bump).

2. **Dependency rule violation:** Run the local command shown in the
   workflow log. Fix the import or document the exception in
   `.dependency-cruiser.cjs` with a `severity: warn` carve-out.

3. **Coverage drop:** Add tests for the new code. Don't add `@ts-ignore`
   or skip tests — the gate exists because that path was breaking customers.

4. **Complexity ceiling:** Refactor. Extract helpers. If it's truly
   irreducible (rare — usually parser/state-machine code), add an inline
   `// eslint-disable-next-line complexity` with a comment explaining why.

## Adoption playbook

1. Install with all defaults → run on a recent merged PR (manually) to
   establish current baseline.
2. Set thresholds 10–20% looser than baseline so existing code passes.
3. Tighten one threshold per sprint — communicate the change in retro.
4. Within ~3 months you'll be at industry-standard thresholds and the
   gate becomes a real bar, not theatre.

## How DevStarter uses this

When `/devstarter-new` or `/devstarter-existing` runs, the workflow is
copied automatically and branch protection is configured to require it.

`/devstarter-change` Gate A4 verifies the fitness checks have passed
before allowing PR merge.

`@devstarter-techlead` references this template when defining
architectural fitness in their ADRs.
