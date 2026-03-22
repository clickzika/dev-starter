# Changelog

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
