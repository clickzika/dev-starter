# dev-hotfix.md — Emergency Production Fix

## How to Use

When there is a critical bug in PRODUCTION that cannot wait for normal sprint:
```
claude
> Read ~/.claude/dev-hotfix.md and start a hotfix
```

---

## ⚠️ HOTFIX RULES

1. Hotfix goes directly: `main` ← `hotfix/[slug]` ← merge back to `develop`
2. Minimum viable fix only — do NOT add features or refactor
3. ALWAYS write a test that catches the bug before fixing
4. Hotfix skips Gate 1–3 docs but MUST update bugfix-log.html
5. Read from disk before every step — never rely on memory

---

## PHASE 1 — Triage

Ask ONE AT A TIME:

**Q1. Describe the production bug:**
(free text — what is broken, what users are affected)

**Q2. Severity:**
1. P0 — System down / data loss (fix NOW, < 1 hour)
2. P1 — Core feature broken, no workaround (fix today)
3. P2 — Feature broken, workaround exists (fix this sprint)

If P2 → route to `dev-change.md` fix bug flow instead.
Only P0 and P1 continue here.

**Q3. How many users are affected?**
1. All users
2. Specific user role (which?)
3. Specific feature users
4. Single user / edge case

**Q4. When did it start?**
(free text — e.g. "after last deploy", "this morning", "unknown")

**Q5. Can you reproduce it?**
1. Yes — reproducible steps known
2. Intermittent — sometimes reproducible
3. No — only seen in production logs

---

## PHASE 2 — Notify Team

Agent drafts notification message:

```
🚨 PRODUCTION HOTFIX — [P0/P1]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Issue:    [description]
Affected: [who/what]
Started:  [when]
Owner:    [name]
ETA fix:  [estimated time]
Status:   Investigating
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Send to: [team channel from TEAM.md]

---

## PHASE 3 — Investigation

Agent reads:
- Recent git commits (what changed last?)
- Relevant code files in affected area
- Error logs if provided
- `docs/bugfix-log.html` (has this happened before?)

Shows root cause hypothesis:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 ROOT CAUSE HYPOTHESIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Most likely cause:  [what]
Evidence:           [why we think this]
Files involved:     [list]
Proposed fix:       [minimal change needed]
Risk of fix:        [Low / Medium / High]
Rollback option:    [yes — run dev-rollback.md / no]

  "approve"  → start hotfix branch
  "investigate more" → dig deeper
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE H1 — wait for approval before touching code.

---

## PHASE 4 — Hotfix Branch + Fix

```bash
# Branch from main (not develop)
git checkout main
git pull origin main
git checkout -b hotfix/[issue-number]-[slug]

# Write failing test FIRST
# Then implement minimum fix
# Run all tests — must pass

git add .
git commit -m "fix: [description] (hotfix #[issue])"
```

---

## PHASE 5 — Expedited Review

```bash
# Push and create PR targeting main
git push origin hotfix/[slug]
gh pr create \
  --title "HOTFIX: [description]" \
  --body "Fixes #[issue]
  
  Root cause: [cause]
  Fix: [what changed]
  Tests: [test added]
  Risk: [Low/Medium/High]" \
  --base main \
  --label "hotfix,priority:critical"
```

```
⛔ GATE H2 — HOTFIX PR APPROVAL
P0: Tech Lead must approve within 30 minutes
P1: Tech Lead must approve within 2 hours

  "approve"  → deploy to production immediately
  "revise"   → fix before merging
```

---

## PHASE 6 — Deploy + Verify

```bash
# Merge to main
gh pr merge --squash --delete-branch

# Tag hotfix
git checkout main && git pull
git tag "v[version]-hotfix.[N]"
git push origin main --tags

# Merge hotfix back to develop
git checkout develop
git merge main --no-ff -m "chore: merge hotfix back to develop"
git push origin develop
```

Post-deploy verification (5 minutes):
```
[ ] Bug is resolved in production
[ ] No new errors introduced
[ ] Affected users confirmed working
[ ] Error rate back to baseline
```

---

## PHASE 7 — Hotfix Documentation

Agent updates `docs/bugfix-log.html` with hotfix entry:
```
ID:       HOTFIX-[YYYY-MM-DD]-[N]
Severity: P[0/1]
Response: [time from detection to fix]
Impact:   [users affected + duration]
Cause:    [root cause]
Fix:      [what changed]
PR:       #[N]
```

Notify team:
```
✅ HOTFIX RESOLVED — [P0/P1]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Issue:     [description]
Resolved:  [time]
Fix:       [brief description]
Version:   v[version]-hotfix.[N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Post-Hotfix Action Items

Within 24 hours after hotfix:
- Write proper regression test (if not done during hotfix)
- Add monitoring/alert to detect this class of error earlier
- Schedule post-mortem if P0
- Create GitHub issue for root cause prevention
