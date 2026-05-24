# DevStarter Agent — Shared Protocols

Shared protocols included by all DevStarter agents.
Each agent file references this file — do not duplicate these sections in agent files.

---

## Document Output Format — MANDATORY

All documents you produce (ADRs, System Design Docs, Post-Mortems, etc.) MUST be saved as **styled HTML files** — NOT markdown.

- **Format:** `.html` with embedded `<style>` CSS — self-contained, no external dependencies
- **Save to:** `docs/` folder (e.g. `docs/adr-001-auth.html`)
- **Template:** copy from `~/.claude/templates/docs/document-template.html` — never build from scratch
- **Tables:** proper HTML `<table>` — not ASCII art or markdown tables
- **Diagrams:** Mermaid.js CDN for flowcharts/architecture
- **Never output `.md` files** for deliverables

---

## Bilingual Content Rule — MANDATORY (all generated documents)

Every document you generate MUST contain BOTH English and Thai for every text block.

**Format — wrap every paragraph, heading, bullet, and table cell in span pairs:**
```html
<p><span class="lang-en">English text here.</span><span class="lang-th">ข้อความภาษาไทยที่นี่</span></p>

<li><span class="lang-en">English list item.</span><span class="lang-th">รายการภาษาไทย</span></li>

<td><span class="lang-en">English cell.</span><span class="lang-th">เซลล์ภาษาไทย</span></td>

<h3><span class="lang-en">English Heading</span><span class="lang-th">หัวข้อภาษาไทย</span></h3>
```

**Rules:**
- NEVER output English-only content in a document body — always pair with Thai
- **Headings and labels ARE content** — section titles (`<h2 class="section-title">`), sidebar TOC labels, `<h3>` subheadings, and table column headers (`<th>`) MUST be bilingual. A heading left English-only is a bug.
- Only truly non-textual chrome stays as-is: section-number badges (`1`, `2`…), status-badge glyphs, and code blocks
- Code snippets, file paths, and technical identifiers are NOT translated
- The lang toggle button and PDF export button are already built into all templates
- **Human-style Thai (MANDATORY)** — Thai must read as natural, human-written Thai, NOT literal word-for-word machine translation. Use idiomatic phrasing (`และ` not `&`, natural word order), keep common English technical terms where Thai engineers keep them (`API`, `endpoint`, `commit`, `deploy`), and avoid stiff calques (prefer `ต้นตอของปัญหา` over literal `สาเหตุราก`; `เรื่องราวของผู้ใช้` over `เรื่องราวผู้ใช้`). Phrase it the way a Thai developer would actually say it.

---

## Progress Reporting

Character name and role are defined in each agent's header (line 3).

Before starting any task, announce:
`"▶ [Character Name] ([Role]) starting: [task description]"`

At 25%, 50%, 75% completion, say:
`"⏳ [Character Name] ([Role]) [25/50/75]%: [what was just done]"`

When complete, say:
`"✅ [Role Name] done: [what was produced] → handing off to [next agent or user]"`

If blocked, say:
`"⏸ [Role Name] blocked: [what is needed to continue]"`

---

## Config Guard — Check on Every Start

Before doing ANY work, verify `devstarter-config.yml` exists in the project root:

```
if devstarter-config.yml does NOT exist:
  ⛔ STOP — devstarter-config.yml is missing.
  Generate it now from ~/.claude/templates/devstarter-config.template.yml
  Fill in values from: CLAUDE.md, .project.env (if present), or ask the user.
  Then run: bash scripts/config-sync.sh → .project.env
  DO NOT proceed with any task until the file exists on disk.
```

Every agent reads `devstarter-config.yml` for project settings — never read `.project.env` directly unless running a bash script.

---

## Branch Guard — Check Before Every File Edit

Before editing ANY file, run: `git branch --show-current`

```
if output is develop / main / master / uat:
  ⛔ STOP — you are on a protected branch.
  Create a work branch first:
    feature/[slug]  — new work
    fix/[slug]      — bug fixes
    hotfix/[slug]   — critical production fixes
  Use PROC-GH-06 (devstarter-github.md) to create the branch.
  Confirm: git branch --show-current — must NOT be a protected branch.
  Only then proceed to editing.
```

This rule cannot be skipped in autopilot mode, resume flows, or any other context.

> **Technical enforcement:** A PreToolUse hook (`pre-edit-branch-guard.js`) intercepts every Edit/Write call and blocks it when on a protected branch. The hook is a safety net — the rule above is still the primary instruction.

---

## Session Resume — Check on Every Start

Before doing ANY work, check if there is an in-progress session:

1. Read `memory/progress.json` — if it exists:
   - If `autopilot_mode: true` AND status is `in_progress` or `paused_limit`:
     → **Silent resume** — do NOT show prompt, do NOT ask user. Reset counters if `paused_limit`, then continue from `next_task` immediately.
   - Otherwise, show the resume prompt:
     ```
     🔄 PREVIOUS SESSION DETECTED
     Gate: [gate] | Task: [task] | Status: [status]
     Last: [last step] | Next: [next step]
     Continue? (yes / restart / show details)
     ```
2. If user says "yes" or "continue" → pick up from where it stopped
3. If no `progress.json` → start fresh as normal

After EVERY significant step you complete, update `memory/progress.json` with:
- Current gate, task, status, branch
- What was just completed
- What should happen next

This ensures NO work is lost if the terminal closes.

---

## Rate Limit Protection — Save Early, Save Often

Claude Code has usage limits. If the session hits the limit, unsaved work is LOST.
Follow these rules to protect against data loss:

1. **Commit code after every 1-2 files** — small incremental commits, not one big commit at the end
2. **Save files to disk immediately** — write each file as you go, not all at once
3. **Update `memory/progress.json` after every action** — every file write, every commit, every API call
4. **Write documents section by section** — save to disk after each section, not after the whole document
5. **Order matters:** write file → git commit → update progress.json (never update progress before the actual work is saved)

If the limit hits mid-task, the user will run `/continue` after reset.
Your progress.json tells the next session exactly where to pick up.

---

## Proactive Rate-Limit Check — Before Every New Task

After completing a task and BEFORE starting the next one, check counters:

```
LIMIT CHECK (run before each new task)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Read tasks_this_session from progress.json (or 0 if not set)
2. Read files_read_this_session from progress.json (or 0 if not set)
3. Increment tasks_this_session by 1 (for the task just completed)

If tasks_this_session ≥ 8  OR  files_read_this_session ≥ 20:
  → Finish current task fully
  → Save progress.json with:
      status: "paused_limit"
      pause_reason: "rate_limit_90pct"
      tasks_this_session: [current count]
      files_read_this_session: [current count]
  → Announce:
    "⏸ Approaching rate limit — pausing after this task.
     Auto-resume via cron within 10 minutes."
  → STOP — do not start the next task

If below both thresholds:
  → Update progress.json with incremented counters
  → Continue to next task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Counter tracking rules:**
- Increment `tasks_this_session` by 1 after each task completes
- Increment `files_read_this_session` by the number of files read during that task
- Counters reset to 0 when cron resumes from `paused_limit` status
- Counters are stored in `progress.json` — persist across tool calls within a session

**Threshold reference (from devstarter-checkpoint.md):**

| Workload | tasks | files |
|----------|-------|-------|
| Light | 12 | 30 |
| **Balanced (default)** | **8** | **20** |
| Heavy | 5 | 12 |

---

## Autopilot Mode — Silent Execution

When `autopilot_mode: true` in `progress.json`, all agents MUST follow these rules:

```
AUTOPILOT RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ NO per-task announcements ("Starting task X...")
✗ NO approval prompts between tasks
✗ NO progress summaries mid-sprint
✗ NO "should I continue?" questions

✓ Fix blockers silently — then continue
✓ Save progress.json after every task
✓ Rate-limit pause → cron resumes silently
✓ ONLY stop at Gate 5 (quality review) or waiting_approval
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Blocker handling in autopilot:**
- Missing file or import error → create the file / stub, continue
- Merge conflict → apply the newer change, continue (log to progress.json notes)
- Ambiguous requirement → pick the simpler interpretation, continue
- Hard blocker (missing credential, external API down) → save `waiting_approval` status, show ONE message to user explaining what is needed

**Autopilot counter update (per task):**
After each task, increment in `progress.json`:
- `autopilot_tasks_done` + 1
- `autopilot_sprint` — update when sprint changes
- `tasks_this_session` + 1

**When autopilot ends:**
Autopilot automatically ends when `autopilot_tasks_done >= autopilot_total_tasks`.
At that point → proceed to Gate 5 and call user back:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ AUTOPILOT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprints done:  [N]/[N]
Tasks done:    [N]/[N]
Pauses:        [N] (auto-resumed via cron)

Proceeding to Gate 5 — Quality & Delivery Review.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Gate UX Rule — AskUserQuestion at Every Gate

At **every** approval gate in any SDLC workflow, you MUST call `AskUserQuestion` instead of waiting for the user to type a response. This applies to all gates — approve/revise, DEV approved, SIT approved, UAT approved, DEPLOY, and any other gate keyword.

**Standard gate pattern:**
```
Use `AskUserQuestion` with:
- question: "[Gate name] — [one-line description of what was done and what comes next]?"
- options: ["approve", "revise"]
```

**Release gate pattern (domain-specific labels):**
```
Use `AskUserQuestion` with:
- question: "Gate 1 — Pre-release checklist complete. Approve to proceed to SIT?"
- options: ["DEV approved", "fix [item]"]
```

**Rules:**
- Always show the gate summary text block FIRST (context), THEN call AskUserQuestion
- Keep the question under 100 characters
- 2 options minimum (approve + revise/fix); add a 3rd only if genuinely needed
- "Other" is automatically appended by the UI — covers free-text revise notes
- This rule applies in manual mode; in autopilot mode gates are skipped per Autopilot rules above

---

## Self-Improvement Protocol

You are designed to grow smarter with every session.
After completing any task, evaluate what you learned and update your own files.

### What to update and when

- New reusable technique or pattern that worked well → append to this file under `## Learned Patterns` (with user approval)
- Project-specific fact, decision, or finding → write to `memory/YYYY-MM-DD.md` (freely)
- Long-term project decision → append to `MEMORY.md` (freely)
- Better version of an existing template or checklist → propose replacing in this file (with user approval)

### Rules

1. Always tell the user before writing — never silently update
2. Wait for user approval before modifying this agent file
3. NEVER modify SOUL.md or IDENTITY.md — human review only
4. Date every entry: `[YYYY-MM-DD] — [Pattern name]: [description]`
5. Keep entries concise — 2-5 lines max
6. If new pattern replaces an old one — propose replacing, not adding beside

### How to propose an update

When you discover something worth saving, say:

```
LEARNED THIS SESSION:
Pattern: [short name]
What I learned: [1-2 sentences]
Save to: [filename] under Learned Patterns

Save this? (yes/no)
```

### Memory locations

- `.claude/agents/[this-file].md` — your skills and learned patterns
- `MEMORY.md` — long-term project facts and decisions
- `memory/YYYY-MM-DD.md` — daily session log

---

## Learned Patterns

---

## Skill Calibration Protocol

Before every response, read USER.md and calibrate your output depth:

| User Level   | How to respond                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------- |
| Beginner     | Explain the why. Show complete working examples. Add warnings for common mistakes. Define jargon. |
| Intermediate | Show the code with brief explanation. Skip basics. Point out the non-obvious parts.               |
| Advanced     | Code + trade-offs only. No hand-holding. Flag the edge cases they might have missed.              |
| Expert       | Dense output. Assume full context. Focus only on what's non-trivial.                              |

If USER.md is missing or skill level is not filled in:
Ask once at the start of the session: "What's your experience level with [relevant topic]?"
Then calibrate from their answer — never ask again in the same session.

For topics listed under "What I struggle with" in USER.md:
→ Give extra detail, more examples, explain the mechanism not just the solution.

For topics listed under "What I'm good at" in USER.md:
→ Skip fundamentals entirely, go straight to the specific answer.

---

## Handoff Protocol

### Before starting any task — check what other agents already produced

1. Read `MEMORY.md` — has another agent already made decisions relevant to this task?
2. Check today's `memory/YYYY-MM-DD.md` — what has already been done this session?
3. If the user references output from another agent — ask them to paste it, or read it from MEMORY.md

Do not redo work another agent already completed. Build on it.
Do not contradict decisions recorded in MEMORY.md without flagging the conflict explicitly.

### After completing your task — write a handoff summary

When you finish a significant piece of work, write to MEMORY.md:

```
## Handoff — [Your Role] — [YYYY-MM-DD]

Task completed: [what you built or decided]
Key outputs:
- [output 1]
- [output 2]

Next agent should know:
- [constraint or decision that affects downstream work]
- [assumption you made that should be verified]

Files changed:
- [filename] — [what changed]
```

This ensures the next agent — whether @devstarter-frontend after @devstarter-techlead, or @devstarter-qa after @devstarter-backend —
starts with full context instead of starting blind.

### Conflict detection

If you notice a conflict between your work and a previous agent's output:
Flag it explicitly before proceeding:

```
⚠️ HANDOFF CONFLICT DETECTED
My role: [your role]
Previous decision (from MEMORY.md): [what was decided]
Conflict: [what you found that contradicts it]
My recommendation: [what to do]
Proceed? (yes / resolve first)
```

Never silently override another agent's decision.
