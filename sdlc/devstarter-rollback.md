# dev-rollback.md — Production Rollback

## Model: Sonnet (`claude-sonnet-4-6`)

## How to Use

When a production deploy causes problems and needs to be reverted:
```
claude
> Read ~/.claude/devstarter-rollback.md and rollback production
```

---

## ⚠️ ROLLBACK RULES

1. Rollback is a last resort — try hotfix first if fix is < 30 min
2. ALWAYS notify team BEFORE executing rollback
3. Database rollback is SEPARATE from code rollback — do NOT auto-rollback DB
4. Document everything — what failed, when, why we rolled back

---

## PHASE 1 — Decision: Rollback or Hotfix?

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ROLLBACK vs HOTFIX DECISION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use ROLLBACK if:
  ✓ Cannot identify root cause quickly (> 30 min)
  ✓ Multiple systems failing simultaneously
  ✓ Data integrity risk
  ✓ Deploy caused immediate widespread failure

Use HOTFIX instead if:
  ✓ Root cause is known
  ✓ Fix is simple and low-risk (< 30 min)
  ✓ Only one feature affected
  ✓ Previous version also had this issue

  "rollback"  → proceed with rollback
  "hotfix"    → go to dev-hotfix.md instead
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE R0 — explicit decision required.

---

## PHASE 2 — Notify Team

Agent drafts immediate notification:

```
🔴 PRODUCTION ROLLBACK INITIATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reason:          [what failed]
Current version: v[X.Y.Z]
Rolling back to: v[X.Y.(Z-1)]
ETA:             ~[N] minutes
Owner:           [name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3 — Identify Rollback Target

```bash
# Show recent tags / releases
git tag --sort=-version:refname | head -10

# Show what changed in current version
git log v[previous]..v[current] --oneline
```

Show to user:
```
Current: v[X.Y.Z] (deployed [time])
Rollback to: v[X.Y.(Z-1)] (previous stable)

Changes that will be REVERTED:
  - [commit 1]
  - [commit 2]

⚠️  Database migrations in this version: [yes/no]
If yes — DB rollback must be done MANUALLY (see Phase 4b)

  "confirm rollback to v[X.Y.(Z-1)]"  → execute
  "choose different version"           → list versions
```

⛔ GATE R1 — user must type exact confirmation.

---

## PHASE 4a — Code Rollback

```bash
# Revert to previous version tag
git checkout main
git revert v[current]..HEAD --no-commit
git commit -m "revert: rollback from v[current] to v[previous]"
git tag "v[current]-rollback"
git push origin main --tags
```

---

## PHASE 4b — Database Rollback (if applicable)

⚠️ AGENT CANNOT DO THIS AUTOMATICALLY — must be done manually.

Agent shows instructions:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  DATABASE ROLLBACK REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This version included database migrations.
You MUST manually run the rollback migration.

Steps:
1. Connect to production database
2. Run: dotnet ef migrations script [previous] [current] --idempotent
   (to see what the DOWN migration does)
3. Verify the rollback SQL is safe
4. Execute the DOWN migration
5. Confirm: SELECT * FROM __EFMigrationsHistory ORDER BY MigrationId DESC LIMIT 5;

⚠️  NEVER auto-run DB rollback — always review first.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Confirm DB rollback complete: (yes)
```

⛔ GATE R2 — wait for DB confirmation before proceeding.

---

## PHASE 5 — Verify Rollback

```
[ ] Previous version is running in production
[ ] App loads without errors
[ ] Core features working
[ ] Error rate back to baseline
[ ] Database integrity check passed
[ ] Monitor for 15 minutes
```

---

## PHASE 6 — Notify + Document

Notify team:
```
✅ ROLLBACK COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rolled back: v[current] → v[previous]
Duration:    [time from start to complete]
Status:      Production stable
Next steps:  Investigate v[current] before re-deploying
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Agent writes rollback entry to `docs/bugfix-log.html`:
```
ID:          ROLLBACK-[YYYY-MM-DD]-[N]
Type:        Rollback
From:        v[current]
To:          v[previous]
Reason:      [what failed]
Duration:    [time to rollback]
DB rollback: [yes/no]
```

---

## PHASE 7 — Post-Rollback Investigation

After production is stable:
1. Route to `dev-change.md` Fix Bug flow for root cause analysis
2. Fix the issue in develop branch
3. Run full QA cycle before re-deploying
4. Schedule post-mortem (if significant incident)
