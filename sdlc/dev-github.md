# dev-github.md — Shared GitHub Procedures

## Purpose

This file contains shared GitHub procedures used by all dev workflows.
Agents import these procedures by reading this file when GitHub actions are needed.

---

## Prerequisites Check

Before any GitHub operation, verify:

```bash
# 1. Load global config
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)

# 2. Verify GITHUB_USERNAME is a username, not a token
node -e "
const u = process.env.GITHUB_USERNAME || '';
if (u.startsWith('ghp_') || u.startsWith('github_pat_') || u.length > 40) {
  console.log('ERROR: GITHUB_USERNAME looks like a token, not a username');
  process.exit(1);
}
console.log('OK: ' + u);
"

# 3. Verify GitHub CLI is authenticated
gh auth status
```

If any check fails → STOP and tell user to run `bash ~/.claude/setup.sh`

---

## PROC-GH-01 — Create New Repository

**Used by:** dev-starter.md (new project)

```bash
cd "$PROJECT_DIR"

# Init git if not already
if [ ! -d .git ]; then
  git init
  cat > .gitignore << 'GITEOF'
node_modules/
.env
.project.env
dist/
build/
*.log
.DS_Store
obj/
bin/
*.user
.vs/
.angular/
__pycache__/
*.pyc
.pytest_cache/
GITEOF
  git add .gitignore
  git commit -m "chore: initial commit"
fi

# Create GitHub repo (private by default)
if ! gh repo view "$GITHUB_USERNAME/$PROJECT_NAME" &>/dev/null; then
  gh repo create "$PROJECT_NAME" --private --source=. --push
  echo "✅ GitHub repo created: github.com/$GITHUB_USERNAME/$PROJECT_NAME"
else
  echo "⚠️  Repo already exists — adding remote"
  git remote add origin "https://github.com/$GITHUB_USERNAME/$PROJECT_NAME.git" 2>/dev/null || true
fi

# Create branch strategy: main (production) + uat (user testing) + develop (development)
git checkout -b develop 2>/dev/null || git checkout develop
git push -u origin develop 2>/dev/null || true

git checkout -b uat 2>/dev/null || git checkout uat
git push -u origin uat 2>/dev/null || true

git checkout develop

echo "✅ Branch strategy:"
echo "   develop  → Claude develops + local test"
echo "   uat      → User acceptance testing"
echo "   main     → Production"
```

---

## PROC-GH-02 — Connect Existing Repository

**Used by:** dev-existing.md, dev-migrate.md

```bash
cd "$PROJECT_DIR"

# Check if remote already set
if git remote get-url origin &>/dev/null; then
  EXISTING_REMOTE=$(git remote get-url origin)
  echo "✅ Remote already set: $EXISTING_REMOTE"
else
  # Ask user for repo
  echo "Enter GitHub repo URL or name (e.g. myrepo or https://github.com/user/myrepo):"
  read -r REPO_INPUT

  if [[ "$REPO_INPUT" == http* ]]; then
    git remote add origin "$REPO_INPUT"
  else
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_INPUT.git"
  fi
  git fetch origin
  echo "✅ Remote connected"
fi
```

---

## PROC-GH-03 — Create Branch Strategy for Migration

**Used by:** dev-migrate.md

```bash
cd "$PROJECT_DIR"

# Create migration branch
MIGRATION_BRANCH="migration/$PROJECT_NAME-$(date +%Y%m%d)"
git checkout -b "$MIGRATION_BRANCH" 2>/dev/null || git checkout "$MIGRATION_BRANCH"
git push -u origin "$MIGRATION_BRANCH" 2>/dev/null || true

echo "✅ Migration branch: $MIGRATION_BRANCH"
echo "⚠️  main and develop branches are PROTECTED — do not modify until Gate 7"
```

---

## PROC-GH-04 — Setup Labels and Milestones

**Used by:** all workflows after task breakdown is approved

```bash
cd "$PROJECT_DIR"

# Create standard labels
echo "Creating GitHub labels..."

# Gate labels
gh label create "gate:1-discovery"   --color "0075ca" --description "Gate 1: Discovery" 2>/dev/null || true
gh label create "gate:2-design"      --color "e4e669" --description "Gate 2: Design" 2>/dev/null || true
gh label create "gate:3-foundation"  --color "d93f0b" --description "Gate 3: Foundation" 2>/dev/null || true
gh label create "gate:4-feature"     --color "0e8a16" --description "Gate 4: Feature" 2>/dev/null || true
gh label create "gate:5-delivery"    --color "5319e7" --description "Gate 5: Delivery" 2>/dev/null || true

# Role labels
gh label create "role:frontend"  --color "1d76db" --description "@frontend" 2>/dev/null || true
gh label create "role:backend"   --color "e4e669" --description "@backend"  2>/dev/null || true
gh label create "role:dba"       --color "0e8a16" --description "@dba"      2>/dev/null || true
gh label create "role:qa"        --color "d93f0b" --description "@qa"       2>/dev/null || true
gh label create "role:devops"    --color "5319e7" --description "@devops"   2>/dev/null || true
gh label create "role:security"  --color "b60205" --description "@security" 2>/dev/null || true
gh label create "role:uxui"      --color "f9d0c4" --description "@uxui"     2>/dev/null || true

# Status labels
gh label create "status:blocked"     --color "b60205" --description "Blocked" 2>/dev/null || true
gh label create "status:in-progress" --color "e4e669" --description "In Progress" 2>/dev/null || true
gh label create "status:in-review"   --color "0075ca" --description "In Review" 2>/dev/null || true

# Priority labels
gh label create "priority:critical" --color "b60205" 2>/dev/null || true
gh label create "priority:high"     --color "d93f0b" 2>/dev/null || true
gh label create "priority:medium"   --color "e4e669" 2>/dev/null || true
gh label create "priority:low"      --color "0e8a16" 2>/dev/null || true

echo "✅ Labels created"
```

---

## PROC-GH-05 — Create GitHub Issue (per task)

**Used by:** all workflows when creating tasks

```bash
# Create one issue per task
# Variables required: TASK_TITLE, TASK_BODY, TASK_LABELS, TASK_MILESTONE

ISSUE_URL=$(gh issue create \
  --title "$TASK_TITLE" \
  --body "$TASK_BODY" \
  --label "$TASK_LABELS" \
  2>/dev/null)

ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')
echo "✅ Issue #$ISSUE_NUMBER created: $ISSUE_URL"

# Save issue number for Notion linking
echo "$ISSUE_NUMBER"
```

**Task body template:**
```markdown
## Description
[task description]

## Acceptance Criteria
- [ ] [criterion 1]
- [ ] [criterion 2]

## Related Documents
- Gate: [N]
- Role: [agent]
- Effort: [S/M/L]
- Notion: [notion task URL — filled after Notion task created]

## Dependencies
[list or "none"]
```

---

## PROC-GH-06 — Start Task (create feature branch)

**Used by:** Gate 4 of all workflows

```bash
# Variables required: ISSUE_NUMBER, TASK_SLUG (kebab-case task name)

BRANCH_NAME="feature/$ISSUE_NUMBER-$TASK_SLUG"
git checkout develop
git pull origin develop
git checkout -b "$BRANCH_NAME"

echo "✅ Branch created: $BRANCH_NAME"
echo "📋 Working on issue #$ISSUE_NUMBER"

# Update GitHub issue status label
gh issue edit "$ISSUE_NUMBER" --add-label "status:in-progress" --remove-label "status:blocked" 2>/dev/null || true
```

---

## PROC-GH-07 — Create Pull Request

**Used by:** Gate 4 after task is complete

```bash
# Variables required: ISSUE_NUMBER, BRANCH_NAME, TASK_TITLE

git push origin "$BRANCH_NAME"

PR_URL=$(gh pr create \
  --title "$TASK_TITLE" \
  --body "Closes #$ISSUE_NUMBER

## Changes
[summary of changes]

## Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing done

## Checklist
- [ ] Code follows project standards (CLAUDE.md)
- [ ] Docs updated if needed
- [ ] No secrets in code
- [ ] OWASP checklist verified (if security-relevant)" \
  --base develop \
  --label "status:in-review")

echo "✅ PR created: $PR_URL"
gh issue edit "$ISSUE_NUMBER" --add-label "status:in-review" --remove-label "status:in-progress" 2>/dev/null || true
```

---

## PROC-GH-08 — Merge PR and Close Issue

**Used by:** Gate 5 after user approves PR

```bash
# Variables required: PR_NUMBER, ISSUE_NUMBER

gh pr merge "$PR_NUMBER" --squash --delete-branch
gh issue close "$ISSUE_NUMBER" --comment "✅ Implemented and merged to develop."

echo "✅ PR merged, issue #$ISSUE_NUMBER closed"
```

---

## PROC-GH-09 — Release Merge Flow (develop → uat → main)

**Used by:** dev-release.md

### Step 1 — Merge develop → uat (for user acceptance testing)

```bash
git checkout uat
git pull origin uat
git merge develop --no-ff -m "release: merge develop to uat for testing"
git push origin uat

echo "✅ Merged develop → uat"
echo "📋 Ready for User Acceptance Testing"
echo "⛔ Wait for user to approve UAT before merging to main"
```

### Step 2 — Merge uat → main (after UAT approved)

```bash
git checkout main
git pull origin main

# Determine version using PROC-GH-15 semver logic
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
# Default to minor bump — override with RELEASE_TYPE if set
NEXT_VERSION=$(PROC-GH-15 logic — see below)

git merge uat --no-ff -m "release: $PROJECT_NAME $NEXT_VERSION"
git tag "$NEXT_VERSION"
git push origin main --tags

echo "✅ Merged to main — tagged $NEXT_VERSION"
echo "🚀 Ready for production deployment"
```

---

## PROC-GH-10 — Branch Protection Rules

**Used by:** dev-starter.md Gate 0 (after repo creation)

```bash
cd "$PROJECT_DIR"

# Protect main branch
gh api repos/$GITHUB_USERNAME/$PROJECT_NAME/branches/main/protection \
  --method PUT \
  --input - << 'EOF'
{
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "enforce_admins": false,
  "required_status_checks": null,
  "restrictions": null
}
EOF

echo "✅ Branch protection set on main:"
echo "   - Require 1 PR review"
echo "   - Dismiss stale reviews on new push"
echo "   - No direct push allowed"

# Note: uat branch uses same protection as main
gh api repos/$GITHUB_USERNAME/$PROJECT_NAME/branches/uat/protection \
  --method PUT \
  --input - << 'EOF2'
{
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "enforce_admins": false,
  "required_status_checks": null,
  "restrictions": null
}
EOF2

echo "✅ Branch protection set on uat:"
echo "   - Only merge from develop (via PROC-GH-09)"

# Note: develop branch is NOT protected
# (agents need to push directly during Gate 3 scaffold)
# After Gate 3, optionally protect develop too:
# gh api repos/$GITHUB_USERNAME/$PROJECT_NAME/branches/develop/protection ...
```

⚠️ **Requires GitHub Pro or public repo** — free private repos cannot set branch protection via API. If it fails, print warning and continue.

---

## PROC-GH-11 — Create Milestones (per Epic)

**Used by:** dev-starter.md Gate 3 (after task breakdown approved)

```bash
cd "$PROJECT_DIR"

# Create one milestone per epic
# Variables required: EPIC_TITLE, EPIC_DESCRIPTION, EPIC_DUE_DATE (optional)

MILESTONE_URL=$(gh api repos/$GITHUB_USERNAME/$PROJECT_NAME/milestones \
  --method POST \
  --field title="$EPIC_TITLE" \
  --field description="$EPIC_DESCRIPTION" \
  --field state="open" \
  --jq '.number')

echo "✅ Milestone created: $EPIC_TITLE (#$MILESTONE_URL)"

# When creating issues (PROC-GH-05), add milestone:
# gh issue create --title "$TASK_TITLE" --body "$TASK_BODY" --milestone "$EPIC_TITLE"
```

**Example milestones for a typical project:**
```
Milestone 1: "Auth & User Management"    — issues #1-#5
Milestone 2: "Core Features"             — issues #6-#12
Milestone 3: "Reports & Export"           — issues #13-#16
Milestone 4: "Quality & Polish"           — issues #17-#20
```

---

## PROC-GH-12 — Hotfix Flow

**Used by:** dev-hotfix.md (critical production bug)

### Step 1 — Create hotfix branch from main

```bash
cd "$PROJECT_DIR"

# Get latest main
git checkout main
git pull origin main

# Create hotfix branch
HOTFIX_BRANCH="hotfix/$ISSUE_NUMBER-$HOTFIX_SLUG"
git checkout -b "$HOTFIX_BRANCH"

echo "✅ Hotfix branch: $HOTFIX_BRANCH (from main)"
echo "⚠️  Fix the bug, then run PROC-GH-12 Step 2"
```

### Step 2 — PR to main + backport to develop

```bash
cd "$PROJECT_DIR"

# Push and create PR to main
git push -u origin "$HOTFIX_BRANCH"

PR_URL=$(gh pr create \
  --title "hotfix: $HOTFIX_TITLE" \
  --body "Closes #$ISSUE_NUMBER

## Hotfix
**Severity:** $SEVERITY
**Impact:** $IMPACT

## Root Cause
[description]

## Fix
[what was changed]

## Testing
- [ ] Fix verified locally
- [ ] No regression in related features
- [ ] Rollback plan confirmed" \
  --base main \
  --label "priority:critical,status:in-review")

echo "✅ Hotfix PR created: $PR_URL"
echo "⛔ Wait for approval before merging"
```

### Step 3 — After PR approved: merge to main + backport to uat + develop

```bash
cd "$PROJECT_DIR"

# Merge to main
gh pr merge "$PR_NUMBER" --squash --delete-branch

# Tag with patch version
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
PATCH_VERSION=$(echo "$LATEST_TAG" | awk -F. '{print $1"."$2"."$3+1}')
git checkout main && git pull
git tag "$PATCH_VERSION"
git push origin main --tags

echo "✅ Hotfix merged to main — tagged $PATCH_VERSION"

# Backport to uat
git checkout uat
git pull origin uat
git merge main --no-ff -m "chore: backport hotfix $PATCH_VERSION to uat"
git push origin uat

echo "✅ Hotfix backported to uat"

# Backport to develop
git checkout develop
git pull origin develop
git merge main --no-ff -m "chore: backport hotfix $PATCH_VERSION to develop"
git push origin develop

echo "✅ Hotfix backported to develop"
gh issue close "$ISSUE_NUMBER" --comment "✅ Hotfix $PATCH_VERSION deployed and backported to uat + develop."
```

---

## PROC-GH-13 — Merge Conflict Resolution

**Used by:** Any workflow when `git merge` or `gh pr merge` fails with conflicts

### Step 1 — Detect conflict

```bash
# When merging develop into feature branch:
git checkout "$FEATURE_BRANCH"
git merge develop

# If conflict detected, git will output:
# CONFLICT (content): Merge conflict in [filename]
# Automatic merge failed; fix conflicts and then commit the result.
```

### Step 2 — Resolve conflicts

```
⚠️ MERGE CONFLICT DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch: [feature branch]
Merging from: develop
Conflicting files:
  - [file1]
  - [file2]

Resolution strategy:
  1. Read both versions of each conflicting file
  2. Understand the intent of BOTH changes
  3. Merge manually — preserve both intentions where possible
  4. If unclear → ask user which version to keep
  5. NEVER blindly pick "ours" or "theirs"
```

### Step 3 — Complete merge

```bash
# After resolving all conflicts in the files:
git add .
git commit -m "chore: resolve merge conflict with develop

Conflicts resolved:
- [file1]: [what was kept/merged]
- [file2]: [what was kept/merged]"

git push origin "$FEATURE_BRANCH"
echo "✅ Conflict resolved and pushed"
```

### Rules:
- **NEVER** use `git checkout --ours .` or `git checkout --theirs .` without reading both sides
- **ALWAYS** read the conflicting sections and understand what each side intended
- **ASK** the user if intent is ambiguous
- **TEST** after resolving — conflicts can introduce subtle bugs

---

## PROC-GH-14 — PR and Issue Templates

**Used by:** dev-starter.md Gate 0 (after repo creation)

Create `.github/` directory with templates:

### Pull Request Template

```bash
mkdir -p "$PROJECT_DIR/.github"

cat > "$PROJECT_DIR/.github/pull_request_template.md" << 'PREOF'
## Summary
<!-- Brief description of what this PR does -->

## Related Issue
Closes #

## Changes
-

## Type of Change
- [ ] Feature (new functionality)
- [ ] Bug fix (fixes an issue)
- [ ] Hotfix (critical production fix)
- [ ] Refactor (no behavior change)
- [ ] Docs (documentation only)
- [ ] Chore (build, CI, dependencies)

## Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing done
- [ ] No regression in related features

## Checklist
- [ ] Code follows project standards (CLAUDE.md)
- [ ] Self-reviewed my own code
- [ ] Docs updated if needed
- [ ] No secrets or credentials in code
- [ ] Database migration included (if schema changed)
PREOF

echo "✅ PR template created: .github/pull_request_template.md"
```

### Issue Templates

```bash
mkdir -p "$PROJECT_DIR/.github/ISSUE_TEMPLATE"

# Bug Report
cat > "$PROJECT_DIR/.github/ISSUE_TEMPLATE/bug_report.md" << 'BUGEOF'
---
name: Bug Report
about: Report a bug to help us improve
title: "[BUG] "
labels: bug
---

## Describe the Bug
<!-- Clear description of what the bug is -->

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
<!-- What should happen -->

## Actual Behavior
<!-- What actually happens -->

## Screenshots
<!-- If applicable -->

## Environment
- OS:
- Browser:
- Version:
BUGEOF

# Feature Request
cat > "$PROJECT_DIR/.github/ISSUE_TEMPLATE/feature_request.md" << 'FEATEOF'
---
name: Feature Request
about: Suggest a new feature
title: "[FEATURE] "
labels: enhancement
---

## Summary
<!-- Brief description of the feature -->

## Problem
<!-- What problem does this solve? -->

## Proposed Solution
<!-- How should it work? -->

## Acceptance Criteria
- [ ]
- [ ]

## Priority
<!-- Critical / High / Medium / Low -->
FEATEOF

echo "✅ Issue templates created: bug_report.md, feature_request.md"
```

---

## PROC-GH-15 — Semantic Versioning

**Used by:** PROC-GH-09 (release), PROC-GH-12 (hotfix)

### Version Format: `vMAJOR.MINOR.PATCH`

```bash
cd "$PROJECT_DIR"

# Get latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
MAJOR=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f3)

echo "Current version: $LATEST_TAG"
```

### Determine bump type

```
VERSION BUMP RULES
━━━━━━━━━━━━━━━━━━
PATCH (v1.0.0 → v1.0.1):
  - Bug fixes
  - Hotfixes
  - Typo/doc fixes
  - No API or behavior changes

MINOR (v1.0.0 → v1.1.0):
  - New features (backward compatible)
  - New API endpoints
  - New UI screens/components
  - Non-breaking database additions

MAJOR (v1.0.0 → v2.0.0):
  - Breaking API changes
  - Database schema breaking changes
  - Removed features
  - Major architecture changes
  - Incompatible with previous version
```

### Auto-increment

```bash
# Usage: bump_version [patch|minor|major]
bump_version() {
  case "$1" in
    patch) PATCH=$((PATCH + 1)) ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  esac
  echo "v${MAJOR}.${MINOR}.${PATCH}"
}

# Determine type from context:
# - Called from PROC-GH-12 (hotfix) → patch
# - Called from PROC-GH-09 (release with new features) → minor
# - Called from PROC-GH-09 (breaking changes) → major
# - If unsure → ask user

NEXT_VERSION=$(bump_version "$RELEASE_TYPE")
echo "Next version: $NEXT_VERSION"

# Apply tag
git tag "$NEXT_VERSION"
git push origin --tags
echo "✅ Tagged: $NEXT_VERSION"
```

### Decision flow for agents:

```
Is this a hotfix? (from PROC-GH-12)
  └── YES → PATCH bump

Is this a release? (from PROC-GH-09)
  ├── Any breaking changes in this release?
  │   └── YES → MAJOR bump
  ├── Any new features?
  │   └── YES → MINOR bump
  └── Only fixes/refactors?
      └── PATCH bump

If unsure → ask user:
  "This release includes [summary]. Should this be a patch, minor, or major version bump?"
```
