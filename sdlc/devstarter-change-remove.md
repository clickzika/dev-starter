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

---
