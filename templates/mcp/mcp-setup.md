# MCP Server Setup Guide

This directory contains ready-to-use MCP (Model Context Protocol) server configs for Claude Code.

## How to activate

Copy the desired JSON config into `~/.claude/mcp.json` (or merge with existing):

```bash
# Activate GitHub MCP
cp ~/.claude/templates/mcp/github.json ~/.claude/mcp.json
```

Or run `/devstarter-mcp` to get an interactive picker.

---

## Available Configs

### github.json — GitHub MCP Server

Gives Claude Code direct access to GitHub repos, issues, PRs, and code search.

**Requires:**
- `GITHUB_TOKEN` env var — create at https://github.com/settings/tokens
- Scopes needed: `repo`, `read:org`

**Set env var:**
```bash
# Add to .env or export before running claude
export GITHUB_TOKEN=ghp_yourtoken
```

**Capabilities:**
- Read/create/update issues and PRs
- Search code, commits, and repos
- Read file contents from any repo

---

### postgres.json — PostgreSQL MCP Server

Gives Claude Code read access to a PostgreSQL database for schema inspection and query assistance.

**Requires:**
- `DATABASE_URL` env var in format: `postgresql://user:pass@host:5432/dbname`

**Set env var:**
```bash
export DATABASE_URL=postgresql://myuser:mypass@localhost:5432/mydb
```

**Capabilities:**
- List tables and schemas
- Describe table structure
- Run SELECT queries (read-only)

---

### sqlite.json — SQLite MCP Server

Gives Claude Code access to a local SQLite database file.

**Requires:**
- `SQLITE_DB_PATH` env var pointing to your `.db` file

**Set env var:**
```bash
export SQLITE_DB_PATH=/path/to/database.db
```

**Capabilities:**
- List tables
- Describe schema
- Run SELECT queries

---

### brave-search.json — Brave Search MCP Server

Gives Claude Code web search capabilities via Brave Search API.

**Requires:**
- `BRAVE_API_KEY` env var — get a free key at https://api.search.brave.com

**Set env var:**
```bash
export BRAVE_API_KEY=BSA_yourkey
```

**Capabilities:**
- Web search from within Claude Code
- News search
- Image search

---

## Merging multiple configs

If you want multiple MCP servers active at once, merge the `mcpServers` objects:

```json
{
  "mcpServers": {
    "github": { "...": "from github.json" },
    "postgres": { "...": "from postgres.json" }
  }
}
```

Or use `/devstarter-mcp` to select and merge automatically.

---

## Verifying activation

After placing your mcp.json, restart Claude Code. Run:

```
> /mcp
```

Active servers will appear in the list.
