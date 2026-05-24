# OPERATION B — REMOVE FEATURE

> **TL;DR** — Remove a feature with deprecation, code cleanup, and rollback plan · **Lifecycle** Build · **Gates** 5

## Model: Sonnet (`claude-sonnet-4-6`)

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

Use `AskUserQuestion` with:
- question: "Gate B1 — Removal impact confirmed. Proceed with full removal?"
- options: ["confirm removal", "cancel"]

⛔ GATE B1 — wait for "confirm removal" explicitly. Do NOT proceed on any other input.

---

## B-PHASE 2.4 — Generate Kickoff & Sign-off Document (plain language)

After removal impact is confirmed, before any doc/code removal, generate the
**kickoff document** — a plain-language pre-removal sign-off for the requester
(Sections 1–3) and management (Sections 4–5).

**Step 1 — Fill and save kickoff.html:**
Read `~/.claude/templates/docs/devstarter-change-kickoff-template.html`.
Create folder `docs/feature/[slug]/` (slug = removed feature name, lowercase-
hyphenated, max 4 words). Replace all `{{PLACEHOLDER}}` tokens:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | `CR-[YYYY-MM-DD]-NNN` (same ID used by plan.html) |
| `{{CHANGE_TYPE}}` | `Remove Feature` |
| `{{FEATURE_NAME}}` | feature being removed (from B-Q1) |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{DATE}}` | today |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{PRIORITY}}` / `{{PRIORITY_PILL_COLOR}}` | removal urgency; pill color accordingly |
| `{{EFFORT}}` / `{{EFFORT_DETAIL}}` | estimated removal effort + rationale |
| `{{RISK_LEVEL}}` / `{{RISK_PILL_COLOR}}` / `{{RISK_DETAIL}}` | risk of removing (dependents, data loss); pill green/yellow/red |
| `{{PLAIN_SUMMARY}}` | 2–3 plain sentences: what is being removed and why |
| `{{CONFIRMATION_HEADING}}` | `What We Will Remove` |
| `{{CONFIRMATION_DETAIL}}` | plain-language description of the feature + why it is going away (from B-Q2) |
| `{{CONFIRMATION_SECONDARY_TITLE}}` | `Rollback Plan` |
| `{{CONFIRMATION_SECONDARY}}` | how the removal can be reverted if needed |
| `{{IN_SCOPE_LIST}}` | `<li>` — what gets removed (docs, code, endpoints, screens) |
| `{{OUT_OF_SCOPE_LIST}}` | `<li>` — what stays (dependents preserved, data retained, etc.) |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` Given/When/Then — feature gone, no broken references, build passes |
| `{{BUSINESS_NEED}}` | why remove now (from B-Q2), plain language |
| `{{WHO_BENEFITS}}` | who is affected / who benefits from removal |
| `{{IMPACT_IF_DEFERRED}}` | cost of keeping the feature (maintenance, risk, confusion) |
| `{{TIMELINE_ESTIMATE}}` / `{{TIMELINE_NOTES}}` | rough removal window |
| `{{PRIORITY_NOTES}}` | one line on urgency |
| `{{SIGN_OFF_MEANING}}` | "Approving authorises branch creation and removal of this feature against this scope." |
| `{{APPROVER_ROWS}}` | `<tr>` per approver (Requester, Manager) with Approve/Revise checkbox |

**Bilingual (MANDATORY):** every filled text block contains both English and Thai
via `<span class="lang-en">` / `<span class="lang-th">` pairs (Rule 8).

Save to: `docs/feature/[slug]/kickoff.html`. Register in docs/index.html under
"Change Kickoffs" (create section if absent):
```html
<a href="feature/[slug]/kickoff.html">[CHANGE_ID] — Remove [Feature Name] — Kickoff — [Date] (Pending Sign-off)</a>
```

---

## B-PHASE 2.5 — Generate Removal Plan Document

**Step 1 — Initialize change log:** Create `memory/change-log-[slug].md`
(Type: `Remove Feature`).

**Step 2 — Fill and save plan.html:**
Read `~/.claude/templates/docs/devstarter-change-plan-template.html`. Replace
`{{PLACEHOLDER}}` tokens for the removal (technical):

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` / `{{CHANGE_TYPE}}` | same CR-ID; `Remove Feature` |
| `{{FEATURE_NAME}}` / `{{SLUG}}` / `{{DATE}}` | feature, slug, today |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{BRANCH_NAME}}` | `chore/remove-[slug]` (created after approval) |
| `{{ROOT_PROBLEM}}` | why this feature must go |
| `{{SOLUTION_APPROACH}}` | removal approach (delete code, deprecate endpoints, drop tables) |
| `{{WHY_THIS_APPROACH}}` | reasoning (clean delete vs deprecate-first) |
| `{{FILES_TO_MODIFY_ROWS}}` | `<tr>` per file/folder to delete or edit |
| `{{REGRESSION_GUARD_LIST}}` | `<li>` — dependents that must keep working |
| `{{DB_IMPACT}}` / `{{API_IMPACT}}` / `{{UI_IMPACT}}` / `{{SEC_IMPACT}}` | from impact analysis |
| `{{IMPLEMENTATION_STEPS_LIST}}` | `<li>` removal steps |
| `{{RISKS_ROWS}}` | `<tr>` removal risks |
| `{{ROLLBACK_PLAN}}` | revert branch; restore deleted code/data |
| (remaining placeholders) | fill per add/bug plan mapping, removal-framed |

Save to: `docs/feature/[slug]/plan.html`. Register in docs/index.html under
"Change Plans".

**Step 3 — Announce:**
```
📝 Kickoff + plan created: docs/feature/[slug]/kickoff.html + plan.html
   Plain-language removal sign-off + technical plan — review before removal.
```

---

### Pre-Gate B1-DOC — Kickoff Preflight (mandatory)

Before the picker, verify both docs: zero `{{` placeholders remain; bilingual
`lang-en`/`lang-th` spans present; kickoff Sections 2 (what we remove) and 4
(Management Summary) populated. Fix and re-run if any check fails.

Use `AskUserQuestion` with:
- question: "Gate B1-DOC — Open kickoff.html (plain-language removal sign-off) and plan.html (technical) in browser, review both, then approve to create branch and start removal."
- options: ["Approved — create branch and start removal", "Request changes (describe in notes)"]

**If "Approved":**
1. Show: `✅ Removal plan approved — creating branch chore/remove-[slug]`
2. Run `git branch --show-current`; if on `develop`/`main`/`master`/`uat` → PROC-GH-06: create `chore/remove-[slug]`
3. Confirm `git branch --show-current` shows `chore/remove-[slug]`
4. Proceed to B-PHASE 3

**If "Request changes":** apply to kickoff.html and/or plan.html, re-announce, loop back to Gate B1-DOC.

⛔ GATE B1-DOC — branch is NOT created and NO files are edited until this gate is approved.

---

## B-PHASE 3 — Document Removal (upstream → downstream)

Update documents in this order.

**⚠️ REVISION HISTORY RULE (MANDATORY):**
Same rule as Operation A — every Gate 1 document modified MUST have a Revision History row appended with the CR ID, date, type=REMOVE, and description of what was removed. See A-PHASE 3 for the HTML template.

### Step B3.1 — Update CLAUDE.md
- Remove feature from Features list
- Remove related tasks from Progress Tracker
- Add note: `[YYYY-MM-DD] Removed: [feature name] — Reason: [reason]`

### Step B3.2 — Update docs/brd.html
- Remove related user stories
- Remove related acceptance criteria
- Add removed section note with date and reason
- **Add Revision History row:** CR ID, date, type=REMOVE, description of stories removed

### Step B3.3 — Update docs/database-design.html (if applicable)
- Mark tables/fields as deprecated or remove
- Note: if data exists in production, add migration note before removing
- **Add Revision History row:** CR ID, date, type=REMOVE, description of schema changes

### Step B3.4 — Update docs/api-reference.html (if applicable)
- Remove endpoint definitions
- Add deprecation notice with date
- **Add Revision History row:** CR ID, date, type=REMOVE, description of endpoints removed

### Step B3.5 — Update docs/prototype/index.html (if applicable)
- Remove screen wireframes or components
- Update navigation flow
- **Add Revision History row:** CR ID, date, type=REMOVE, description of screens removed

### Step B3.6 — Update docs/security-design.html (if applicable)
- Remove related security rules
- **Add Revision History row:** CR ID, date, type=REMOVE, description of security rules removed

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

Use `AskUserQuestion` with:
- question: "Gate B2 — Document removal complete. Approve to proceed to code removal?"
- options: ["approve", "revise"]

⛔ GATE B2 — wait for approval before touching code.

### Step B3.7 — Update docs/changerequest-log.html

After Gate B2 approved, Docs agent writes/updates `docs/changerequest-log.html`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 CHANGE REQUEST LOG ENTRY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          CR-[YYYY-MM-DD]-[NNN]
Date:        [YYYY-MM-DD]
Type:        REMOVE FEATURE
Priority:    —
Effort:      [S / M / L]
Requester:   [user or "internal"]
Context:     [New / Existing / Live / Migration]

Feature Name:
  [feature name being removed]

Reason for Removal:
  [from B-Q2 — why this feature is being removed]

Code Existed:
  [from B-Q3 — Yes (deployed) / Yes (not deployed) / Partial / No]

Impact Summary:
  Database:    [tables/fields removed or "no change"]
  API:         [endpoints removed or "no change"]
  UI:          [screens removed or "no change"]
  Security:    [rules removed or "no change"]

Dependencies Affected:
  - [dependent feature] — [how affected]
  (or "None")

Documents Updated:
  - [doc 1] — [what changed]
  - [doc 2] — [what changed]

Status:      [In Progress / Completed]
GitHub Issue: #[N] (closed as won't do)
GitHub PR:    #[N]
Notion Task:  [task URL] (Cancelled)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If `docs/changerequest-log.html` does not exist yet, create it with this entry using `~/.claude/templates/docs/document-template.html` as the base template.
If it exists, append the new entry at the top (newest first).

---

## B-PHASE 4 — Code Removal + Task Cleanup

After Gate B2 approved:

### Step B4.1 — Remove Code (if B-Q3 = 1, 2, or 3)
- Branch `chore/remove-[slug]` already created at Gate B1-DOC — confirm with `git branch --show-current`
- Remove feature code files
- Remove related tests
- Remove routes, endpoints, components
- Append each removed file/function to `memory/change-log-[slug].md` (REMOVED: ...)
- Verify build still passes
- Create PR

### Step B4.2 — Close GitHub Issues
For each open issue linked to removed feature:
```bash
gh issue close [ISSUE_NUMBER] \
  --comment "Feature removed: [reason]. Closed as won't do."
```

### Step B4.3 — Update Notion Tasks
Read `~/.claude/devstarter-notion.md` → PROC-NT-04 with status "Cancelled" for all related tasks.

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

Use `AskUserQuestion` with:
- question: "Gate B3 — Removal complete. Approve to merge PR and close all tasks?"
- options: ["approve", "revise"]

⛔ GATE B3 — wait for approval before merging.

---

## B-PHASE END — Testing Gate + Summary & Management Brief

### ⛔ GATE B-TEST — Removal Confirmation

After the removal PR is merged, confirm nothing broke:

Use `AskUserQuestion` with:
- question: "Gate B-TEST — Has the app been verified after removing [feature]? (build passes, no broken references, dependents still work)"
- options: ["Verified — generate summary + mgmt brief", "Still testing — save checkpoint and stop"]

If "Still testing": write `memory/progress.json` `"status": "waiting_test"` and stop.
If "Verified": generate the post-removal documents below.

### Generate summary.html + mgmt-brief.html

1. **summary.html** — Read `~/.claude/templates/docs/devstarter-change-summary-template.html`.
   Fill per the placeholder mapping in `devstarter-change-add.md` (Phase A-END),
   removal-framed: `{{CHANGE_TYPE}}` = `Remove Feature`; `{{HOW_RESOLVED}}` = what was
   removed and verified; files/functions from `memory/change-log-[slug].md`.
   `{{AUTHOR}}` = Name from install-root `~/.claude/USER.md` (fallback `IT Dept`). Save to `docs/feature/[slug]/summary.html`,
   register under "Change Summaries".
2. **mgmt-brief.html** — Read `~/.claude/templates/docs/devstarter-change-mgmt-template.html`.
   Plain business language: what was removed, why, who is affected, residual risk,
   rollback capability. `{{AUTHOR}}` = Name from install-root `~/.claude/USER.md` (fallback `IT Dept`). Save to
   `docs/feature/[slug]/mgmt-brief.html`, register alongside summary.

3. **Announce:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ FEATURE REMOVED — [Feature Name]
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Kickoff:    docs/feature/[slug]/kickoff.html
   📋 Plan:       docs/feature/[slug]/plan.html
   📝 Summary:    docs/feature/[slug]/summary.html
   📊 Mgmt Brief: docs/feature/[slug]/mgmt-brief.html
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

---
