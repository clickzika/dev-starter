# dev-existing.md — Existing Project Onboarding

## Instructions for Claude Code

This workflow is for projects that already have code.
Follow these phases in order. Do NOT skip any phase.

---

## ⚠️ CRITICAL RULES (same as all workflows)

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

### Rule 3 — Save Before Handing Off
Write file → git commit → update memory/progress.json → then announce handoff.

---

## PHASE 1 — Project Discovery

Ask these questions ONE AT A TIME:

**Q1. What is the project name?**
(free text)

---

**Q2. What do you want to do with this project?**
(select all that apply)
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

**Q3. Is there an existing CLAUDE.md or spec document in this project?**
1. Yes — CLAUDE.md exists in the project root
2. Yes — spec exists but in a different format (Word, Notion, etc.)
3. No — no spec document exists
4. Not sure

---

**Q4. Is there existing documentation?**
(select all that apply)
1. docs/ folder with HTML documents
2. README.md
3. Notion / Confluence pages
4. Swagger / OpenAPI spec
5. Inline code comments only
6. No documentation at all

---

**Q5. What is the current tech stack?**
(free text — describe what you know: language, framework, database, etc.)

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

1. Read folder structure (max 3 levels deep)
2. Read key config files (package.json, *.csproj, pyproject.toml, go.mod, etc.)
3. Read entry points (Program.cs, main.ts, app.py, main.go, etc.)
4. Read existing README if present
5. Identify: language, framework, database, auth method, main features

Then write a discovery report and show it:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CODEBASE DISCOVERY REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Language:    [detected]
Framework:   [detected]
Database:    [detected]
Auth:        [detected]
Main features found:
  - [feature 1]
  - [feature 2]

Existing docs:  [list or "none"]
Test coverage:  [estimated or "unknown"]
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

## PHASE 3.5 — GitHub + Notion Setup (after Gate 1 approved)

After Gate 1 approved, before showing work plan:

1. Read `~/.claude/dev-github.md` → follow PROC-GH-02 (connect existing repo)
2. Read `~/.claude/dev-notion.md` → follow PROC-NT-01 + PROC-NT-02 (create task board)
3. Save `.project.env` with NOTION_DATABASE_ID and GITHUB_REPO

Show:
```
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

## PHASE 5 — Execute with Gates

Follow the same Gate structure as new projects.
For each task:

1. PM → read `~/.claude/dev-notion.md` → PROC-NT-03: create Notion task
2. DevOps → read `~/.claude/dev-github.md` → PROC-GH-05: create GitHub issue
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
