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
├── commands/
│   ├── context.md           ← Refresh CLAUDE.md when project evolves
│   ├── export.md            ← Backup everything for transfer
│   └── import.md            ← Restore from backup
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

This single command will:
1. Clone the repo
2. Backup existing `~/.claude/` files (if any)
3. Copy everything to `~/.claude/`
4. Run setup wizard (GitHub, Notion, profile, permissions)

### Option B — Manual Install

```bash
# Clone
git clone https://github.com/clickzika/dev-starter.git

# Copy to Claude Code's config directory
cp -r dev-starter/* ~/.claude/

# Run setup
bash ~/.claude/setup.sh
```

The setup wizard asks:
- GitHub username + CLI auth
- Notion API key (optional)
- 3 profile questions (experience, skills, language)
- Auto-configures permissions in `settings.json` (merges, won't overwrite)

### Start Building

```bash
# Open any project folder
cd ~/Projects

# Start Claude Code
claude

# Then type:
> Read ~/.claude/dev-menu.md and help me get started
```

Pick option **1 (New Project)** and the system walks you through everything — from requirements to deployment.

## Workflows (17 Runbooks)

| Category | Workflow | File |
|----------|----------|------|
| **Setup** | New Project (full lifecycle) | `dev-starter.md` |
| | Existing Project | `dev-existing.md` |
| | Migration (new stack) | `dev-migrate.md` |
| | Audit & Review | `dev-audit.md` |
| **Daily** | Change (feature/bugfix) | `dev-change.md` |
| | Sprint Planning | `dev-sprint.md` |
| | Dependency Update | `dev-dependency.md` |
| **Team** | Onboard New Member | `dev-onboarding.md` |
| | Handover Project | `dev-handover.md` |
| | Sprint Retrospective | `dev-retrospective.md` |
| **Production** | Release + Deploy | `dev-release.md` |
| | Hotfix (critical) | `dev-hotfix.md` |
| | Rollback | `dev-rollback.md` |
| | Incident Response | `dev-incident.md` |
| **Infra** | Local Environment Setup | `dev-env.md` |
| | Secrets Management | `dev-secrets.md` |
| | Monitoring Setup | `dev-monitor.md` |

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

Or let `dev-starter.md` orchestrate them automatically through the 5-gate build process.

## The 5-Gate Build Process

When you start a new project with `dev-starter.md`:

```
Gate 1: Discovery      → Requirements (Q1–Q26), CLAUDE.md, USER.md
Gate 2: Architecture   → Tech stack, DB schema, API design, UI prototype
Gate 3: Implementation → Sprint-by-sprint coding with all agents
Gate 4: Quality        → Testing, security audit, performance
Gate 5: Delivery       → Deploy, monitoring, documentation, handover
```

Each gate has a **Definition of Done** checklist. No shortcuts.

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
