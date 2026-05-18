# /devstarter-handover — Handover Project

Transfer project ownership: knowledge capture, handover doc, access revocation, secret rotation.

## When to use vs alternatives

- **Use this** when: an existing owner is leaving / changing role / transferring an area to someone else
- **Use /devstarter-onboard** instead when: a new person is joining with no predecessor (no transfer, just setup)
- **Use /devstarter-retro** instead when: closing out a sprint (no ownership change)

## Inline Args

```
/devstarter-handover                        → interactive (from / to / area / deadline)
/devstarter-handover Alice Bob full         → handover full project from Alice to Bob
/devstarter-handover Alice Bob backend      → handover backend area only
```

Read `~/.claude/sdlc/devstarter-handover.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-handover` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Hand over a project to another team or person

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-handover.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
