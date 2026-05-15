# devstarter-gitsetup.md — Git & Gitflow Setup

> **TL;DR** — Set up git + GitFlow + branch protection + standard labels on a repo · **Lifecycle** Discovery · **Gates** 1

## Model: Sonnet (`claude-sonnet-4-6`)

**Agent:** @devstarter-devops (Pompompurin)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.*`, `branch_protection.*`).

Idempotent — safe to re-run on a repo already partially configured. Each step checks current state before making changes.

---

## ⚠️ CRITICAL RULES

### Rule — Read Config First
Always read `devstarter-config.yml` before doing anything. Never assume branch names or repo details.

### Rule — Idempotent Steps
Every step MUST check current state before acting:
- Branch already exists → skip creation, print ✅
- Label already exists → skip creation, print ✅
- Remote already set → skip, print ✅
Never fail on already-done state.

### Rule — Inline Args
If called with a specific arg (`branches`, `protect`, `cleanup`, `labels`), run ONLY that phase.
If called with `full`, skip Gate 1 confirmation and run all phases.
If called with no args, show the setup plan at Gate 1 and wait for approval.

---

## PHASE 1 — Read Config

Read `devstarter-config.yml` and extract:

```bash
# Variables used throughout all phases
GITHUB_USERNAME=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
PROJECT_NAME=$(grep 'name:' devstarter-config.yml | head -1 | awk '{print $2}')
MAIN_BRANCH=$(grep 'main_branch:' devstarter-config.yml | awk '{print $2}' || echo "main")
UAT_BRANCH=$(grep 'uat_branch:' devstarter-config.yml | awk '{print $2}' || echo "uat")
DEV_BRANCH=$(grep 'dev_branch:' devstarter-config.yml | awk '{print $2}' || echo "develop")
RELEASE_REMOTE=$(grep 'release_remote:' devstarter-config.yml | awk '{print $2}' | tr -d '"' || echo "origin")
RELEASE_REPO=$(grep 'release_repo:' devstarter-config.yml | awk '{print $2}' | tr -d '"' || echo "")
```

If `devstarter-config.yml` is missing, print:
```
⚠️  devstarter-config.yml not found.
    Copy ~/.claude/templates/devstarter-config.template.yml to this project root
    and fill in your values, then run /devstarter-gitsetup again.
```
Then stop.

---

## GATE 1 — Setup Plan

(Skip if called with `full` arg.)

Show plan before making any changes:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌿 GIT & GITFLOW SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:  [project name]
Repo:     [github username]/[project name]

Steps that will run:
  Phase 2 — Connect/verify remote origin
  Phase 3 — Create gitflow branches (main · uat · develop)
  Phase 4 — Apply branch protection
  Phase 4.5 — Post-merge branch cleanup (auto-delete + fetch.prune)
  Phase 5 — Create standard GitHub labels

Each step is idempotent — already-done items are skipped.

  "approve" → run all phases
  "cancel"  → exit without changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate 1 — Git setup plan ready. Approve to run all phases?"
- options: ["approve", "cancel"]

⛔ Wait for approval before proceeding.

---

## PHASE 2 — Connect Remote

(Skip if arg = `branches`, `protect`, or `labels`.)

Read `~/.claude/sdlc/devstarter-github.md` → PROC-GH-02:

```bash
# Check if remote already set
if git remote get-url origin &>/dev/null; then
  EXISTING_REMOTE=$(git remote get-url origin)
  echo "✅ Remote already set: $EXISTING_REMOTE"
else
  echo "⚠️  No remote 'origin' found."
  echo "    Enter GitHub repo URL or name (e.g. myrepo or https://github.com/user/myrepo):"
  # Claude prompts user, then:
  git remote add origin "https://github.com/$GITHUB_USERNAME/$PROJECT_NAME.git"
  git fetch origin
  echo "✅ Remote connected: origin → github.com/$GITHUB_USERNAME/$PROJECT_NAME"
fi

# Verify connectivity
git ls-remote --exit-code origin &>/dev/null && \
  echo "✅ Remote is reachable" || \
  echo "⚠️  Remote unreachable — check credentials or repo name"
```

---

## PHASE 3 — Ensure Gitflow Branches

(Run if arg = `branches` or `full` or no arg.)

```bash
cd "$PROJECT_DIR"

for BRANCH in "$MAIN_BRANCH" "$UAT_BRANCH" "$DEV_BRANCH"; do

  # Check local
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    echo "✅ Local branch exists: $BRANCH"
  else
    git checkout -b "$BRANCH" 2>/dev/null
    echo "✅ Created local branch: $BRANCH"
  fi

  # Check remote
  if git ls-remote --exit-code origin "$BRANCH" &>/dev/null; then
    echo "✅ Remote branch exists: origin/$BRANCH"
  else
    git push -u origin "$BRANCH" 2>/dev/null && \
      echo "✅ Pushed to remote: origin/$BRANCH" || \
      echo "⚠️  Could not push $BRANCH — check permissions"
  fi

done

# Return to dev branch
git checkout "$DEV_BRANCH"

# Set default branch on GitHub
gh repo edit "$GITHUB_USERNAME/$PROJECT_NAME" --default-branch "$DEV_BRANCH" 2>/dev/null && \
  echo "✅ Default branch set to: $DEV_BRANCH" || \
  echo "⚠️  Could not set default branch via gh — set manually in GitHub repo settings"
```

---

## PHASE 4 — Apply Branch Protection

(Run if arg = `protect` or `full` or no arg.)

Read `~/.claude/sdlc/devstarter-github.md`:
- → PROC-GH-18: apply standard protection to `main` + `uat`
- → PROC-GH-10 Scenario A check: if `release_remote != origin` and `release_repo` is set, also protect release repo main

After main + uat are protected, ask about develop:

```
Protect the develop branch too?

  Recommended for teams ≥ 3 — forces all devs to use feature/* branches + PRs.
  Claude agents already use PRs via Gate 4 (PROC-GH-06/07/08).

Use `AskUserQuestion` with:
- question: "Protect the develop branch? (Recommended for teams ≥ 3)"
- options: ["yes — protect develop", "no — skip for now"]
```

Then → PROC-GH-10 Step 2 based on user answer.

---

## PHASE 4.5 — Post-Merge Branch Cleanup

(Run if arg = `protect`, `cleanup`, `full`, or no arg.)

Eliminate stale feature branches on both remote and local clone after every PR merge. Two one-time settings + one optional alias.

### Step 1 — Enable GitHub auto-delete head branches (remote)

```bash
# Check current state
CURRENT=$(gh api "repos/$GITHUB_USERNAME/$PROJECT_NAME" --jq '.delete_branch_on_merge')
if [ "$CURRENT" = "true" ]; then
  echo "✅ delete_branch_on_merge already enabled"
else
  gh api -X PATCH "repos/$GITHUB_USERNAME/$PROJECT_NAME" \
    -f delete_branch_on_merge=true --jq '{delete_branch_on_merge}' \
    && echo "✅ Enabled delete_branch_on_merge on $GITHUB_USERNAME/$PROJECT_NAME" \
    || echo "⚠️  Could not enable — check repo admin permission"
fi
```

Effect: GitHub removes the head branch (`feature/*`, `fix/*`, etc.) on the remote the moment a PR is merged via UI / `gh pr merge` / API.

### Step 2 — Enable global git fetch.prune (local)

```bash
# Check current state
CURRENT=$(git config --global --get fetch.prune 2>/dev/null)
if [ "$CURRENT" = "true" ]; then
  echo "✅ fetch.prune already enabled globally"
else
  git config --global fetch.prune true \
    && echo "✅ Enabled global fetch.prune=true" \
    || echo "⚠️  Could not set git config"
fi
```

Effect: Every `git fetch`/`git pull` auto-removes stale `origin/feature/*` tracking refs whose remote branches were deleted by Step 1.

### Step 3 — Offer optional `git sweep` alias

Ask the user whether to add a global alias that batch-deletes locally-merged feature branches:

Use `AskUserQuestion` with:
- question: "Add `git sweep` alias? (deletes all local branches already merged into develop)"
- options: ["yes — add sweep alias", "no — skip"]

If yes:

```bash
# Git for Windows / Git Bash / macOS / Linux — alias runs through sh
git config --global alias.sweep "!git branch --merged $DEV_BRANCH | grep -vE '^\\*|$MAIN_BRANCH|$UAT_BRANCH|$DEV_BRANCH' | xargs -r git branch -d"
echo "✅ Added: git sweep  (run after a merge to clean local branches)"
```

Note for pure PowerShell users without Git Bash on PATH: provide this inline command instead of an alias, since `!`-shell aliases route through sh:

```powershell
git branch --merged develop | Where-Object { $_ -notmatch '^\*|develop|main|uat' } | ForEach-Object { git branch -d $_.Trim() }
```

### Step 4 — Print per-merge workflow reminder

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧹 POST-MERGE CLEANUP CONFIGURED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
After every PR merge, run:

  git checkout develop && git pull
  git branch -d feature/<slug>

  Remote branch:    already deleted by GitHub on merge
  Stale origin/*:   auto-pruned on the git pull
  Local branch:     removed by `git branch -d` (safe — refuses unmerged)

Squash-merged PRs leave the feature branch "unmerged" from git's POV.
Either force-delete with `git branch -D feature/<slug>` (safe if you
trust the squash landed), or use `gh pr list --state merged` to
identify branches that actually landed and delete those.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Rollback (if ever needed)

```bash
git config --global --unset fetch.prune
gh api -X PATCH "repos/$GITHUB_USERNAME/$PROJECT_NAME" -f delete_branch_on_merge=false
git config --global --unset alias.sweep   # if added
```

---

## PHASE 5 — Create Standard Labels

(Run if arg = `labels` or `full` or no arg.)

Read `~/.claude/sdlc/devstarter-github.md` → PROC-GH-04:

```bash
echo "Creating GitHub labels (skipping any that already exist)..."

# Gate labels
gh label create "gate:1-discovery"   --color "0075ca" --description "Gate 1: Discovery" 2>/dev/null || true
gh label create "gate:2-design"      --color "e4e669" --description "Gate 2: Design" 2>/dev/null || true
gh label create "gate:3-foundation"  --color "d93f0b" --description "Gate 3: Foundation" 2>/dev/null || true
gh label create "gate:4-feature"     --color "0e8a16" --description "Gate 4: Feature" 2>/dev/null || true
gh label create "gate:5-delivery"    --color "5319e7" --description "Gate 5: Delivery" 2>/dev/null || true

# Role labels
gh label create "role:frontend"  --color "1d76db" --description "@devstarter-frontend" 2>/dev/null || true
gh label create "role:backend"   --color "e4e669" --description "@devstarter-backend"  2>/dev/null || true
gh label create "role:dba"       --color "0e8a16" --description "@devstarter-dba"      2>/dev/null || true
gh label create "role:qa"        --color "d93f0b" --description "@devstarter-qa"       2>/dev/null || true
gh label create "role:devops"    --color "5319e7" --description "@devstarter-devops"   2>/dev/null || true
gh label create "role:security"  --color "b60205" --description "@devstarter-security" 2>/dev/null || true
gh label create "role:uxui"      --color "f9d0c4" --description "@devstarter-uxui"     2>/dev/null || true

# Status labels
gh label create "status:blocked"     --color "b60205" --description "Blocked" 2>/dev/null || true
gh label create "status:in-progress" --color "e4e669" --description "In Progress" 2>/dev/null || true
gh label create "status:in-review"   --color "0075ca" --description "In Review" 2>/dev/null || true

# Priority labels
gh label create "priority:critical" --color "b60205" 2>/dev/null || true
gh label create "priority:high"     --color "d93f0b" 2>/dev/null || true
gh label create "priority:medium"   --color "e4e669" 2>/dev/null || true
gh label create "priority:low"      --color "0e8a16" 2>/dev/null || true

echo "✅ Labels done"
```

---

## PHASE 6 — Summary

Print final state:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ GIT & GITFLOW SETUP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Repo:    github.com/[username]/[project]

Branches:
  main     → Production (protected ✅)
  uat      → User acceptance testing (protected ✅)
  develop  → Active development (default branch ✅)
             [protected ✅ | unprotected ⚠️]

Labels:   [N] created · [N] already existed (skipped)

Post-merge cleanup:
  delete_branch_on_merge ✅
  global fetch.prune     ✅
  git sweep alias        [✅ added | — skipped]

Next steps:
  → Start a feature:  /devstarter-change add [feature]
  → Run CI setup:     /devstarter-devops
  → Set up secrets:   /devstarter-secrets
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
