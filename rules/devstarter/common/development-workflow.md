# Development Workflow Rules

## Starting Work
- Read CLAUDE.md and memory/progress.json before touching any code
- Check for in-progress work from prior sessions — resume before starting new work
- Confirm the branch: never commit directly to `main`, `develop`, `uat` — create `feature/`, `fix/`, or `hotfix/` branch

## Making Changes
- Make one logical change per commit — atomic commits, not "WIP" dumps
- Write the commit message before you start coding — it clarifies scope
- Run tests locally before committing; do not push red builds
- Stage specific files by name — never `git add .` unless all changes are intentional

## Code Quality Gates
- Linter passes: zero warnings in CI-relevant checks
- Type checker passes: no type errors
- Tests pass: all existing tests green; new behavior has new tests
- Security scan: no new high/critical findings in SAST output

## Review & Merge
- Self-review the diff before requesting review — read it line by line
- Respond to every review comment: either fix it or explain why not
- Squash fixup commits before merge if the PR history is noisy
- Delete the branch after merge

## Definition of Done
- Feature works as specified in the acceptance criteria
- Tests cover the happy path and at least one failure path
- Documentation updated if public API or behavior changed
- No TODO/FIXME comments left in new code
- Deployed to staging and smoke-tested (if applicable)
