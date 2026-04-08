# DevStarter Command Registry

Quick reference for all 24 slash commands. Each entry lists the command, its purpose, SDLC target, and whether it accepts inline arguments.

---

## Commands with Full Logic (standalone — do not route)

| Command | Title | Notes |
|---------|-------|-------|
| `/devstarter-new` | Start a New Project | Inline args: project description |
| `/devstarter-existing` | Setup Existing Project | Inline args: project description |
| `/devstarter-change` | Add / Remove / Fix | Inline args: `add X`, `fix Y`, `remove Z` |
| `/devstarter-audit` | Audit & Review | Inline args: audit scope |
| `/devstarter-document` | Generate Documents | Inline args: doc scope |
| `/devstarter-context` | Keep Context Fresh | Full sync logic inline |
| `/devstarter-export` | Export for Backup | Archive + transfer logic inline |
| `/devstarter-import` | Import from Backup | Restore logic inline |

---

## Commands that Route to SDLC (thin — 2-line files)

| Command | Title | Routes to |
|---------|-------|-----------|
| `/devstarter-sprint` | Sprint Planning | `sdlc/devstarter-sprint.md` |
| `/devstarter-release` | Release + Deploy | `sdlc/devstarter-release.md` |
| `/devstarter-hotfix` | Critical Production Fix | `sdlc/devstarter-hotfix.md` |
| `/devstarter-rollback` | Rollback Production | `sdlc/devstarter-rollback.md` |
| `/devstarter-incident` | Incident Response | `sdlc/devstarter-incident.md` |
| `/devstarter-dependency` | Update Dependencies | `sdlc/devstarter-dependency.md` |
| `/devstarter-env` | Setup Local Environment | `sdlc/devstarter-env.md` |
| `/devstarter-secrets` | Secrets Management | `sdlc/devstarter-secrets.md` |
| `/devstarter-monitor` | Setup Monitoring | `sdlc/devstarter-monitor.md` |
| `/devstarter-migrate` | Migration to New Stack | `sdlc/devstarter-migrate.md` |
| `/devstarter-onboard` | Onboard Team Member | `sdlc/devstarter-onboarding.md` |
| `/devstarter-handover` | Handover Project | `sdlc/devstarter-handover.md` |
| `/devstarter-retro` | Sprint Retrospective | `sdlc/devstarter-retrospective.md` |
| `/devstarter-consult` | Consult & Advise | `sdlc/devstarter-consult.md` |
| `/devstarter-menu` | Project Launcher Menu | `devstarter-menu.md` |
| `/devstarter-update` | Update DevStarter | Runs `~/.claude/update.sh` |
