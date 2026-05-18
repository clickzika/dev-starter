# /devstarter-sprint — Sprint Planning

Plan a sprint: pull from backlog, prioritize, estimate, assign tasks, set sprint goal.

## When to use vs alternatives

- **Use this** when: starting a new sprint cycle (refine backlog → commit work for the next 1–2 weeks)
- **Use /devstarter-retro** instead when: ending the previous sprint (review what worked / didn't)
- **Use /devstarter-change** instead when: a single feature/bug needs work right now (no sprint context)

## Inline Args

```
/devstarter-sprint                          → interactive intake (sprint #, length, goal)
/devstarter-sprint plan v3.6.0              → name the sprint upfront
/devstarter-sprint refine                   → backlog refinement only (no commitment)
```

Read `~/.claude/sdlc/devstarter-sprint.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-sprint` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run sprint planning with task breakdown and Notion/GitHub sync

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-sprint.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
