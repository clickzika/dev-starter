# Dev Starter V1

A complete development workflow system for **Claude Code**. Drop it into `~/.claude/` and get a full software team — 12 specialized AI agents, 17 workflow runbooks, and battle-tested templates — ready to build any project from scratch.

## What's Inside

```
~/.claude/
├── devstarter-menu.md              ← Entry point: pick a workflow
│
├── sdlc/ (17 workflow runbooks)
│   ├── devstarter-starter.md       ← New project (Gate 1–5 full lifecycle)
│   ├── devstarter-change.md        ← Add/remove features, fix bugs
│   ├── devstarter-audit.md         ← Audit & review
│   └── ...                         ← 14 more runbooks
│
├── agents/ (12 agents)
│   ├── devstarter-techlead.md      ← Architecture & code review
│   ├── devstarter-backend.md       ← API, services, server-side
│   ├── devstarter-frontend.md      ← UI components, state, responsive
│   ├── devstarter-mobile.md        ← Flutter, React Native, Swift, Kotlin
│   ├── devstarter-dba.md           ← Schema design, queries, migrations
│   ├── devstarter-devops.md        ← CI/CD, infra, Docker, cloud
│   ├── devstarter-qa.md            ← Testing strategy & automation
│   ├── devstarter-security.md      ← OWASP, auth, vulnerability scanning
│   ├── devstarter-pm.md            ← Sprint planning, tracking, stakeholders
│   ├── devstarter-ba.md            ← Requirements, user stories, BRD
│   ├── devstarter-uxui.md          ← Design system, prototypes, wireframes
│   └── devstarter-docs.md          ← Technical writing, API docs, runbooks
│
├── commands/ (21 slash commands)
│   ├── devstarter-new.md           ← /devstarter-new — start new project
│   ├── devstarter-change.md        ← /devstarter-change — add feature / fix bug
│   ├── devstarter-release.md       ← /devstarter-release — deploy pipeline
│   ├── devstarter-context.md       ← /devstarter-context — refresh CLAUDE.md
│   └── ...                         ← 17 more shortcuts
│
├── templates/
│   ├── CLAUDE.md.template   ← Project context file template
│   ├── project.env.template ← Per-project environment variables
│   └── docs/                ← HTML documentation templates
│
├── .env.example             ← Global secrets template (GitHub, Notion)
├── USER.md                  ← Developer skill profile (agent calibration)
└── setup.sh                 ← First-time setup script
```

## Quick Start

### Option A — One Command (recommended)

```bash
git clone https://github.com/clickzika/dev-starter.git && bash dev-starter/install.sh
```

> **Windows users:** Open **Git Bash** (not PowerShell/CMD).
> Right-click desktop → "Git Bash Here", or search "Git Bash" in Start menu.
> Git Bash is installed automatically with [Git for Windows](https://git-scm.com).

This will: clone → backup existing files → copy to `~/.claude/` → run setup wizard.

### Option B — Manual Install

```bash
git clone https://github.com/clickzika/dev-starter.git
cp -r dev-starter/* ~/.claude/
bash ~/.claude/setup.sh
```

The setup wizard asks:
- GitHub username + CLI auth
- Notion API key (optional)
- 3 profile questions (experience, skills, language)
- Auto-configures permissions in `settings.json` (merges, won't overwrite)

### Start Building

```bash
claude
> /devstarter-menu          # show launcher menu
> /devstarter-new           # or go directly — start a new project
```

## Slash Commands (21)

Every workflow has a shortcut — no need to remember file paths:

| Category | Command | What it does |
|----------|---------|-------------|
| **Menu** | `/devstarter-menu` | Show launcher menu |
| **Setup** | `/devstarter-new` | New project (full 5-gate lifecycle) |
| | `/devstarter-existing` | Setup existing project |
| | `/devstarter-migrate` | Migration to new tech stack |
| | `/devstarter-audit` | Audit & review project |
| **Daily** | `/devstarter-change` | Add/remove feature, fix bug |
| | `/devstarter-sprint` | Sprint planning |
| | `/devstarter-dependency` | Update dependencies |
| **Team** | `/devstarter-onboard` | Onboard new member |
| | `/devstarter-handover` | Handover project |
| | `/devstarter-retro` | Sprint retrospective |
| **Production** | `/devstarter-release` | Release + deploy (DEV → SIT → UAT → DEPLOY) |
| | `/devstarter-hotfix` | Critical production bug fix |
| | `/devstarter-rollback` | Rollback production |
| | `/devstarter-incident` | Incident response |
| **Infra** | `/devstarter-env` | Setup local environment |
| | `/devstarter-secrets` | Secrets management |
| | `/devstarter-monitor` | Setup monitoring |
| **Utility** | `/devstarter-context` | Refresh CLAUDE.md from codebase |
| | `/devstarter-export` | Backup everything to zip |
| | `/devstarter-import` | Restore from zip |

## Agents (12 Specialists)

Each agent has:
- Domain-specific behavior rules
- Output templates with real code examples
- Standards reference tables
- Quality gate checklists
- Anti-pattern warnings

Invoke any agent directly:

```
> Read ~/.claude/agents/devstarter-backend.md and help me design the API
> Read ~/.claude/agents/devstarter-qa.md and create a test plan
> Read ~/.claude/agents/devstarter-uxui.md and design the UI
```

Or use `/devstarter-new` and the system orchestrates all agents automatically through the 5-gate build process.

## The 5-Gate Build Process

When you start a new project with `/devstarter-new`:

```
Gate 0: Setup          → GitHub repo, Notion board, branch strategy (auto)
Gate 1: Discovery      → Requirements (Q1–Q26), CLAUDE.md, BRD, SRS
Gate 2: Architecture   → DB schema, API design, security, UI prototype
Gate 3: Foundation     → Task breakdown, GitHub Issues, Notion tasks, scaffold
Gate 4: Development    → Feature-by-feature with PR review per feature
Gate 5: Quality        → Testing, security audit, performance
```

## Release Flow

After Gate 5, use `/devstarter-release` for the full deployment pipeline:

```
develop ──→ Local Test ──→ uat ──→ User Test ──→ main ──→ Production

⛔ "DEV approved"    → proceed to SIT
⛔ "SIT approved"    → proceed to UAT
⛔ "UAT approved"    → proceed to Production
⛔ "DEPLOY v[X.Y.Z]" → deploy
```

## Usage Examples

### Example 1 — Build a new web app from scratch
```
claude
> /devstarter-new
# Answer 26 questions about your project
# Claude creates: CLAUDE.md, BRD, SRS, DB design, API, prototype...
# Approve each gate → Claude builds feature by feature
# /devstarter-release when done → DEV → SIT → UAT → Production
```

### Example 2 — Add a feature to existing project
```
claude
> /devstarter-change
# Claude reads CLAUDE.md, asks what to change
# Creates feature branch → implements → PR → review → merge
```

### Example 3 — Critical bug in production
```
claude
> /devstarter-hotfix
# Claude branches from main → fixes → PR to main
# After merge: backports to uat + develop automatically
```

### Example 4 — Plan next sprint
```
claude
> /devstarter-sprint
# Claude reads Notion backlog → proposes sprint tasks
# Assigns to sprint → shows sprint board
```

### Example 5 — Release to production
```
claude
> /devstarter-release
# Gate 1: "DEV approved"     → checklist passed
# Gate 2: "SIT approved"     → automated tests passed
# Gate 3: "UAT approved"     → user tested and approved
# Gate 4: "DEPLOY v1.2.0"    → deployed to production
```

## Deploying Project Docs

Each project built with Dev Starter generates an HTML document portal (`docs/index.html`). You can host it for your team:

### GitHub Pages (public repos)

```bash
# In your project repo settings:
# Settings → Pages → Source: Deploy from branch → /docs → Save
# Your docs will be at: https://username.github.io/project-name/
```

### Cloudflare Pages (private repos — free)

If your repo is **private**, GitHub Pages requires a paid plan. Use Cloudflare Pages instead (free, unlimited bandwidth):

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Workers & Pages** → **Create** → **Pages**
2. **Connect to Git** → select your repo
3. Configure:
   - Production branch: `develop` (or `main`)
   - Build command: *(leave empty — static HTML)*
   - Output directory: `docs`
4. **Save and Deploy**

Your docs will be at: `https://project-name.pages.dev` (auto-deploys on every push)

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Git
- GitHub CLI (`gh`) — for auto-creating repos
- Node.js — for frontend tooling
- Docker (optional) — for containerized workflows

## License

MIT — see [LICENSE](LICENSE)
