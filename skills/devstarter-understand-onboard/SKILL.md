# /devstarter-understand-onboard — Codebase Onboarding Guide
Read `~/.claude/sdlc/devstarter-understand-onboard.md` and generate the guide.

Delegates to the **Understand-Anything** plugin's `/understand-onboard`. Generates a
graph-driven onboarding guide for new team members — architecture tour ordered by
dependency. If the plugin is not installed, the runbook prompts to install it first.

> **Not** the same as `/devstarter-onboard` (team-member SDLC onboarding). This is
> codebase-structure onboarding driven by the knowledge graph.

## Inline Args

```
/devstarter-understand-onboard           → generate onboarding guide from the graph
```

All args are passed through verbatim to `/understand-onboard`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-onboard` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Generate a codebase onboarding guide from the knowledge graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-onboard.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
