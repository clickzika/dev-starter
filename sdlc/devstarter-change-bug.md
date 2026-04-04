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
Read `~/.claude/devstarter-github.md` → PROC-GH-05

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
Read `~/.claude/devstarter-notion.md` → PROC-NT-03

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

1. **NOTION → In Progress:** Read `~/.claude/devstarter-notion.md` → PROC-NT-04: status → In Progress ⚠️ MANDATORY
2. Read `~/.claude/devstarter-github.md` → PROC-GH-06: create fix branch
   Branch name: `fix/[issue-number]-[short-slug]`
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

1. Read `~/.claude/devstarter-github.md` → PROC-GH-07: create PR
2. PR REVIEW — focused review on the fix:
   - Code Quality: fix addresses root cause, not just symptom?
   - Security (@devstarter-security): fix doesn't introduce new vulnerability?
   - Performance: fix doesn't degrade performance?
   - Testing (@devstarter-qa): regression test covers the bug scenario?
   Severity: 🔴 BLOCKER | 🟡 MAJOR | 🟢 MINOR
   → If 🔴 BLOCKER → fix before showing approval gate
3. Read `~/.claude/devstarter-notion.md` → PROC-NT-05: status → In Review

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
