# dev-change.md — Change Management Workflow

> **TL;DR** — Router for Add Feature / Remove Feature / Fix Bug operations · **Lifecycle** Build · **Gates** 0 (gates live in sub-files)

## Model: Sonnet (`claude-sonnet-4-6`)

Use for: add feature · remove feature · fix bug (routes to sub-files per selection).

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

### Rule 2 — Always Read First
Before any agent produces output, read `~/.claude/agents/[agent].md` (defines format, template, quality gate).
Before doing anything, read from disk: `CLAUDE.md`, `memory/progress.json`, `docs/[relevant].html`.
Never rely on chat history.

### Rule 3 — Save Before Handing Off
Write file → git commit → update memory/progress.json → announce handoff.

### Rule 3b — Mirror to Secondary VCS After Every Merge
After merging to primary VCS (`VCS_TYPE`), always run Step 5 from
`~/.claude/agents/shared/devstarter-vcs-pm-guide.md` to push to secondary VCS.
Skip if `VCS_SECONDARY_1` and `VCS_SECONDARY_2` are both `none` or unset.

### Rule 4 — Docs Before Code
Generate plain-language + technical HTML documents BEFORE writing any code. The gate is the HTML review, not chat output. Branch is created ONLY after approval.

Order: Impact Analysis → **kickoff.html** (plain sign-off) → **plan.html** (technical) → **Gate A1-DOC/C1-DOC approval** → **branch creation** → domain docs → Code

- Add Feature / Modify / Remove Feature: kickoff + plan saved to `docs/feature/[slug]/kickoff.html` + `docs/feature/[slug]/plan.html`
- Fix Bug: kickoff + plan saved to `docs/fix/[slug]/kickoff.html` + `docs/fix/[slug]/plan.html`
- After dev + user testing confirmed: generate `summary.html` in the same folder
- Existing domain docs (brd.html, api-reference.html, etc.) continue to be updated — kickoff.html, plan.html and summary.html supplement, not replace, those docs

**Document family (symmetric — plain + technical at each phase):**
| Phase | Plain-language | Technical |
|-------|----------------|-----------|
| Pre-dev | `kickoff.html` (requester + mgmt sign-off) | `plan.html` |
| Post-test | `mgmt-brief.html` | `summary.html` |

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
- **docs/feature/[slug]/kickoff.html** and **docs/fix/[slug]/kickoff.html** — generated from `~/.claude/templates/docs/devstarter-change-kickoff-template.html`. Plain-language pre-development sign-off for the requester (requirement / root-cause + fix solution) AND management (scope, why, effort, risk). Generated BEFORE plan.html, reviewed at Gate A1-DOC/C1-DOC. No code, plain business language in the requester/mgmt sections.
- **docs/feature/[slug]/plan.html** — generated from `~/.claude/templates/docs/devstarter-change-plan-template.html`. Required before any feature/modify dev starts.
- **docs/fix/[slug]/plan.html** — same template. Required before any bug fix dev starts.
- **docs/feature/[slug]/summary.html** and **docs/fix/[slug]/summary.html** — generated from `~/.claude/templates/docs/devstarter-change-summary-template.html`. Generated after testing confirmed.
- **docs/feature/[slug]/mgmt-brief.html** and **docs/fix/[slug]/mgmt-brief.html** — generated from `~/.claude/templates/docs/devstarter-change-mgmt-template.html`. Non-technical management brief. Generated alongside summary.html after testing confirmed. Plain business language — no code, no technical terms.
- **Function-level change tracking** — agents append to `memory/change-log-[slug].md` during development. Summary phase reads this file. Format: `### file.ext` → `- ADDED/MODIFIED/FIXED: functionName — description`.
- **Document Author (MANDATORY)** — the `{{AUTHOR}}` / "Author" / "Prepared by" field in EVERY generated document MUST be the **Name** from the **install-root** `USER.md` — `~/.claude/USER.md` (Mac/Linux) or `%USERPROFILE%\.claude\USER.md` (Windows), Identity section. NOT the project-local `USER.md`. If that file is missing or has no `Name:` value, use the literal fallback **`IT Dept`**. NEVER an agent alias (`@devstarter-ba`, `@devstarter-techlead`, etc.). Read the root USER.md at generation time and use the current Name value. Applies to kickoff, plan, summary, mgmt-brief, incident-brief, and any other generated doc across all flows.
- **Bilingual content (MANDATORY)** — ALL generated documents MUST contain both English and Thai for every text block using `<span class="lang-en">` / `<span class="lang-th">` pairs. See Bilingual Content Rule in `agents/shared/devstarter-agent-base.md`. Code blocks, file paths, and technical identifiers are NOT translated. Lang toggle + PDF export buttons are built into all templates.

### Rule 9 — Branch Guard (ALWAYS active, no exceptions)
**NEVER edit any file while on `develop`, `main`, `master`, or `uat`.**
Before writing any code or editing any file:
1. Run `git branch --show-current`
2. If output is `develop`, `main`, `master`, or `uat` → **STOP immediately**
3. Create and checkout `feature/[slug]` or `fix/[slug]` branch via PROC-GH-06
4. Confirm with `git branch --show-current` — result MUST NOT be a protected branch
5. Only then proceed to editing
This rule cannot be skipped in autopilot mode, resume flows, or any other context.
> **Technical enforcement (secondary):** A PreToolUse hook (`pre-edit-branch-guard.js`) blocks Edit/Write tool calls on protected branches. Install via `install.sh --hooks`.

---

## ⚡ Quick Mode — `--quick` flag

If the user invoked `/devstarter-change --quick ...`, apply scope-based
agent + doc skips per the algorithm below. This reduces newcomer reading
load from ~3000 lines to ~1000 for a typical scoped change. Documented
in detail in `~/.claude/skills/devstarter-change/SKILL.md` (Quick Mode
section).

**Auto-scope detection (run after intake):**

| Detected scope | Skip these agents | Skip these doc updates |
|----------------|-------------------|------------------------|
| Backend-only (api/, services/, db/) | @uxui, @frontend, @mobile | docs/frontend-spec.html, docs/ux-spec.html, docs/prototype/ |
| Frontend-only (frontend/, components/) | @backend, @dba, @mobile | docs/api-reference.html, docs/api/openapi.yaml, docs/database-design.html |
| Mobile-only (mobile/, native/) | @uxui (web), @frontend (web) | docs/frontend-spec.html (web parts) |
| Full-stack | (none — full flow) | (none) |
| Bug fix (localized) | @ba (no BRD update for tiny bugs) | docs/brd.html (tiny bugs only) |

**Auto-promotion guards** (these scope conditions force full mode even with `--quick`):

- Touches auth, multi-tenancy, schema migrations, billing, payments, or external integrations → full mode (ADR + Threat Model + SLO are mandatory regardless of scope)
- Cross-cutting refactor → full mode
- New top-level domain or bounded context → full mode

When auto-promotion fires, print:
```
⚠️  --quick disabled for this change — [reason].
   This scope requires the full agent flow because [auth/schema/etc.].
```

**Doc Quality Preflight** at Gate A2 still runs in `--quick` mode, but
only checks the docs that ARE updated for the detected scope. Quality
bar is unchanged; surface area is smaller.

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
