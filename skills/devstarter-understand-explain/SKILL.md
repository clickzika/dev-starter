# /devstarter-understand-explain — Deep-Dive a File or Function
Read `~/.claude/sdlc/devstarter-understand-explain.md` and explain the target.

Delegates to the **Understand-Anything** plugin's `/understand-explain`. Produces a
plain-English deep-dive of a specific file or function — what it does, its
relationships, and how it fits the architecture. If the plugin is not installed,
the runbook prompts to install it first.

## Inline Args

```
/devstarter-understand-explain src/auth/login.ts
/devstarter-understand-explain src/services/payment.py
```

The file path is passed through verbatim to `/understand-explain`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-explain` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Deep-dive a single file or function using the knowledge graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-explain.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: pass a file path
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
