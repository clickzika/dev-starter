# /devstarter-rollback — Rollback Production

Revert production to a previous version when a forward fix is risky or slow.

## When to use vs alternatives

- **Use this** when: prod is broken AND a forward fix would take longer than a revert AND the previous version is known-good
- **Use /devstarter-hotfix** instead when: a small, surgical forward fix is safer than reverting (e.g., revert would lose unrelated good changes)
- **Use /devstarter-incident** instead when: this is a full incident (comms, escalation, postmortem) — incident orchestrates rollback and/or hotfix

## Inline Args

```
/devstarter-rollback                        → interactive (pick target version)
/devstarter-rollback v3.4.0                 → roll back to a specific tag
/devstarter-rollback last                   → revert to the previous release tag
```

Read `~/.claude/sdlc/devstarter-rollback.md` and follow all phases.
