# /devstarter-postmortem — Blameless Incident Post-Mortem

After a SEV-1/SEV-2 incident is resolved, run a structured blameless post-mortem: timeline reconstruction → 5 Whys causal analysis → contributing factors → action items with owners + dates → published doc + tickets.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-postmortem`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: a SEV-1 / SEV-2 incident or critical near-miss has been resolved and it's time to learn from it
- **Use /devstarter-incident** instead when: the incident is ACTIVE (this is retrospective, not response)
- **Use /devstarter-retro** instead when: closing a sprint — different lens (what worked vs what hurt; not causal analysis)
- **Use /devstarter-debug** instead when: investigating a non-incident bug (no customer-facing event)

## Inline Args

```
/devstarter-postmortem                                    → interactive (intake from Q1)
/devstarter-postmortem checkout-down                      → use as incident slug (skip Q1)
/devstarter-postmortem memory/incident-2026-05-09.md     → read incident notes as context
```

Read `~/.claude/sdlc/devstarter-postmortem.md` and run all phases (intake → timeline → 5 Whys → contributing factors → action items → publish → tickets → handoff).

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-postmortem` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run a blameless post-mortem with 5 Whys root cause analysis

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-postmortem.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
