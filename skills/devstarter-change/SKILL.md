# /devstarter-change — Add Feature / Remove Feature / Fix Bug

Read `~/.claude/sdlc/devstarter-change.md` and help me make a change.
Follow all phases and approval rules in that file.

---

## File Arg Handling (check FIRST — before anything else)

If the argument looks like a file path (ends with `.md`, `.txt`, or contains `/`):
```
/devstarter-change newfeature.md
/devstarter-change docs/feature-spec.md
/devstarter-change bugfix.md
```

**Then:**
1. Read the file from disk
2. Detect change type from file content:
   - Contains "bug", "error", "fix", "broken" → type 3 (Fix Bug)
   - Contains "AS-IS", "TO-BE", "modify", "change existing" → type 1 modify path
   - Otherwise → type 1 (Add Feature)
3. Extract requirements from the file (feature name, user story, AC, scope, priority)
4. Skip SECTION 0 / A-SECTION 0 / C-SECTION 0 entirely
5. Show INTAKE SUMMARY (pre-filled from file) and wait for approval
6. After approval → proceed directly to Impact Analysis (A-PHASE 2 or C-PHASE 2)

**File detection rule:** arg contains `.md` / `.txt` / a path separator (`/` or `\`),
OR the arg matches an existing file on disk → treat as file.
Otherwise → treat as inline text description.

---

## Inline Args Handling (text description)

If the user invoked this command with a plain text description:
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
