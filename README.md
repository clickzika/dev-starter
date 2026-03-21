# Dev Starter V1

A complete development workflow system for **Claude Code**. Drop it into `~/.claude/` and get a full software team — 12 specialized AI agents, 17 workflow runbooks, and battle-tested templates — ready to build any project from scratch.

## What's Inside

```
~/.claude/
├── dev-menu.md              ← Entry point: pick a workflow
│
├── sdlc/ (17 workflow runbooks)
│   ├── dev-starter.md       ← New project (Gate 1–5 full lifecycle)
│   ├── dev-change.md        ← Add/remove features, fix bugs
│   ├── dev-audit.md         ← Audit & review
│   └── ...                  ← 14 more runbooks
│
├── agents/ (12 agents)
│   ├── techlead.md          ← Architecture & code review
│   ├── backend.md           ← API, services, server-side
│   ├── frontend.md          ← UI components, state, responsive
│   ├── mobile.md            ← Flutter, React Native, Swift, Kotlin
│   ├── dba.md               ← Schema design, queries, migrations
│   ├── devops.md            ← CI/CD, infra, Docker, cloud
│   ├── qa.md                ← Testing strategy & automation
│   ├── security.md          ← OWASP, auth, vulnerability scanning
│   ├── pm.md                ← Sprint planning, tracking, stakeholders
│   ├── ba.md                ← Requirements, user stories, BRD
│   ├── uxui.md              ← Design system, prototypes, wireframes
│   └── docs.md              ← Technical writing, API docs, runbooks
│
├── commands/ (21 slash commands)
│   ├── new.md               ← /new — start new project
│   ├── change.md            ← /change — add feature / fix bug
│   ├── release.md           ← /release — deploy pipeline
│   ├── context.md           ← /context — refresh CLAUDE.md
│   └── ...                  ← 17 more shortcuts
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

**Mac / Linux / Git Bash:**
```bash
git clone https://github.com/clickzika/dev-starter.git && bash dev-starter/install.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/clickzika/dev-starter.git; bash dev-starter/install.sh
```

This will: clone → backup existing files → copy to `~/.claude/` → run setup wizard.

### Option B — Manual Install

**Mac / Linux / Git Bash:**
```bash
git clone https://github.com/clickzika/dev-starter.git
cp -r dev-starter/* ~/.claude/
bash ~/.claude/setup.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/clickzika/dev-starter.git
Copy-Item -Recurse dev-starter\* $env:USERPROFILE\.claude\
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
> /menu          # show launcher menu
> /new           # or go directly — start a new project
```

## Slash Commands (21)

Every workflow has a shortcut — no need to remember file paths:

| Category | Command | What it does |
|----------|---------|-------------|
| **Menu** | `/menu` | Show launcher menu |
| **Setup** | `/new` | New project (full 5-gate lifecycle) |
| | `/existing` | Setup existing project |
| | `/migrate` | Migration to new tech stack |
| | `/audit` | Audit & review project |
| **Daily** | `/change` | Add/remove feature, fix bug |
| | `/sprint` | Sprint planning |
| | `/dependency` | Update dependencies |
| **Team** | `/onboard` | Onboard new member |
| | `/handover` | Handover project |
| | `/retro` | Sprint retrospective |
| **Production** | `/release` | Release + deploy (DEV → SIT → UAT → DEPLOY) |
| | `/hotfix` | Critical production bug fix |
| | `/rollback` | Rollback production |
| | `/incident` | Incident response |
| **Infra** | `/env` | Setup local environment |
| | `/secrets` | Secrets management |
| | `/monitor` | Setup monitoring |
| **Utility** | `/context` | Refresh CLAUDE.md from codebase |
| | `/export` | Backup everything to zip |
| | `/import` | Restore from zip |

## Agents (12 Specialists)

Each agent has:
- Domain-specific behavior rules
- Output templates with real code examples
- Standards reference tables
- Quality gate checklists
- Anti-pattern warnings

Invoke any agent directly:

```
> Read ~/.claude/agents/backend.md and help me design the API
> Read ~/.claude/agents/qa.md and create a test plan
> Read ~/.claude/agents/uxui.md and design the UI
```

Or use `/new` and the system orchestrates all agents automatically through the 5-gate build process.

## The 5-Gate Build Process

When you start a new project with `/new`:

```
Gate 0: Setup          → GitHub repo, Notion board, branch strategy (auto)
Gate 1: Discovery      → Requirements (Q1–Q26), CLAUDE.md, BRD, SRS
Gate 2: Architecture   → DB schema, API design, security, UI prototype
Gate 3: Foundation     → Task breakdown, GitHub Issues, Notion tasks, scaffold
Gate 4: Development    → Feature-by-feature with PR review per feature
Gate 5: Quality        → Testing, security audit, performance
```

## Release Flow

After Gate 5, use `/release` for the full deployment pipeline:

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
> /new
# Answer 26 questions about your project
# Claude creates: CLAUDE.md, BRD, SRS, DB design, API, prototype...
# Approve each gate → Claude builds feature by feature
# /release when done → DEV → SIT → UAT → Production
```

### Example 2 — Add a feature to existing project
```
claude
> /change
# Claude reads CLAUDE.md, asks what to change
# Creates feature branch → implements → PR → review → merge
```

### Example 3 — Critical bug in production
```
claude
> /hotfix
# Claude branches from main → fixes → PR to main
# After merge: backports to uat + develop automatically
```

### Example 4 — Plan next sprint
```
claude
> /sprint
# Claude reads Notion backlog → proposes sprint tasks
# Assigns to sprint → shows sprint board
```

### Example 5 — Release to production
```
claude
> /release
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
