# OPERATION A — ADD FEATURE

> **TL;DR** — Add a new feature with 4-gate review (impact → docs → tasks → approve) · **Lifecycle** Build · **Gates** 6

## Model: Sonnet (`claude-sonnet-4-6`)

---

## A-SECTION 0 — Requirements Intake (ALWAYS run first)

Before asking specification questions, collect feature requirements.
This captures the full scope before any impact analysis or coding begins.

**Step 0 — File arg check (check FIRST):**
If `/devstarter-change` was called with a `.md` file path (e.g. `/devstarter-change feature.md`):
1. Read the file: `Read [filepath]`
2. Detect type: contains "AS-IS"/"TO-BE"/"modify" → modify path; contains "bug"/"error"/"fix" → bug path; otherwise → add-feature path
3. Extract all requirement sections from the file content
4. Show INTAKE SUMMARY (pre-filled from file) and wait for approval
5. After approval → skip Steps 1–5 below, go directly to A-PHASE 2 (Impact Analysis)
Do NOT run Steps 1–5 if a file arg was provided and successfully read.

**Step 1 — Detect feature type from description:**
- New feature keywords: "add", "create", "build", "implement", "new"
- Modify feature keywords: "change", "update", "modify", "extend", "improve", "edit"
- When ambiguous, ask: "Is this a NEW feature or modifying an EXISTING one?"

**Step 2 — Read the matching template:**
- New feature   → read `~/.claude/templates/intake/devstarter-intake-add-feature.md`
- Modify feature → read `~/.claude/templates/intake/devstarter-intake-modify-feature.md`

**Step 3 — Collect requirements:**
Present each section to the user ONE SECTION AT A TIME.
Fill in answers as the user responds.

**Step 4 — Save filled intake:**
- New:    `memory/intake-add-feature-[YYYY-MM-DD].md`
- Modify: `memory/intake-modify-feature-[YYYY-MM-DD].md`

**Step 5 — Show INTAKE SUMMARY and wait for approval.**
After approval → skip A-PHASE 1 questions and go directly to A-PHASE 2 (Impact Analysis).

**Answer carry-forward after approval:**
- A-Q1 (feature name)  → Section 1.1
- A-Q2 (problem)       → Section 1.3
- A-Q3 (users)         → Section 2.1
- A-Q4 (DB changes)    → Section 3.3
- A-Q5 (API changes)   → Section 3.2
- A-Q6 (UI changes)    → Section 3.1
- A-Q7 (priority)      → Section 5.1
- A-Q8 (effort)        → Section 5.2

---

## A-PHASE 1 — Feature Specification

> **Note:** A-PHASE 1 is skipped when A-SECTION 0 intake is complete and approved.
> Only run A-PHASE 1 questions if intake was skipped or incomplete.

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

---

## A-PHASE 2.4 — Generate Kickoff & Sign-off Document (plain language)

Immediately after impact analysis, before plan.html, generate the **kickoff
document** — a plain-language pre-development sign-off for the requester
(Sections 1–3) and management (Sections 4–5). All inputs come from the intake
+ impact analysis; no code exists yet.

**Step 1 — Fill and save kickoff.html:**
Read `~/.claude/templates/docs/devstarter-change-kickoff-template.html`.
Create folder `docs/feature/[slug]/` now if not yet created (slug =
lowercase-hyphenated feature name, max 4 words, e.g. `auth-refresh-token`).
Replace all `{{PLACEHOLDER}}` tokens:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | `CR-[YYYY-MM-DD]-001` (same ID used by plan.html) |
| `{{CHANGE_TYPE}}` | `Add Feature` or `Modify Feature` |
| `{{FEATURE_NAME}}` | from A-Q1 / intake Section 1.1 |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{DATE}}` | today |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{PRIORITY}}` / `{{PRIORITY_PILL_COLOR}}` | from A-Q7; pill: red/yellow/blue/gray |
| `{{EFFORT}}` / `{{EFFORT_DETAIL}}` | from A-Q8 + one-line rationale |
| `{{RISK_LEVEL}}` / `{{RISK_PILL_COLOR}}` / `{{RISK_DETAIL}}` | from impact analysis; pill: green(Low)/yellow(Medium)/red(High) |
| `{{PLAIN_SUMMARY}}` | 2–3 plain sentences: what is being approved |
| `{{CONFIRMATION_HEADING}}` | bilingual span — Add: `<span class="lang-en">What We Will Build</span><span class="lang-th">สิ่งที่เราจะสร้าง</span>` · Modify: `What We Will Change` / `สิ่งที่เราจะเปลี่ยน` |
| `{{CONFIRMATION_DETAIL}}` | plain description of the feature from intake Section 1.3 / 2.2 |
| `{{CONFIRMATION_SECONDARY_TITLE}}` | `User Story` |
| `{{CONFIRMATION_SECONDARY}}` | `As a [role], I want [want], so that [benefit]` from Section 2.2 |
| `{{IN_SCOPE_LIST}}` | `<li>` items — what this change includes |
| `{{OUT_OF_SCOPE_LIST}}` | `<li>` items — explicitly excluded |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` Given/When/Then items from intake Section 2.3 |
| `{{BUSINESS_NEED}}` | from A-Q2 / Section 1.3 — why now, plain language |
| `{{WHO_BENEFITS}}` | from A-Q3 — target users, plain language |
| `{{IMPACT_IF_DEFERRED}}` | business cost of not doing it |
| `{{TIMELINE_ESTIMATE}}` / `{{TIMELINE_NOTES}}` | rough delivery window from effort |
| `{{PRIORITY_NOTES}}` | one line on priority rationale |
| `{{SIGN_OFF_MEANING}}` | "Approving authorises branch creation and development to begin against this scope." |
| `{{APPROVER_ROWS}}` | `<tr>` per approver (Requester, Manager) with Approve/Revise checkbox |

**Bilingual (MANDATORY):** every filled text block must contain both English and
Thai via `<span class="lang-en">` / `<span class="lang-th">` pairs (Rule 8).

Save to: `docs/feature/[slug]/kickoff.html`

**Step 2 — Register in docs/index.html:**
Add under "Change Kickoffs" section (create section if absent):
```html
<a href="feature/[slug]/kickoff.html">[CHANGE_ID] — [Feature Name] — Kickoff — [Date] (Pending Sign-off)</a>
```

**Step 3 — Announce:**
```
📝 Kickoff document created: docs/feature/[slug]/kickoff.html
   Plain-language sign-off (requester + management) — review before plan.
```

---

## A-PHASE 2.5 — Generate Change Plan Document

Immediately after the kickoff document, before any gate, generate the plan HTML:

**Step 1 — Initialize change log:**
(Folder `docs/feature/[slug]/` already created in A-PHASE 2.4 Step 1.)
- Create `memory/change-log-[slug].md`:
  ```markdown
  # Change Log — [feature-name]
  Change ID: CR-[YYYY-MM-DD]-NNN
  Date: [YYYY-MM-DD]
  Type: [Add Feature / Modify Feature]

  <!-- Agents: append entries below during development. Format:
  ### path/to/file.ext
  - ADDED: functionName — description
  - MODIFIED: functionName — what changed
  - FIXED: functionName — what was wrong, what was fixed
  -->
  ```

**Step 2 — Fill and save plan.html:**
Read `~/.claude/templates/docs/devstarter-change-plan-template.html`.
Replace all `{{PLACEHOLDER}}` tokens with values from the intake + impact analysis:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | `CR-[YYYY-MM-DD]-001` (auto-increment if changerequest-log.html exists) |
| `{{CHANGE_TYPE}}` | `Add Feature` or `Modify Feature` |
| `{{FEATURE_NAME}}` | from A-Q1 or intake Section 1.1 |
| `{{SLUG}}` | derived slug |
| `{{DATE}}` | today |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{PRIORITY}}` / `{{PRIORITY_COLOR}}` | from A-Q7; color: red/orange/yellow/gray |
| `{{EFFORT}}` | from A-Q8 |
| `{{BRANCH_NAME}}` | `feature/[slug]` (created after approval) |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{ROOT_PROBLEM}}` | from A-Q2 or intake Section 1.3 |
| `{{BUSINESS_REQUIREMENT}}` | from intake Section 1.3 |
| `{{USER_ROLE}}` / `{{USER_WANT}}` / `{{USER_BENEFIT}}` | from intake Section 2.2 |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` items from intake Section 2.3 |
| `{{SOLUTION_APPROACH}}` | approach summary from impact analysis |
| `{{WHY_THIS_APPROACH}}` | reasoning based on project context |
| `{{ALTERNATIVES_ROWS}}` | `<tr>` rows for alternatives considered |
| `{{FILES_TO_MODIFY_ROWS}}` | `<tr>` rows from "Code that will be created/modified" |
| `{{REGRESSION_GUARD_LIST}}` | `<li>` items from intake Section 4.1 |
| `{{DB_IMPACT}}` / `{{API_IMPACT}}` / `{{UI_IMPACT}}` / `{{SEC_IMPACT}}` | from impact analysis |
| Impact badge classes | `badge-green` (None), `badge-yellow` (Minor), `badge-orange` (Moderate), `badge-red` (Major) |
| `{{IMPLEMENTATION_STEPS_LIST}}` | `<li>` items for each dev task |
| `{{DEPENDENCIES_LIST}}` | `<li>` from intake Section 5.3 |
| `{{TESTING_APPROACH}}` | brief testing strategy |
| `{{RISKS_ROWS}}` | `<tr>` rows from risk assessment |
| `{{ROLLBACK_PLAN}}` | revert branch; undo migrations if any |

Save to: `docs/feature/[slug]/plan.html`

**Step 3 — Register in docs/index.html:**
Add entry under "Change Plans" section (create section if absent):
```html
<a href="feature/[slug]/plan.html">[CHANGE_ID] — [Feature Name] — [Date] (Pending Approval)</a>
```

**Step 4 — Announce:**
```
📋 Plan document created: docs/feature/[slug]/plan.html
   Open in browser to review before approving.
```

---

### Pre-Gate A1-DOC — Kickoff Preflight (mandatory)

Before showing the Gate A1-DOC picker, verify both pre-dev docs are complete.
Do NOT show the picker until all rows pass:

1. **No unfilled placeholders** — `docs/feature/[slug]/kickoff.html` and `plan.html`
   contain zero `{{` tokens (grep both files for `{{` → must be empty)
2. **Bilingual present** — kickoff.html contains both `lang-en` and `lang-th`
   spans in the filled content (Rule 8)
3. **Both audience sections populated** — kickoff Section 2 (requirement) and
   Section 4 (Management Summary) have real content, not template comments

If any row fails, fix the doc and re-run this preflight. Only then show the picker.

Use `AskUserQuestion` with:
- question: "Gate A1-DOC — Open kickoff.html (plain-language sign-off) and plan.html (technical) in browser, review both, then approve to create branch and start development."
- options: ["Approved — create branch and start development", "Request changes (describe in notes)"]

**If "Approved — create branch and start development":**
1. Show: `✅ Plan approved — creating branch feature/[slug]`
2. Run: `git branch --show-current`
3. If on `develop`, `main`, `master`, or `uat` → execute PROC-GH-06: create `feature/[slug]` branch
4. Confirm: `git branch --show-current` — MUST show `feature/[slug]`
5. Show: `🌿 Branch ready: feature/[slug] — all edits are isolated on this branch`
6. Proceed to A-PHASE 3

**If "Request changes":**
1. Apply requested changes to `docs/feature/[slug]/kickoff.html` and/or `docs/feature/[slug]/plan.html` (re-fill affected placeholders)
2. Announce: `📋 Updated: kickoff.html / plan.html`
3. Loop back to Gate A1-DOC AskUserQuestion

⛔ GATE A1-DOC — branch is NOT created and NO files are edited until this gate is approved.

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

After all docs updated, run the **Doc Quality Preflight** before showing
the Gate A2 picker. This converts Gate A2 from "did you remember to update
docs?" into "are docs to spec?"

### Pre-Gate A2 — Doc Quality Preflight (mandatory)

For each updated doc, programmatically verify spec compliance. Show a row
with ✅ / ❌ / ⚠️ for each check. The picker only appears once all ❌ are
resolved (⚠️ are non-blocking warnings).

**Universal checks (always run):**
1. **CLAUDE.md** — feature row added to Recently Shipped or in-progress section
2. **docs/brd.html** — every new user story has ≥ 2 Given-When-Then
   acceptance criteria (regex check on page content for `Given ... When
   ... Then` patterns; count must be ≥ 2 × story count)
3. **Revision History row** present on every modified doc with current CR ID

**Conditional checks (run only if the feature touches the relevant domain):**

4. **docs/database-design.html** present AND the migration script section
   includes a reversible rollback (search for `DROP`, `ALTER ... DROP`, or
   explicit "Rollback:" block) — for any feature with `change_type = data` /
   schema modification

5. **docs/api-reference.html** updated AND **`docs/api/openapi.yaml`**
   present AND validates — for any backend feature adding/modifying endpoints
   - `openapi-spec-validator docs/api/openapi.yaml` exits 0 (or `redocly lint`)
   - SLO table (section 6) has concrete P50/P95/P99 numbers (no `TBD`)
   - For endpoints touching auth/money/PII/multi-tenant/external integrations:
     Threat Model section present with all 6 STRIDE rows populated

5b. **docs/frontend-spec.html** updated — for any frontend feature adding/
   modifying routes, components, or pages
   - Section 6 (Performance Budget) has concrete KB numbers per touched route
     (no `TBD`, no "we'll measure later")
   - Section 7 (Accessibility Conformance Plan) names WCAG level + audit
     tooling (axe-core in CI is mandatory)
   - Section 4 (Component Inventory) appended for every new shared component

5c. **docs/ux-spec.html** updated — for any UX-touching feature (new screens,
   new components, flow changes, microcopy changes)
   - Section 6 (Accessibility Conformance) WCAG level named explicitly
   - Conformance table has Pass / Partial / Fail for every Level AA criterion
     touched by the change — every Partial / Fail row has issue link + owner
     + target date (no "TBD")
   - Section 5 (Component Specifications) appended for every new shared component
     visible in `docs/prototype/`
   - Design tokens (section 3) match `docs/prototype/components.html` (no drift)

6. **docs/security-design.html** updated — for any feature touching auth,
   data scope, multi-tenancy, or external integrations
   - OWASP checklist updated with new feature's risk class

7. **docs/adr/NNNN-<slug>.html** present — for any feature touching auth,
   multi-tenancy, schema, caching, payments, billing, or external integrations
   (the "non-trivial decision" set; mandate added in v3.6.0)
   - Uses TechLead ADR template
   - Status: Accepted (not Proposed)

Show the preflight result block:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔎 DOC QUALITY PREFLIGHT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CLAUDE.md — feature row added
✅ BRD — [N] stories, [M] GWT acceptance criteria (≥ 2× ratio met)
✅ Revision History — CR-[ID] row added on [docs touched]
✅ Schema migration — reversible rollback present (or "n/a — no schema change")
✅ API spec — openapi.yaml validates; SLO table populated; threat model present
✅ Security design — OWASP updated (or "n/a — no auth/data scope change")
✅ ADR — docs/adr/[NNNN]-[slug].html present (or "n/a — trivial change")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If any row is ❌: do **not** show the Gate A2 picker. List the failing rows
with the specific gap (e.g., "BRD has 3 stories but only 4 GWT criteria —
need ≥ 6"). Loop back to A-PHASE 3 with the agent that owns the failing doc.

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
  ✏️ docs/api/openapi.yaml       — [or "no changes needed"]
  ✏️ docs/frontend-spec.html     — [or "no changes needed"]
  ✏️ docs/ux-spec.html           — [or "no changes needed"]
  ✏️ docs/prototype/index.html    — [or "no changes needed"]
  ✏️ docs/security-design.html — [or "no changes needed"]
  ✏️ docs/adr/[NNNN]-[slug].html  — [or "no ADR required for this change"]

Doc Quality Preflight: ✅ all checks passed (see block above)

Please review all updated documents.

  "approve"        → create tasks + start development
  "revise [notes]" → update documents first
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate A2 — Documents updated. Approve to create tasks and start development?"
- options: ["approve", "revise"]

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

Use `AskUserQuestion` with:
- question: "Gate A3 — Task list ready. Approve to create GitHub issues + Notion tasks?"
- options: ["approve", "revise"]

⛔ GATE A3 — wait for approval.

### Step A4.2 — Create GitHub Issues
Read `~/.claude/devstarter-github.md` → follow PROC-GH-05 for each task.

### Step A4.3 — Create Notion Tasks
Read `~/.claude/devstarter-notion.md` → follow PROC-NT-03 for each task.

### Step A4.4 — TaskCreate for UI Visibility
For each task, call `TaskCreate` so progress is visible in the Claude Code UI:
```
TaskCreate(
  description: "[Feature Name] — [task name]",
  prompt: "Implement: [task description] (@[role], Effort: [S/M/L])"
)
```
Store returned task IDs for TaskUpdate calls in A5.2.

Show summary:
```
✅ [N] GitHub issues created
✅ [N] Notion tasks created (Status: To Do)
✅ [N] UI tasks created (TaskCreate)
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

Use `AskUserQuestion` with:
- question: "Ready to develop [N] tasks. Run autopilot or step through manually?"
- options: ["autopilot", "manual"]

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

### ⚠️ BRANCH GUARD — mandatory before every task
Before editing any file for any task:
1. Run `git branch --show-current`
2. If result is `develop`, `main`, `master`, or `uat` → **STOP — do not edit anything**
3. Execute PROC-GH-06 to create the correct `feature/[slug]` or `fix/[slug]` branch
4. Call `EnterWorktree` with that branch name
5. Confirm with `git branch --show-current` — MUST be on a `feature/*` or `fix/*` branch
This guard applies in autopilot mode, resume flows, and all other contexts without exception.

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
2. **TaskUpdate → in_progress:** `TaskUpdate(task_id, status="in_progress")` for this task's UI task
3. **Branch Guard:** Run `git branch --show-current` — if on `develop`, `main`, `master`, or `uat` → STOP
4. Read `~/.claude/devstarter-github.md` → PROC-GH-06: create `feature/[slug]` branch
5. **Enter worktree** — use `EnterWorktree` tool with the feature branch name for isolated working copy
6. Agent reads relevant docs from disk before coding:
   - @devstarter-backend → docs/api-reference.html + docs/database-design.html
   - @devstarter-frontend → docs/prototype/index.html + docs/brd.html
   - @devstarter-dba → docs/database-design.html
7. Implement code
7b. **Append to change log** — for each file modified, add to `memory/change-log-[slug].md`:
    ```markdown
    ### path/to/file.ext
    - ADDED: functionName — description
    - MODIFIED: functionName — what changed
    - FIXED: functionName — what was wrong, what was fixed
    ```
    Only log functions/methods actually created or changed (not unchanged files).
8. Read `~/.claude/devstarter-github.md` → PROC-GH-07: create PR
9. **Exit worktree** — use `ExitWorktree` tool to return to main working copy
10. **TaskUpdate → completed:** `TaskUpdate(task_id, status="completed")` for this task's UI task
11. **NOTION → In Review:** Read `~/.claude/devstarter-notion.md` → PROC-NT-05: status → In Review ⚠️ MANDATORY
12. Announce progress and **continue to next task immediately** — do NOT wait for approval:
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

**If `autopilot_mode=true`** — before showing Gate A4, call `PushNotification`:
```
title: "DevStarter — Gate A4 Ready"
body:  "Feature '[feature name]' — all [N] tasks done. Review and approve to merge."
```
This alerts the user without requiring them to watch the terminal.

### Pre-Gate A4 — Fitness Functions verification (mandatory)

Before showing the Gate A4 picker, verify CI fitness functions passed on
each PR. This wires `~/.claude/templates/github/fitness-functions.yml` into
the merge gate.

For each PR in this feature, run:
```bash
gh pr checks <PR_NUMBER> --json name,bucket --jq \
  '.[] | select(.name | contains("Fitness Functions")) | {name, bucket}'
```

Decision:
- **All `Fitness Functions / All checks` rows are `pass`** → ✅ proceed to next pre-gate step
- **Any row is `fail`** → ❌ Do NOT show Gate A4. Print the failing fitness
  check name, the specific metric (bundle KB, coverage %, complexity), the
  PR/file involved, and route to `/devstarter-debug` or `/devstarter-change
  fix-bug` to address. Re-run the gate after fix lands.
- **Workflow not present on the repo** → emit a one-line warning and
  proceed (some legacy projects don't have it yet); recommend installing
  per `~/.claude/templates/github/fitness-functions-setup.md`.
- **Workflow `pending`** → wait up to 5 min via `Monitor`, then re-check.
  Do not skip.

### Pre-Gate A4 — TechLead PR Review Checklist (mandatory)

After fitness functions pass, TechLead runs the 26-item PR Review Checklist
from `agents/devstarter-techlead.md` against each PR diff and posts the
findings as a PR comment. Gate A4 cannot proceed if any item in
**CORRECTNESS / SECURITY / OPERATIONS** is ❌ unmitigated.

For each PR in the feature, TechLead loads the diff and evaluates 26 items
across 6 categories. Mark each:

| Symbol | Meaning | Behavior |
|--------|---------|----------|
| ✅     | Pass    | No action |
| ❌     | Fail (must fix) | Blocks the gate; route to /devstarter-change fix-bug |
| ⚠️     | Waiver  | Allowed if a written rationale + owner + revisit-date is added to the PR description under `## Review Waivers` |
| n/a    | Doesn't apply | Skip (e.g., no DB migration → ops "Rollback is possible" is n/a) |

Severity classes:
- **🔴 BLOCKER (any ❌):** CORRECTNESS, SECURITY, OPERATIONS — Gate A4 cannot pass
- **🟡 MAJOR (any ❌):** TESTS, CODE QUALITY, OBSERVABILITY — surface in summary, owner can ship-with-debt by adding waiver

Post the checklist as a PR comment:
```bash
gh pr review <PR_NUMBER> --comment --body "$(cat <<EOF
## TechLead PR Review Checklist

**Correctness**
- [✅/❌] Happy path correct
- [✅/❌] Edge cases handled
- [✅/❌] Errors surfaced not swallowed
- [✅/❌] No race conditions
- [✅/❌] Concurrent access safe

**Security**
- [✅/❌] No secrets in code/logs
- [✅/❌] Input validated
- [✅/❌] Auth/authz correct
- [✅/❌] No new OWASP Top 10 issues
- [✅/❌] Dependencies not vulnerable

**Tests**
- [✅/❌] New logic unit tested
- [✅/❌] Edge cases tested
- [✅/❌] Integration tests updated
- [✅/❌] Test names describe behavior

**Code Quality**
- [✅/❌] Single responsibility
- [✅/❌] Descriptive names
- [✅/❌] No unnecessary complexity
- [✅/❌] No commented-out code
- [✅/❌] No magic numbers

**Observability**
- [✅/❌] Structured logging added
- [✅/❌] No PII in logs
- [✅/❌] Metrics instrumented

**Operations**
- [✅/❌] No breaking API changes without versioning
- [✅/❌] DB migrations backward-compatible
- [✅/❌] Rollback is possible

**Verdict:** [N] ✅ / [N] ❌ blockers / [N] ⚠️ waivers
EOF
)"
```

Decision:
- **All BLOCKER items ✅ or ⚠️ (with waiver in PR description):** proceed to Gate A4
- **Any BLOCKER ❌:** Do NOT show Gate A4. Route to `/devstarter-change fix-bug`
  for that finding (each ❌ becomes one bug intake). Re-run gate after fix.
- **MAJOR items have ❌:** surface in Gate A4 summary; owner can choose
  approve (with ship-as-debt waiver) or revise.

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

Fitness Functions (all PRs):
  ✅ Bundle budget       (within [BUDGET_KB] KB)
  ✅ Dependency rules    (0 violations)
  ✅ Coverage gate       ([PCT]% / [THRESHOLD]%)
  ✅ Complexity ceiling  (≤ [CEILING])
  (or ⚠️ skipped if workflow not installed on legacy repo — flag for follow-up)

TechLead PR Review Checklist (all PRs):
  Correctness    [N]/5 ✅
  Security       [N]/5 ✅
  Tests          [N]/4 ✅
  Code Quality   [N]/5 ✅
  Observability  [N]/3 ✅
  Operations     [N]/3 ✅
  ─────────────────────────
  Total          [N]/26 ✅  ([N] ⚠️ waivers, [N] ❌ blockers)
  → All BLOCKER class (Correctness/Security/Operations) items must be ✅ or ⚠️.

Review findings (combined fitness + TechLead checklist + agent reviews):
  🔴 Blockers: [N — all fixed before this gate]
  🟡 Major:    [N — listed below with recommendations]
  🟢 Minor:    [N — non-blocking suggestions]

  "approve"        → merge ALL PRs + mark ALL Done in Notion
  "revise [notes]" → fix issues and re-submit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate A4 — All [N] tasks complete. Approve to merge all PRs and mark Done?"
- options: ["approve", "revise"]

After approval:
- For EACH task:
  - PROC-GH-08: merge PR + close issue
  - PROC-NT-06: mark task → Done ⚠️ MANDATORY
- Update CLAUDE.md: tick feature checkbox ✅

---

## A-PHASE END — Testing Gate + Change Summary Document

### ⛔ GATE A-TEST — Testing Confirmation

After all PRs merged and Gate A4 approved, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 TESTING GATE — [Feature Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRs merged: [N]
Plan document: docs/feature/[slug]/plan.html

Test in your environment, then confirm below.
To re-trigger later: /devstarter-change → resume → select this feature.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate A-TEST — Has user testing passed for [feature name]?"
- options: ["Testing passed — generate summary doc", "Still testing — save checkpoint and stop"]

If "Still testing": write `memory/progress.json` with `"status": "waiting_test"` and stop.
If "Testing passed": proceed to Phase A-END below.

---

### Phase A-END — Generate Change Summary Document

1. **Read `memory/change-log-[slug].md`** — collect all function-level changes logged during dev
2. **Get file list:**
   ```bash
   git diff develop...feature/[slug] --name-only
   ```
   (If branch already merged/deleted, read from PR diff via `gh pr diff [PR_NUMBER] --name-only`)
3. **Fill template:** Read `~/.claude/templates/docs/devstarter-change-summary-template.html`
   Replace all `{{PLACEHOLDER}}` tokens:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | same CR-ID from plan.html |
| `{{CHANGE_TYPE}}` | `Add Feature` or `Modify Feature` |
| `{{FEATURE_NAME}}` | feature name |
| `{{SLUG}}` | same slug as plan |
| `{{BRANCH_NAME}}` | `feature/[slug]` |
| `{{PR_NUMBER}}` | from A-PHASE 5 |
| `{{GITHUB_ISSUE}}` | from A-PHASE 4 |
| `{{NOTION_TASK}}` | Notion task URL |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{PLAN_APPROVED_DATE}}` | date of Gate A1-DOC approval |
| `{{DEV_COMPLETED_DATE}}` | date of Gate A4 approval |
| `{{COMPLETED_DATE}}` | today |
| `{{ORIGINAL_PROBLEM}}` | from intake A-Q2 / Section 1.3 |
| `{{ROOT_CAUSE_OR_GAP}}` | business gap / reason for feature |
| `{{HOW_RESOLVED}}` | paragraph describing solution delivered |
| `{{ACCEPTANCE_CRITERIA_VERIFIED_ROWS}}` | `<tr>` per criterion: criterion, `✅ Pass` or `❌ Fail`, notes |
| `{{FILES_CHANGED_ROWS}}` | `<tr>` per file: path, badge (created/modified/deleted), notes |
| `{{TOTAL_FILES_CHANGED}}` | count |
| `{{FUNCTIONS_CHANGED_ROWS}}` | `<tr>` per function from change-log-[slug].md: name, file, badge (ADDED/MODIFIED/FIXED), description |
| `{{TOTAL_FUNCTIONS_CHANGED}}` | count |
| `{{KEY_DECISIONS_LIST}}` | `<li>` items — major implementation choices |
| `{{TECHNICAL_APPROACH}}` | paragraph summary of technical implementation |
| `{{DEVIATIONS_FROM_PLAN}}` | what changed from plan.html, or "None — implemented as planned" |
| `{{TESTS_ADDED_ROWS}}` | `<tr>` per test: name, file, type, description |
| `{{VERIFICATION_STEPS_LIST}}` | `<li>` numbered steps — how to verify the feature |
| `{{REGRESSION_CHECKS_ROWS}}` | `<tr>` per check: area, test, result |
| `{{REVIEWER_FOCUS_LIST}}` | `<li>` items — specific areas for code reviewer attention |
| `{{REVIEWER_FILES_LIST}}` | `<li>` items — files needing closest review |
| `{{REVIEWER_TRADEOFFS}}` | known trade-offs or deferred work |
| `{{QA_SCENARIOS_LIST}}` | `<li>` numbered test scenarios |
| `{{QA_EDGE_CASES_LIST}}` | `<li>` edge cases to verify |
| `{{QA_REGRESSION_LIST}}` | `<li>` regression areas |
| `{{QA_ENVIRONMENT_NOTES}}` | environment / config notes for QA |
| `{{MGMT_BUSINESS_IMPACT}}` | non-technical summary of business value |
| `{{MGMT_USER_IMPACT}}` | how end users are affected |
| `{{MGMT_RISK}}` | residual risk: Low/Medium/High + explanation |
| `{{MGMT_DELIVERED_LIST}}` | `<li>` plain-language bullets of what was delivered |

4. **Save to:** `docs/feature/[slug]/summary.html`
5. **Register in docs/index.html** under "Change Summaries" (create section if absent):
   ```html
   <a href="feature/[slug]/summary.html">[CHANGE_ID] — [Feature Name] — [Date] (Completed)</a>
   ```
6. **Generate management brief:** Read `~/.claude/templates/docs/devstarter-change-mgmt-template.html`
   Replace all `{{PLACEHOLDER}}` tokens — use plain business language, no technical terms:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_ID}}` | same CR-ID from plan.html |
| `{{FEATURE_NAME}}` | feature name |
| `{{COMPLETED_DATE}}` | today |
| `{{PROJECT_NAME}}` / `{{PROJECT_INITIALS}}` | from CLAUDE.md |
| `{{EXECUTIVE_SUMMARY}}` | 2–3 sentence non-technical summary of the feature and its business value |
| `{{PROBLEM_PLAIN_LANGUAGE}}` | plain English description of the gap or need that existed before this feature |
| `{{SITUATION_BEFORE}}` | bullet list: what was missing, what users couldn't do, what was manual/slow |
| `{{SITUATION_AFTER}}` | bullet list: what works now, what improved, what is automated |
| `{{WHO_WAS_AFFECTED}}` | which users or teams were impacted before; who benefits now |
| `{{IMPACT_IF_NOT_FIXED}}` | business risk or cost of leaving this undone |
| `{{DELIVERED_LIST}}` | `<li>` plain-language bullets of each capability delivered |
| `{{IMPROVEMENT_TILES}}` | `<div class="improvement-tile">` per improvement area with icon + title + plain description |
| `{{METRICS_ROWS}}` | `<tr>` per measurable outcome: metric name, before value, after value, improvement |
| `{{RESIDUAL_RISK_DETAIL}}` | Low/Medium/High + plain English explanation of any remaining risk |
| `{{WHAT_WAS_TESTED_LIST}}` | `<li>` plain description of what was verified (no test names — business scenarios) |
| `{{ROLLBACK_CAPABILITY}}` | can this be reverted? how quickly? any data implications? |
| `{{NEXT_STEPS_ROWS}}` | `<tr>` per follow-on action: action description, owner, timeline |
| `{{PLAN_PATH}}` | `feature/[slug]/plan.html` |
| `{{SUMMARY_PATH}}` | `feature/[slug]/summary.html` |

   **Save to:** `docs/feature/[slug]/mgmt-brief.html`
   **Register in docs/index.html** alongside summary.html entry:
   ```html
   <a href="feature/[slug]/mgmt-brief.html">[CHANGE_ID] — [Feature Name] — Management Brief — [Date]</a>
   ```

7. **Announce:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ FEATURE COMPLETE — [Feature Name]
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Plan:         docs/feature/[slug]/plan.html
   📝 Summary:      docs/feature/[slug]/summary.html
   📊 Mgmt Brief:   docs/feature/[slug]/mgmt-brief.html

   Share with:
     👁  Code Reviewers — summary.html, Section 7 "For Code Reviewers"
     ✅  QA Team       — summary.html, Section 7 "For QA / Testers"
     📊  Management   — mgmt-brief.html (non-technical)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

---

---
