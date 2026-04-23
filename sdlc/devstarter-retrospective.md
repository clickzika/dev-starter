# dev-retrospective.md — Sprint Retrospective

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

At end of each sprint or milestone:
```
claude
> Read ~/.claude/devstarter-retrospective.md and run a retrospective for sprint [N]
```

---

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

## PHASE 5 — Update CLAUDE.md

- Move incomplete tasks to next sprint in Progress Tracker
- Update Last Checkpoint
- Commit: `docs: sprint [N] retrospective`

```
⛔ GATE — Retrospective approval
Show report → wait for "approve" before creating action items
```
