# dev-change.md — Change Management Workflow

## How to Use

Place at `~/.claude/dev-change.md`

Use when a project already exists and you need to:
- Add a new feature
- Remove an existing feature
- Fix a bug

```
claude
> Read ~/.claude/dev-change.md and help me make a change
```

---

## ⚠️ CRITICAL RULES

### Rule 1 — Hard Approval Gates
STOP at every gate. Show output. Wait for "approve" or "revise [notes]".
Never proceed without explicit approval.

### Rule 2 — Always Read From Files First
Before doing anything:
```
📂 Reading from disk:
- CLAUDE.md ✓
- memory/progress.json ✓
- docs/[relevant].html ✓
```
Never rely on chat history.

### Rule 3 — Save Before Handing Off
Write file → git commit → update memory/progress.json → announce handoff.

### Rule 4 — Docs Before Code
Always update documents before writing any code.
Order: CLAUDE.md → BRD → Schema → API → UX → Security → Code

---

## PHASE 1 — Identify Change Type

Ask these questions ONE AT A TIME:

**Q1. What type of change do you want to make?**
1. Add a new feature
2. Remove an existing feature
3. Fix a bug

---

**Q2. What is the project context?**
1. New project — feature not yet started, still in Gate 1–2
2. Existing project — project is in active development (Gate 3–4)
3. Live project — project is deployed to production
4. Migration project — currently migrating tech stack

---

**Q3. Briefly describe the change:**
(free text — e.g. "add PDF export for monthly reports", "remove social login", "login redirect goes to wrong page after auth")

---

Then route to the correct operation below.

---

---

# OPERATION A — ADD FEATURE

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

### Step A3.1 — Update CLAUDE.md
- Add feature to Features list: `- [ ] [Feature Name]`
- Add tasks to Progress Tracker under Gate 4

### Step A3.2 — Update docs/brd.html
Read current file from disk, then add:
- New user story with Given-When-Then acceptance criteria
- New business rules if applicable
- Update scope section

### Step A3.3 — Update docs/database-design.html (if A-Q4 = 1 or 2)
Read current file from disk, then add:
- New table definition with columns, types, constraints
- Updated ERD diagram
- Migration script outline

### Step A3.4 — Update docs/api-reference.html (if A-Q5 = 1 or 2)
Read current file from disk, then add:
- New endpoint definitions (method, path, request, response, errors)
- Updated authentication requirements

### Step A3.5 — Update docs/prototype/index.html (if A-Q6 = 1 or 2)
Read current file from disk, then add:
- New screen wireframes or component specs
- Updated navigation flow

### Step A3.6 — Update docs/security-design.html (if new data or auth scope)
Read current file from disk, then add:
- Security considerations for new feature
- Updated OWASP checklist items if applicable

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
Read `~/.claude/dev-github.md` → follow PROC-GH-05 for each task.

### Step A4.3 — Create Notion Tasks
Read `~/.claude/dev-notion.md` → follow PROC-NT-03 for each task.

Show summary:
```
✅ [N] GitHub issues created
✅ [N] Notion tasks created (Status: To Do)
→ Ready to start development
```

---

## A-PHASE 5 — Development

For each task (in dependency order):

1. Read `~/.claude/dev-github.md` → PROC-GH-06: create feature branch
2. Read `~/.claude/dev-notion.md` → PROC-NT-04: status → In Progress
3. Agent reads relevant docs from disk before coding:
   - @backend → docs/api-reference.html + docs/database-design.html
   - @frontend → docs/prototype/index.html + docs/brd.html
   - @dba → docs/database-design.html
4. Implement code
5. Read `~/.claude/dev-github.md` → PROC-GH-07: create PR
6. PR REVIEW — multi-dimensional review before approval:
   - Architecture (@techlead): fits existing design? over-engineered?
   - Code Quality (@backend/@frontend): error handling, all states?
   - Security (@security): input validation, auth, OWASP?
   - Performance: N+1 queries? re-renders? bundle size?
   - Testing (@qa): unit + integration + E2E coverage?
   - Docs (@docs): new endpoints documented? changelog?
   Severity: 🔴 BLOCKER | 🟡 MAJOR | 🟢 MINOR
   → If 🔴 BLOCKER → fix before showing approval gate
   → If 🟡 MAJOR → list in summary, recommend fix
7. Read `~/.claude/dev-notion.md` → PROC-NT-05: status → In Review

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE A4 — FEATURE APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: [feature name]
PR: #[N] — [PR URL]

Review findings:
  🔴 Blockers: [N — all fixed before this gate]
  🟡 Major:    [N — listed below with recommendations]
  🟢 Minor:    [N — non-blocking suggestions]

  "approve"        → merge PR + mark Done in Notion
  "revise [notes]" → fix issues and re-submit PR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After approval:
- PROC-GH-08: merge PR + close issue
- PROC-NT-06: mark task → Done
- Update CLAUDE.md: tick feature checkbox ✅

---

---

# OPERATION B — REMOVE FEATURE

---

## B-PHASE 1 — Identify Feature to Remove

**B-Q1. Which feature do you want to remove?**
(free text — exact feature name as it appears in CLAUDE.md)

---

**B-Q2. Why is this feature being removed?**
1. Out of scope for current release
2. No longer needed by business
3. Replaced by another feature
4. Too complex / too risky right now
5. Other (specify)

---

**B-Q3. Is this feature already implemented in code?**
1. Yes — code exists and is deployed
2. Yes — code exists but not yet deployed
3. Partially — some code exists
4. No — only in documents, not yet coded

---

## B-PHASE 2 — Removal Impact Analysis

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 REMOVAL IMPACT ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature to remove: [feature name]
Reason: [B-Q2]
Code exists: [yes/partial/no]

This will remove:
  📄 docs/brd.html      — [N] user stories, [N] acceptance criteria
  📄 docs/database-design.html   — [N] tables or fields (if applicable)
  📄 docs/api-reference.html      — [N] endpoints (if applicable)
  📄 docs/prototype/index.html     — [N] screens or components (if applicable)
  📄 docs/security-design.html — [N] security rules (if applicable)
  📁 Code               — [list files/folders to delete or "none yet"]

Features that DEPEND on this feature:
  ⚠️ [dependent feature 1] — will be affected
  ⚠️ [dependent feature 2] — will be affected
  (or "No dependencies found")

Open GitHub Issues linked to this feature:
  #[N] [issue title] — will be closed as "won't do"
  (or "None")

Open Notion tasks linked to this feature:
  [task name] — will be marked "Cancelled"
  (or "None")

  "confirm removal"  → proceed with all removals
  "cancel"           → keep the feature, exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE B1 — wait for "confirm removal" explicitly. Do NOT proceed on any other input.

---

## B-PHASE 3 — Document Removal (upstream → downstream)

Update documents in this order:

### Step B3.1 — Update CLAUDE.md
- Remove feature from Features list
- Remove related tasks from Progress Tracker
- Add note: `[YYYY-MM-DD] Removed: [feature name] — Reason: [reason]`

### Step B3.2 — Update docs/brd.html
- Remove related user stories
- Remove related acceptance criteria
- Add removed section note with date and reason

### Step B3.3 — Update docs/database-design.html (if applicable)
- Mark tables/fields as deprecated or remove
- Note: if data exists in production, add migration note before removing

### Step B3.4 — Update docs/api-reference.html (if applicable)
- Remove endpoint definitions
- Add deprecation notice with date

### Step B3.5 — Update docs/prototype/index.html (if applicable)
- Remove screen wireframes or components
- Update navigation flow

### Step B3.6 — Update docs/security-design.html (if applicable)
- Remove related security rules

After all docs updated:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE B2 — DOCUMENT REMOVAL APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Documents updated:
  ✏️ CLAUDE.md          — feature removed
  ✏️ docs/brd.html      — [N] stories removed
  ✏️ docs/database-design.html   — [changes or "no changes"]
  ✏️ docs/api-reference.html      — [changes or "no changes"]
  ✏️ docs/prototype/index.html     — [changes or "no changes"]

  "approve"        → remove code + close tasks
  "revise [notes]" → adjust removals
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE B2 — wait for approval before touching code.

---

## B-PHASE 4 — Code Removal + Task Cleanup

After Gate B2 approved:

### Step B4.1 — Remove Code (if B-Q3 = 1, 2, or 3)
- Create branch: `chore/remove-[feature-slug]`
- Remove feature code files
- Remove related tests
- Remove routes, endpoints, components
- Verify build still passes
- Create PR

### Step B4.2 — Close GitHub Issues
For each open issue linked to removed feature:
```bash
gh issue close [ISSUE_NUMBER] \
  --comment "Feature removed: [reason]. Closed as won't do."
```

### Step B4.3 — Update Notion Tasks
Read `~/.claude/dev-notion.md` → PROC-NT-04 with status "Cancelled" for all related tasks.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE B3 — REMOVAL COMPLETE APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature "[feature name]" has been removed.

Code: PR #[N] ready for review
      [or "No code to remove"]

Tasks closed:
  ✅ [N] GitHub issues closed (won't do)
  ✅ [N] Notion tasks → Cancelled

  "approve"        → merge removal PR + done
  "revise [notes]" → adjust before merging
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

---

# OPERATION C — FIX BUG

---

## C-PHASE 1 — Bug Report

Ask these questions ONE AT A TIME:

**C-Q1. Describe the bug:**
(free text — what is happening vs what should happen)

---

**C-Q2. How do you reproduce it?**
(free text — step by step, or "intermittent / unknown")

---

**C-Q3. What is the severity?**
1. Critical — system is down or data loss occurring
2. High — major feature broken, no workaround
3. Medium — feature broken, workaround exists
4. Low — minor issue, cosmetic or edge case

---

**C-Q4. What environment is this in?**
1. Production (live users affected)
2. Staging
3. Development only
4. All environments

---

**C-Q5. Which area of the system is affected?**
(free text — e.g. "login flow", "budget CRUD", "PDF export", "database migration")

---

**C-Q6. Any error messages or logs?**
(free text — paste relevant error, or "none visible")

---

## C-PHASE 2 — Bug Analysis

Tech Lead + relevant agent reads:
- CLAUDE.md
- Relevant code files in the affected area
- Relevant docs (docs/api-reference.html, docs/database-design.html if data-related)

Then shows analysis:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐛 BUG ANALYSIS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bug:      [description]
Severity: [Critical / High / Medium / Low]
Area:     [affected area]

Root cause (suspected):
  [what is likely causing the bug]

Files likely involved:
  📁 [file 1] — [why]
  📁 [file 2] — [why]

Fix approach:
  [proposed fix in 1-3 sentences]

Docs that need updating after fix:
  📄 [doc] — [why] (or "No doc updates needed")

Risk of fix:
  [Low / Medium / High — and why]

  "approve"        → create bug task + start fix
  "revise [notes]" → adjust analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE C1 — wait for approval before creating tasks or writing any code.

---

## C-PHASE 3 — Task Creation + GitHub + Notion

After Gate C1 approved:

### Step C3.1 — Create GitHub Issue
Read `~/.claude/dev-github.md` → PROC-GH-05

Issue template:
```markdown
## Bug Report

**Summary:** [one line description]
**Severity:** [Critical / High / Medium / Low]
**Environment:** [Production / Staging / Dev]

## Steps to Reproduce
1. [step 1]
2. [step 2]
3. [step 3]

## Expected Behavior
[what should happen]

## Actual Behavior
[what is happening]

## Error Messages / Logs
[paste error or "none"]

## Root Cause (suspected)
[from analysis]

## Proposed Fix
[from analysis]

## Files Involved
- [file 1]
- [file 2]
```

Labels: `bug`, `severity:[critical/high/medium/low]`, `role:@[agent]`

### Step C3.2 — Create Notion Task
Read `~/.claude/dev-notion.md` → PROC-NT-03

```
Title:    "BUG: [short description]"
Status:   To Do
Gate:     Gate 4 — Feature
Role:     @[agent]
Priority: [Critical / High / Medium / Low]
Effort:   [S / M / L]
Notes:    GitHub Issue #[N]
```

Show:
```
✅ GitHub Issue #[N] created
✅ Notion task created: "BUG: [description]"
→ Ready to start fix
```

---

## C-PHASE 4 — Fix Development

1. Read `~/.claude/dev-github.md` → PROC-GH-06: create fix branch
   Branch name: `fix/[issue-number]-[short-slug]`
2. Read `~/.claude/dev-notion.md` → PROC-NT-04: status → In Progress
3. Agent reads relevant code and docs from disk
4. Implement fix
5. Write or update tests to cover the bug scenario
6. Verify fix resolves the issue

---

## C-PHASE 5 — Bug Fix Documentation

After fix is implemented, Docs agent writes/updates `docs/bugfix-log.html`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 BUGFIX LOG ENTRY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          BUG-[YYYY-MM-DD]-[NNN]
Date:        [YYYY-MM-DD]
Severity:    [Critical / High / Medium / Low]
Reporter:    [user or "discovered during dev"]
Area:        [affected area]
Environment: [Production / Staging / Dev]

Summary:
  [one paragraph description of the bug]

Root Cause:
  [what caused the bug — specific code/logic issue]

Fix Applied:
  [what was changed and why it resolves the issue]

Files Changed:
  - [file 1] — [what changed]
  - [file 2] — [what changed]

Tests Added:
  - [test name] — [what it verifies]

Docs Updated:
  - [doc] — [what changed] (or "None required")

GitHub Issue: #[N]
GitHub PR:    #[N]
Notion Task:  [task URL]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If `docs/bugfix-log.html` does not exist yet, create it with this entry.
If it exists, append the new entry at the top (newest first).

---

## C-PHASE 6 — PR + Review + Final Approval

1. Read `~/.claude/dev-github.md` → PROC-GH-07: create PR
2. PR REVIEW — focused review on the fix:
   - Code Quality: fix addresses root cause, not just symptom?
   - Security (@security): fix doesn't introduce new vulnerability?
   - Performance: fix doesn't degrade performance?
   - Testing (@qa): regression test covers the bug scenario?
   Severity: 🔴 BLOCKER | 🟡 MAJOR | 🟢 MINOR
   → If 🔴 BLOCKER → fix before showing approval gate
3. Read `~/.claude/dev-notion.md` → PROC-NT-05: status → In Review

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE C2 — FIX APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bug: [description]
PR:  #[N] — [PR URL]

Fix summary:
  [what was changed]

Review findings:
  🔴 Blockers: [N — all fixed before this gate]
  🟡 Major:    [N — listed below]
  🟢 Minor:    [N — suggestions]

Tests:
  ✅ [N] tests passing
  ✅ New test added: [test name]

Docs updated:
  ✅ docs/bugfix-log.html — entry added

  "approve"        → merge PR + close issue + mark Done
  "revise [notes]" → fix issues before merging
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After approval:
- PROC-GH-08: merge PR + close issue
- PROC-NT-06: mark Notion task → Done
- Commit bugfix-log.html update

---

---

# RESUME INSTRUCTIONS

If resuming mid-change:

1. Read `memory/progress.json` first
2. Identify which operation (A/B/C) and which phase
3. Read the relevant docs from disk
4. Announce:
   ```
   📂 Resuming [Operation A/B/C] — [Phase name]
   Reading from: [filename]
   Last completed: [from progress.json]
   Next action: [from progress.json]
   ```
5. Continue from next action — never skip gate approvals
6. Run /compact when context gets long

---

# PROGRESS TRACKER TEMPLATE

```
## Change In Progress
Operation:      [A: Add Feature / B: Remove Feature / C: Fix Bug]
Name:           [feature name or bug description]
Started:        [YYYY-MM-DD]
Context:        [New / Existing / Live / Migration]
GitHub Issue:   #[N]
Notion Task:    [URL]
Branch:         [branch name]

Gate status:
  [ ] Gate 1 — Impact analysis approved
  [ ] Gate 2 — Documents approved
  [ ] Gate 3 — Task list approved (A/B only)
  [ ] Gate 4 — Implementation approved
  [ ] Done — merged + closed

Last completed: [what was just done]
Next action:    [exactly what to do next]
Files modified: [list]
```
