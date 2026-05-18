# /devstarter-retro — Sprint Retrospective

Run a sprint retrospective: what went well, what didn't, action items with owners.

## When to use vs alternatives

- **Use this** when: closing a sprint — review the work delivered and capture learning
- **Use /devstarter-sprint** instead when: planning the *next* sprint (retro feeds into this)
- **Use /devstarter-incident** instead when: this is a SEV incident review (separate workflow — postmortem ≠ sprint retro)

## Inline Args

```
/devstarter-retro                           → interactive (sprint name, dates, attendees)
/devstarter-retro sprint-12                 → retro for sprint-12
```

Read `~/.claude/sdlc/devstarter-retrospective.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-retro` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run a blameless sprint retrospective

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-retrospective.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
