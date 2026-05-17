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
