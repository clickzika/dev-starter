# CLAUDE.md — Project Context

This file is auto-generated during project setup. It is loaded automatically by Claude Code on every session.

---

## Project

Name: DevStarter
Description: A workflow orchestration framework for Claude Code that provides 13 specialized AI agents, 28 SDLC workflow runbooks, and 23 slash commands — enabling AI-assisted development from project inception through production deployment.
Repository: https://github.com/clickzika/DevStarter.git
Status: Active development
Version: 1.4.0
Created: 2026-04-05

---

## What This Project Is

DevStarter is **not a typical application**. It is a meta-framework installed at `~/.claude/` that:

- Provides 13 specialized AI agents with domain-specific behavior rules, output templates, and quality gates
- Orchestrates 28 SDLC workflows from project discovery through production release
- Integrates with 5 VCS systems, 7 PM tools, 4 secrets backends, and multi-provider AI
- Enforces hard approval gates at every stage
- Protects against rate limits via checkpoint-based auto-resume (memory/progress.json)
- Generates production-ready projects with architecture, schema, API specs, UI prototypes, and deployment pipelines

---

## Session Start — Every Agent Reads These Files First

Before responding to ANYTHING, read in this exact order:

1. `CLAUDE.md` — project context (this file)
2. `~/.claude/USER.md` — who the user is, skill level, communication preferences
3. `memory/progress.json` — **current gate/task progress** (if exists)

Then:

- Calibrate output depth to USER.md skill level
- Check for in-progress work before starting new tasks
- **If `memory/progress.json` exists with `status: "in_progress"`, show resume prompt immediately**

---

## Session Resume Protocol

### On EVERY session start, check for `memory/progress.json`:

If found with `status: "in_progress"`, show:

```
🔄 PREVIOUS SESSION DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Workflow: [workflow name]
Gate:     [current gate]
Task:     [current task name]
Last step: [what was last completed]
Next step: [what should happen next]

Continue from here? (yes / restart / show details)
```

### Rate Limit Protection — Save Early, Save Often

- `git add` + `git commit` after every meaningful change (every 1-2 files)
- Save `memory/progress.json` after EVERY completed action
- Write documents section by section — never all at once at the end
- Order: Write file → git commit → update progress.json

---

## Project Structure

```
DevStarter/
├── agents/         13 specialized AI agent definitions
│   ├── shared/     Shared base protocol + VCS/PM guide
│   └── teams/      Team-level agents
├── commands/       24 slash command definitions
├── sdlc/           28 SDLC workflow runbooks
├── templates/      CLAUDE.md template, HTML doc templates,
│                   GitHub Actions, secrets backends, LiteLLM, ML stacks
├── scripts/        dev-setup.sh, publish.sh
├── memory/         progress.json (checkpoint state)
├── install.sh      One-command installer
├── setup.sh        First-time config wizard
├── update.sh       Auto-updater
├── VERSION         Current: 1.4.0
└── CHANGELOG.md    Version history
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Primary language | Markdown (runbooks, agents, workflows) |
| Scripting | Bash (install, setup, update, CI hooks) |
| Templates | HTML with embedded CSS (dark theme) |
| Config formats | YAML, HCL (Vault), JSON |
| AI backend | Anthropic Claude (primary) + LiteLLM multi-provider |
| Version control | Git + GitHub (primary) |
| Package manager | None (no Node.js app) |

**Supported project stacks (generated projects):**
- Frontend: React, Vue, Svelte, Angular
- Backend: Node.js/Express, Python, C#/.NET, Go, Java
- Database: PostgreSQL, MySQL, MongoDB
- Mobile: Flutter, React Native, Swift, Kotlin
- ML: scikit-learn, PyTorch, TensorFlow + MLflow, DVC, BentoML

---

## 13 Agents

| Agent | File | Role |
|-------|------|------|
| @devstarter-ba | `agents/devstarter-ba.md` | Business Analyst — requirements, BRD, SRS |
| @devstarter-techlead | `agents/devstarter-techlead.md` | Tech Lead — architecture, ADRs, code review |
| @devstarter-dba | `agents/devstarter-dba.md` | DBA — schema, migrations, query optimization |
| @devstarter-backend | `agents/devstarter-backend.md` | Backend Dev — REST/GraphQL/gRPC, APIs |
| @devstarter-frontend | `agents/devstarter-frontend.md` | Frontend Dev — React/Vue/Svelte/Angular |
| @devstarter-devops | `agents/devstarter-devops.md` | DevOps — CI/CD, Docker, IaC, monitoring |
| @devstarter-qa | `agents/devstarter-qa.md` | QA — unit/integration/E2E/load/security |
| @devstarter-security | `agents/devstarter-security.md` | Security — OWASP, auth, secrets |
| @devstarter-uxui | `agents/devstarter-uxui.md` | UX/UI — components, prototypes, design tokens |
| @devstarter-pm | `agents/devstarter-pm.md` | PM — sprint planning, Notion/Jira/GitHub Issues |
| @devstarter-docs | `agents/devstarter-docs.md` | Technical Writer — HTML docs, API reference |
| @devstarter-mobile | `agents/devstarter-mobile.md` | Mobile Dev — Flutter/React Native/Swift/Kotlin |
| @devstarter-mlops | `agents/devstarter-mlops.md` | MLOps — scikit-learn/PyTorch/MLflow/BentoML |

**Shared protocols:** `agents/shared/devstarter-agent-base.md` + `agents/shared/devstarter-vcs-pm-guide.md`

---

## 24 Slash Commands

| Command | Purpose |
|---------|---------|
| `/devstarter-new` | Start a new project (5-gate lifecycle) |
| `/devstarter-existing` | Setup/onboard existing project |
| `/devstarter-change` | Add feature / fix bug / remove feature |
| `/devstarter-document` | Generate or regenerate a specific doc (brd, api, schema, test, security, infra, prototype, all) |
| `/devstarter-release` | Release + deploy (DEV→SIT→UAT→Production) |
| `/devstarter-hotfix` | Critical production bug fix |
| `/devstarter-rollback` | Production rollback |
| `/devstarter-incident` | Incident response |
| `/devstarter-sprint` | Sprint planning |
| `/devstarter-audit` | Full project audit & review |
| `/devstarter-migrate` | Tech stack migration |
| `/devstarter-dependency` | Update dependencies |
| `/devstarter-onboard` | Onboard new team member |
| `/devstarter-handover` | Project handover |
| `/devstarter-retro` | Sprint retrospective |
| `/devstarter-env` | Setup local environment |
| `/devstarter-secrets` | Secrets management |
| `/devstarter-monitor` | Monitoring setup |
| `/devstarter-context` | Refresh CLAUDE.md |
| `/devstarter-consult` | Get solution advice |
| `/devstarter-export` | Export/backup to zip |
| `/devstarter-import` | Import from backup |
| `/devstarter-update` | Update DevStarter to latest version |
| `/devstarter-menu` | Show interactive launcher menu |

---

## 28 SDLC Workflows (`sdlc/`)

| Domain | Workflows |
|--------|-----------|
| Project Setup | devstarter-starter, devstarter-existing, devstarter-migrate, devstarter-audit |
| Change Management | devstarter-change (router), change-add, change-remove, change-bug, change-resume |
| Release | devstarter-release, release-prep, release-verify, release-deploy, hotfix, rollback, incident |
| Daily Ops | devstarter-sprint, devstarter-retrospective, devstarter-dependency, devstarter-onboarding, devstarter-handover, devstarter-document |
| Infrastructure | devstarter-env, devstarter-secrets, devstarter-monitor |
| VCS | devstarter-github (17 procs), devstarter-gitlab (17), devstarter-svn (13), devstarter-vcs-sync |
| PM Tools | devstarter-notion (8 procs), devstarter-jira (9 procs) |
| Specialized | devstarter-ml-workflow, devstarter-ai-providers, devstarter-autopr, devstarter-consult, devstarter-checkpoint |

---

## Integrations

| Category | Options |
|----------|---------|
| VCS | GitHub, GitLab, Bitbucket, SVN, Azure DevOps |
| PM Tools | Notion, Jira, GitHub Issues, GitLab Issues, Azure Boards, Linear, Trello |
| CI/CD | GitHub Actions, GitLab CI, Jenkins, Azure Pipelines |
| Secrets | env-file, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager, HashiCorp Vault |
| AI | Claude (primary) + LiteLLM (GPT-4, Gemini, local Ollama) |

---

## Key Mechanics

### 5-Gate Process (new projects via `/devstarter-new`)
```
GATE 0 — Project Setup    → auto (GitHub repo + PM board)
GATE 1 — Discovery        → STOP → wait: "Approved" (BRD + SRS)
GATE 2 — Architecture     → STOP → wait: "Approved" (all 9 docs)
GATE 3 — Task Breakdown   → STOP → wait: "Task list approved"
GATE 4 — Per-Task Dev     → STOP → wait: "go" per task + PR review
GATE 5 — Quality          → STOP → wait: "Approved" → merge + tag
```

### Checkpoint System
- `memory/progress.json` tracks gate, task, status
- 10-minute cron auto-resume protects against rate limit interruptions
- See: `sdlc/devstarter-checkpoint.md`

### Release Strategy (v1.4.0)
Auto-detect at runtime:
- **Model A (dual-remote):** `release` remote exists → push main + tag to release remote
- **Model B (single-repo):** no release remote → push main + tag to `origin`

### Document Standards
- All docs as styled HTML (dark theme `#0f0f23`) — never markdown
- Base template: `templates/docs/document-template.html`
- All docs portal: `docs/index.html` (copy from `templates/docs/index.html`)
- Prototype components: `docs/prototype/components.html` (8 mandatory sections)

### Skill Calibration
- Reads `~/.claude/USER.md` to detect skill level (Beginner / Intermediate / Advanced / Expert)
- Output depth adjusts accordingly

---

## Branch Naming

```
feature/[issue-#]-[kebab-description]
fix/[issue-#]-[kebab-description]
hotfix/[issue-#]-[kebab-description]
release/v[semver]
```

Current branch: `develop`
Main branch: `main`

---

## Conventional Commits

```
feat:     new feature
fix:      bug fix
chore:    maintenance (update, deps, config)
docs:     documentation only
refactor: code change without new feature/fix
test:     test changes
release:  version bump + CHANGELOG
```

---

## Code Conventions (Bash scripts)

- Idempotent — safe to run multiple times
- Print status with colors: `\033[0;32m` (green), `\033[1;33m` (yellow), `\033[0;31m` (red)
- Backup before overwrite
- Exit on error with meaningful message

---

## Approval Keywords

| You say | What happens |
|---------|-------------|
| `yes` / `approve` | Confirm current gate output |
| `revise [notes]` | Correct and regenerate |
| `continue` / `resume` | Check progress.json → resume |
| `go` | Agent starts working on next task |
| `next task` | Move to next task in plan |
| `pause` | Stop after current task |
| `stop` | Stop immediately |

---

## Autonomy Level

HIGH AUTONOMY — auto-approve all file edits, git commits, script reads.
STOP only for: push to main, production operations, permanent deletion.

---

_Auto-generated by /devstarter-existing onboard — 2026-04-05_
