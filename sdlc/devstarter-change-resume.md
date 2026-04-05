# RESUME INSTRUCTIONS

If resuming mid-change:

1. Read `memory/progress.json` first
2. Identify which operation (A/B/C) and which phase
3. Read the relevant docs from disk
4. Announce:
   ```
   📂 Resuming [Operation A/B/C] — [Phase name]
   Reading from: [filename]
   Last completed: [from progress.json]
   Next action: [from progress.json]
   ```
5. Continue from next action — never skip gate approvals
6. Run /compact when context gets long

---

# PROGRESS TRACKER TEMPLATE

```
## Change In Progress
Operation:      [A: Add Feature / B: Remove Feature / C: Fix Bug]
Name:           [feature name or bug description]
Started:        [YYYY-MM-DD]
Context:        [New / Existing / Live / Migration]
GitHub Issue:   #[N]
Notion Task:    [URL]
Branch:         [branch name]

Gate status:
  [ ] Gate 1 — Impact analysis approved
  [ ] Gate 2 — Documents approved
  [ ] Gate 3 — Task list approved (A/B only)
  [ ] Gate 4 — Implementation approved
  [ ] Done — merged + closed

Last completed: [what was just done]
Next action:    [exactly what to do next]
Files modified: [list]
```
