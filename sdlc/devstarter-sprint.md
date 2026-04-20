# dev-sprint.md — Sprint Planning

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

At the start of each sprint:
```
claude
> Read ~/.claude/devstarter-sprint.md and plan sprint [N]
```

---

## PHASE 1 — Collect Sprint Context

Agent reads automatically:
- CLAUDE.md → Progress Tracker (what is done, what remains)
- Notion → backlog tasks
- GitHub → open issues
- Previous retrospective (if exists)

**Q1. Sprint number and duration?**
(e.g. "Sprint 3, 2 weeks, Nov 4–15")

**Q2. Who is available this sprint?**
(free text — any team members on leave or part-time?)

**Q3. Any fixed commitments or deadlines?**
(free text — demos, releases, external deadlines)

**Q4. What is the sprint goal?**
(free text — one sentence: "By end of sprint, users can [X]")

---

## PHASE 2 — Backlog Review

Agent shows all pending items from CLAUDE.md + Notion:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 AVAILABLE BACKLOG — Sprint [N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Carried from last sprint:
  🔴 [task] — [effort] — [blocked by?]

Gate 4 — Features (in priority order):
  [ ] [feature 1] — [effort] — [agent]
  [ ] [feature 2] — [effort] — [agent]
  [ ] [feature 3] — [effort] — [agent]

Bug backlog:
  🟠 [bug 1] — [severity] — [effort]
  🟡 [bug 2] — [severity] — [effort]

Technical debt:
  [item 1] — [effort]

Team capacity this sprint:
  [N] person-days available
  [N] story points (based on last sprint velocity)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3 — Sprint Selection

Agent recommends sprint scope based on capacity:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 RECOMMENDED SPRINT [N] SCOPE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint goal: [goal]

Committed items:
  [ ] [item 1] — @[agent] — [effort]
  [ ] [item 2] — @[agent] — [effort]
  [ ] [item 3] — @[agent] — [effort]

Buffer (20% capacity reserved):
  [ ] [stretch item if capacity allows]

Total effort: [N] / [N] available capacity

  "approve"        → create sprint in Notion + GitHub
  "revise [notes]" → adjust scope
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE S1 — wait for approval before creating sprint.

---

## PHASE 4 — Create Sprint in Tools

After approval:

### GitHub Milestone
```bash
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  --field title="Sprint [N]" \
  --field description="[sprint goal]" \
  --field due_on="[end date]T17:00:00Z"
```

### Assign Issues to Milestone
```bash
for issue in [issue numbers]; do
  gh issue edit $issue --milestone "Sprint [N]"
done
```

### Notion — Update Sprint Field
Read `~/.claude/devstarter-notion.md` → PROC-NT-04 for each task:
- Update Sprint field to "Sprint [N]"
- Keep Status as "To Do"

### TaskCreate — UI Visibility
For each committed sprint item, call `TaskCreate`:
```
TaskCreate(
  description: "Sprint [N] — [task name]",
  prompt: "[task description] (@[role], Effort: [S/M/L])"
)
```

Show summary:
```
✅ Sprint [N] created
  GitHub milestone: [URL]
  Notion sprint view: [URL]
  [N] issues assigned
  [N] Notion tasks assigned
  [N] UI tasks created (TaskCreate)
```

---

## PHASE 5 — Definition of Done

Agent confirms DoD for this sprint:

```
A task is DONE when:
  [ ] Code written and reviewed
  [ ] Unit tests passing (≥ threshold)
  [ ] Integration tests passing
  [ ] PR merged to develop
  [ ] GitHub issue closed
  [ ] Notion task → Done
  [ ] Relevant docs updated (if feature)
  [ ] CLAUDE.md Progress Tracker updated
  [ ] No new linting errors
  [ ] Tested in development environment
```

---

## Daily Standup Helper

During the sprint, use:
```
claude
> What did we complete yesterday? What is in progress? Any blockers?
```

Agent reads GitHub + Notion and generates standup summary:
```
📊 STANDUP — [Date]
Yesterday: [N] tasks moved to Done
Today:     [N] tasks In Progress
Blockers:  [list or "none"]
Sprint:    [N]% complete ([N]/[N] tasks done)
```
