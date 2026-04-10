# OPERATION A — ADD FEATURE

## Model: Sonnet (`claude-sonnet-4-6`)

---

## A-PHASE 1 — Feature Specification

Ask these questions ONE AT A TIME:

**A-Q1. What is the feature name?**
(free text — short name, e.g. "PDF Export", "Dark Mode", "Bulk Import")

---

**A-Q2. What problem does this feature solve?**
(free text — describe the business need or user pain point)

---

**A-Q3. Who will use this feature?**
(free text — which user role(s): Admin / Manager / User / All)

---

**A-Q4. Does this feature require new database tables or fields?**
1. Yes — new tables needed
2. Yes — new fields on existing tables only
3. No — uses existing data only
4. Not sure yet

---

**A-Q5. Does this feature require new API endpoints?**
1. Yes — new endpoints needed
2. Yes — modifying existing endpoints only
3. No — frontend only
4. Not sure yet

---

**A-Q6. Does this feature require new UI screens or components?**
1. Yes — new screens needed
2. Yes — modifying existing screens only
3. No — backend/API only
4. Not sure yet

---

**A-Q7. What is the priority?**
1. Critical — blocks other work
2. High — needed this sprint
3. Medium — next sprint
4. Low — nice to have

---

**A-Q8. What is the estimated effort?**
1. S — small (1–2 days)
2. M — medium (3–5 days)
3. L — large (1–2 weeks)
4. XL — extra large (needs breaking into sub-features)

---

## A-PHASE 2 — Impact Analysis

Before touching any file, run impact analysis:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 FEATURE IMPACT ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature:  [feature name]
Context:  [New / Existing / Live / Migration]

Documents that MUST be updated:
  📄 CLAUDE.md          — add to Features list + Progress Tracker
  📄 docs/brd.html      — add user stories + acceptance criteria
  📄 docs/database-design.html   — [yes/skip — based on A-Q4]
  📄 docs/api-reference.html      — [yes/skip — based on A-Q5]
  📄 docs/prototype/index.html     — [yes/skip — based on A-Q6]
  📄 docs/security-design.html — [yes if new data or auth scope]

Code that will be created/modified:
  📁 backend/  — [list affected files or "new handler + endpoint"]
  📁 frontend/ — [list affected files or "new component + route"]

New tasks to create:
  GitHub Issues: [N] new issues
  Notion tasks:  [N] new tasks

Estimated impact: [Low / Medium / High]
Sprint:           [current / next]

  "approve"        → proceed to document updates
  "revise [notes]" → adjust scope before proceeding
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE A1 — wait for approval before touching any file.

---

## A-PHASE 3 — Document Updates (upstream → downstream)

Update documents in this order. After each update, announce:
```
✅ Updated: [filename]
   Added: [what was added]
   Next: [next document]
```

**⚠️ REVISION HISTORY RULE (MANDATORY):**
Every Gate 1 document that is modified MUST have a Revision History table appended/updated at the bottom of the document. Add a row for each change:

```html
<!-- Revision History — append at bottom of document, before </main> -->
<div class="section-header" id="revision-history">
  <span class="section-number s10">R</span>
  <h2 class="section-title">Revision History</h2>
</div>
<table>
  <thead>
    <tr><th>CR ID</th><th>Date</th><th>Type</th><th>Description</th><th>Author</th></tr>
  </thead>
  <tbody>
    <tr>
      <td>CR-[YYYY-MM-DD]-[NNN]</td>
      <td>[YYYY-MM-DD]</td>
      <td>ADD / REMOVE / UPDATE</td>
      <td>[what was added, changed, or removed in this document]</td>
      <td>@[agent]</td>
    </tr>
  </tbody>
</table>
```

If the document already has a Revision History section, append the new row to the existing table (newest first). If not, create the section.

### Step A3.1 — Update CLAUDE.md
- Add feature to Features list: `- [ ] [Feature Name]`
- Add tasks to Progress Tracker under Gate 4

### Step A3.2 — Update docs/brd.html
Read current file from disk, then add:
- New user story with Given-When-Then acceptance criteria
- New business rules if applicable
- Update scope section
- **Add Revision History row:** CR ID, date, type=ADD, description of stories added

### Step A3.3 — Update docs/database-design.html (if A-Q4 = 1 or 2)
Read current file from disk, then add:
- New table definition with columns, types, constraints
- Updated ERD diagram
- Migration script outline
- **Add Revision History row:** CR ID, date, type=ADD, description of schema changes

### Step A3.4 — Update docs/api-reference.html (if A-Q5 = 1 or 2)
Read current file from disk, then add:
- New endpoint definitions (method, path, request, response, errors)
- Updated authentication requirements
- **Add Revision History row:** CR ID, date, type=ADD, description of endpoints added

### Step A3.5 — Update docs/prototype/index.html (if A-Q6 = 1 or 2)
Read current file from disk, then add:
- New screen wireframes or component specs
- Updated navigation flow
- **Add Revision History row:** CR ID, date, type=ADD, description of screens added

### Step A3.6 — Update docs/security-design.html (if new data or auth scope)
Read current file from disk, then add:
- Security considerations for new feature
- Updated OWASP checklist items if applicable
- **Add Revision History row:** CR ID, date, type=ADD, description of security rules added

After all docs updated, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE A2 — DOCUMENT APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: [feature name]

Documents updated:
  ✏️ CLAUDE.md         — feature added to tracker
  ✏️ docs/brd.html     — [N] new user stories added
  ✏️ docs/database-design.html  — [or "no changes needed"]
  ✏️ docs/api-reference.html     — [or "no changes needed"]
  ✏️ docs/prototype/index.html    — [or "no changes needed"]
  ✏️ docs/security-design.html — [or "no changes needed"]

Please review all updated documents.

  "approve"        → create tasks + start development
  "revise [notes]" → update documents first
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE A2 — wait for approval before creating tasks or writing code.

### Step A3.7 — Update docs/changerequest-log.html

After Gate A2 approved, Docs agent writes/updates `docs/changerequest-log.html`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 CHANGE REQUEST LOG ENTRY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          CR-[YYYY-MM-DD]-[NNN]
Date:        [YYYY-MM-DD]
Type:        ADD FEATURE
Priority:    [Critical / High / Medium / Low]
Effort:      [S / M / L / XL]
Requester:   [user or "internal"]
Context:     [New / Existing / Live / Migration]

Feature Name:
  [feature name]

Problem / Business Need:
  [from A-Q2 — why this feature is needed]

Target Users:
  [from A-Q3 — who uses this feature]

Impact Summary:
  Database:    [new tables/fields or "no change"]
  API:         [new/modified endpoints or "no change"]
  UI:          [new/modified screens or "no change"]
  Security:    [new rules or "no change"]

Documents Updated:
  - [doc 1] — [what changed]
  - [doc 2] — [what changed]

Status:      [In Progress / Completed / Rolled Back]
GitHub Issue: #[N]
GitHub PR:    #[N]
Notion Task:  [task URL]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If `docs/changerequest-log.html` does not exist yet, create it with this entry using `~/.claude/templates/docs/document-template.html` as the base template.
If it exists, append the new entry at the top (newest first).

---

## A-PHASE 4 — Task Breakdown + GitHub + Notion

After Gate A2 approved:

### Step A4.1 — Break into tasks

PM agent reads updated docs and breaks feature into tasks:

```
Epic: [Feature Name]

Tasks:
  [ ] [task 1] — @[role] — Effort: [S/M/L] — Gate: 4
  [ ] [task 2] — @[role] — Effort: [S/M/L] — Gate: 4
  [ ] [task 3] — @[role] — Effort: [S/M/L] — Gate: 4

Dependencies:
  [task 2] depends on [task 1]
```

Show task list:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE A3 — TASK LIST APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  "approve"            → create GitHub issues + Notion tasks
  "revise [notes]"     → adjust tasks before creating
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE A3 — wait for approval.

### Step A4.2 — Create GitHub Issues
Read `~/.claude/devstarter-github.md` → follow PROC-GH-05 for each task.

### Step A4.3 — Create Notion Tasks
Read `~/.claude/devstarter-notion.md` → follow PROC-NT-03 for each task.

Show summary:
```
✅ [N] GitHub issues created
✅ [N] Notion tasks created (Status: To Do)
→ Ready to start development
```

── AUTOPILOT PROMPT (show immediately after tasks created) ──────────────

Count total tasks from the Notion task list, then show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 READY TO DEVELOP — [Feature Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tasks:  [N]   Tracks:  Backend · Frontend · Infra (parallel)

Next stop after development: Gate A4 — Feature Approval

  "autopilot"  → develop all tasks unattended
                 rate-limit pauses auto-resume via cron
                 you will be called back only at Gate A4

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
2. Announce: "🤖 Autopilot ON — developing [N] tasks. Come back at Gate A4."
3. Proceed to A-PHASE 5 — develop ALL tasks without stopping

When user types "manual":
1. Write to progress.json: `"autopilot_mode": false`
2. Proceed to A-PHASE 5 with normal per-task flow

⚠️ AUTOPILOT in A-PHASE 5: If `autopilot_mode=true` — no announcements between tasks,
no per-task stops, silent blocker handling (fix and continue), silent cron resume.
Increment `autopilot_tasks_done` by 1 after each task.
Next human interaction: Gate A4 only.

---

## A-PHASE 5 — Development (Continuous + Parallel)

### Step A5.1 — Organize Parallel Tracks

Group tasks into tracks based on dependencies:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 DEVELOPMENT TRACKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Track A (Backend):  [list backend/dba tasks in order]
Track B (Frontend): [list frontend/uxui tasks in order]
Track C (Infra):    [list devops/security tasks — if any]

Parallel plan:
  [Track A] ──────────→  (if no cross-dependency)
  [Track B] ──────────→  (runs at same time)
  — OR —
  [Track A] ────→ then [Track B] (if B depends on A)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step A5.2 — Develop ALL Tasks Continuously

For **each track** (parallel when independent, sequential when dependent):

For **each task** within a track:

1. **NOTION → In Progress:** Read `~/.claude/devstarter-notion.md` → PROC-NT-04: status → In Progress ⚠️ MANDATORY
2. Read `~/.claude/devstarter-github.md` → PROC-GH-06: create feature branch
3. Agent reads relevant docs from disk before coding:
   - @devstarter-backend → docs/api-reference.html + docs/database-design.html
   - @devstarter-frontend → docs/prototype/index.html + docs/brd.html
   - @devstarter-dba → docs/database-design.html
4. Implement code
5. Read `~/.claude/devstarter-github.md` → PROC-GH-07: create PR
6. **NOTION → In Review:** Read `~/.claude/devstarter-notion.md` → PROC-NT-05: status → In Review ⚠️ MANDATORY
7. Announce progress and **continue to next task immediately** — do NOT wait for approval:
   ```
   ✅ Task [N/total]: [task name]
      Branch: [branch]  |  PR: #[N]
      Notion: In Review ✓
   → Continuing to next task...
   ```

**⚠️ DO NOT stop between tasks.** Continue developing until ALL tasks are complete.

### Step A5.3 — Final Review (all tasks complete)

After ALL tasks are developed:

PR REVIEW — review ALL PRs together:
   - Architecture (@devstarter-techlead): fits existing design? over-engineered?
   - Code Quality (@devstarter-backend/@devstarter-frontend): error handling, all states?
   - Security (@devstarter-security): input validation, auth, OWASP?
   - Performance: N+1 queries? re-renders? bundle size?
   - Testing (@devstarter-qa): unit + integration + E2E coverage?
   - Docs (@devstarter-docs): new endpoints documented? changelog?
   Severity: 🔴 BLOCKER | 🟡 MAJOR | 🟢 MINOR
   → If 🔴 BLOCKER → fix before showing approval gate
   → If 🟡 MAJOR → list in summary, recommend fix

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE A4 — FEATURE APPROVAL (ALL TASKS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: [feature name]
Tasks completed: [N/N]

PRs:
  #[N] — [task 1 name] — [branch]
  #[N] — [task 2 name] — [branch]
  #[N] — [task 3 name] — [branch]

Review findings:
  🔴 Blockers: [N — all fixed before this gate]
  🟡 Major:    [N — listed below with recommendations]
  🟢 Minor:    [N — non-blocking suggestions]

  "approve"        → merge ALL PRs + mark ALL Done in Notion
  "revise [notes]" → fix issues and re-submit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After approval:
- For EACH task:
  - PROC-GH-08: merge PR + close issue
  - PROC-NT-06: mark task → Done ⚠️ MANDATORY
- Update CLAUDE.md: tick feature checkbox ✅

---

---
