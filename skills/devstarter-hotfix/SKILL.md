# /devstarter-hotfix — Critical Production Bug Fix

Emergency forward-fix on production: branch from main → fix → merge main → backport uat + develop.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-hotfix`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: production is broken AND a small, surgical fix is safer than reverting (forward-fix path)
- **Use /devstarter-rollback** instead when: reverting to the previous version is faster/safer than fixing forward
- **Use /devstarter-incident** instead when: you need full incident response (comms, escalation, customer notification, postmortem) — incident orchestrates rollback and/or hotfix
- **Use /devstarter-change fix-bug** instead when: the bug is on `develop` or non-critical (normal flow, no main branching)

## Inline Args

```
/devstarter-hotfix                          → interactive (severity + symptom intake)
/devstarter-hotfix login redirects fail     → use as symptom (skip Q1)
/devstarter-hotfix memory/debug-2026-05-09-foo.md   → read diagnosis file as context
```

Read `~/.claude/sdlc/devstarter-hotfix.md` — branch from main → fix → merge main → backport uat + develop.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-hotfix` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Apply a critical production bug fix bypassing normal flow

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-hotfix.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
