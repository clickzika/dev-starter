# Git Workflow Rules

## Branch Naming
- `feature/short-description` — new functionality
- `fix/short-description` — bug fixes on develop
- `hotfix/short-description` — production emergency fixes (branch from main)
- `release/vX.Y.Z` — release preparation branch

## Commits
- Use Conventional Commits format: `type(scope): message`
  - `feat:` new feature
  - `fix:` bug fix
  - `chore:` maintenance, deps, tooling
  - `docs:` documentation only
  - `refactor:` no behavior change
  - `test:` tests only
- Subject line: imperative mood, under 72 chars, no period
- Body: explain WHY, not WHAT — reference issue numbers

## Protected Branches
- `main` — production; only release branches merge here
- `develop` — integration; feature branches merge here via PR
- `uat` — staging; develop merges here before release
- Never `git push --force` on shared branches

## Pull Requests
- One PR per feature/fix — do not bundle unrelated changes
- Title = commit message format; body = what, why, how to test
- Request review from the right people — not everyone needs to review everything
- Rebase onto target branch before merging to keep linear history

## Do Not
- Never commit secrets, tokens, or credentials — use `.env` (gitignored)
- Never `--no-verify` to skip hooks — fix the hook failure instead
- Never amend published commits — create a new fixup commit
- Never rewrite history on shared branches
