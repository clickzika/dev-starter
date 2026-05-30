# /devstarter-understand-diff — Change Impact Analysis
Read `~/.claude/sdlc/devstarter-understand-diff.md` and analyze impact.

Delegates to the **Understand-Anything** plugin's `/understand-diff`. Shows which
parts of the system your current changes affect — ripple effects across the graph —
before you commit. If the plugin is not installed, the runbook prompts to install it first.

## Inline Args

```
/devstarter-understand-diff              → analyze impact of current uncommitted changes
```

All args are passed through verbatim to `/understand-diff`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-diff` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Analyze the impact of current changes across the codebase graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-diff.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
