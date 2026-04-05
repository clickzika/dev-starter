# /devstarter-audit — Audit & Review Project

Read `~/.claude/sdlc/devstarter-audit.md` and audit this project.
Follow all phases and approval rules in that file.

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a description, e.g.:
```
/devstarter-audit security
/devstarter-audit full audit and fix everything
/devstarter-audit performance and dependencies, report only
```

**Then:**
1. Extract audit type(s) from the text (security/quality/performance/tests/dependencies/architecture/full)
2. Extract outcome from the text: "report" → type 1, "plan" → type 2, "fix" → type 3 (default: type 1)
3. Skip Q1 (use folder name), Q2 (extracted), Q3 (extracted), Q5 (assume staging)
4. Ask Q4 only ("any known issues?") if not mentioned — or skip if "full" audit was requested
5. Start the audit immediately

**If no args were provided** (user just typed `/devstarter-audit`):
→ Show the quick-picker as the first prompt (see SDLC file FIRST ACTION section).
