# Changelog

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
- `/new` — Start new project (3 intake modes: Quick Start, Custom, Describe)
- `/change` — Add feature / Remove feature / Fix bug
- `/consult` — Consultation & solution advice (no code changes)
- `/existing` — Setup existing project with codebase scan
- `/release` — Release + deploy (8 deploy strategies)
- `/hotfix` — Critical production bug fix
- `/rollback` — Rollback production
- `/incident` — Incident response
- `/sprint` — Sprint planning
- `/audit` — Audit & review project
- `/migrate` — Migration to new tech stack
- `/onboard` — Onboard new team member
- `/handover` — Handover project
- `/retro` — Sprint retrospective
- `/env` — Setup local environment
- `/secrets` — Secrets management
- `/monitor` — Setup monitoring
- `/dependency` — Update dependencies
- `/menu` — Show project launcher menu
- `/context` — Keep project context fresh
- `/export` / `/import` — Backup and restore Dev Starter
- `/update` — Update to latest version

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
