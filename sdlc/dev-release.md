# dev-release.md — Release Checklist + Deployment

## How to Use

When ready to release a version:
```
claude
> Read ~/.claude/dev-release.md and prepare release v[X.Y.Z]
```

---

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
⛔ GATE 1 — PRE-RELEASE APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checklist: [N]/[total] items passing
Failed items: [list]

  "approve"  → proceed to staging deploy
  "fix [item]" → fix then re-check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3 — Staging Deploy + Smoke Test

```bash
# Merge develop → staging branch
git checkout staging
git merge develop --no-ff -m "release: v[X.Y.Z] to staging"
git push origin staging

# CI/CD deploys to staging automatically
# Run smoke tests
```

Smoke test checklist:
```
[ ] App loads without errors
[ ] Login works
[ ] Core feature [1] works end-to-end
[ ] Core feature [2] works end-to-end
[ ] No errors in browser console
[ ] No errors in server logs
[ ] API /health endpoint returns 200
```

```
⛔ GATE 2 — STAGING APPROVAL
Show smoke test results → wait for "approve"
```

---

## PHASE 4 — Production Deploy

```bash
# Read ~/.claude/dev-github.md → PROC-GH-09
git checkout main
git merge develop --no-ff -m "release: v[X.Y.Z]"
git tag "v[X.Y.Z]" -m "Release v[X.Y.Z]: [summary]"
git push origin main --tags
```

```
⛔ GATE 3 — PRODUCTION DEPLOY APPROVAL (FINAL)
Type "DEPLOY v[X.Y.Z]" to confirm production release.
```

---

## PHASE 5 — Post-Deploy Verification

```
[ ] Production URL loads
[ ] Login works in production
[ ] Core features working
[ ] Monitor error rates for 30 minutes
[ ] Check server metrics (CPU, memory, response time)
[ ] Notify team: "v[X.Y.Z] deployed successfully"
```

---

## PHASE 6 — Release Notes

Agent writes `docs/release-[vX.Y.Z].html`:
```
- Version + date
- What's new (features added)
- What's fixed (bugs resolved)
- What's removed (features deprecated)
- Breaking changes (if any)
- How to update (migration steps if needed)
```

Update Notion → add release entry.
Commit: `docs: release notes v[X.Y.Z]`

---

## Rollback Trigger

If anything goes wrong after production deploy:
```
claude
> Read ~/.claude/dev-rollback.md and rollback v[X.Y.Z]
```
