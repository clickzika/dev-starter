# /devstarter-dependency — Update Dependencies

Audit and update project dependencies (npm / pip / go.mod / etc.) with safety checks.

## When to use vs alternatives

- **Use this** when: routine dependency hygiene (security patches, version bumps, lockfile refresh)
- **Use /devstarter-audit** instead when: you want a full project audit (security + quality + drift), not just dependencies
- **Use /devstarter-secrets** instead when: rotating credentials or vault-managed secrets (different concern)

## Inline Args

```
/devstarter-dependency                      → interactive (pick scope: security / minor / major)
/devstarter-dependency security             → security patches only (npm audit fix, etc.)
/devstarter-dependency minor                → minor + patch updates (skip majors)
```

Read `~/.claude/sdlc/devstarter-dependency.md` and follow all phases.
