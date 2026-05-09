# /devstarter-adr — Architecture Decision Record (Standalone)

Capture an architecture decision *outside* of a feature change. Produces a numbered, dated ADR with context + forces + ≥ 3 options + recommendation + consequences, saved to `docs/adr/NNNN-<slug>.html`.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-adr`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: recording a decision *outside* a feature change — tech stack, library evaluation, infra move, process change, library/vendor end-of-life
- **Use /devstarter-change** instead when: the decision is *part of* a feature — Gate A2 already enforces ADR for non-trivial features (auth, multi-tenancy, schema, caching, payments, billing, external integrations)
- **Use /devstarter-consult** instead when: you want options + tradeoffs but aren't ready to commit (consult feeds into ADR)
- **Use /devstarter-audit** instead when: reviewing whether existing decisions are still appropriate

## Inline Args

```
/devstarter-adr                                       → interactive intake
/devstarter-adr "switch from MongoDB to Postgres"     → use as decision title (skip Q1)
/devstarter-adr memory/consult-2026-05-09.md         → read consult file as context
```

Read `~/.claude/sdlc/devstarter-adr.md` and run all phases (intake → forces → ≥ 3 options → recommendation → consequences → supersedes → publish → approval gate → handoff).
