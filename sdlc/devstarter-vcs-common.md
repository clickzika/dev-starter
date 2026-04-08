# devstarter-vcs-common.md — Shared VCS Conventions

Shared reference for all VCS workflows. Read this file for conventions that apply
regardless of which VCS tool is in use (GitHub, GitLab, SVN).

Referenced by: `devstarter-github.md` · `devstarter-gitlab.md` · `devstarter-svn.md`

---

## Branch Naming Conventions

```
feature/[description]     — new feature work
fix/[description]         — non-critical bug fix
hotfix/[description]      — critical production fix (branches from main)
release/[version]         — release preparation
migration/[name]-[date]   — tech stack migration
```

**Branch strategy: develop → uat → main**

| Branch | Purpose |
|--------|---------|
| `develop` | Claude develops + local test |
| `uat` | User acceptance testing |
| `main` | Production — protected |

---

## Commit Message Format (Conventional Commits)

```
feat:     New feature
fix:      Bug fix
hotfix:   Critical production fix
chore:    Build, deps, config — no behavior change
docs:     Documentation only
refactor: Code restructure — no behavior change
test:     Tests only
ci:       CI/CD pipeline changes
release:  Version bump + changelog
```

Example:
```
feat: add bulk import for orders
fix: correct redirect after login
chore: update dependencies to latest
```

---

## Standard .gitignore Template

```gitignore
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
```

---

## Standard Label Definitions

Used by all workflows for issue and PR labeling.

### Gate Labels
| Label | Color | Purpose |
|-------|-------|---------|
| `gate:1-discovery` | `#0075ca` | Gate 1: Discovery |
| `gate:2-design` | `#e4e669` | Gate 2: Design |
| `gate:3-foundation` | `#d93f0b` | Gate 3: Foundation |
| `gate:4-feature` | `#0e8a16` | Gate 4: Feature |
| `gate:5-delivery` | `#5319e7` | Gate 5: Delivery |

### Role Labels
| Label | Color | Purpose |
|-------|-------|---------|
| `role:frontend` | `#1d76db` | @devstarter-frontend |
| `role:backend` | `#e4e669` | @devstarter-backend |
| `role:dba` | `#0e8a16` | @devstarter-dba |
| `role:qa` | `#d93f0b` | @devstarter-qa |
| `role:devops` | `#5319e7` | @devstarter-devops |
| `role:security` | `#b60205` | @devstarter-security |
| `role:uxui` | `#f9d0c4` | @devstarter-uxui |

### Status / Priority Labels
| Label | Color |
|-------|-------|
| `status:blocked` | `#b60205` |
| `status:in-progress` | `#e4e669` |
| `status:in-review` | `#0075ca` |
| `priority:critical` | `#b60205` |
| `priority:high` | `#d93f0b` |
| `priority:medium` | `#e4e669` |
| `priority:low` | `#0e8a16` |

---

## Semantic Versioning Rules

Format: `vMAJOR.MINOR.PATCH`

```
VERSION BUMP RULES
━━━━━━━━━━━━━━━━━━
PATCH (v1.0.0 → v1.0.1):
  - Bug fixes, hotfixes, typo/doc fixes
  - No API or behavior changes

MINOR (v1.0.0 → v1.1.0):
  - New features (backward compatible)
  - New API endpoints, UI screens, non-breaking DB additions

MAJOR (v1.0.0 → v2.0.0):
  - Breaking API changes, DB schema breaking changes
  - Removed features, major architecture changes
```

**Decision flow:**
```
Hotfix?       → PATCH
Breaking changes in release? → MAJOR
New features in release?     → MINOR
Only fixes/refactors?        → PATCH
Unsure? → ask user: "patch, minor, or major?"
```

---

## Conflict Resolution Protocol

When `git merge` fails with conflicts:

```
⚠️ MERGE CONFLICT DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch: [feature branch]
Merging from: develop
Conflicting files: [list]

Resolution strategy:
  1. Read both versions of each conflicting file
  2. Understand the intent of BOTH changes
  3. Merge manually — preserve both intentions where possible
  4. If unclear → ask user which version to keep
  5. NEVER blindly pick "ours" or "theirs"
```

**Rules:**
- NEVER use `git checkout --ours .` or `--theirs .` without reading both sides
- ALWAYS understand what each side intended
- ASK the user if intent is ambiguous
- TEST after resolving — conflicts can introduce subtle bugs

---

## Branch Protection Defaults

| Branch | Protection |
|--------|-----------|
| `main` | Require 1 PR review + dismiss stale reviews |
| `uat` | Same as main — only merge from develop via release flow |
| `develop` | Not protected (agents push directly during Gate 3 scaffold) |
