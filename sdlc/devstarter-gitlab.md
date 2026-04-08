# devstarter-gitlab.md — Shared GitLab Procedures

**Common VCS conventions (branch naming, labels, semver rules, conflict protocol):**
Read `~/.claude/sdlc/devstarter-vcs-common.md` — do not duplicate those definitions here.

## Purpose

This file contains GitLab-specific procedures (`glab` CLI) used by all DevStarter workflows
when `VCS_TYPE=gitlab` or `VCS_SECONDARY_1/2=gitlab` is set in `.project.env`.

GitLab equivalent of `devstarter-github.md` — same structure, GitLab API + `glab` CLI.

---

## Prerequisites Check

Before any GitLab operation, verify:

```bash
# 1. Load project config
source .project.env 2>/dev/null || true
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs) 2>/dev/null || true

# 2. Verify glab CLI is installed and authenticated
if ! command -v glab &>/dev/null; then
  echo "ERROR: glab CLI not installed"
  echo "Install: https://gitlab.com/gitlab-org/cli/-/releases"
  exit 1
fi

glab auth status

# 3. Verify required vars
echo "GITLAB_USERNAME: ${GITLAB_USERNAME:-NOT SET}"
echo "GITLAB_URL:      ${GITLAB_URL:-https://gitlab.com}"
echo "GITLAB_PROJECT:  ${GITLAB_PROJECT:-NOT SET}"  # e.g. mygroup/myrepo
```

Required `.env` fields:
```bash
GITLAB_USERNAME=yourname
GITLAB_URL=https://gitlab.com         # or self-hosted: https://gitlab.company.com
GITLAB_PROJECT=mygroup/myrepo         # namespace/repo slug
GITLAB_TOKEN=glpat-xxxxxxxxxxxx       # Personal Access Token (api + write_repository)
```

If any check fails → STOP and tell user to run `glab auth login` or update `.env`.

---

## PROC-GL-01 — Create New Repository

**Used by:** devstarter-starter.md (new project)

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

# Create GitLab repo (private by default)
if ! glab repo view "$GITLAB_PROJECT" &>/dev/null; then
  glab repo create "$PROJECT_NAME" --private
  git remote add origin "${GITLAB_URL}/${GITLAB_PROJECT}.git"
  git push -u origin main 2>/dev/null || git push -u origin master
  echo "✅ GitLab repo created: ${GITLAB_URL}/${GITLAB_PROJECT}"
else
  echo "⚠️  Repo already exists — adding remote"
  git remote add origin "${GITLAB_URL}/${GITLAB_PROJECT}.git" 2>/dev/null || true
fi

# Create branch strategy: main + uat + develop
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

## PROC-GL-02 — Connect Existing Repository

**Used by:** devstarter-existing.md, devstarter-migrate.md

```bash
cd "$PROJECT_DIR"

if git remote get-url origin &>/dev/null; then
  EXISTING_REMOTE=$(git remote get-url origin)
  echo "✅ Remote already set: $EXISTING_REMOTE"
else
  echo "Enter GitLab repo URL or path (e.g. mygroup/myrepo or full URL):"
  read -r REPO_INPUT

  if [[ "$REPO_INPUT" == http* ]]; then
    git remote add origin "$REPO_INPUT"
  else
    git remote add origin "${GITLAB_URL}/${REPO_INPUT}.git"
  fi
  git fetch origin
  echo "✅ Remote connected"
fi
```

---

## PROC-GL-03 — Create Branch Strategy for Migration

**Used by:** devstarter-migrate.md

```bash
cd "$PROJECT_DIR"

MIGRATION_BRANCH="migration/$PROJECT_NAME-$(date +%Y%m%d)"
git checkout -b "$MIGRATION_BRANCH" 2>/dev/null || git checkout "$MIGRATION_BRANCH"
git push -u origin "$MIGRATION_BRANCH" 2>/dev/null || true

echo "✅ Migration branch: $MIGRATION_BRANCH"
echo "⚠️  main and develop branches are PROTECTED — do not modify until Gate 7"
```

---

## PROC-GL-04 — Setup Labels

**Used by:** all workflows after task breakdown is approved

GitLab labels are scoped to the project. Using GitLab REST API:

```bash
GITLAB_API="${GITLAB_URL}/api/v4"
GL_HEADERS=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json")
PROJECT_ID=$(curl -s "${GITLAB_API}/projects/$(python3 -c "import urllib.parse; print(urllib.parse.quote('${GITLAB_PROJECT}', safe=''))")" \
  "${GL_HEADERS[@]}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

create_label() {
  local NAME=$1 COLOR=$2 DESC=$3
  curl -s -X POST "${GITLAB_API}/projects/${PROJECT_ID}/labels" \
    "${GL_HEADERS[@]}" \
    -d "{\"name\": \"$NAME\", \"color\": \"$COLOR\", \"description\": \"$DESC\"}" \
    -o /dev/null
  echo "  ✅ $NAME"
}

echo "Creating GitLab labels..."

# Gate labels
create_label "gate::1-discovery"  "#0075ca" "Gate 1: Discovery"
create_label "gate::2-design"     "#e4e669" "Gate 2: Design"
create_label "gate::3-foundation" "#d93f0b" "Gate 3: Foundation"
create_label "gate::4-feature"    "#0e8a16" "Gate 4: Feature"
create_label "gate::5-delivery"   "#5319e7" "Gate 5: Delivery"

# Role labels
create_label "role::frontend"  "#1d76db" "@devstarter-frontend"
create_label "role::backend"   "#e4e669" "@devstarter-backend"
create_label "role::dba"       "#0e8a16" "@devstarter-dba"
create_label "role::qa"        "#d93f0b" "@devstarter-qa"
create_label "role::devops"    "#5319e7" "@devstarter-devops"
create_label "role::security"  "#b60205" "@devstarter-security"
create_label "role::uxui"      "#f9d0c4" "@devstarter-uxui"

# Status labels
create_label "status::blocked"     "#b60205" "Blocked"
create_label "status::in-progress" "#e4e669" "In Progress"
create_label "status::in-review"   "#0075ca" "In Review"

# Priority labels
create_label "priority::critical" "#b60205" "Critical priority"
create_label "priority::high"     "#d93f0b" "High priority"
create_label "priority::medium"   "#e4e669" "Medium priority"
create_label "priority::low"      "#0e8a16" "Low priority"

echo "✅ Labels created"
```

---

## PROC-GL-05 — Create GitLab Issue (per task)

**Used by:** all workflows when creating tasks

```bash
# Variables required: TASK_TITLE, TASK_BODY, TASK_LABELS (comma-separated)

ISSUE_RESPONSE=$(glab issue create \
  --title "$TASK_TITLE" \
  --description "$TASK_BODY" \
  --label "$TASK_LABELS")

ISSUE_NUMBER=$(echo "$ISSUE_RESPONSE" | grep -o '#[0-9]*' | head -1 | tr -d '#')
echo "✅ Issue #$ISSUE_NUMBER created"
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
- Notion/Jira: [task URL — filled after PM task created]

## Dependencies
[list or "none"]
```

---

## PROC-GL-06 — Start Task (create feature branch)

**Used by:** Gate 4 of all workflows

```bash
# Variables required: ISSUE_NUMBER, TASK_SLUG (kebab-case task name)

BRANCH_NAME="feature/$ISSUE_NUMBER-$TASK_SLUG"
git checkout develop
git pull origin develop
git checkout -b "$BRANCH_NAME"

echo "✅ Branch created: $BRANCH_NAME"
echo "📋 Working on issue #$ISSUE_NUMBER"

# Update issue label
glab issue update "$ISSUE_NUMBER" --label "status::in-progress" 2>/dev/null || true
```

---

## PROC-GL-07 — Create Merge Request

**Used by:** Gate 4 after task is complete
(GitLab equivalent of GitHub Pull Request)

```bash
# Variables required: ISSUE_NUMBER, BRANCH_NAME, TASK_TITLE

git push origin "$BRANCH_NAME"

MR_URL=$(glab mr create \
  --title "$TASK_TITLE" \
  --description "Closes #$ISSUE_NUMBER

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
  --source-branch "$BRANCH_NAME" \
  --target-branch develop \
  --label "status::in-review" \
  --remove-source-branch)

echo "✅ MR created: $MR_URL"
glab issue update "$ISSUE_NUMBER" --label "status::in-review" 2>/dev/null || true
```

---

## PROC-GL-08 — Merge MR and Close Issue

**Used by:** Gate 5 after user approves MR

```bash
# Variables required: MR_IID (MR number), ISSUE_NUMBER

glab mr merge "$MR_IID" --squash --delete-source-branch --yes
glab issue close "$ISSUE_NUMBER" --note "✅ Implemented and merged to develop."

echo "✅ MR merged, issue #$ISSUE_NUMBER closed"
```

---

## PROC-GL-09 — Release Merge Flow (develop → uat → main)

**Used by:** devstarter-release.md

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

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
# Determine RELEASE_TYPE (patch/minor/major) using PROC-GL-15 logic
NEXT_VERSION=$(PROC-GL-15-bump-version "$RELEASE_TYPE")

git merge uat --no-ff -m "release: $PROJECT_NAME $NEXT_VERSION"
git tag "$NEXT_VERSION"
git push origin main --tags

echo "✅ Merged to main — tagged $NEXT_VERSION"
echo "🚀 Ready for production deployment"
```

---

## PROC-GL-10 — Branch Protection Rules

**Used by:** devstarter-starter.md Gate 0 (after repo creation)

```bash
GITLAB_API="${GITLAB_URL}/api/v4"
GL_HEADERS=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json")

protect_branch() {
  local BRANCH=$1
  curl -s -X POST "${GITLAB_API}/projects/${PROJECT_ID}/protected_branches" \
    "${GL_HEADERS[@]}" \
    -d "{
      \"name\": \"$BRANCH\",
      \"push_access_level\": 40,
      \"merge_access_level\": 40,
      \"allow_force_push\": false,
      \"code_owner_approval_required\": false
    }" -o /dev/null
  echo "✅ Protected: $BRANCH (maintainer+ can push/merge, no force push)"
}

protect_branch "main"
protect_branch "uat"

echo "✅ Branch protection rules set"
echo "   main — protected, merge via MR only"
echo "   uat  — protected, merge via MR only"
echo "   develop — NOT protected (agents push directly during Gate 3)"
```

Access levels: `0`=No access, `30`=Developer, `40`=Maintainer, `60`=Admin

---

## PROC-GL-11 — Create Milestones (per Epic)

**Used by:** devstarter-starter.md Gate 3 (after task breakdown approved)

```bash
GITLAB_API="${GITLAB_URL}/api/v4"
GL_HEADERS=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json")

# Variables required: EPIC_TITLE, EPIC_DESCRIPTION, EPIC_DUE_DATE (YYYY-MM-DD, optional)

MILESTONE_RESPONSE=$(curl -s -X POST "${GITLAB_API}/projects/${PROJECT_ID}/milestones" \
  "${GL_HEADERS[@]}" \
  -d "{
    \"title\": \"$EPIC_TITLE\",
    \"description\": \"$EPIC_DESCRIPTION\"
    $([ -n \"$EPIC_DUE_DATE\" ] && echo ", \"due_date\": \"$EPIC_DUE_DATE\"")
  }")

MILESTONE_ID=$(echo "$MILESTONE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "✅ Milestone created: $EPIC_TITLE (ID: $MILESTONE_ID)"

# When creating issues, add milestone:
# glab issue create --title "$TASK_TITLE" --milestone "$EPIC_TITLE"
```

**Example milestones for a typical project:**
```
Milestone 1: "Auth & User Management"    — issues #1-#5
Milestone 2: "Core Features"             — issues #6-#12
Milestone 3: "Reports & Export"          — issues #13-#16
Milestone 4: "Quality & Polish"          — issues #17-#20
```

---

## PROC-GL-12 — Hotfix Flow

**Used by:** devstarter-hotfix.md (critical production bug)

### Step 1 — Create hotfix branch from main

```bash
cd "$PROJECT_DIR"

git checkout main
git pull origin main

HOTFIX_BRANCH="hotfix/$ISSUE_NUMBER-$HOTFIX_SLUG"
git checkout -b "$HOTFIX_BRANCH"

echo "✅ Hotfix branch: $HOTFIX_BRANCH (from main)"
echo "⚠️  Fix the bug, then run PROC-GL-12 Step 2"
```

### Step 2 — MR to main + backport to develop

```bash
cd "$PROJECT_DIR"

git push -u origin "$HOTFIX_BRANCH"

MR_URL=$(glab mr create \
  --title "hotfix: $HOTFIX_TITLE" \
  --description "Closes #$ISSUE_NUMBER

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
  --source-branch "$HOTFIX_BRANCH" \
  --target-branch main \
  --label "priority::critical,status::in-review" \
  --remove-source-branch)

echo "✅ Hotfix MR created: $MR_URL"
echo "⛔ Wait for approval before merging"
```

### Step 3 — After MR approved: merge to main + backport to uat + develop

```bash
cd "$PROJECT_DIR"

glab mr merge "$MR_IID" --squash --delete-source-branch --yes

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

glab issue close "$ISSUE_NUMBER" --note "✅ Hotfix $PATCH_VERSION deployed and backported to uat + develop."
```

---

## PROC-GL-13 — Merge Conflict Resolution

**Used by:** Any workflow when `git merge` or MR merge fails with conflicts

### Step 1 — Detect conflict

```bash
git checkout "$FEATURE_BRANCH"
git merge develop
# If conflict: "CONFLICT (content): Merge conflict in [filename]"
```

### Step 2 — Resolve conflicts

See `devstarter-vcs-common.md § Conflict Resolution Protocol` for the resolution strategy and rules.

### Step 3 — Complete merge

```bash
git add .
git commit -m "chore: resolve merge conflict with develop

Conflicts resolved:
- [file1]: [what was kept/merged]
- [file2]: [what was kept/merged]"

git push origin "$FEATURE_BRANCH"
echo "✅ Conflict resolved and pushed"
```

---

## PROC-GL-14 — MR and Issue Templates

**Used by:** devstarter-starter.md Gate 0 (after repo creation)

Create `.gitlab/` directory with templates:

### Merge Request Template

```bash
mkdir -p "$PROJECT_DIR/.gitlab/merge_request_templates"

cat > "$PROJECT_DIR/.gitlab/merge_request_templates/default.md" << 'MREOF'
## Summary
<!-- Brief description of what this MR does -->

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
MREOF

echo "✅ MR template created: .gitlab/merge_request_templates/default.md"
```

### Issue Templates

```bash
mkdir -p "$PROJECT_DIR/.gitlab/issue_templates"

# Bug Report
cat > "$PROJECT_DIR/.gitlab/issue_templates/bug_report.md" << 'BUGEOF'
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
cat > "$PROJECT_DIR/.gitlab/issue_templates/feature_request.md" << 'FEATEOF'
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

## PROC-GL-15 — Semantic Versioning

**Used by:** PROC-GL-09 (release), PROC-GL-12 (hotfix)

Same rules as PROC-GH-15. Version format: `vMAJOR.MINOR.PATCH`

```bash
cd "$PROJECT_DIR"

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
MAJOR=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | sed 's/v//' | cut -d. -f3)

echo "Current version: $LATEST_TAG"

bump_version() {
  case "$1" in
    patch) PATCH=$((PATCH + 1)) ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  esac
  echo "v${MAJOR}.${MINOR}.${PATCH}"
}

# Decision flow:
# - Called from PROC-GL-12 (hotfix) → patch
# - Called from PROC-GL-09 (release with new features) → minor
# - Called from PROC-GL-09 (breaking changes) → major
# - If unsure → ask user

NEXT_VERSION=$(bump_version "$RELEASE_TYPE")
echo "Next version: $NEXT_VERSION"

git tag "$NEXT_VERSION"
git push origin --tags
echo "✅ Tagged: $NEXT_VERSION"
```

---

## PROC-GL-16 — Setup GitLab CI/CD Pipeline

**Used by:** devstarter-starter.md Gate 0, devstarter-devops.md

Create `.gitlab-ci.yml` for automated testing on every push:

```bash
cat > "$PROJECT_DIR/.gitlab-ci.yml" << 'CIEOF'
stages:
  - test
  - build
  - deploy

variables:
  NODE_ENV: test

# ── Test Stage ──────────────────────────────────────────────────────────────
test:unit:
  stage: test
  image: node:20-alpine
  cache:
    paths:
      - node_modules/
  script:
    - npm ci
    - npm test
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "develop"'

test:lint:
  stage: test
  image: node:20-alpine
  script:
    - npm ci
    - npm run lint
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

# ── Build Stage ──────────────────────────────────────────────────────────────
build:
  stage: build
  image: node:20-alpine
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_BRANCH == "uat"'

# ── Deploy Stage ─────────────────────────────────────────────────────────────
deploy:uat:
  stage: deploy
  script:
    - echo "Deploy to UAT environment"
    # Add your deploy commands here
  environment:
    name: uat
    url: https://uat.yourapp.com
  rules:
    - if: '$CI_COMMIT_BRANCH == "uat"'

deploy:production:
  stage: deploy
  script:
    - echo "Deploy to Production"
    # Add your deploy commands here
  environment:
    name: production
    url: https://yourapp.com
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
  when: manual   # Require manual trigger for production deploys
CIEOF

echo "✅ .gitlab-ci.yml created"
echo "   Stages: test → build → deploy"
echo "   Production deploy: manual trigger required"
```

---

## PROC-GL-17 — Setup Autonomous MR Review (Claude AI)

**When:** Setting up CI/CD for a project using GitLab.
**Who:** @devstarter-devops

GitLab equivalent of PROC-GH-16. Uses GitLab CI + Anthropic API to review every MR.

```bash
# Step 1: Add CI job to .gitlab-ci.yml
cat >> "$PROJECT_DIR/.gitlab-ci.yml" << 'REVIEWEOF'

# ── AI MR Review ─────────────────────────────────────────────────────────────
review:ai:
  stage: test
  image: node:20-alpine
  script:
    - apk add --no-cache curl jq
    - |
      MR_DIFF=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/changes" \
        | jq -r '.changes[].diff' | head -c 8000)

      REVIEW=$(curl -s https://api.anthropic.com/v1/messages \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "{
          \"model\": \"claude-haiku-4-5-20251001\",
          \"max_tokens\": 1024,
          \"messages\": [{
            \"role\": \"user\",
            \"content\": \"Review this MR diff for bugs, security issues, and code quality. Be concise.\n\n$MR_DIFF\"
          }]
        }" | jq -r '.content[0].text')

      curl -s -X POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/notes" \
        --data-urlencode "body=## 🤖 Claude AI Review

$REVIEW

---
*Reviewed by claude-haiku — ~\$0.003/review*"

  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
REVIEWEOF

# Step 2: Add ANTHROPIC_API_KEY to GitLab CI/CD variables
# Settings → CI/CD → Variables → Add variable
# Key: ANTHROPIC_API_KEY
# Value: sk-ant-...
# Protected: yes, Masked: yes

echo "✅ AI MR review job added to .gitlab-ci.yml"
echo "⚠️  Add ANTHROPIC_API_KEY in: Settings → CI/CD → Variables"
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `glab: command not found` | Install: `brew install glab` or download from gitlab.com/gitlab-org/cli |
| `401 Unauthorized` | Token expired or missing `api` scope — regenerate at GitLab → Settings → Access Tokens |
| `403 Forbidden` on branch protection | Need Maintainer role on the project |
| MR merge blocked | Check required approvals or failing CI jobs |
| `git push` rejected | Branch is protected — use MR flow (PROC-GL-07) |
| CI pipeline not triggering | Check `.gitlab-ci.yml` `rules:` conditions |
| Self-hosted GitLab | Set `GITLAB_URL=https://gitlab.company.com` and ensure token works against that host |

---

## GitLab vs GitHub Quick Reference

| Concept | GitHub | GitLab |
|---------|--------|--------|
| PR | Pull Request | Merge Request (MR) |
| CLI tool | `gh` | `glab` |
| CI config | `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| Templates dir | `.github/` | `.gitlab/` |
| Branch protection API | `/branches/{branch}/protection` | `/protected_branches` |
| Issue close keyword | `Closes #N` | `Closes #N` (same) |
| Token type | `ghp_` / `github_pat_` | `glpat-` |
| Token scope needed | `repo` | `api` + `write_repository` |
