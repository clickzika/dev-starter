# /devstarter-council — Council Decision

Four-voice deliberation for decisions where smart people would disagree.

## The four voices

- **Architect** — correctness, maintainability, long-term
- **Skeptic** — challenges the premise itself
- **Pragmatist** — shipping speed, ops reality
- **Critic** — edge cases, downside risk, failure modes

## When to use

- Tech selection with real tradeoffs
- Irreversible architectural decisions
- Risk assessment under uncertainty

## When NOT to use

- Code review → `/devstarter-review`
- Implementation planning → `/devstarter-change`
- Clear-cut decisions with an obvious answer

## Inline args

```
/devstarter-council Redis vs PostgreSQL for job queues
/devstarter-council should we go monorepo
/devstarter-council memory/decision-context.md
```

Requires **Opus** for quality deliberation.

Read `~/.claude/sdlc/devstarter-council.md` and run the full workflow.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-council` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run a multi-agent council review for critical decisions

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-council.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
