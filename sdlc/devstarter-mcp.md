# devstarter-mcp.md — MCP Server Setup Workflow

> **TL;DR** — Select and activate MCP server configs for Claude Code · **Lifecycle** Environment · **Gates** 1

## Model: Sonnet (`claude-sonnet-4-6`)

---

## CRITICAL RULES

- Do NOT overwrite existing `~/.claude/mcp.json` without showing the user a diff and getting approval
- Always merge new servers into existing config — never replace the whole file
- Validate JSON before writing
- Restart prompt is informational only — user must restart Claude Code themselves

---

## FLOW

### Step 0 — Check for inline arg

If the user ran `/devstarter-mcp [server-name]`:
- Skip Step 1 (picker)
- Jump to Step 2 with the named server

If the user ran `/devstarter-mcp list`:
- Show currently active servers from `~/.claude/mcp.json` (if it exists)
- Show which DevStarter templates are available
- Exit (no install)

---

### Step 1 — Show Picker

Use `AskUserQuestion` with:
- question: "Which MCP server do you want to activate?"
- multiSelect: true
- options:
  - `github` — GitHub repos, issues, PRs, code search (needs GITHUB_TOKEN)
  - `postgres` — PostgreSQL schema + query assistance (needs DATABASE_URL)
  - `mssql` — Microsoft SQL Server schema + queries (needs MSSQL_SERVER/DB/USER/PASSWORD)
  - `sqlite` — SQLite database access (needs SQLITE_DB_PATH)
  - `brave-search` — Web search from Claude Code (needs BRAVE_API_KEY)

---

### Step 2 — Check existing mcp.json

Check if `~/.claude/mcp.json` exists:

```bash
ls ~/.claude/mcp.json 2>/dev/null && echo "exists" || echo "not_found"
```

- **exists** → read the file, merge selected configs into it
- **not_found** → start with empty `{ "mcpServers": {} }`

---

### Step 3 — Check env vars

For each selected server, verify the required env var is set:

| Server | Required env var |
|--------|-----------------|
| github | `GITHUB_TOKEN` |
| postgres | `DATABASE_URL` |
| mssql | `MSSQL_SERVER`, `MSSQL_DATABASE`, `MSSQL_USER`, `MSSQL_PASSWORD` |
| sqlite | `SQLITE_DB_PATH` |
| brave-search | `BRAVE_API_KEY` |

For each missing var, show:
```
⚠️  [SERVER] requires [VAR_NAME]
    Get it at: [URL from mcp-setup.md]
    Add to .env: [VAR_NAME]=your_value_here
```

Missing env vars are a WARNING, not a blocker — user may set them later.
Continue with install but note which vars still need to be set.

---

### Step 4 — Show diff + Gate

Show what will change in `~/.claude/mcp.json`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 MCP CONFIG UPDATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Adding to ~/.claude/mcp.json:

  + "github": { ... }
  + "postgres": { ... }

Existing servers (unchanged):
  = [any already present]

⚠️  Missing env vars: GITHUB_TOKEN, DATABASE_URL
    Add these to .env before restarting Claude Code.

  "approve" → write the config
  "cancel"  → exit without changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Approve MCP config update?"
- options: ["approve", "cancel"]

---

### Step 5 — Write config

After approval:

1. Read templates from `~/.claude/templates/mcp/[server].json` for each selected server
2. Merge into existing mcp.json (or create new)
3. Write to `~/.claude/mcp.json`
4. Show confirmation:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ MCP CONFIG UPDATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File: ~/.claude/mcp.json
Added: [server names]

Next:
  1. Set missing env vars in .env (if any)
  2. Restart Claude Code
  3. Run /mcp to verify active servers

Full setup docs: ~/.claude/templates/mcp/mcp-setup.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Available Templates

All templates live at `~/.claude/templates/mcp/`:

| File | Server | Required env var |
|------|--------|-----------------|
| `github.json` | GitHub | `GITHUB_TOKEN` |
| `postgres.json` | PostgreSQL | `DATABASE_URL` |
| `mssql.json` | Microsoft SQL Server | `MSSQL_SERVER`, `MSSQL_DATABASE`, `MSSQL_USER`, `MSSQL_PASSWORD` |
| `sqlite.json` | SQLite | `SQLITE_DB_PATH` |
| `brave-search.json` | Brave Search | `BRAVE_API_KEY` |

Full setup instructions: `~/.claude/templates/mcp/mcp-setup.md`
