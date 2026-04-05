# Changelog

## v1.4.1 (2026-04-05)

### New Command: /devstarter-document

Add a standalone document generator command — the 24th slash command.

- **`/devstarter-document`** — generate or regenerate any project document independently,
  without re-running a full gate workflow. Supports 10 doc types:
  `brd`, `srs`, `api`, `schema`, `test`, `security`, `infra`, `prototype`, `plan`, `all`
- Each doc type routes to the correct specialist agent (@devstarter-ba, @devstarter-backend,
  @devstarter-dba, @devstarter-qa, @devstarter-security, @devstarter-devops, @devstarter-uxui, @devstarter-pm)
- Inline args supported: `/devstarter-document api` skips the picker, generates immediately
- Auto-generation during `/devstarter-new` Gate 2 is **unchanged** — this command is additive
- Registered in `devstarter-menu.md` as item 6 under Daily Work (menu renumbered 7–20)

---

## v1.4.0 (2026-04-05)

### Release: Git Auto-Detection (Strategy I)

- **`/devstarter-release`** — added Strategy I for git-based toolkit/library projects.
  Auto-detects release model at runtime:
  - **Model A** (dual-remote): `release` remote exists → pushes `main` + tag to `release` remote
  - **Model B** (single-repo): no `release` remote → pushes `main` + tag to `origin`
  Includes copy-paste ready `release.sh <version>` script.

---

## v1.3.0 (2026-04-05)

### UX: Quick-Picker First Prompt + Inline Args

Dramatically reduced friction for all intake commands — users no longer
need to answer questions they didn't ask for.

- **`/devstarter-new`** — 3-mode picker shown before any questions:
  Quick (8Q) / Custom (15Q) / Describe (1Q).
  Inline args bypass all questions: `/devstarter-new React todo app` → direct to summary.

- **`/devstarter-change`** — Quick-picker: Add / Remove / Fix.
  Inline args extract type from first word: `/devstarter-change add dark mode` → skip Q1+Q2.

- **`/devstarter-existing`** — Quick-picker: Onboard / Add+Fix / Refactor / Security / Full setup.
  Q3–Q5 (CLAUDE.md, docs/, tech stack) now auto-detected from disk — never asked.
  Inline args set intent directly: `/devstarter-existing onboard me` → scan runs immediately.

- **`/devstarter-audit`** — Quick-picker: 7 audit types + report/plan/fix outcome in one prompt.
  Q1 (project name) and Q5 (environment) auto-detected — never asked.
  Inline args: `/devstarter-audit security` or `/devstarter-audit full audit fix`.

### New VCS Runbooks

- **`sdlc/devstarter-gitlab.md`** — Full GitLab procedure runbook (PROC-GL-01 to GL-17),
  matching `devstarter-github.md` depth. Covers: create repo, MR workflow, branch
  protection, labels, milestones, hotfix, CI/CD pipeline, autonomous MR review via Claude AI.
  Uses `glab` CLI throughout.

- **`sdlc/devstarter-svn.md`** — Full SVN procedure runbook (PROC-SV-01 to SV-13).
  Mode A (SVN as primary): create repo, checkout, branch, commit, merge, tag, revert.
  Mode B (git-svn bridge/secondary): first-time setup, push commits to SVN, pull SVN changes,
  tag releases, mirror hotfixes.

- **`agents/shared/devstarter-vcs-pm-guide.md`** — Added GitLab and SVN routing sections
  with references to the new runbooks.

## v1.2.0 (2026-04-05)

### VCS_SECONDARY — Multi-VCS Project Support

- **New SDLC runbook:** `sdlc/devstarter-vcs-sync.md` — Mirror/sync runbook for pushing to secondary VCS after every primary merge. Covers GitLab, GitHub, Bitbucket, SVN (git-svn bridge), and Azure DevOps. Includes CI auto-sync via GitHub Actions and conflict resolution guide
- **Updated template:** `templates/project.env.template` — Added `VCS_SECONDARY_1`, `VCS_SECONDARY_2`, `VCS_SYNC_BRANCHES` fields with full connection options for all VCS types
- **Updated shared guide:** `agents/shared/devstarter-vcs-pm-guide.md` — Added Step 5 (Secondary VCS mirror function) and Multi-VCS special case documentation with "primary = source of truth" rule
- **Updated SDLC:** `sdlc/devstarter-change.md` — Rule 3b: mirror after every primary merge
- **Updated SDLC:** `sdlc/devstarter-release-verify.md` — Phase 10: mirror on release
- **Updated SDLC:** `sdlc/devstarter-hotfix.md` — Mirror step after hotfix merge

### Jira Full Sprint Management

- **New SDLC runbook:** `sdlc/devstarter-jira.md` — Full Jira procedures (equivalent depth to `devstarter-notion.md`):
  - `PROC-JR-01` — Create Jira project + board (Scrum template)
  - `PROC-JR-02` — Create sprint with start/end date and goal
  - `PROC-JR-03` — Create issue (Story/Task/Bug/Epic) with story points, epic link, sprint assignment
  - `PROC-JR-04` — Update issue status via transition auto-discovery (To Do → In Progress → In Review → Done)
  - `PROC-JR-05` — Start sprint (set state = active)
  - `PROC-JR-06` — Close sprint + velocity report (SP completed, carry-over list)
  - `PROC-JR-07` — Link PR/commit to issue + add comment
  - `PROC-JR-08` — Create Epic with epic name field
  - `PROC-JR-09` — Bulk create issues from task list with sprint assignment
- **Updated agent:** `agents/devstarter-pm.md` — Added PM Tool Selection routing table and Jira Sprint Management section (planning, status rules, retro, field discovery)
- **Updated shared guide:** `agents/shared/devstarter-vcs-pm-guide.md` — Expanded PM operations table (create task, create sprint, update status, close sprint) for all PM_TYPE values
- **Updated template:** `templates/project.env.template` — Added full Jira fields: `JIRA_BOARD_ID`, `JIRA_SPRINT_ID`, `JIRA_DEFAULT_ISSUE_TYPE`, `JIRA_STORY_POINTS_FIELD`, `JIRA_EMAIL`

## v1.1.0 (2026-04-05)

### MLOps Agent + AI/ML Project Templates

- **New agent:** `agents/devstarter-mlops.md` — MLOps Engineer specializing in ML pipelines, model serving, experiment tracking, drift monitoring, and LLM/RAG systems
- **New stack template:** `templates/stacks/ml-starter.md` — Lightweight ML project (scikit-learn + MLflow local + FastAPI)
- **New stack template:** `templates/stacks/ml-standard.md` — Production ML system (PyTorch + BentoML + Evidently + CI/CD auto-training)
- **New SDLC runbook:** `sdlc/devstarter-ml-workflow.md` — ML intake questions (Q1–Q6), stack selection, Gate 2 ML docs, deployment strategies, LLM/RAG setup
- **Updated menu:** `devstarter-menu.md` — Added options 18 (New AI/ML Project) and 19 (ML Workflow)
- **Updated team:** `agents/teams/devstarter-platform.md` — MLOps agent added to Platform team
- **Updated template:** `sdlc/devstarter-starter-template.md` — Template I added for AI/ML projects

### GitHub Actions Autonomous PR Review

- **New workflow template:** `templates/github/claude-pr-review.yml` — GitHub Actions workflow that triggers on every PR, calls Claude API, posts structured review comment with security/performance/quality findings, adds labels
- **New setup guide:** `templates/github/claude-pr-review-setup.md` — 5-minute setup, model selection, path filtering, LiteLLM proxy integration, label automation
- **New SDLC runbook:** `sdlc/devstarter-autopr.md` — Autonomous PR review architecture, cost estimates (~$0.003/review with Haiku), extension patterns (auto-issue creation, auto-test generation)
- **Updated SDLC:** `sdlc/devstarter-github.md` — Added PROC-GH-16 (setup autonomous review) and PROC-GH-17 (AI provider rotation)

### Multi-Provider AI Support via LiteLLM

- **New config template:** `templates/litellm/litellm-config.yaml` — LiteLLM proxy config with Claude, OpenAI, Gemini, Azure, Bedrock, and Ollama. Includes cost-based routing, fallbacks, and context window failover
- **New setup guide:** `templates/litellm/provider-setup.md` — Provider comparison, Node.js/Python integration, Docker Compose, cost optimization, usage logging to PostgreSQL
- **New SDLC runbook:** `sdlc/devstarter-ai-providers.md` — Provider selection guide, LiteLLM proxy setup, provider-agnostic AIService patterns, cost controls, rotation checklist
- **Updated agent:** `agents/devstarter-techlead.md` — Added AI/LLM Architecture section with provider selection ADR template
- **Updated:** `.env.example` — Added AI provider keys (Anthropic, OpenAI, Google) and LiteLLM proxy vars

### Enterprise Secrets Management

- **New template:** `templates/secrets/vault-setup.md` — HashiCorp Vault setup guide (Docker dev, production init, dynamic DB creds, K8s auth, OIDC, audit logs, GitHub Actions integration)
- **New template:** `templates/secrets/vault-config.hcl` — Production Vault config (Raft storage, TLS, AWS/Azure/GCP KMS auto-unseal, Prometheus telemetry)
- **New template:** `templates/secrets/aws-secrets-setup.md` — AWS Secrets Manager (IAM policies, rotation Lambda, ECS/EKS injection, Terraform, OIDC for GitHub Actions)
- **New template:** `templates/secrets/azure-keyvault-setup.md` — Azure Key Vault (Managed Identity, federated OIDC, Container Apps, AKS CSI driver, Terraform)
- **New template:** `templates/secrets/gcp-secretmanager.md` — GCP Secret Manager (Workload Identity, Cloud Run, GKE External Secrets, rotation Pub/Sub, audit logging, Terraform)
- **Updated SDLC:** `sdlc/devstarter-secrets.md` — Added Phases 6–9: enterprise backend selection, migration checklist, secrets registry, rotation runbook
- **Updated agent:** `agents/devstarter-security.md` — Added Enterprise Secrets Management section with backend selection guide, mandatory checklist, and SOC2/ISO27001/PCI DSS compliance mapping
- **Updated agent:** `agents/devstarter-devops.md` — Added enterprise secrets procedures, rotation schedule, and OIDC authentication patterns for AWS/GCP/Azure
- **Updated template:** `templates/CLAUDE.md.template` — Added `SECRETS_BACKEND` config section
- **Updated template:** `templates/project.env.template` — Added `SECRETS_BACKEND` and `AI_PROVIDER` fields with all options documented

## v1.0.3 (2026-04-05)

### Namespace Prefixing — `devstarter-` Identity
- All 12 agent files prefixed: `techlead.md` → `devstarter-techlead.md`, etc.
- All 23 command files prefixed: `menu.md` → `devstarter-menu.md`, etc.
- All 22 SDLC workflow files prefixed: `dev-starter.md` → `devstarter-starter.md`, etc.
- Team agent files prefixed: `engineering.md` → `devstarter-engineering.md`, etc.
- Shared agent files prefixed: `vcs-pm-guide.md` → `devstarter-vcs-pm-guide.md`
- Root file renamed: `dev-menu.md` → `devstarter-menu.md`
- All internal `@agent` references updated: `@techlead` → `@devstarter-techlead`, etc.
- All slash command references updated: `/menu` → `/devstarter-menu`, etc.
- All file path cross-references updated across agents, commands, sdlc, scripts, templates
- **Why:** Establishes clear identity/ownership — makes it immediately obvious which agents, commands, and workflows belong to Dev Starter vs. other Claude Code extensions

## v1.0.2 (2026-03-23)

### Light Mode Default + Dark Mode Toggle
- **Document Portal** (`templates/docs/index.html`): Redesigned with light mode as default
- **Document Template** (`templates/docs/document-template.html`): Redesigned with light mode as default
- Both templates now include a dark mode toggle (sun/moon icon) in the topbar
- Theme preference persisted via `localStorage` and shared between portal and documents
- Mermaid diagrams auto-select light/dark theme based on saved preference

### Change Request Log
- New document: `docs/changerequest-log.html` — tracks all feature additions and removals
- `/devstarter-change` Operation A (Add Feature): now creates a CR entry with ID `CR-[YYYY-MM-DD]-[NNN]`
- `/devstarter-change` Operation B (Remove Feature): now creates a CR entry with removal reason and impact
- **Revision History rule**: every Gate 1 document modified by Operation A or B MUST append a Revision History table row linking back to the CR ID

### Document Portal Registry
- Added Audit & Review section: Audit Report (`audit-report.html`), Fix Plan (`fix-plan.html`)
- Added Change Log section: Change Request Log (`changerequest-log.html`), Bugfix Log (`bugfix-log.html`)
- Total documents: 10 required (Gate 1) + 4 optional (on-demand) = 14 documents

### Removed
- Removed Help button and dropdown from Document Portal (no longer needed)
- Deleted `_readme.html` and `_project-readme.html` template files (unused)

## v1.0.1 (2026-03-22)

### Agent Identity — Sanrio Theme
- All 12 agents now have unique Sanrio character names and emoji
- Progress reporting shows character name + role (e.g. "🐧 Badtz-Maru (Backend) starting: ...")
- Characters: Hello Kitty (PM), Tuxedo Sam (Tech Lead), My Melody (BA), Badtz-Maru (Backend), Cinnamoroll (Frontend), Pochacco (DBA), Keroppi (QA), Kuromi (Security), Pompompurin (DevOps), Kiki (UX/UI), Gudetama (Docs), Aggretsuko (Mobile)

### Workflow Improvements
- **Notion task status**: Added Rule 5 — tasks MUST update through To Do → In Progress → In Review → Done (all 3 workflows)
- **Continuous development**: Added Rule 6 — after doc approval, develop ALL tasks without per-task stops (all 3 workflows)
- **Parallel execution**: Added Rule 7 — backend + frontend + infra run in parallel when independent (all 3 workflows)
- **Gate 4 rewritten** in dev-starter.md — removed per-feature HARD STOP, added parallel track diagram

### Document Standards
- **Document Portal**: Added Rule 8 — docs/index.html MUST be copied from template, never created from scratch
- **Component Library**: docs/prototype/components.html now mandatory in completion check (11 files full-stack / 10 files client-only)
- **UX/UI agent**: Added mandatory HTML skeleton, concrete Tailwind code examples for Typography, Colors, Buttons, Forms, Data Display, Feedback sections
- **Critical reminders**: Agent explicitly told "NEVER output text descriptions" + "NEVER use ASCII art"

### Bug Fixes
- Fixed: docs/index.html was being generated from scratch instead of using template
- Fixed: UX/UI prototype produced text descriptions instead of rendered HTML components
- Fixed: Component Library (components.html) was not being created
- Fixed: Notion tasks not updated during development phase
- Fixed: Development stopped after each task for approval instead of continuous flow

## v1.0.0 (2026-03-22)

### Initial Release

**Agents (12):**
- BA, Backend, DBA, DevOps, Docs, Frontend, Mobile, PM, QA, Security, Tech Lead, UX/UI
- All agents upgraded with Anti-patterns, Standards Reference, Quality Gate Checklist

**Commands (22):**
- `/devstarter-new` — Start new project (3 intake modes: Quick Start, Custom, Describe)
- `/devstarter-change` — Add feature / Remove feature / Fix bug
- `/devstarter-consult` — Consultation & solution advice (no code changes)
- `/devstarter-existing` — Setup existing project with codebase scan
- `/devstarter-release` — Release + deploy (8 deploy strategies)
- `/devstarter-hotfix` — Critical production bug fix
- `/devstarter-rollback` — Rollback production
- `/devstarter-incident` — Incident response
- `/devstarter-sprint` — Sprint planning
- `/devstarter-audit` — Audit & review project
- `/devstarter-migrate` — Migration to new tech stack
- `/devstarter-onboard` — Onboard new team member
- `/devstarter-handover` — Handover project
- `/devstarter-retro` — Sprint retrospective
- `/devstarter-env` — Setup local environment
- `/devstarter-secrets` — Secrets management
- `/devstarter-monitor` — Setup monitoring
- `/devstarter-dependency` — Update dependencies
- `/devstarter-menu` — Show project launcher menu
- `/devstarter-context` — Keep project context fresh
- `/devstarter-export` / `/devstarter-import` — Backup and restore Dev Starter
- `/devstarter-update` — Update to latest version

**SDLC Workflows:**
- 5-gate workflow with hard approval gates
- Cross-project API handoff (api-request.html)
- Checkpoint & auto-resume for rate limit recovery
- GitHub procedures (15): repo, branches, PRs, issues, milestones, hotfix, semver
- Notion procedures (10): database, tasks, views, sprint, dashboard
- 8 deploy strategies (Docker, K8s, Azure, AWS, Cloud Run, Vercel/Netlify/Cloudflare, Railway, GitHub Pages)
- Local staging with Docker Compose

**Project Types:**
- Q3: Web, Mobile, Web+Mobile, Desktop, API only, CLI, Background Service
- Q3.1: Build new backend OR connect to existing API
- 8 folder structure templates (A-H)
- Solution stack bundles per platform (Starter/Standard/Professional)

**Setup:**
- One-command install: `bash install.sh`
- Setup wizard: GitHub + Notion config, permissions merge, USER.md
- Cross-platform: Windows (Git Bash), macOS, Linux
