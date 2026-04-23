# Changelog

## v2.3.1 (2026-04-23)

### Publish Fix — Exclude docs/ and memory/ from Public Release

- **`scripts/publish.sh`** — added `EXCLUDE_FROM_RELEASE=("docs" "memory")` variable; release step now creates a `_release_clean` temp branch from `main`, strips excluded folders, and pushes that to the `release` remote — keeping local `main` intact with dev files while `dev-starter.git` stays clean
- **`scripts/publish.sh`** — removed `git pull release main` (release remote is write-only); local `main` is now merged from `develop` then pushed to `origin/main` independently
- **`docs/management-report.html`** — removed (dev-only document, not needed in repo)
- **`docs/release-v2.3.0.html`** — release notes for v2.3.0

---

## v2.3.0 (2026-04-23)

### Git Branch Strategy — 3-Branch Setup + Protection Rules

- **`sdlc/devstarter-github.md` — PROC-GH-01** — auto-creates 3 branches (`main`, `uat`, `develop`) on new project init; sets `develop` as the GitHub default branch via `gh repo edit --default-branch develop`
- **`sdlc/devstarter-github.md` — PROC-GH-10 Step 1** — standard branch protection for `main` + `uat`: `allow_force_pushes: false`, `allow_deletions: false`, `required_status_checks`, `required_pull_request_reviews` (1 approving review, dismiss stale reviews)
- **`sdlc/devstarter-github.md` — PROC-GH-10 Step 2** (NEW) — optional `develop` branch protection prompted after scaffold at Gate 3; recommended for teams ≥ 3; applies same protection payload as Step 1
- **`sdlc/devstarter-github.md` — PROC-GH-18** (NEW) — idempotent procedure to apply branch protection to existing repos; reads `main_branch` + `uat_branch` from `devstarter-config.yml`; checks branch exists before applying; wired into `/devstarter-existing` Phase 3.5 after PROC-GH-02
- **`sdlc/devstarter-starter-gates.md`** — Gate 0 output updated to show `✅ Branches: main → uat → develop (default ★)` and `✅ Default branch: develop`; Gate 3 completion wired to PROC-GH-10 Step 2 with status line `✅ develop branch: [protected | unprotected]`
- **`sdlc/devstarter-existing.md`** — Phase 3.5 Step 3 (GitHub path): runs PROC-GH-18 after PROC-GH-02; confirms `✅ Branch protection: main + uat — PR required, no force push, no deletion`
- **`templates/CLAUDE.md.template`** — Gate 0 section updated with 3-branch strategy table (main/uat/develop with protection status and flow)
- **`devstarter-config.yml`** — added `uat_branch: uat` field; `sync_branches` updated to `"main uat develop"`
- **`docs/git-workflow.md`** (NEW) — team handoff reference: Branch Overview table, Daily Dev Workflow (feature/* → PR), Head Dev PR review/merge commands, Release Flow (develop→uat→main), Hotfix Flow, Branch Protection Rules table, 7 Key Rules, Quick Reference block

---

## v2.2.0 (2026-04-23)

### Requirement Intake Templates + File-Arg Pattern

- **`templates/intake/devstarter-intake-new-project.md`** (NEW) — 8-section structured PRD template for new projects; covers Project Identity, Target Users, Core Features (MoSCoW), Technical Constraints, NFRs, Success Criteria, Constraints, and Out of Scope; includes INTAKE SUMMARY block for Claude to fill and present for approval before proceeding to Q0-VCS
- **`templates/intake/devstarter-intake-add-feature.md`** (NEW) — 5-section intake for new features; Feature Identity, User Story + Given/When/Then acceptance criteria, Technical Scope (UI/API/DB), Constraints & Boundaries, Priority & Effort; use with `/devstarter-change newfeature.md`
- **`templates/intake/devstarter-intake-modify-feature.md`** (NEW) — 5-section intake for modifying existing features; captures AS-IS vs TO-BE behavior, regression criteria, impact assessment (breaking change flag, UI/API/DB scope), Priority & Effort; use with `/devstarter-change change-login.md`
- **`templates/intake/devstarter-intake-fix-bug.md`** (NEW) — 5-section bug report template; Bug Identity (severity, environment), Reproduction steps, Expected vs Actual + error logs (with sanitize warning for secrets/PII), Context, Fix Acceptance Criteria; use with `/devstarter-change bug-login.md`
- **`sdlc/devstarter-starter-intake.md`** — `## SECTION 0` prepended: (1) file-arg check — if `.md`/`.txt` file passed, read it, extract requirements, show pre-filled INTAKE SUMMARY, wait for approval, go directly to Q0-VCS; (2) inline MODE 3 pre-fill path; (3) interactive section-by-section fallback; answer carry-forward skips Q1, Q2, Q6, Q7 after intake approval
- **`sdlc/devstarter-change-add.md`** — `## A-SECTION 0` prepended: file-arg check with type auto-detection from file content ("AS-IS"/"TO-BE"/"modify" → Modify Feature; "bug"/"error"/"fix"/"broken" → Bug Fix; else → Add Feature); interactive fallback reads matching template; A-PHASE 1 skipped after intake approval; answer carry-forward covers A-Q1 through A-Q8
- **`sdlc/devstarter-change-bug.md`** — `## C-SECTION 0` prepended: file-arg check reads bug report template; C-PHASE 1 skipped after intake approval; answer carry-forward covers C-Q1 through C-Q6
- **`commands/devstarter-new.md`** — File Arg Handling section added before Inline Args: detects `.md`/`.txt` path or file-on-disk arg, reads file, extracts requirements, skips mode-picker + SECTION 0, shows INTAKE SUMMARY for approval; fallback to inline text (MODE 3) if file not found
- **`commands/devstarter-change.md`** — File Arg Handling section added before Inline Args: reads file, auto-detects change type from content keywords, extracts requirements, skips A-SECTION 0 / C-SECTION 0, shows typed INTAKE SUMMARY for approval; fallback to inline text if file not found

---

## v2.1.0 (2026-04-22)

### Multi-VCS + Multi-PM Selection at Project Creation

- **`sdlc/devstarter-starter-intake.md`** — new Q0-VCS + Q0-PM questions added before Q1; user selects VCS (GitHub / GitLab / SVN / None) and PM tool (GitHub Issues / GitLab Issues / Notion / Jira / None) at the very start of every new project; PM auto-suggested based on VCS choice (GitHub → GitHub Issues, GitLab → GitLab Issues, SVN/None → None); answers written immediately to `devstarter-config.yml`
- **`templates/CLAUDE.md.template`** — removed hardcoded `github.com` repository URL and `Notion Board` fields; replaced with `{{REPOSITORY_URL}}`, `{{PM_BOARD_URL}}`, `{{VCS_TYPE}}`, `{{PM_TYPE}}` placeholders; Gate 0 now branches on `vcs.type` and `pm.type` (GitHub → `gh repo create`, GitLab → `glab project create`, SVN → SVN init, None → `git init`; PM setup routes to matching CLI/API per tool); `Notion ↔ GitHub Sync Rules` section renamed to `PM ↔ VCS Sync Rules` covering all PM/VCS combinations
- **`sdlc/devstarter-existing.md`** — Phase 3.5 Step 1 now asks Q0-VCS + Q0-PM when `devstarter-config.yml` does not exist or has placeholder values; Step 3 conditional on `vcs.type` and `pm.type` — routes to `devstarter-github.md`, `devstarter-gitlab.md`, or `devstarter-svn.md` for VCS, and to Notion / `gh` / `glab` / Jira for PM setup

---

## v2.0.1 (2026-04-20)

### Agent Slash Commands — Invoke Any Agent Directly

- **`commands/devstarter-ba.md`** through **`commands/devstarter-mlops.md`** — 13 new slash commands, one per agent; type `/devstarter-ba [task]` to invoke the BA agent directly without going through a workflow
- **`devstarter-menu.md`** — new AGENTS section listing all 13 agent commands for discoverability

---

## v2.0.0 (2026-04-20)

### Native Platform Integration — TaskCreate, AskUserQuestion, agents/custom/, Doctor + Review Commands

- **`sdlc/devstarter-checkpoint.md`** — new Section 1b: `TaskCreate`/`TaskUpdate` protocol alongside `progress.json`; creates one UI task per SDLC task for session visibility; `TaskUpdate(in_progress)` on start, `TaskUpdate(completed)` on finish; complements cross-session `progress.json` (not a replacement)
- **`sdlc/devstarter-change-add.md`** — Step A4.4: `TaskCreate` for each task after GitHub/Notion creation, stored task IDs used for `TaskUpdate` calls in A5.2; Step A5.2 steps 2 + 8: `TaskUpdate(in_progress)` / `TaskUpdate(completed)` per task
- **`sdlc/devstarter-existing.md`** — Phase 5: `TaskCreate` + `TaskUpdate(in_progress/completed)` alongside Notion/GitHub steps
- **`sdlc/devstarter-sprint.md`** — Phase 4: `TaskCreate` for each sprint item alongside GitHub/Notion creation
- **`sdlc/devstarter-change-add.md`** — `AskUserQuestion` at gates A1, A2, A3, A4 with approve/revise options; interactive gate prompts replace passive text blocks
- **`sdlc/devstarter-existing.md`** — `AskUserQuestion` at analysis confirm, Gate 1 (discovery), and work plan approval
- **`sdlc/devstarter-sprint.md`** — `AskUserQuestion` at Gate S1 sprint scope approval
- **`agents/custom/`** — new folder for user custom agents; preserved by `update.sh` (backup before overwrite, restore after); `install.sh` creates folder on fresh install; `README.md` documents naming convention and usage
- **`commands/devstarter-doctor.md` + `sdlc/devstarter-doctor.md`** — new `/devstarter-doctor` command (#21 in menu); health check for core files, 13+13 agents, 25 commands, key SDLC runbooks, config; outputs ✅/⚠️/❌ per category; Model: Haiku
- **`commands/devstarter-review.md` + `sdlc/devstarter-review.md`** — new `/devstarter-review` command (#22 in menu); 3 modes: PR `#N`, branch name, or current changes; parallel review by @techlead (architecture), @qa (testing), @security (OWASP); outputs 🔴 BLOCKER / 🟡 MAJOR / 🟢 MINOR + verdict; Model: Opus
- **Cleanup:** `agents/teams/` removed (5 files); `sdlc/devstarter-dod.md` merged into `devstarter-checkpoint.md`; `sdlc/devstarter-vcs-common.md` merged into `devstarter-github.md`
- **`setup.sh`** — Q0 name prompt → `devName` in USER.md Identity section; Q2b weak skills field; alias map normalisation (`js→javascript`, `node→node.js`, `azure→cloud`, etc.); `WEAK_LEVEL` auto-calculated one tier below default
- **`sdlc/` 15 runbooks** — Config Guard (`**Config:** Read devstarter-config.yml...`) prepended after `## Model:` header in: audit, autopr, consult, dependency, document, env, handover, incident, ml-workflow, monitor, onboarding, release, retrospective, rollback, sprint

---

## v1.9.0 (2026-04-20)

### Platform Features — Claude Code Native Tool Integration

- **`sdlc/devstarter-change-add.md`** — Step A5.2 now wraps each task's feature branch in `EnterWorktree`/`ExitWorktree` for isolated working copies; prevents dirty state between parallel tasks
- **`sdlc/devstarter-change-add.md`** — Gate A4 autopilot path now calls `PushNotification` before showing the approval prompt; users get a system notification when unattended development completes instead of having to watch the terminal
- **`sdlc/devstarter-consult.md`** — added Step 0: `EnterPlanMode` at consultation start, `ExitPlanMode` after advice delivered; signals to Claude Code that this session is analysis-only
- **`sdlc/devstarter-dependency.md`** — new Phase 1b WebSearch Enrichment step; after local audit, runs `WebSearch` for latest stable version, active CVE IDs (CVSS severity), and breaking changes for every 🔴 Vulnerable and 🟡 Outdated package found

---

## v1.8.1 (2026-04-20)

### Short Agent Aliases — Type @pm Instead of @devstarter-pm

- **`agents/pm.md`, `agents/techlead.md`, `agents/ba.md`, `agents/backend.md`, `agents/frontend.md`, `agents/dba.md`, `agents/qa.md`, `agents/security.md`, `agents/devops.md`, `agents/uxui.md`, `agents/docs.md`, `agents/mobile.md`, `agents/mlops.md`** — 13 thin alias files; each delegates immediately to the full `devstarter-*.md` spec so aliases stay maintenance-free; `install.sh` copies them automatically via existing `agents/*.md` glob
- **`CLAUDE.md`** — agent table updated with Short Alias column; alias file convention documented

---

## v1.8.0 (2026-04-10)

### Model Tier Mapping — Per-Command Model Selection

- **`devstarter-config.yml`** — new `model_management:` section; declares `haiku`, `sonnet`, and `opus` model IDs as the single source of truth; `command_tiers` map lists which commands belong to each tier (5 opus, 12 sonnet, 6 haiku); update model IDs here when Anthropic releases new versions
- **29 SDLC runbooks** — each workflow runbook now opens with a `## Model: [tier] (model-id)` header so users know which Claude model to switch to before running the command
  - **Opus** (5): `audit`, `hotfix`, `incident`, `migrate`, `consult` — deep reasoning, critical production decisions
  - **Sonnet** (19): `change`, `change-add/bug/remove/resume`, `existing`, `release`, `sprint`, `document`, `onboard`, `handover`, `retro`, `dependency`, `rollback`, `monitor`, `autopr`, `ml-workflow`, `ai-providers`, `starter`
  - **Haiku** (5): `env`, `secrets`, `checkpoint`, `config-sync`, `dod` — mechanical, lightweight tasks

---

## v1.7.0 (2026-04-08)

### Autopilot Mode — Extended to Existing + Change Flows

- **`sdlc/devstarter-existing.md`** — new Phase 4.5 autopilot prompt shown immediately after plan approval; `"autopilot"` sets `autopilot_mode=true` + task count in `progress.json`; Phase 5 executes all tasks unattended with silent cron resume; `"manual"` preserves original per-task flow
- **`sdlc/devstarter-change-add.md`** — autopilot prompt added after Gate A3 (GitHub issues + Notion tasks created); `"autopilot"` runs all A-PHASE 5 development tasks unattended; `autopilot_tasks_done` incremented per task; next human interaction is Gate A4 only
- **`sdlc/devstarter-checkpoint.md`** — expanded workflow list to all 7 SDLC runbooks with correct `devstarter-` prefixes; added explicit rule: autopilot resume logic (`paused_limit` → silent, `in_progress` → silent, `waiting_approval` → always wait) applies to **all** workflows, not only `devstarter-starter-gates`

---

## v1.6.1 (2026-04-08)

### Config Auto-Sync — devstarter-config.yml → .project.env

- **`scripts/config-sync.sh`** — new bash script; reads `devstarter-config.yml` and regenerates `.project.env` with all sections; run manually with `bash scripts/config-sync.sh`
- **`scripts/devstarter-config-hook.sh`** — Claude Code `PostToolUse` hook wrapper; detects edits to `devstarter-config.yml` and triggers `config-sync.sh` automatically
- **`.claude/settings.json`** — new project-level Claude Code settings; registers the config-sync hook on `Edit`/`Write` tool use
- **`devstarter-config.yml`** — updated: `pm.type` → `github-issues`, `skill_level` → `expert`, `version` → `1.6.1`
- **`.project.env`** — now fully regenerated by `config-sync.sh`; Notion fields omitted when PM is not `notion`

---

## v1.6.0 (2026-04-08)

### Mandatory devstarter-config.yml — Every Project Must Have One

- **`sdlc/devstarter-starter-gates.md`** — Gate 0 now generates `devstarter-config.yml` from template + syncs `.project.env`; config file is created before any Gate 1 work begins
- **`sdlc/devstarter-existing.md`** — Phase 3.5 promoted to a hard stop: `devstarter-config.yml` must exist on disk before proceeding to work plan; handles both create and update cases
- **`agents/shared/devstarter-agent-base.md`** — new `Config Guard` rule: every agent checks for `devstarter-config.yml` on session start and blocks until it exists
- **`sdlc/devstarter-starter.md`** — Rule 2 "read from disk" now includes `devstarter-config.yml` in the required file list
- **`update.sh`** — post-update check: warns user if current project is missing `devstarter-config.yml` and directs them to `/devstarter-existing`

---

## v1.5.0 (2026-04-08)

### Token Optimization — Leaner Commands, Agents & VCS Runbooks

- **Command routing registry** (`commands/devstarter-registry.md`) — single lookup table for all 24 commands; 16 thin routing files collapsed from 4 lines → 2 lines each
- **Agent boilerplate extracted** — `Progress Reporting` + `Shared Protocols` sections stripped from all 13 agent files into `agents/shared/devstarter-agent-base.md`; net −351 lines across agents
- **VCS common conventions** (`sdlc/devstarter-vcs-common.md`) — branch naming, commit format, .gitignore, labels, semver, and conflict resolution shared across github/gitlab/svn runbooks

### Centralized Config — devstarter-config.yml

- **`devstarter-config.yml`** — new primary config file at project root; replaces `.project.env` as the source of truth
- **`templates/devstarter-config.template.yml`** — full template with all options documented (GitHub/GitLab/SVN, all PM tools, CI, secrets, AI provider)
- **`sdlc/devstarter-config-sync.md`** — Python sync script to auto-generate `.project.env` from `devstarter-config.yml` for bash compatibility
- All 15 SDLC runbooks updated to read `devstarter-config.yml` for project settings

### Proactive Rate-Limit Pause

- **`devstarter-checkpoint.md`** — new `1b. Limit Check` protocol: before each new task, check `tasks_this_session` (≥8) and `files_read_this_session` (≥20) counters
- **`devstarter-agent-base.md`** — `Proactive Rate-Limit Check` section: finish current task → save `paused_limit` → stop → cron auto-resumes with reset counters
- New `paused_limit` status in progress.json: voluntary clean pause, safer than mid-task crash

### Autopilot Mode — Unattended Gate 4 Development

- **`devstarter-starter-gates.md`** — after Gate 3 approval, shows sprint/task summary and offers `"autopilot"` / `"manual"` choice
- `"autopilot"` → runs ALL Gate 4 tasks end-to-end with no user interaction; rate-limit pauses auto-resume via cron; next human interaction is Gate 5 only
- **`devstarter-checkpoint.md`** — `paused_limit` + `autopilot_mode: true` resumes silently; `in_progress` + autopilot also skips resume prompt
- **`devstarter-agent-base.md`** — new `## Autopilot Mode` section: no per-task announcements, silent blocker handling, counter updates, Gate 5 callout on completion

---

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
