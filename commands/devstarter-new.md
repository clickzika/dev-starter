# /devstarter-new — Start a New Project

Read `~/.claude/sdlc/devstarter-starter.md` and start a new project.
Follow all gates and approval rules in that file.
Generates `devstarter-config.yml` (primary config) and `.project.env` (bash compat layer).

---

## File Arg Handling (check FIRST — before anything else)

If the argument looks like a file path (ends with `.md`, `.txt`, or contains `/`):
```
/devstarter-new prd.md
/devstarter-new docs/brief.md
/devstarter-new /path/to/requirements.md
```

**Then:**
1. Read the file from disk
2. Extract project requirements from the content (name, description, features, users,
   stack preferences, constraints, success criteria)
3. Fill gaps with best-practice defaults
4. Skip the mode-picker and SECTION 0 entirely
5. Show INTAKE SUMMARY (pre-filled from file) and wait for approval
6. After approval → proceed directly to Q0-VCS

**File detection rule:** arg contains `.md` / `.txt` / a path separator (`/` or `\`),
OR the arg matches an existing file on disk → treat as file.
Otherwise → treat as inline text description (MODE 3).

---

## Inline Args Handling (text description)

If the user invoked this command with a plain text description:
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
