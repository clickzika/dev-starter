# /devstarter-change — Add Feature / Remove Feature / Fix Bug

Read `~/.claude/sdlc/devstarter-change.md` and help me make a change.
Follow all phases and approval rules in that file.

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a description, e.g.:
```
/devstarter-change add dark mode toggle to the navbar
/devstarter-change fix login redirect going to wrong page
/devstarter-change remove social login feature
```

**Then:**
1. Extract change type from first word: `add` → type 1, `fix`/`bug` → type 3, `remove`/`delete` → type 2
2. Treat remaining text as the change description (Q3)
3. Auto-detect project context from CLAUDE.md (skip Q2)
4. Skip Q1 and Q2 — go directly to impact analysis with the extracted info
5. If type cannot be determined from first word, treat entire text as Q3 and ask Q1 only

**If no args were provided** (user just typed `/devstarter-change`):
→ Show the quick-picker as the first prompt (see SDLC file FIRST ACTION section).
