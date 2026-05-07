# dev-change.md — Change Management Workflow

## Model: Sonnet (`claude-sonnet-4-6`)

## How to Use

Place at `~/.claude/devstarter-change.md`

Use when a project already exists and you need to:
- Add a new feature
- Remove an existing feature
- Fix a bug

```
claude
> Read ~/.claude/devstarter-change.md and help me make a change
```

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## ⚠️ CRITICAL RULES

### Rule 0 — Checkpoint & Auto-Resume (ALWAYS active)

Read `~/.claude/sdlc/devstarter-checkpoint.md` and follow the protocol:
1. **At start** — Setup Cron auto-resume (every 10 minutes)
2. **After every task** — Save checkpoint to `memory/progress.json`
3. **At end** — Cleanup (update status to completed, delete Cron)

---

### Rule 1 — Hard Approval Gates
STOP at every gate. Show output. Wait for "approve" or "revise [notes]".
Never proceed without explicit approval.

### Rule 2 — Read Agent File Before Doing Any Work
Before any agent produces output, MUST read `~/.claude/agents/[agent].md` first.
The agent file defines format, template, standards, and quality gate for every deliverable.

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

### Rule 3b — Mirror to Secondary VCS After Every Merge
After merging to primary VCS (`VCS_TYPE`), always run Step 5 from
`~/.claude/agents/shared/devstarter-vcs-pm-guide.md` to push to secondary VCS.
Skip if `VCS_SECONDARY_1` and `VCS_SECONDARY_2` are both `none` or unset.

### Rule 4 — Docs Before Code
Always update documents before writing any code.
Order: CLAUDE.md → BRD → Schema → API → UX → Security → Code

### Rule 5 — Notion Task Status MUST Be Updated
**Before starting any task:** PROC-NT-04 → Status: "In Progress"
**After creating PR:** PROC-NT-05 → Status: "In Review"
**After PR merged:** PROC-NT-06 → Status: "Done"
Never skip status updates. Each task MUST go through: To Do → In Progress → In Review → Done.

### Rule 6 — Continuous Development After Doc Approval
After all documents are approved (Gate A2/B2/C1), develop ALL tasks continuously without stopping for per-task approval. Only show the final approval gate (Gate A4/B3/C2) after ALL tasks are complete.

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

### Rule 9 — Branch Guard (ALWAYS active, no exceptions)
**NEVER edit any file while on `develop`, `main`, `master`, or `uat`.**
Before writing any code or editing any file:
1. Run `git branch --show-current`
2. If output is `develop`, `main`, `master`, or `uat` → **STOP immediately**
3. Create and checkout `feature/[slug]` or `fix/[slug]` branch via PROC-GH-06
4. Confirm with `git branch --show-current` — result MUST NOT be a protected branch
5. Only then proceed to editing
This rule cannot be skipped in autopilot mode, resume flows, or any other context.

---

## ⚡ FIRST ACTION — Show This Before Anything Else

**If no inline args were provided, the very first message to the user MUST be:**

```
What do you want to do?

  1. ➕ Add feature    — add something new
  2. ➖ Remove feature — remove or disable something
  3. 🐛 Fix bug        — something is broken

Or just describe it:
  "add dark mode", "remove social login", "fix login redirect"
```

Use `AskUserQuestion` with:
- question: "What do you want to do?"
- options: ["Add feature", "Remove feature", "Fix bug"]

Wait for the user to select or type a description. Nothing else before this.

**Special case — inline args:** If the user ran `/devstarter-change [text]`,
skip this prompt. Extract type + description from the args and proceed directly.

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

**Q4. Is there an API Request Spec from another project?** (ask only if Q1 = 1)
1. Yes — provide file path (e.g. `/path/to/other-project/docs/api-request.html`)
2. No — I'll describe the requirements myself

If user picks **1**: read the api-request.html file → use it as the feature spec.
Skip A-Q1 to A-Q5 (the spec already defines endpoints, request/response, auth).
Go directly to A-PHASE 2 (Impact Analysis) with the spec as input.

---

Then route to the correct operation below.

---

---

## Operation Sub-files

After Phase 1 routing, load the correct operation file:

| User selected | Load |
|---------------|------|
| Q1 = 1 (Add Feature) | `~/.claude/sdlc/devstarter-change-add.md` |
| Q1 = 2 (Remove Feature) | `~/.claude/sdlc/devstarter-change-remove.md` |
| Q1 = 3 (Fix Bug) | `~/.claude/sdlc/devstarter-change-bug.md` |
| Resuming mid-change | `~/.claude/sdlc/devstarter-change-resume.md` |
