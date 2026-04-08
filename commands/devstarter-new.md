# /devstarter-new — Start a New Project

Read `~/.claude/sdlc/devstarter-starter.md` and start a new project.
Follow all gates and approval rules in that file.
Generates `devstarter-config.yml` (primary config) and `.project.env` (bash compat layer).

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a description argument, e.g.:
```
/devstarter-new a React todo app with login and dark mode
/devstarter-new ecommerce site Flutter + Node.js with payments
```

**Then:**
1. Treat the argument text as MODE 3 (Describe) input — skip the mode-picker entirely
2. Extract: project name, platform, stack, features, roles from the description
3. Fill any gaps with best-practice defaults
4. Show the PROJECT SUMMARY immediately for approval
5. Do NOT ask Q1–Q8 — the description replaces all questions

**If no args were provided** (user just typed `/devstarter-new`):
→ Proceed to `devstarter-starter.md` and show the mode-picker as the first prompt.
