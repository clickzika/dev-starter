## PHASE 1 — Release Scope

**Q1. What version is this?**
(e.g. v1.0.0 / v1.2.0 / v2.0.0)
- Major (X) = breaking changes
- Minor (Y) = new features, backward compatible
- Patch (Z) = bug fixes only

**Q2. What environment?**
1. Staging (pre-production test)
2. Production (live users)

**Q3. What is the release window?**
(free text — date + time)

---

## PHASE 2 — Pre-Release Checklist

Agent verifies each item before allowing release:

### Code Quality
```
[ ] All Gate 4 features approved and merged to develop
[ ] No open critical/high bugs in GitHub
[ ] All tests passing in CI
[ ] Code coverage ≥ [threshold]%
[ ] npm audit / dotnet list package --vulnerable → clean
[ ] No TODO/FIXME comments in new code
```

### Documentation
```
[ ] CLAUDE.md Progress Tracker fully updated
[ ] docs/bugfix-log.html current
[ ] README.md accurate
[ ] API docs (Swagger) up to date
[ ] CHANGELOG.md updated with this version
[ ] Notion tasks → all Done
```

### Security
```
[ ] OWASP checklist verified
[ ] Secrets not in code (grep for hardcoded keys)
[ ] Environment variables documented
[ ] HTTPS configured in production
[ ] Docker images using specific version tags
```

### Database
```
[ ] All migrations tested on staging
[ ] Migration rollback script ready
[ ] Data backup taken before deploy
[ ] No breaking schema changes without migration
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 1 — DEV APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checklist: [N]/[total] items passing
Failed items: [list]

  "DEV approved"  → proceed to SIT
  "fix [item]" → fix then re-check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

