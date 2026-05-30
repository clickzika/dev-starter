# /devstarter-understand-knowledge — Analyze an LLM Wiki Knowledge Base
Read `~/.claude/sdlc/devstarter-understand-knowledge.md` and run knowledge analysis.

Delegates to the **Understand-Anything** plugin's `/understand-knowledge`. Points at a
Karpathy-pattern LLM wiki and builds a force-directed knowledge graph with community
clustering — extracts wikilinks, categories, entities, and claims. If the plugin is
not installed, the runbook prompts to install it first.

## Inline Args

```
/devstarter-understand-knowledge ~/path/to/wiki
```

The wiki path is passed through verbatim to `/understand-knowledge`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-knowledge` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Analyze an LLM wiki knowledge base into a navigable graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-knowledge.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: pass a wiki path
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
