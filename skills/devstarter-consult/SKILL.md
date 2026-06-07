# /devstarter-consult — Consult & Get Solution Advice

Get expert advice on architecture, design, or strategy choices. Consultation only — no code changes, no branches. Outputs a saved intake file you can hand to `/devstarter-change` later.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-consult`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: deciding *what* to build / *how* to architect / *which* tech to pick — you want options + tradeoffs before writing any code
- **Use /devstarter-debug** instead when: you have a *bug* to root-cause (not a strategy question)
- **Use /devstarter-review** instead when: you have a *diff/PR* to evaluate (not a forward-looking question)
- **Use /devstarter-audit** instead when: you want a full project assessment (not a single decision)

## Inline Args

```
/devstarter-consult                          → interactive (state your question)
/devstarter-consult Redis vs RabbitMQ for jobs   → use as question (skip intake)
/devstarter-consult memory/notes.md         → read file as the question context
```

Read `~/.claude/sdlc/devstarter-consult.md` — consultation only, no code changes, no branch creation.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-consult` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Get expert architecture and strategy advice before building

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-consult.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
