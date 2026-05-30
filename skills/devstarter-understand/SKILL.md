# /devstarter-understand — Analyze Codebase → Knowledge Graph
Read `~/.claude/sdlc/devstarter-understand.md` and run the analysis.

Delegates to the **Understand-Anything** plugin's `/understand`. Scans the project,
extracts every file, function, class, and dependency, and builds a knowledge graph
at `.understand-anything/knowledge-graph.json`. If the plugin is not installed, the
runbook prompts to install it first.

## Inline Args

```
/devstarter-understand                  → analyze whole project (incremental)
/devstarter-understand src/frontend     → scope to a subdirectory
/devstarter-understand --language zh     → localized graph + dashboard
/devstarter-understand --auto-update     → post-commit hook keeps graph fresh
```

All args are passed through verbatim to `/understand`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Analyze a codebase into an interactive knowledge graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type 'start' or pass a path / flags
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
