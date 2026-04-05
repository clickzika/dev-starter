# /devstarter-document — Generate or Regenerate Project Documents

Read `~/.claude/sdlc/devstarter-document.md` and generate the requested document.
Follow all phases and agent-routing rules in that file.

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a doc type, e.g.:
```
/devstarter-document brd
/devstarter-document api
/devstarter-document schema
/devstarter-document all
```

**Then:**
1. Treat the argument as the doc type — skip the quick-picker
2. Auto-detect project context from CLAUDE.md
3. Go directly to generation for that doc type

**Supported doc types:**

| Arg | Document | Agent |
|-----|----------|-------|
| `brd` | `docs/brd.html` — Business Requirements | @devstarter-ba |
| `srs` | `docs/srs.html` — Software Requirements | @devstarter-ba |
| `api` | `docs/api-reference.html` — API Reference | @devstarter-backend |
| `schema` | `docs/database-design.html` — DB Schema | @devstarter-dba |
| `test` | `docs/test-strategy.html` — Test Strategy | @devstarter-qa |
| `security` | `docs/security-design.html` — Security Design | @devstarter-security |
| `infra` | `docs/infrastructure-guide.html` — Infra Guide | @devstarter-devops |
| `prototype` | `docs/prototype/` — UI Prototype | @devstarter-uxui |
| `plan` | `docs/project-plan.html` — Project Plan | @devstarter-pm |
| `all` | All of the above | all agents |

**If no args were provided** (user just typed `/devstarter-document`):
→ Show the quick-picker as the first prompt (see SDLC file).
