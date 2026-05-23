# /devstarter-migrate — Migration to New Tech Stack

Plan and execute a tech-stack migration: discovery → ADR → strangler-fig plan → phased rollout → cutover.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-migrate`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: replacing a major piece of the stack (e.g., React → Vue, Postgres → MySQL, monolith → services) — multi-phase, cross-team
- **Use /devstarter-change** instead when: changing a single feature within the existing stack (no stack swap)
- **Use /devstarter-consult** instead when: you haven't decided to migrate yet (use consult to weigh options first)
- **Use /devstarter-audit** instead when: assessing what *would* need to migrate (preflight before deciding)

## Inline Args

```
/devstarter-migrate                          → interactive (from / to / scope intake)
/devstarter-migrate React Vue                → migrate React → Vue
/devstarter-migrate Postgres MySQL data      → migrate Postgres → MySQL with data move
```

Read `~/.claude/sdlc/devstarter-migrate.md` and follow all phases and approval rules.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-migrate` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Migrate a project to a new tech stack

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-migrate.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
