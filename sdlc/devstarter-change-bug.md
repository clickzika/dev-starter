# OPERATION C — FIX BUG

> **TL;DR** — Fix a bug with intake → analysis → fix → review flow · **Lifecycle** Build · **Gates** 2

## Model: Sonnet (`claude-sonnet-4-6`)

---

## C-SECTION 0 — Requirements Intake (ALWAYS run first)

Before starting bug analysis, capture a complete structured bug report.
A thorough report leads to faster root cause diagnosis and fewer back-and-forth rounds.

**Step 0 — File arg check (check FIRST):**
If `/devstarter-change` was called with a `.md` file path (e.g. `/devstarter-change bug.md`):
1. Read the file: `Read [filepath]`
2. Extract all bug report sections from the file content
3. Show INTAKE SUMMARY (pre-filled from file) and wait for approval
4. After approval → skip Steps 1–5 below, go directly to C-PHASE 2 (Bug Analysis)
Do NOT run Steps 1–5 if a file arg was provided and successfully read.

**Steps 1–5 — Interactive intake (only if no file arg):**
1. Read `~/.claude/templates/intake/devstarter-intake-fix-bug.md`
2. Present each section to the user ONE SECTION AT A TIME
3. Fill in answers as the user responds
4. Save the completed intake to: `memory/intake-fix-bug-[YYYY-MM-DD].md`
5. Show the INTAKE SUMMARY and wait for approval before continuing

After approval → skip C-PHASE 1 questions and go directly to C-PHASE 2 (Bug Analysis).
The intake replaces C-Q1 through C-Q6.

**Answer carry-forward after approval:**
- C-Q1 (describe bug)   → Sections 1.1 + 3.1 + 3.2
- C-Q2 (reproduction)   → Sections 2.1 + 2.2
- C-Q3 (severity)       → Section 1.3
- C-Q4 (environment)    → Section 1.4
- C-Q5 (affected area)  → Section 1.2
- C-Q6 (error messages) → Section 3.3

---

## C-PHASE 1 — Bug Report

> **Note:** C-PHASE 1 is skipped when C-SECTION 0 intake is complete and approved.
> Only run C-PHASE 1 questions if intake was skipped or incomplete.

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

---

## C-PHASE 2.4 — Generate Kickoff & Sign-off Document (plain language)

Immediately after bug analysis, before plan.html, generate the **kickoff
document** — a plain-language pre-fix sign-off confirming the root cause and the
fix solution for the requester (Sections 1–3) and management (Sections 4–5).
No code exists yet.

**Step 1 — Fill and save kickoff.html:**
Read `~/.claude/templates/docs/devstarter-change-kickoff-template.html`.
Create folder `docs/fix/[slug]/` now if not yet created (slug = lowercase-
hyphenated bug summary, max 4 words). Replace all `{{PLACEHOLDER}}` tokens:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | `BUG-[YYYY-MM-DD]-NNN` (same ID used by plan.html) |
| `{{CHANGE_TYPE}}` | `Fix Bug` |
| `{{FEATURE_NAME}}` | bug summary (one line) |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{DATE}}` | today |
| `{{AUTHOR}}` | `@devstarter-techlead` |
| `{{PRIORITY}}` / `{{PRIORITY_PILL_COLOR}}` | from C-Q3 severity; pill: red(Critical)/yellow(High/Medium)/gray(Low) |
| `{{EFFORT}}` / `{{EFFORT_DETAIL}}` | estimated from analysis + one-line rationale |
| `{{RISK_LEVEL}}` / `{{RISK_PILL_COLOR}}` / `{{RISK_DETAIL}}` | risk of the fix; pill: green(Low)/yellow(Medium)/red(High) |
| `{{PLAIN_SUMMARY}}` | 2–3 plain sentences: the bug + the fix being approved |
| `{{CONFIRMATION_HEADING}}` | `Root Cause & Fix Solution` |
| `{{CONFIRMATION_DETAIL}}` | plain-language root cause from analysis (no jargon) |
| `{{CONFIRMATION_SECONDARY_TITLE}}` | `The Fix We Will Apply` |
| `{{CONFIRMATION_SECONDARY}}` | plain description of the fix approach + how the user will know it is fixed |
| `{{IN_SCOPE_LIST}}` | `<li>` — what the fix changes |
| `{{OUT_OF_SCOPE_LIST}}` | `<li>` — what stays untouched (regression guard) |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` Given/When/Then fix acceptance criteria |
| `{{BUSINESS_NEED}}` | user/business impact of the bug — why fix now |
| `{{WHO_BENEFITS}}` | affected users |
| `{{IMPACT_IF_DEFERRED}}` | cost/risk of not fixing |
| `{{TIMELINE_ESTIMATE}}` / `{{TIMELINE_NOTES}}` | rough fix window |
| `{{PRIORITY_NOTES}}` | one line on severity rationale |
| `{{SIGN_OFF_MEANING}}` | "Approving authorises branch creation and the fix to begin against this root-cause analysis." |
| `{{APPROVER_ROWS}}` | `<tr>` per approver (Requester, Manager) with Approve/Revise checkbox |

**Bilingual (MANDATORY):** every filled text block contains both English and Thai
via `<span class="lang-en">` / `<span class="lang-th">` pairs (Rule 8).

Save to: `docs/fix/[slug]/kickoff.html`

**Step 2 — Register in docs/index.html:**
Add under "Fix Kickoffs" section (create section if absent):
```html
<a href="fix/[slug]/kickoff.html">[CHANGE_ID] — [Bug Summary] — Kickoff — [Date] (Pending Sign-off)</a>
```

**Step 3 — Announce:**
```
📝 Kickoff document created: docs/fix/[slug]/kickoff.html
   Plain-language sign-off (root cause + fix) — review before plan.
```

---

## C-PHASE 2.5 — Generate Bug Fix Plan Document

Immediately after the kickoff document, before any gate, generate the plan HTML:

**Step 1 — Initialize change log:**
(Folder `docs/fix/[slug]/` already created in C-PHASE 2.4 Step 1.)
- Create `memory/change-log-[slug].md`:
  ```markdown
  # Change Log — [bug-slug]
  Change ID: BUG-[YYYY-MM-DD]-NNN
  Date: [YYYY-MM-DD]
  Type: Fix Bug

  <!-- Agents: append entries below during fix. Format:
  ### path/to/file.ext
  - FIXED: functionName — what was wrong, what was fixed
  - MODIFIED: functionName — what changed
  - ADDED: functionName — description (e.g. new test)
  -->
  ```

**Step 2 — Fill and save plan.html:**
Read `~/.claude/templates/docs/devstarter-change-plan-template.html`.
Replace all `{{PLACEHOLDER}}` tokens with values from the bug report + analysis:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | `BUG-[YYYY-MM-DD]-NNN` |
| `{{CHANGE_TYPE}}` | `Fix Bug` |
| `{{FEATURE_NAME}}` | bug summary (one line) |
| `{{SLUG}}` | derived slug |
| `{{DATE}}` | today |
| `{{AUTHOR}}` | `@devstarter-techlead` |
| `{{PRIORITY}}` / `{{PRIORITY_COLOR}}` | from C-Q3 severity; Critical=red, High=orange, Medium=yellow, Low=gray |
| `{{EFFORT}}` | estimated from analysis (S/M/L) |
| `{{BRANCH_NAME}}` | `fix/[slug]` (created after approval) |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{ROOT_PROBLEM}}` | root cause from analysis |
| `{{BUSINESS_REQUIREMENT}}` | impact of bug on users/business |
| `{{USER_ROLE}}` / `{{USER_WANT}}` / `{{USER_BENEFIT}}` | affected users, desired behavior, benefit of fix |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` items from intake Section 5 (fix acceptance criteria) |
| `{{SOLUTION_APPROACH}}` | fix approach from analysis |
| `{{WHY_THIS_APPROACH}}` | why this fix addresses root cause, not just symptom |
| `{{ALTERNATIVES_ROWS}}` | `<tr>` rows for alternative fixes considered |
| `{{FILES_TO_MODIFY_ROWS}}` | `<tr>` rows from "Files likely involved" in analysis |
| `{{REGRESSION_GUARD_LIST}}` | `<li>` items — what must NOT break after fix |
| `{{DB_IMPACT}}` / `{{API_IMPACT}}` / `{{UI_IMPACT}}` / `{{SEC_IMPACT}}` | from analysis |
| `{{IMPLEMENTATION_STEPS_LIST}}` | `<li>` steps for the fix |
| `{{DEPENDENCIES_LIST}}` | `<li>` — any dependencies needed |
| `{{TESTING_APPROACH}}` | regression test approach |
| `{{RISKS_ROWS}}` | `<tr>` risk of fix from analysis |
| `{{ROLLBACK_PLAN}}` | revert branch; restore previous behavior |

Save to: `docs/fix/[slug]/plan.html`

**Step 3 — Register in docs/index.html:**
Add entry under "Fix Plans" section (create section if absent):
```html
<a href="fix/[slug]/plan.html">[CHANGE_ID] — [Bug Summary] — [Date] (Pending Approval)</a>
```

**Step 4 — Announce:**
```
📋 Fix plan document created: docs/fix/[slug]/plan.html
   Open in browser to review before approving.
```

---

### Pre-Gate C1-DOC — Kickoff Preflight (mandatory)

Before showing the Gate C1-DOC picker, verify both pre-dev docs are complete.
Do NOT show the picker until all rows pass:

1. **No unfilled placeholders** — `docs/fix/[slug]/kickoff.html` and `plan.html`
   contain zero `{{` tokens (grep both files for `{{` → must be empty)
2. **Bilingual present** — kickoff.html contains both `lang-en` and `lang-th`
   spans in the filled content (Rule 8)
3. **Both audience sections populated** — kickoff Section 2 (root cause + fix) and
   Section 4 (Management Summary) have real content, not template comments

If any row fails, fix the doc and re-run this preflight. Only then show the picker.

Use `AskUserQuestion` with:
- question: "Gate C1-DOC — Open kickoff.html (plain-language root cause + fix) and plan.html (technical) in browser, review both, then approve to create branch and start fix."
- options: ["Approved — create branch and start fix", "Request changes (describe in notes)"]

**If "Approved — create branch and start fix":**
1. Show: `✅ Fix plan approved — creating branch fix/[slug]`
2. Run: `git branch --show-current`
3. If on `develop`, `main`, `master`, or `uat` → execute PROC-GH-06: create `fix/[slug]` branch
4. Confirm: `git branch --show-current` — MUST show `fix/[slug]`
5. Show: `🌿 Branch ready: fix/[slug] — all edits are isolated on this branch`
6. Proceed to C-PHASE 3

**If "Request changes":**
1. Apply requested changes to `docs/fix/[slug]/kickoff.html` and/or `docs/fix/[slug]/plan.html`
2. Announce: `📋 Updated: kickoff.html / plan.html`
3. Loop back to Gate C1-DOC AskUserQuestion

⛔ GATE C1-DOC — branch is NOT created and NO code is written until this gate is approved.

---

## C-PHASE 3 — Task Creation + GitHub + Notion

After Gate C1-DOC approved:

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
2. **Branch Guard:** Run `git branch --show-current` — if on `develop`, `main`, `master`, or `uat` → **STOP — do not edit anything**
3. Read `~/.claude/devstarter-github.md` → PROC-GH-06: create fix branch
   Branch name: `fix/[issue-number]-[short-slug]`
4. **Enter worktree** — use `EnterWorktree` tool with the fix branch name for isolated working copy
5. Agent reads relevant code and docs from disk
6. Implement fix
6b. **Append to change log** — for each file modified, add to `memory/change-log-[slug].md`:
    ```markdown
    ### path/to/file.ext
    - FIXED: functionName — what was wrong, what was fixed
    - MODIFIED: functionName — what changed (if additional refactor)
    - ADDED: functionName — new test or helper added
    ```
    Only log functions/methods actually changed.
7. Write or update tests to cover the bug scenario
8. Verify fix resolves the issue
9. Read `~/.claude/devstarter-github.md` → PROC-GH-07: create PR
10. **Exit worktree** — use `ExitWorktree` tool to return to main working copy

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

## C-PHASE END — Testing Gate + Change Summary Document

### ⛔ GATE C-TEST — Testing Confirmation

After PR merged and Gate C2 approved, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 TESTING GATE — [Bug Summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR merged: #[N]
Fix plan:  docs/fix/[slug]/plan.html

Reproduce the original bug scenario to confirm fix.
When testing passes, confirm below.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate C-TEST — Has the fix been tested and verified for [bug summary]?"
- options: ["Testing passed — generate summary doc", "Still testing — save checkpoint and stop"]

If "Still testing": write `memory/progress.json` with `"status": "waiting_test"` and stop.
If "Testing passed": proceed to Phase C-END below.

---

### Phase C-END — Generate Change Summary Document

1. **Read `memory/change-log-[slug].md`** — collect all function-level changes logged during fix
2. **Get file list:**
   ```bash
   git diff develop...fix/[slug] --name-only
   ```
   (If branch already merged/deleted, read from PR diff via `gh pr diff [PR_NUMBER] --name-only`)
3. **Fill template:** Read `~/.claude/templates/docs/devstarter-change-summary-template.html`
   Replace all `{{PLACEHOLDER}}` tokens:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | same BUG-ID from plan.html |
| `{{CHANGE_TYPE}}` | `Fix Bug` |
| `{{FEATURE_NAME}}` | bug summary |
| `{{SLUG}}` | same slug as plan |
| `{{BRANCH_NAME}}` | `fix/[slug]` |
| `{{PR_NUMBER}}` | from C-PHASE 4 |
| `{{GITHUB_ISSUE}}` | from C-PHASE 3 |
| `{{NOTION_TASK}}` | Notion task URL |
| `{{AUTHOR}}` | `@devstarter-techlead` |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{PLAN_APPROVED_DATE}}` | date of Gate C1-DOC approval |
| `{{DEV_COMPLETED_DATE}}` | date of Gate C2 approval |
| `{{COMPLETED_DATE}}` | today |
| `{{ORIGINAL_PROBLEM}}` | original bug description from intake |
| `{{ROOT_CAUSE_OR_GAP}}` | confirmed root cause from analysis |
| `{{HOW_RESOLVED}}` | paragraph describing the fix applied |
| `{{ACCEPTANCE_CRITERIA_VERIFIED_ROWS}}` | `<tr>` per fix criterion: criterion, ✅ Pass / ❌ Fail, notes |
| `{{FILES_CHANGED_ROWS}}` | `<tr>` per file: path, badge (created/modified/deleted), notes |
| `{{TOTAL_FILES_CHANGED}}` | count |
| `{{FUNCTIONS_CHANGED_ROWS}}` | `<tr>` per function from change-log-[slug].md |
| `{{TOTAL_FUNCTIONS_CHANGED}}` | count |
| `{{KEY_DECISIONS_LIST}}` | `<li>` — decisions made during fix (e.g. chose minimal fix vs refactor) |
| `{{TECHNICAL_APPROACH}}` | paragraph: what was wrong at the code level and how fix addresses it |
| `{{DEVIATIONS_FROM_PLAN}}` | what changed from plan.html, or "None — fixed as planned" |
| `{{TESTS_ADDED_ROWS}}` | `<tr>` per test: name, file, type, what it verifies |
| `{{VERIFICATION_STEPS_LIST}}` | `<li>` steps — how to reproduce the original bug and confirm it's fixed |
| `{{REGRESSION_CHECKS_ROWS}}` | `<tr>` per check: area, test, result |
| `{{REVIEWER_FOCUS_LIST}}` | `<li>` — what reviewers should check (correctness of root cause fix) |
| `{{REVIEWER_FILES_LIST}}` | `<li>` — files needing closest review |
| `{{REVIEWER_TRADEOFFS}}` | known limitations or deferred improvements |
| `{{QA_SCENARIOS_LIST}}` | `<li>` — numbered scenarios to verify (including original bug reproduction) |
| `{{QA_EDGE_CASES_LIST}}` | `<li>` — edge cases that could re-trigger the bug |
| `{{QA_REGRESSION_LIST}}` | `<li>` — areas potentially affected by the fix |
| `{{QA_ENVIRONMENT_NOTES}}` | environment notes (prod data state, config flags, etc.) |
| `{{MGMT_BUSINESS_IMPACT}}` | what the bug was breaking (business terms) |
| `{{MGMT_USER_IMPACT}}` | how users were affected; fix outcome |
| `{{MGMT_RISK}}` | residual risk after fix: Low/Medium/High + explanation |
| `{{MGMT_DELIVERED_LIST}}` | `<li>` plain-language bullets of what was fixed |

4. **Save to:** `docs/fix/[slug]/summary.html`
5. **Register in docs/index.html** under "Fix Summaries" (create section if absent):
   ```html
   <a href="fix/[slug]/summary.html">[CHANGE_ID] — [Bug Summary] — [Date] (Completed)</a>
   ```
6. **Generate management brief:** Read `~/.claude/templates/docs/devstarter-change-mgmt-template.html`
   Replace all `{{PLACEHOLDER}}` tokens — use plain business language, no technical terms:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | same BUG-ID from plan.html |
| `{{FEATURE_NAME}}` | bug summary (plain language title) |
| `{{COMPLETED_DATE}}` | today |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{EXECUTIVE_SUMMARY}}` | 2–3 sentence non-technical summary: what was broken, what was fixed, status now |
| `{{PROBLEM_PLAIN_LANGUAGE}}` | plain English description of the bug in business terms (what users experienced) |
| `{{SITUATION_BEFORE}}` | bullet list: what was broken, error users saw, business impact |
| `{{SITUATION_AFTER}}` | bullet list: what works now, how the experience improved |
| `{{WHO_WAS_AFFECTED}}` | which users, teams, or processes were impacted |
| `{{IMPACT_IF_NOT_FIXED}}` | business cost or risk of leaving bug unresolved |
| `{{DELIVERED_LIST}}` | `<li>` plain-language bullets of what was fixed |
| `{{IMPROVEMENT_TILES}}` | `<div class="improvement-tile">` per improvement area with icon + title + plain description |
| `{{METRICS_ROWS}}` | `<tr>` per measurable outcome: metric name, before (broken state), after (fixed state), improvement |
| `{{RESIDUAL_RISK_DETAIL}}` | Low/Medium/High + plain English: any remaining risk after fix |
| `{{WHAT_WAS_TESTED_LIST}}` | `<li>` plain description of verification done (business scenarios, not test names) |
| `{{ROLLBACK_CAPABILITY}}` | can fix be reverted? how quickly? any data implications? |
| `{{NEXT_STEPS_ROWS}}` | `<tr>` per follow-on action: action, owner, timeline |
| `{{PLAN_PATH}}` | `fix/[slug]/plan.html` |
| `{{SUMMARY_PATH}}` | `fix/[slug]/summary.html` |

   **Save to:** `docs/fix/[slug]/mgmt-brief.html`
   **Register in docs/index.html** alongside summary.html entry:
   ```html
   <a href="fix/[slug]/mgmt-brief.html">[CHANGE_ID] — [Bug Summary] — Management Brief — [Date]</a>
   ```

7. **Announce:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ BUG FIX COMPLETE — [Bug Summary]
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Fix Plan:     docs/fix/[slug]/plan.html
   📝 Summary:      docs/fix/[slug]/summary.html
   📊 Mgmt Brief:   docs/fix/[slug]/mgmt-brief.html

   Share with:
     👁  Code Reviewers — summary.html, Section 7 "For Code Reviewers"
     ✅  QA Team       — summary.html, Section 7 "For QA / Testers"
     📊  Management   — mgmt-brief.html (non-technical)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

---

---
