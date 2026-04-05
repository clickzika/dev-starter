# dev-release.md — Release Checklist + Deployment

## How to Use

When ready to release a version:
```
claude
> Read ~/.claude/sdlc/devstarter-release.md and prepare release v[X.Y.Z]
```

## Release Flow Overview

```
develop ──→ Local Test (Claude) ──→ uat ──→ User Test ──→ main ──→ Production
              Phase 5                  Phase 6               Phase 7

PHASE 1: Release scope (version, environment)
PHASE 2: Pre-release checklist (code, docs, security, database)
  ⛔ GATE 1: "DEV approved"  → proceed to SIT
PHASE 3: Deploy preparation (env vars, strategy)
PHASE 4: Deploy strategy selection (A-H)
PHASE 5: SIT — Local Docker test — Claude runs automated tests
  ⛔ GATE 2: "SIT approved"  → proceed to UAT
PHASE 6: UAT — merge develop → uat — User tests manually
  ⛔ GATE 3: "UAT approved"  → proceed to production
PHASE 7: Production — merge uat → main — deploy production
  ⛔ GATE 4: "DEPLOY v[X.Y.Z]"  → deploy
PHASE 8: Post-deploy verification
PHASE 9: Release notes
```

---


---

## Phase Sub-files

Load sub-files as you progress through the release:

| When | Load |
|------|------|
| Starting release | `~/.claude/sdlc/devstarter-release-prep.md` |
| After Gate 1 approval | `~/.claude/sdlc/devstarter-release-deploy.md` |
| After deploy execution | `~/.claude/sdlc/devstarter-release-verify.md` |
