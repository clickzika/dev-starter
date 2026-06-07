# /devstarter-debug — Senior Dev Problem Analysis

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-debug`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

Read `~/.claude/sdlc/devstarter-debug.md` and run the investigation.

## Inline Args

```
/devstarter-debug                              → start with intake questions
/devstarter-debug login fails after deploy     → use as problem description (skip Q1)
/devstarter-debug memory/bug-report.md        → read file as problem context
```

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-debug` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run a senior-dev hypothesis-driven investigation to root-cause a bug

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-debug.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
