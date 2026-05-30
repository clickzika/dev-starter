# /devstarter-understand-chat — Ask Questions About the Codebase
Read `~/.claude/sdlc/devstarter-understand-chat.md` and answer the question.

Delegates to the **Understand-Anything** plugin's `/understand-chat`. Answers
natural-language questions about the project using the knowledge graph. If the
plugin is not installed, the runbook prompts to install it first.

## Inline Args

```
/devstarter-understand-chat How does the payment flow work?
/devstarter-understand-chat Which parts handle auth?
```

The question text is passed through verbatim to `/understand-chat`.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-understand-chat` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Ask questions about a codebase using its knowledge graph

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-understand-chat.md` from your DevStarter install.
Requires the Understand-Anything plugin: /plugin install understand-anything

Start: type your question
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
