# /devstarter-mcp — MCP Server Setup

Interactively select and activate MCP server configurations for Claude Code.
Copies the selected config to `~/.claude/mcp.json` (or merges with existing).

## Inline Args

```
/devstarter-mcp                  → interactive picker (show all available configs)
/devstarter-mcp github           → activate GitHub MCP directly
/devstarter-mcp postgres         → activate PostgreSQL MCP directly
/devstarter-mcp sqlite           → activate SQLite MCP directly
/devstarter-mcp brave-search     → activate Brave Search MCP directly
/devstarter-mcp list             → show currently active MCP servers
```

Read `~/.claude/sdlc/devstarter-mcp.md` and follow the MCP setup workflow.

ARGUMENTS: {{args}}
