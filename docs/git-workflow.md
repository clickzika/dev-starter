# Git Workflow Guide

_Branch strategy: **develop → uat → main**_
_Last updated: 2026-04-23_

---

## Branch Overview

| Branch | Purpose | Who pushes | Protection |
|--------|---------|-----------|-----------|
| `main` | Production — live users | Only via release merge | ✅ Protected |
| `uat` | User Acceptance Testing | Only via release merge | ✅ Protected |
| `develop` | Active development (default) | Only via PR from `feature/*` | ✅ Protected |
| `feature/*` | Each task / story | Each dev freely | ❌ Open |

---

## Daily Dev Workflow (every developer)

### 1. Start a new task

```bash
git checkout develop
git pull origin develop              # always sync before branching

git checkout -b feature/[task-name]
# e.g. feature/user-login
#      feature/payment-api
#      fix/cart-total-wrong
```

### 2. Work and commit

```bash
git add [files]
git commit -m "feat: add user login form"
# Use conventional commits:
# feat:     new feature
# fix:      bug fix
# chore:    config, deps, no logic change
# docs:     documentation only
# refactor: restructure, no behavior change
# test:     tests only
```

### 3. Push and open PR

```bash
git push origin feature/[task-name]

gh pr create \
  --title "feat: add user login form" \
  --body "Closes #[issue-number]" \
  --base develop
```

### 4. After PR is approved and merged

```bash
git checkout develop
git pull origin develop              # sync the merged work
git branch -d feature/[task-name]   # delete local branch (remote auto-deleted)
```

---

## View, Approve & Merge PRs (Head Dev)

### View open PRs

```bash
# List all open PRs targeting develop
gh pr list --base develop

# View details of a specific PR
gh pr view 12

# View in browser
gh pr view 12 --web
```

### Review / Approve a PR

```bash
# Approve
gh pr review 12 --approve

# Approve with comment
gh pr review 12 --approve --body "LGTM, tested locally"

# Request changes
gh pr review 12 --request-changes --body "Please fix the validation"

# Comment only (no decision)
gh pr review 12 --comment --body "Question on line 45"
```

### Merge PR to develop

```bash
# Squash + delete feature branch (recommended)
gh pr merge 12 --squash --delete-branch

# Merge commit (keeps all commits)
gh pr merge 12 --merge --delete-branch

# Rebase merge
gh pr merge 12 --rebase --delete-branch
```

### Full daily flow (Head Dev)

```bash
# 1. See what's ready
gh pr list --base develop

# 2. Review the code
gh pr view 12

# 3. Approve
gh pr review 12 --approve --body "LGTM"

# 4. Merge + delete branch
gh pr merge 12 --squash --delete-branch

# 5. Sync local develop
git checkout develop && git pull origin develop
```

---

## Release Flow (Head Dev only)

### Step 1 — Merge develop → uat (for testing)

```bash
git checkout uat
git pull origin uat
git merge develop --no-ff -m "release: merge develop to uat for testing"
git push origin uat
```

→ QA team pulls `uat` branch to test environment and tests  
→ Do NOT touch `main` until QA approves

### Step 2 — Merge uat → main (after QA approves)

```bash
git checkout main
git pull origin main
git merge uat --no-ff -m "release: v2.0.0"
git tag v2.0.0
git push origin main --tags
```

→ Production deployment runs from `main`

### Step 3 — Return to develop

```bash
git checkout develop
```

> **Using DevStarter?**
> Run `/devstarter-release v2.0.0` — it handles all phases above,
> stops at each gate for your approval (SIT → UAT → Production).

---

## Hotfix Flow (critical production bug)

### 1. Branch from main

```bash
git checkout main
git pull origin main
git checkout -b hotfix/[bug-description]
# e.g. hotfix/payment-crash-on-checkout
```

### 2. Fix the bug, commit, open PR to main

```bash
git add [files]
git commit -m "hotfix: fix payment crash on checkout"
git push origin hotfix/[bug-description]

gh pr create --title "hotfix: fix payment crash" --base main
```

### 3. After PR approved — merge, tag, backport

```bash
# Tag on main
git checkout main && git pull
git tag v2.0.1
git push origin main --tags

# Backport to uat
git checkout uat
git pull origin uat
git merge main --no-ff -m "chore: backport hotfix v2.0.1 to uat"
git push origin uat

# Backport to develop
git checkout develop
git pull origin develop
git merge main --no-ff -m "chore: backport hotfix v2.0.1 to develop"
git push origin develop
```

---

## Branch Protection Rules

All three branches (main, uat, develop) are protected:

| Rule | main | uat | develop |
|------|------|-----|---------|
| Require PR to merge | ✅ | ✅ | ✅ |
| 1 approving review required | ✅ | ✅ | ✅ |
| Dismiss stale reviews | ✅ | ✅ | ✅ |
| Status checks must pass | ✅ | ✅ | ✅ |
| Block force push (`--force`) | ✅ | ✅ | ✅ |
| Block branch deletion | ✅ | ✅ | ✅ |

**No one can `git push origin main`, `git push origin uat`, or `git push origin develop` directly.**
All code enters via Pull Request.

---

## Key Rules

1. **Never commit directly to `main`, `uat`, or `develop`**
2. **Always branch from `develop`**, not from `main` or `uat`
3. **One feature = one branch = one PR**
4. **Sync develop before branching**: `git pull origin develop`
5. **Use conventional commits** — `feat:`, `fix:`, `chore:`, `docs:`
6. **Hotfixes branch from `main`** — not develop
7. **Backport hotfixes** to both `uat` and `develop` after merging to `main`

---

## Quick Reference

```bash
# New task
git checkout develop && git pull origin develop
git checkout -b feature/[name]

# Push + open PR to develop
git push origin feature/[name]
gh pr create --base develop

# Review & merge PR
gh pr list --base develop
gh pr review 12 --approve
gh pr merge 12 --squash --delete-branch

# Release: develop → uat
git checkout uat && git pull origin uat
git merge develop --no-ff -m "release: merge to uat"
git push origin uat

# Release: uat → main (after QA approves)
git checkout main && git pull origin main
git merge uat --no-ff -m "release: vX.Y.Z"
git tag vX.Y.Z && git push origin main --tags

# Hotfix: branch from main
git checkout main && git pull origin main
git checkout -b hotfix/[name]
# fix → PR to main → tag → backport to uat + develop
```
