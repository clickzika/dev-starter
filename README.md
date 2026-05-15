# DevStarter

A complete development workflow system for **Claude Code**. Drop it into `~/.claude/` and get a full software team — 13 specialized AI agents, 48 workflow runbooks, and battle-tested templates — ready to build any project from scratch.

## What's Inside

```
~/.claude/
├── devstarter-menu.md              ← Entry point: pick a workflow
│
├── sdlc/ (48 workflow runbooks)
│   ├── devstarter-starter.md       ← New project (Gate 1–5 full lifecycle)
│   ├── devstarter-change.md        ← Add/remove features, fix bugs
│   ├── devstarter-ml-workflow.md   ← AI/ML project workflow
│   ├── devstarter-ai-providers.md  ← Multi-provider AI routing
│   ├── devstarter-autopr.md        ← Autonomous PR review setup
│   ├── devstarter-github.md        ← GitHub procedures (PROC-GH-01 to GH-17)
│   ├── devstarter-gitlab.md        ← GitLab procedures (PROC-GL-01 to GL-17)
│   ├── devstarter-svn.md           ← SVN procedures + git-svn bridge (PROC-SV-01 to SV-13)
│   ├── devstarter-jira.md          ← Full Jira sprint management (PROC-JR-01 to JR-09)
│   ├── devstarter-vcs-sync.md      ← Multi-VCS mirror & sync
│   ├── devstarter-audit.md         ← Audit & review
│   └── ...                         ← 17 more runbooks
│
├── agents/ (13 agents)
│   ├── devstarter-techlead.md      ← Architecture, AI/LLM design decisions
│   ├── devstarter-backend.md       ← API, services, server-side
│   ├── devstarter-frontend.md      ← UI components, state, responsive
│   ├── devstarter-mobile.md        ← Flutter, React Native, Swift, Kotlin
│   ├── devstarter-dba.md           ← Schema design, queries, migrations
│   ├── devstarter-devops.md        ← CI/CD, infra, Docker, cloud, OIDC secrets
│   ├── devstarter-qa.md            ← Testing strategy & automation
│   ├── devstarter-security.md      ← OWASP, auth, enterprise secrets compliance
│   ├── devstarter-pm.md            ← Sprint planning, tracking, stakeholders
│   ├── devstarter-ba.md            ← Requirements, user stories, BRD
│   ├── devstarter-uxui.md          ← Design system, prototypes, wireframes
│   ├── devstarter-docs.md          ← Technical writing, API docs, runbooks
│   └── devstarter-mlops.md         ← ML pipelines, model serving, drift monitoring
│
├── skills/ (34 Claude Code skills)
│   ├── devstarter-new/SKILL.md     ← /devstarter-new — start new project
│   ├── devstarter-change/SKILL.md  ← /devstarter-change — add feature / fix bug
│   ├── devstarter-release/SKILL.md ← /devstarter-release — deploy pipeline
│   ├── devstarter-debug/SKILL.md   ← /devstarter-debug — senior dev problem analysis
│   ├── devstarter-context/SKILL.md ← /devstarter-context — refresh CLAUDE.md
│   └── ...                         ← 37 more skills
│
├── templates/
│   ├── CLAUDE.md.template          ← Project context file template
│   ├── project.env.template        ← Per-project config (AI_PROVIDER, SECRETS_BACKEND)
│   ├── stacks/                     ← ML project stack templates
│   │   ├── ml-starter.md           ← ML starter (scikit-learn + MLflow)
│   │   └── ml-standard.md          ← ML production (PyTorch + BentoML + monitoring)
│   ├── secrets/                    ← Enterprise secrets templates
│   │   ├── vault-setup.md          ← HashiCorp Vault setup + app integration
│   │   ├── vault-config.hcl        ← Vault config template
│   │   ├── aws-secrets-setup.md    ← AWS Secrets Manager + rotation + Terraform
│   │   ├── azure-keyvault-setup.md ← Azure Key Vault + Managed Identity
│   │   └── gcp-secretmanager.md    ← GCP Secret Manager + Workload Identity
│   ├── litellm/                    ← Multi-provider AI templates
│   │   ├── litellm-config.yaml     ← LiteLLM proxy config (Claude+OpenAI+Gemini)
│   │   └── provider-setup.md       ← Provider selection + app integration guide
│   ├── github/                     ← GitHub automation templates
│   │   ├── claude-pr-review.yml    ← GitHub Actions: auto AI PR review
│   │   └── claude-pr-review-setup.md ← Setup guide + customization
│   └── docs/                       ← HTML documentation templates
│
├── .env.example             ← Global secrets template (GitHub, Notion, AI providers)
├── USER.md                  ← Developer skill profile (agent calibration)
└── setup.sh                 ← First-time setup script
```

## Quick Start

### Install — Bash (Mac / Linux / Git Bash on Windows)

```bash
git clone https://github.com/clickzika/dev-starter.git && bash dev-starter/install.sh
```

> **Windows users:** Open **Git Bash** (not PowerShell/CMD).
> Right-click desktop → "Git Bash Here", or search "Git Bash" in Start menu.
> Git Bash is installed automatically with [Git for Windows](https://git-scm.com).

This will: clone → wipe stale DevStarter files → copy fresh to `~/.claude/` → run setup wizard.

### Manual Install

```bash
git clone https://github.com/clickzika/dev-starter.git
cp -r dev-starter/* ~/.claude/
bash ~/.claude/setup.sh
```

The setup wizard asks:
- GitHub username + CLI auth
- PM tool: Notion API key or Jira URL + token (both optional)
- Secondary VCS: GitLab / Bitbucket / SVN / Azure DevOps (optional)
- 3 profile questions (experience, skills, language)
- Auto-configures permissions in `settings.json` (merges, won't overwrite)

### Update (existing install)

```bash
bash ~/.claude/update.sh
```

Pulls latest from GitHub, replaces all DevStarter files, preserves your `CLAUDE.md`, `USER.md`, `.env`, `memory/`, and `agents/custom/`.

### Start Building

```bash
claude
> /devstarter-menu          # show launcher menu
> /devstarter-new           # or go directly — start a new project
```

## Slash Commands

Every workflow has a shortcut — no need to remember file paths:

| Category | Command | What it does |
|----------|---------|-------------|
| **Menu** | `/devstarter-menu` | Show launcher menu |
| **Setup** | `/devstarter-new` | New project (full 5-gate lifecycle) |
| | `/devstarter-existing` | Setup existing project |
| | `/devstarter-migrate` | Migration to new tech stack |
| | `/devstarter-audit` | Audit & review project |
| **Daily** | `/devstarter-change` | Add/remove feature, fix bug |
| | `/devstarter-document` | Generate or regenerate docs (brd, api, schema, test, security, infra, prototype, all) |
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
| | `/devstarter-vcs-sync` | Mirror to secondary VCS (GitLab/Bitbucket/SVN/Azure) |
| **PM** | `/devstarter-jira` | Jira full sprint management (PROC-JR-01 to JR-09) |
| **Utility** | `/devstarter-context` | Refresh CLAUDE.md from codebase |
| | `/devstarter-export` | Backup everything to zip |
| | `/devstarter-import` | Restore from zip |

## Agents (13 Specialists)

Each agent has domain-specific behavior rules, output templates, standards reference tables, quality gate checklists, and anti-pattern warnings.

| Agent | Character | Specialty |
|-------|-----------|-----------|
| `@devstarter-techlead` | 🐧 Tuxedo Sam | Architecture, ADRs, AI/LLM design |
| `@devstarter-backend` | 🐧 Badtz-Maru | APIs, services, server-side |
| `@devstarter-frontend` | ☁️ Cinnamoroll | React/Vue/Svelte, TypeScript |
| `@devstarter-mobile` | 🐭 Aggretsuko | Flutter, React Native, Swift |
| `@devstarter-dba` | 🐶 Pochacco | Schema, queries, migrations |
| `@devstarter-devops` | 🐶 Pompompurin | CI/CD, Docker, cloud, OIDC |
| `@devstarter-qa` | 🐸 Keroppi | Testing, Playwright, k6 |
| `@devstarter-security` | 💜 Kuromi | OWASP, enterprise secrets |
| `@devstarter-pm` | 🎀 Hello Kitty | Sprints, GitHub+Notion+Jira |
| `@devstarter-ba` | 🎀 My Melody | Requirements, BRD, SRS |
| `@devstarter-uxui` | ⭐ Kiki | Design system, prototypes |
| `@devstarter-docs` | 🥚 Gudetama | Technical writing, API docs |
| `@devstarter-mlops` | 🤖 MLOps | ML pipelines, serving, drift |

Invoke any agent directly:

```
> Read ~/.claude/agents/devstarter-mlops.md and help me set up a training pipeline
> Read ~/.claude/agents/devstarter-security.md and review my secrets setup
> Read ~/.claude/agents/devstarter-techlead.md and write an AI provider ADR
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
# Claude reads Notion or Jira backlog → proposes sprint tasks
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
