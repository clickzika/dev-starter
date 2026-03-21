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

# Create branch strategy
git checkout -b develop 2>/dev/null || git checkout develop
git push -u origin develop 2>/dev/null || true

echo "✅ Branch strategy: main (production) + develop (staging)"
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

## PROC-GH-09 — Final Merge to Main (production)

**Used by:** Gate 5 final delivery

```bash
git checkout main
git pull origin main
git merge develop --no-ff -m "release: $PROJECT_NAME v1.0.0"
git tag "v1.0.0"
git push origin main --tags

echo "✅ Merged to main — tagged v1.0.0"
echo "🚀 Ready for production deployment"
```
