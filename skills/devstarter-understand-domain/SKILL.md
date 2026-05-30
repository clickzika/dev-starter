# /devstarter-understand-domain — Extract Business Domains & Flows
Read `~/.claude/sdlc/devstarter-understand-domain.md` and run domain extraction.

Delegates to the **Understand-Anything** plugin's `/understand-domain`. Maps code to
real business processes — domains, flows, and steps laid out as a horizontal graph.
If the plugin is not installed, the runbook prompts to install it first.

## Inline Args

```
/devstarter-understand-domain            → extract domains, flows, and steps
```

All args are passed through verbatim to `/understand-domain`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-domain` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Extract business domains, flows, and steps from a codebase

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-domain.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
