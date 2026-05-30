# /devstarter-understand-dashboard — Interactive Knowledge Graph Dashboard
Read `~/.claude/sdlc/devstarter-understand-dashboard.md` and open the dashboard.

Delegates to the **Understand-Anything** plugin's `/understand-dashboard`. Opens an
interactive web dashboard of the knowledge graph — color-coded by architectural
layer, searchable, clickable. Requires a graph built first via `/devstarter-understand`.
If the plugin is not installed, the runbook prompts to install it first.

> **Note:** the dashboard runs a local web/dev server (provided by the plugin).
> Node.js is required by the underlying plugin, not by DevStarter.

## Inline Args

```
/devstarter-understand-dashboard        → open the dashboard for the current graph
```

All args are passed through verbatim to `/understand-dashboard`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-dashboard` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Open the interactive codebase knowledge-graph dashboard

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-dashboard.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
