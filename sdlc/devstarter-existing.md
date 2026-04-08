# dev-existing.md — Existing Project Onboarding

## Instructions for Claude Code

This workflow is for projects that already have code.
Follow these phases in order. Do NOT skip any phase.

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## ⚠️ CRITICAL RULES (same as all workflows)

### Rule 0 — Checkpoint & Auto-Resume (ALWAYS active)

Read `~/.claude/sdlc/devstarter-checkpoint.md` and follow the protocol:
1. **At start** — Setup Cron auto-resume (every 10 minutes)
2. **After every task** — Save checkpoint to `memory/progress.json`
3. **At end** — Cleanup (update status to completed, delete Cron)

### Rule 1 — Hard Approval Gates
STOP at every gate. Show output. Wait for explicit "approve" or "revise [notes]".
Do NOT continue until user approves.

### Rule 2 — Always Read From Files, Never From Context
When resuming: read from disk first, never rely on chat history.
Announce what you read before doing any work:
```
📂 Reading from disk:
- memory/progress.json ✓
- CLAUDE.md ✓ (or "not found")
- docs/[relevant].html ✓ (or "not found")
```

### Rule 3 — Read Agent File Before Doing Any Work

Before any agent produces output, you MUST read that agent's file first.
The agent file defines the format, template, standards, and quality gate for every deliverable.

```
Agent          File to read first
──────         ─────────────────────────────
BA          → ~/.claude/agents/devstarter-ba.md
Tech Lead   → ~/.claude/agents/devstarter-techlead.md
DBA         → ~/.claude/agents/devstarter-dba.md
Backend     → ~/.claude/agents/devstarter-backend.md
Security    → ~/.claude/agents/devstarter-security.md
DevOps      → ~/.claude/agents/devstarter-devops.md
QA          → ~/.claude/agents/devstarter-qa.md
UX/UI       → ~/.claude/agents/devstarter-uxui.md
PM          → ~/.claude/agents/devstarter-pm.md
Frontend    → ~/.claude/agents/devstarter-frontend.md
Mobile      → ~/.claude/agents/devstarter-mobile.md
Docs        → ~/.claude/agents/devstarter-docs.md
```

Before every agent task, announce:
```
🤖 Acting as [agent name]
📖 Reading agent spec: ~/.claude/agents/[agent].md ✓
📄 Output format: [format from agent file]
📋 Producing: [deliverable name]
```

**If you skip reading the agent file, the output will be rejected.**

### Rule 4 — Save Before Handing Off
Write file → git commit → update memory/progress.json → then announce handoff.

### Rule 5 — Notion Task Status MUST Be Updated
**Before starting any task:** PROC-NT-04 → Status: "In Progress"
**After creating PR:** PROC-NT-05 → Status: "In Review"
**After PR merged:** PROC-NT-06 → Status: "Done"
Never skip status updates. Each task MUST go through: To Do → In Progress → In Review → Done.

### Rule 6 — Continuous Development After Doc Approval
After all documents are approved, develop ALL tasks continuously without stopping for per-task approval. Only show the final approval gate after ALL tasks are complete.

### Rule 7 — Parallel Tracks When Possible
Group tasks into parallel tracks by independence:
- **Track A (Backend):** DB + API tasks → @devstarter-dba, @devstarter-backend
- **Track B (Frontend):** UI + component tasks → @devstarter-frontend, @devstarter-uxui
- **Track C (Infra):** DevOps + security tasks → @devstarter-devops, @devstarter-security
Tasks within a track run in dependency order.
Tracks run in parallel when they have no cross-dependencies.
If Track B depends on Track A output (e.g. API response shape), complete Track A first.

### Rule 8 — Document Standards (MANDATORY)
- **docs/index.html** — MUST be copied from `~/.claude/templates/docs/index.html` template.
  Do NOT create from scratch. Replace `{{PROJECT_NAME}}` with actual project name.
- **docs/prototype/components.html** — MUST be real rendered HTML with Tailwind CSS.
  Must include ALL 8 sections (Typography, Colors, Buttons, Forms, Data Display, Navigation, Feedback, Layout).
  Follow the MANDATORY HTML examples in `~/.claude/agents/devstarter-uxui.md`.
  NEVER output text descriptions — always output actual rendered HTML components.
- All docs MUST use `~/.claude/templates/docs/document-template.html` as the base template.

### Rule 9 — Ask ONE Question at a Time
**NEVER ask multiple questions in one message.**
Ask Q1 → wait for answer → ask Q2 → wait for answer → ...

---

## ⚡ FIRST ACTION — Show This Before Anything Else

**If no inline args were provided, the very first message to the user MUST be:**

```
What do you want to do with this project?

  1. 🔍 Onboard       — understand this codebase first
  2. ➕ Add / fix      — add a feature or fix a bug (describe it)
  3. ♻️  Refactor      — improve code quality / structure
  4. 🔒 Security      — security review + fixes
  5. 📋 Full setup    — generate all missing docs + GitHub + Notion

Or just describe it: "add user management", "fix login bug", "improve test coverage"
```

Wait for the user to type 1–5 or a description. Nothing else before this.

**Auto-detect (skip asking):**
- Q1 (project name) → use current folder name
- Q3 (CLAUDE.md exists?) → check disk silently: `ls CLAUDE.md`
- Q4 (existing docs?) → check disk silently: `ls docs/`
- Q5 (tech stack?) → scan package.json / *.csproj / go.mod / pyproject.toml silently

Only ask Q6 (known issues) after showing the discovery report.

**Special case — inline args:** If the user ran `/devstarter-existing [text]`,
skip this prompt. Treat text as intent (Q2), auto-detect everything else.

---

## PHASE 1 — Project Discovery

Ask these questions ONE AT A TIME:

**Q1. What is the project name?**
(auto-detected from folder name — only ask if detection is ambiguous)

---

**Q2. What do you want to do with this project?**
(select all that apply — or was answered via quick-picker / inline args)
1. Add new features
2. Fix bugs
3. Improve code quality / refactoring
4. Add or improve tests
5. Improve security
6. Improve performance
7. Add or update documentation
8. Onboard — I just want the agent to understand the codebase first
9. Other (specify)

---

**Q3–Q5 — Auto-detected from disk (do NOT ask):**
- Q3: CLAUDE.md exists? → check `CLAUDE.md` on disk
- Q4: Existing docs? → check `docs/` folder on disk
- Q5: Tech stack? → scan config files (package.json, *.csproj, go.mod, pyproject.toml, requirements.txt)

Report what was found in the discovery report. Only ask if detection fails.

---

**Q6. Are there any known issues or pain points?**
(free text — or type "none")

---

## PHASE 2 — Codebase Analysis

After collecting answers, the Tech Lead agent reads the codebase:

### If CLAUDE.md exists
```
📂 Reading CLAUDE.md from disk...
📂 Reading memory/progress.json (if exists)...
📂 Reading docs/ folder (if exists)...
```
Resume from last checkpoint if progress.json exists.

### If CLAUDE.md does NOT exist
Tech Lead performs codebase scan:

**Step 2.1 — Project Structure**
1. Read folder structure (max 3 levels deep)
2. Read key config files (package.json, *.csproj, pyproject.toml, go.mod, etc.)
3. Read entry points (Program.cs, main.ts, app.py, main.go, etc.)
4. Read existing README if present

**Step 2.2 — Stack Detection**
5. Identify: language, framework, database, ORM, auth method
6. Detect package manager (npm, yarn, pnpm, pip, dotnet, go mod)
7. Detect test framework (jest, pytest, xunit, go test, etc.)

**Step 2.3 — API & Route Scan** (if backend/API project)
8. Scan all route definitions — list every endpoint (method + path)
9. Scan middleware (auth, validation, logging, CORS, rate limit)
10. Scan database models/entities — list all tables/collections
11. Scan existing migrations
12. Read Swagger/OpenAPI spec if exists

**Step 2.4 — Feature Detection**
13. Group endpoints into feature domains (e.g. auth, users, products, orders)
14. Identify shared services, utilities, and common patterns

Then write a discovery report and show it:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CODEBASE DISCOVERY REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Language:    [detected]
Framework:   [detected]
Database:    [detected]
ORM:         [detected]
Auth:        [detected]
Test:        [detected framework + estimated coverage]

API Endpoints found: [N] total
  📁 auth/
    POST /api/auth/login
    POST /api/auth/register
    POST /api/auth/refresh
  📁 users/
    GET  /api/users
    GET  /api/users/:id
    PUT  /api/users/:id
  📁 [domain]/
    [method] [path]
    ...

Middleware:
  ✅ Auth middleware — [JWT / session / API key]
  ✅ CORS — [configured / not found]
  ✅ Rate limiting — [yes / no]
  ✅ Validation — [library or "manual"]
  ✅ Error handling — [centralized / per-route]

Database Models: [N] tables
  - users (id, email, password, role, created_at, ...)
  - [table] ([key columns])
  - ...

Existing docs:  [list or "none"]
Known issues:   [from Q6 or "none reported"]

Is this analysis correct?
  "yes"            → generate CLAUDE.md and continue
  "revise [notes]" → correct the analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ STOP — wait for user to confirm analysis before proceeding.

---

## PHASE 3 — CLAUDE.md Generation (if not exists)

After discovery is approved:
1. BA agent generates CLAUDE.md based on discovered stack + user answers
2. BA agent generates missing docs (brd.html, schema.html, api.html) based on codebase
3. Show GATE 1 approval message

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 1 APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate: 1 — Discovery Complete
Completed by: BA Agent + Tech Lead

Output produced:
  📄 CLAUDE.md         — project spec (generated from codebase)
  📄 docs/brd.html     — reverse-engineered requirements
  📄 docs/schema.html  — current database schema
  📄 docs/api.html     — current API endpoints

Please review. Are these accurate?

  "approve"        → proceed to planned work
  "revise [notes]" → correct any inaccuracies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3.5 — Config + GitHub + Notion Setup (after Gate 1 approved)

After Gate 1 approved, before showing work plan:

### Step 1 — devstarter-config.yml (MANDATORY)

Check if `devstarter-config.yml` exists:
- **Does NOT exist** → generate it from `~/.claude/templates/devstarter-config.template.yml`
  - Fill in: `project.name`, `project.type`, `project.language` from discovery
  - Fill in: `vcs.type`, `vcs.repo`, `vcs.branch_strategy`, `vcs.main_branch`, `vcs.dev_branch`
  - Fill in: `pm.type` (and pm-specific fields), `ci.type`, `ai.provider`
  - Fill in: `team.skill_level`, `team.size` from USER.md if available
  - Fill in: `stack.frontend`, `stack.backend`, `stack.database` from stack detection
- **Already exists** → read it; update any fields that differ from what was discovered

⛔ Do NOT proceed past this step until `devstarter-config.yml` exists on disk.

### Step 2 — Sync to .project.env

Run: `python3 sdlc/devstarter-config-sync.md` → auto-generates `.project.env` for bash compat.

### Step 3 — GitHub + Notion

1. Read `~/.claude/sdlc/devstarter-github.md` → follow PROC-GH-02 (connect existing repo)
2. Read `~/.claude/sdlc/devstarter-notion.md` → follow PROC-NT-01 + PROC-NT-02 (create task board)

Show:
```
✅ devstarter-config.yml — created / updated
✅ .project.env — synced from config
✅ GitHub: [repo URL]
✅ Notion: [board URL] — Task Board ready
→ Proceeding to work plan...
```

---

## PHASE 4 — Plan Approved Work

After Gate 1 approved, Tech Lead shows the work plan based on Q2 answers:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 WORK PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Based on your request: [Q2 answers]

Planned tasks:
  [ ] [task 1] — [agent responsible]
  [ ] [task 2] — [agent responsible]
  [ ] [task 3] — [agent responsible]

Estimated gates:
  Gate 1 ✅ Discovery (complete)
  Gate 2 — [description]
  Gate 3 — [description]

  "approve"        → start working on task 1
  "revise [notes]" → adjust the plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ STOP — wait for plan approval before starting any work.

---

## PHASE 4.5 — Autopilot Prompt (show immediately after plan approval)

Count total tasks from the work plan, then show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 READY TO DEVELOP — [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tasks:  [N]   Tracks:  Backend · Frontend · Infra (parallel)

Next stop after development: Final Gate — Delivery Review

  "autopilot"  → execute all tasks unattended
                 rate-limit pauses auto-resume via cron
                 you will be called back only at the final gate

  "manual"     → step-by-step with per-task approvals
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

When user types "autopilot":
1. Write to progress.json:
   ```json
   "autopilot_mode": true,
   "autopilot_total_tasks": [N],
   "autopilot_tasks_done": 0
   ```
2. Announce: "🤖 Autopilot ON — executing [N] tasks. Come back at the final gate."
3. Proceed to Phase 5 — execute ALL tasks without stopping

When user types "manual":
1. Write to progress.json: `"autopilot_mode": false`
2. Proceed to Phase 5 with normal per-task flow

⚠️ AUTOPILOT in Phase 5: If `autopilot_mode=true` — no announcements between tasks,
no per-task stops, silent blocker handling (fix and continue), silent cron resume.
Next human interaction: final delivery gate only.

---

## PHASE 5 — Execute with Gates

Follow the same Gate structure as new projects.
For each task:

1. PM → read `~/.claude/devstarter-notion.md` → PROC-NT-03: create Notion task
2. DevOps → read `~/.claude/devstarter-github.md` → PROC-GH-05: create GitHub issue
3. Start work → PROC-GH-06: feature branch, PROC-NT-04: status → In Progress
4. Complete → PROC-GH-07: PR, PROC-NT-05: status → In Review
5. Approved → PROC-GH-08: merge, PROC-NT-06: status → Done
- Gate per feature: approve before next feature
- Revision Protocol: impact analysis before any change
- Change Impact Map: same cascade rules apply
- Document-first: always read from docs/ before coding

Refer to `dev-starter.md` sections:
- ⚠️ Gate Approval Rules
- ⚠️ Revision Protocol
- 📋 Change Impact Reference Map

---

## Progress Tracker Template

```
## Last Checkpoint
Status:        [IN PROGRESS / BLOCKED / WAITING APPROVAL]
Gate:          [current gate]
Last completed: [what was just done]
Next action:   [what to do next]
Files modified: [list]
```

## Resume Instructions
1. Read memory/progress.json first
2. Read CLAUDE.md from disk
3. Announce: "📂 Resuming — Gate [N], reading from [filename]"
4. Continue from "Next action" — never skip gate approvals
5. Run /compact when context gets long
