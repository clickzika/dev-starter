# /devstarter-release — Release + Deploy

Standard release flow: develop → SIT → UAT → main → deploy + tag.

## When to use vs alternatives

- **Use this** when: shipping a planned release (CHANGELOG ready, gates can run in order)
- **Use /devstarter-hotfix** instead when: a critical production bug needs to bypass the normal flow
- **Use /devstarter-rollback** instead when: production needs to revert to the previous version

## Inline Args

```
/devstarter-release                         → interactive (prompt for version + scope)
/devstarter-release 3.6.0                   → release v3.6.0 (skip version question)
/devstarter-release 3.6.0 minor-feature     → version + short description
```

Read `~/.claude/sdlc/devstarter-release.md` and follow all phases and gate approvals (DEV → SIT → UAT → DEPLOY).
