# Changelog

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
