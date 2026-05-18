# DevStarter

A complete development workflow system for **Claude Code** — and any other AI tool. Drop it into `~/.claude/` and get a full software team — 83 AI agents, 43+ slash commands, 30 SDLC runbooks, 29 MCP server configs, 18 language rule sets, and battle-tested templates — ready to build any project from scratch.

## What's Inside

```
~/.claude/
├── devstarter-menu.md              ← Entry point: pick a workflow
│
├── agents/ (83 agents)
│   ├── [13 core agents]            ← All profiles
│   ├── [5 domain specialists]      ← full profile
│   ├── [15 code reviewers]         ← full profile
│   ├── [12 build resolvers]        ← full profile
│   └── [38 specialist agents]      ← full profile
│
├── skills/ (43+ slash commands)
│   ├── devstarter-new/SKILL.md
│   ├── devstarter-change/SKILL.md
│   ├── devstarter-debug/SKILL.md
│   ├── devstarter-consult/SKILL.md
│   └── ...
│
├── sdlc/ (30 workflow runbooks)
│   ├── devstarter-starter.md       ← New project (Gate 1–5 full lifecycle)
│   ├── devstarter-change.md        ← Add/remove features, fix bugs
│   ├── devstarter-verification-loop.md ← Build/type/lint/test/security gate
│   ├── devstarter-council.md       ← Multi-voice architecture decision
│   └── ...
│
├── rules/ (18 language rule sets)
│   ├── typescript.md / python.md / go.md / rust.md
│   ├── java.md / csharp.md / react.md / flutter.md
│   ├── angular.md / laravel.md / kotlin.md / swift.md
│   ├── dart.md / cpp.md / fsharp.md / node.md
│   ├── devstarter/                 ← DevStarter contributor rules
│   └── common/                     ← Shared cross-language rules
│
├── templates/
│   ├── mcp/                        ← 29 MCP server configs
│   │   ├── github.json             ← GitHub MCP
│   │   ├── postgresql.json         ← PostgreSQL MCP
│   │   ├── brave-search.json       ← Brave Search MCP
│   │   └── ...                     ← 26 more
│   ├── contexts/                   ← Behavior-mode files
│   │   ├── dev.md                  ← Code-first mode
│   │   ├── research.md             ← Explore before acting
│   │   └── review.md               ← PR / security pass
│   ├── hooks/                      ← Hooks config + docs
│   │   ├── hooks.json              ← Claude Code hooks template
│   │   └── README.md               ← Hooks guide
│   ├── team-packs.md               ← 13 pre-built agent group configs
│   ├── agent-disambiguation.md     ← When to use which agent
│   ├── stacks/                     ← ML project stack templates
│   ├── secrets/                    ← Enterprise secrets templates
│   ├── litellm/                    ← Multi-provider AI templates
│   ├── github/                     ← GitHub Actions templates
│   └── docs/                       ← HTML documentation templates
│
├── scripts/
│   ├── hooks/                      ← 5 Node.js lifecycle hooks
│   │   ├── session-start.js        ← Load memory + progress on start
│   │   ├── pre-compact.js          ← Log compaction events
│   │   ├── post-edit-accumulator.js← Track edited files per session
│   │   ├── stop-format-typecheck.js← Auto-format + type-check on stop
│   │   └── stop-check-console-log.js ← Warn on debug statements
│   ├── install-hooks.js            ← Merge hooks into settings.json
│   └── uninstall-hooks.js          ← Remove DevStarter hooks from settings.json
│
├── uninstall.sh                    ← Clean uninstaller
├── .env.example                    ← Global secrets template
├── USER.md                         ← Developer skill profile (agent calibration)
└── setup.sh                        ← First-time setup wizard
```

## Quick Start

### Install — Bash (Mac / Linux / Git Bash on Windows)

```bash
# Standard install (13 core agents, all slash commands)
curl -sL https://raw.githubusercontent.com/clickzika/dev-starter/main/install.sh | bash

# Or if you cloned:
bash install.sh
```

> **Windows users:** Open **Git Bash** (not PowerShell/CMD).
> Right-click desktop → "Git Bash Here", or search "Git Bash" in Start.
> Git Bash installs automatically with [Git for Windows](https://git-scm.com).

### Install Profiles

```bash
# minimal — 7 core agents, no language rules (leaner context)
bash install.sh --profile minimal

# standard — 13 core agents + all skills + language rules (default)
bash install.sh --profile standard

# full — all 83 agents including code reviewers, build resolvers, specialists
bash install.sh --profile full

# Add lifecycle hooks (auto-format, type-check, memory load)
bash install.sh --hooks
bash install.sh --profile full --hooks
```

### Update (existing install)

```bash
bash ~/.claude/update.sh
```

Pulls latest, replaces all DevStarter files, preserves your `CLAUDE.md`, `USER.md`, `.env`, `memory/`, and `agents/custom/`.

Or from inside Claude Code: `/devstarter-update`

### Uninstall

```bash
bash ~/.claude/uninstall.sh              # interactive, keeps your files
bash ~/.claude/uninstall.sh --yes        # skip confirmation
bash ~/.claude/uninstall.sh --purge      # also remove USER.md, CLAUDE.md, memory/
bash ~/.claude/uninstall.sh --hooks-only # only remove hooks from settings.json
```

### Start Building

```bash
claude
> /devstarter-menu          # show launcher menu
> /devstarter-new           # start a new project
```

## Slash Commands

| Category | Command | What it does |
|----------|---------|-------------|
| **Menu** | `/devstarter-menu` | Show launcher menu |
| **Setup** | `/devstarter-new` | New project (full 5-gate lifecycle) |
| | `/devstarter-existing` | Setup existing project |
| | `/devstarter-migrate` | Migration to new tech stack |
| | `/devstarter-gitsetup` | Git + GitFlow + branch protection setup |
| | `/devstarter-mcp` | Activate MCP server configs |
| **Daily** | `/devstarter-change` | Add/remove feature, fix bug |
| | `/devstarter-debug` | Root-cause analysis + fix plan |
| | `/devstarter-consult` | Architecture / strategy advice |
| | `/devstarter-review` | PR / diff / file review |
| | `/devstarter-document` | Generate docs (brd, api, schema, test, security, all) |
| | `/devstarter-sprint` | Sprint planning |
| | `/devstarter-dependency` | Update dependencies |
| | `/devstarter-verification-loop` | Build/type/lint/test/security gate |
| **Decision** | `/devstarter-council` | Multi-voice architecture decision (Opus) |
| | `/devstarter-audit` | Full project audit |
| | `/devstarter-doctor` | Diagnose DevStarter health |
| **Team** | `/devstarter-onboard` | Onboard new member |
| | `/devstarter-handover` | Handover project |
| | `/devstarter-retro` | Sprint retrospective |
| **Production** | `/devstarter-release` | Release + deploy (DEV → UAT → Production) |
| | `/devstarter-hotfix` | Critical production bug fix |
| | `/devstarter-rollback` | Rollback production |
| | `/devstarter-incident` | Incident response |
| **Infra** | `/devstarter-env` | Setup local environment |
| | `/devstarter-secrets` | Secrets management |
| | `/devstarter-monitor` | Setup monitoring |
| | `/devstarter-vcs-sync` | Mirror to secondary VCS |
| **Utility** | `/devstarter-context` | Refresh CLAUDE.md from codebase |
| | `/devstarter-export` | Backup to zip |
| | `/devstarter-import` | Restore from zip |
| | `/devstarter-update` | Update DevStarter |

## Agents

### Core (all profiles)

| Agent | Short alias | Specialty |
|-------|-------------|-----------|
| `@devstarter-techlead` | `@techlead` | Architecture, ADRs, AI/LLM design |
| `@devstarter-backend` | `@backend` | APIs, services, server-side |
| `@devstarter-frontend` | `@frontend` | React/Vue/Svelte, TypeScript |
| `@devstarter-mobile` | `@mobile` | Flutter, React Native, Swift |
| `@devstarter-dba` | `@dba` | Schema, queries, migrations |
| `@devstarter-devops` | `@devops` | CI/CD, Docker, cloud, OIDC |
| `@devstarter-qa` | `@qa` | Testing, Playwright, k6 |
| `@devstarter-security` | `@security` | OWASP, enterprise secrets |
| `@devstarter-pm` | `@pm` | Sprints, GitHub + Notion + Jira |
| `@devstarter-ba` | `@ba` | Requirements, BRD, SRS |
| `@devstarter-uxui` | `@uxui` | Design system, prototypes |
| `@devstarter-docs` | `@docs` | Technical writing, API docs |
| `@devstarter-mlops` | `@mlops` | ML pipelines, serving, drift |

### Extended (full profile only — `bash install.sh --profile full`)

**Domain specialists**: `@architect` `@datascience` `@sre` `@api` `@performance`

**Code reviewers**: `@code-reviewer` `@ts-reviewer` `@py-reviewer` `@go-reviewer` `@java-reviewer` `@csharp-reviewer` `@rust-reviewer` `@kotlin-reviewer` `@swift-reviewer` `@flutter-reviewer` `@cpp-reviewer` `@django-reviewer` `@fastapi-reviewer` `@fsharp-reviewer` `@mle-reviewer` `@laravel-reviewer`

**Build resolvers**: `@build-resolver` `@ts-build-resolver` `@go-build-resolver` `@java-build-resolver` `@rust-build-resolver` `@swift-build-resolver` `@flutter-build-resolver` `@dart-build-resolver` `@kotlin-build-resolver` `@django-build-resolver` `@pytorch-build-resolver` `@cpp-build-resolver`

**Specialists**: `@planner` `@tdd` `@refactor` `@explorer` `@simplifier` `@code-architect` `@db-reviewer` `@security-reviewer` `@a11y` `@network-architect` `@seo` `@silent-failure` `@type-analyzer` `@pr-analyzer` `@pr-test-analyzer` `@chief` `@doc-updater` `@docs-lookup` `@e2e-runner` `@harness-optimizer` `@loop-operator` `@hookify-rules` `@agent-auditor` `@rules-distiller` + network, healthcare, homelab, GAN harness, open-source pipeline agents

See `templates/agent-disambiguation.md` for when to use which agent.
See `templates/team-packs.md` for pre-built group configs (Web API, Full-stack, ML/AI, Incident Response, etc.).

## MCP Server Configs

29 ready-to-use MCP server configs in `templates/mcp/`. Activate with `/devstarter-mcp`.

Includes: GitHub, PostgreSQL, SQLite, MySQL, MongoDB, Redis, Brave Search, Puppeteer, Filesystem, Slack, Notion, Linear, Jira, Sentry, Datadog, AWS S3, Google Drive, Stripe, Twilio, and more.

## Language Rules

18 rule sets automatically loaded as context when working in those languages. Installed to `~/.claude/rules/`.

TypeScript · Python · Go · Rust · Java · C# · React · Flutter · Angular · Laravel · Kotlin · Swift · Dart · C++ · F# · Node.js · plus shared `common/` rules (security, performance, testing) and DevStarter contributor rules.

## Lifecycle Hooks (optional)

Install with `bash install.sh --hooks`. Requires Node.js 18+.

| Hook | When | What it does |
|------|------|-------------|
| `session-start.js` | Claude Code opens | Loads `memory/progress.json` + memory index |
| `pre-compact.js` | Context compaction | Logs event to `memory/compaction-log.txt` |
| `post-edit-accumulator.js` | After file edit/write | Tracks changed files for formatter |
| `stop-format-typecheck.js` | Claude stops responding | Runs formatter + type-checker on changed files |
| `stop-check-console-log.js` | Claude stops responding | Warns on leftover debug statements |

Hooks are self-contained (no external dependencies). Remove anytime: `bash ~/.claude/uninstall.sh --hooks-only`

## The 5-Gate Build Process

```
Gate 0: Setup          → GitHub repo, Notion board, branch strategy (auto)
Gate 1: Discovery      → Requirements, CLAUDE.md, BRD, SRS
Gate 2: Architecture   → DB schema, API design, security, UI prototype
Gate 3: Foundation     → Task breakdown, GitHub Issues, scaffold
Gate 4: Development    → Feature-by-feature with PR review per feature
Gate 5: Quality        → Testing, security audit, performance
```

Every gate requires explicit approval before proceeding.

## Release Flow

```
develop → DEV test → UAT branch → UAT test → main → Production

⛔ "DEV approved"    → proceed to SIT
⛔ "SIT approved"    → proceed to UAT
⛔ "UAT approved"    → proceed to Production
⛔ "DEPLOY v[X.Y.Z]" → deploy
```

## Usage Examples

```bash
# Build a new web app from scratch
> /devstarter-new
# Answer questions → Claude creates BRD, schema, API, prototype
# Approve each gate → builds feature by feature
# /devstarter-release when done

# Add a feature
> /devstarter-change add dark mode toggle

# Debug a bug
> /devstarter-debug the login redirect goes to wrong page

# Architecture advice (saves intake file for /devstarter-change)
> /devstarter-consult Redis vs RabbitMQ for job queues

# Multi-voice architecture decision
> /devstarter-council should we go monolith or microservices

# Review a PR or diff
> /devstarter-review

# Run full quality gate
> /devstarter-verification-loop

# Critical bug in production
> /devstarter-hotfix
```

## Works with Other AI Tools

DevStarter is built for Claude Code but the **SDLC content is AI-agnostic**. You can use any workflow with Copilot, Gemini, ChatGPT, Cursor, or any other AI.

Every skill file (`skills/devstarter-*/SKILL.md`) ends with a **🌐 Universal Prompt** block — copy it into your AI tool to start the workflow without Claude Code.

**Setup guide for non-Claude AI tools:** [`docs/multi-ai-guide.md`](docs/multi-ai-guide.md)

| Feature | Claude Code | Other AIs |
|---------|-------------|-----------|
| All 51 workflows | ✅ slash commands | ✅ Universal Prompt (copy-paste) |
| All 83 agents | ✅ `@agent-name` | ✅ paste agent file as context |
| Gate-based approvals | ✅ automatic | ✅ AI stops and waits |
| Hooks, MCP, slash commands | ✅ | ❌ Claude Code only |

## Requirements

- **Claude Code** (recommended) or any AI tool with file-context support
- Git
- GitHub CLI (`gh`) — for repo automation
- Node.js 18+ — required for lifecycle hooks (optional otherwise)
- Docker (optional) — for containerized workflows

## License

MIT — see [LICENSE](LICENSE)
