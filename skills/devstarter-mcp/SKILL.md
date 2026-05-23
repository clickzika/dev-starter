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

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-mcp` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Set up and configure MCP servers for AI tool integrations

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-mcp.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
