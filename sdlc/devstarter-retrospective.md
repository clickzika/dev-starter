# dev-retrospective.md — Sprint Retrospective

> **TL;DR** — Sprint retrospective with action items (what worked / didn't / change) · **Lifecycle** Operate · **Gates** 1

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## PHASE 1 — Collect Sprint Data

Agent reads automatically:
- CLAUDE.md → Progress Tracker (what was planned)
- Notion → completed/incomplete tasks
- GitHub → PRs merged, issues closed, bugs filed
- `docs/bugfix-log.html` → bugs this sprint

Then shows summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SPRINT [N] SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Period:    [start date] → [end date]
Planned:   [N] tasks
Completed: [N] tasks ([%])
Carried:   [N] tasks → next sprint
Bugs:      [N] filed, [N] fixed
PRs:       [N] merged, [N] open

Velocity:  [story points or task count]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 2 — Team Input

Agent asks each team member (or solo developer):

**Q1. What went well this sprint?**
(free text — things to keep doing)

**Q2. What did not go well?**
(free text — pain points, blockers, friction)

**Q3. What would you do differently?**
(free text — improvements for next sprint)

**Q4. Any shoutouts or kudos?**
(free text — recognize good work)

---

## PHASE 3 — Retrospective Report

Agent writes `docs/retrospective-sprint-[N].html`:

```
Sections:
1. Sprint metrics (velocity, completion rate, bug count)
2. What went well
3. What did not go well
4. Action items (who, what, by when)
5. Kudos
6. Carry-over tasks → next sprint
```

---

## PHASE 4 — Action Items

For each improvement identified:
- Create GitHub issue: `chore: [improvement]`
- Create Notion task: Status "To Do", Sprint: [N+1]
- Assign owner

---

## ⚡ Vault Emit — Retrospective Lessons (v5.9.0+)

After Phase 4 (GitHub issues + Notion tasks created), optionally capture process lessons to the vault.

Read `obsidian.enabled` from `devstarter-config.yml`.
If `obsidian.enabled: false` or `obsidian:` block absent → silently skip; proceed to Phase 5.
If `obsidian.enabled: true`:
  Use `AskUserQuestion` with:
  - question: "Save retro lessons to vault?"
  - options: ["Yes — capture process lessons", "No — skip"]
  If "Yes": collect significant lessons (Q2: what did not go well + Q3: what would you do differently + top 1–3 action items from Phase 4):
    For each distinct process lesson worth sharing:
      Run Vault Emit Procedure (E1–E5) from `sdlc/devstarter-knowledge.md`
      Template: `~/.claude/templates/obsidian/technique-note.md`
      Fill:
        type: technique
        topic: process
        title: "[Sprint N] — [lesson title]"
        symptom: what went wrong / what caused friction
        root_cause_category: most appropriate vocabulary term (e.g. config-drift, missing-validation, process-gap)
        tags: [technique, process, sprint-retro]
        source: Sprint [N] retrospective — [date]
      Emit one note per distinct lesson (not one per action item; group related items).
    Show E5 confirmation per emitted note.
  If "No": continue.
  If transport: git — remind (do not auto-run): commit + push vault repo.

---

## PHASE 5 — Update CLAUDE.md

- Move incomplete tasks to next sprint in Progress Tracker
- Update Last Checkpoint
- Commit: `docs: sprint [N] retrospective`

Use `AskUserQuestion` with:
- question: "Gate — Retrospective report complete. Approve to create action items?"
- options: ["approve", "revise"]

⛔ GATE — wait for approval before creating action items.
