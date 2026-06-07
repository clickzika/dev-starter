# /devstarter-incident — Incident Response

Full incident orchestration: severity triage, comms, escalation, mitigation (rollback OR hotfix), customer notification, postmortem.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-incident`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: a SEV-1/SEV-2 production issue is active and you need orchestration across mitigation + comms + customer + post-action
- **Use /devstarter-hotfix** instead when: you only need the code-fix portion (no comms/escalation orchestration)
- **Use /devstarter-rollback** instead when: you only need the revert portion (no comms/escalation orchestration)
- **Use /devstarter-debug** instead when: investigating a non-urgent bug (no production impact yet)

## Inline Args

```
/devstarter-incident                        → interactive (severity + symptom + impact intake)
/devstarter-incident sev1 checkout-down     → severity + brief title inline
```

Read `~/.claude/sdlc/devstarter-incident.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-incident` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run incident response: detect, contain, resolve, and report

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-incident.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
