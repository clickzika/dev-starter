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

---

## Quick Mode — `--quick` flag

For trivial / scoped changes that don't need the full multi-agent flow.
Skips agents not relevant to the detected scope so reading load drops
from ~3000 lines to ~1000.

```
/devstarter-change --quick add dark mode toggle to navbar
/devstarter-change --quick fix login redirect bug
/devstarter-change --quick small.md
```

**What `--quick` does:**

1. **Auto-scope detection** — based on description and touched files:
   - Backend-only (touches `api/` `services/` `db/`) → skip @uxui, @frontend
   - Frontend-only (touches `frontend/` `components/`) → skip @backend, @dba
   - Full-stack → no skips (full flow runs)
   - Bug fix with localized blast radius → skip BRD update; AC inline in PR description

2. **Reduced reading** — Claude reads only the agent files relevant to scope
   (e.g., backend-only feature: skip reading 700-line uxui agent file)

3. **Reduced doc updates** — only the docs in scope:
   - Backend-only: `api-reference.html` + `openapi.yaml` + maybe ADR; skip frontend-spec / ux-spec
   - Frontend-only: `frontend-spec.html` + maybe ADR; skip api-reference / database-design
   - Bug fix: bugfix-log.html only (no BRD update for tiny bugs)

4. **Doc Quality Preflight** still runs — but only on the docs that ARE
   updated. Quality bar is the same; surface area is smaller.

**When NOT to use `--quick`:**
- Feature touches auth / multi-tenancy / schema / billing / external integrations
  (these always require full ADR + Threat Model + SLO regardless of scope)
- Cross-cutting refactors
- New top-level domain (entire bounded context)
- First feature in a fresh project (use full /devstarter-new + first /devstarter-change)

If `--quick` is supplied for a change that touches an excluded area above,
the workflow auto-promotes to full mode and prints a warning explaining why.
