# dev-incident.md — Production Incident Response

## Model: Opus (`claude-opus-4-6`)
> Deep reasoning required — run `/model opus` before this workflow.

## How to Use

When production is having issues (outage, degradation, security breach):
```
claude
> Read ~/.claude/devstarter-incident.md and start incident response
```

---

## Incident Severity Levels

| Level | Definition | Response Time | Example |
|-------|-----------|---------------|---------|
| SEV-1 | Full outage — all users affected | Immediate | Site down |
| SEV-2 | Partial outage — major feature broken | 15 min | Login broken |
| SEV-3 | Degraded performance — slow or flaky | 1 hour | API slow |
| SEV-4 | Minor issue — low impact | Next business day | UI glitch |

SEV-4 → use `dev-change.md` fix bug flow.
SEV-1 to SEV-3 → continue here.

---

## PHASE 1 — Declare Incident

**Q1. What is happening?**
(free text — describe what is wrong)

**Q2. Severity level?**
(SEV-1 / SEV-2 / SEV-3)

**Q3. When did it start?**
(free text)

**Q4. What was recently deployed or changed?**
(free text — or "nothing known")

---

Agent assigns Incident ID: `INC-[YYYY-MM-DD]-[NNN]`

Notify team immediately:
```
🚨 INCIDENT DECLARED — [SEV-N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:        INC-[YYYY-MM-DD]-[NNN]
Severity:  SEV-[N]
What:      [description]
Started:   [time]
Commander: [Tech Lead name from TEAM.md]
Status:    Investigating
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 2 — Investigate

Agent reads: recent deploys, logs provided, CLAUDE.md architecture.

Timeline building:
```
[ ] When did monitoring first show anomaly?
[ ] What was the last successful deploy?
[ ] Any infrastructure changes?
[ ] Any external service outages? (check status pages)
[ ] What do error logs show?
```

Hypothesis:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 INCIDENT HYPOTHESIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Most likely: [cause]
Evidence:    [what points to this]
Rule out:    [what it is probably NOT]

Immediate options:
  A) Rollback → read dev-rollback.md
  B) Hotfix   → read dev-hotfix.md
  C) Restart service → [command]
  D) Scale up → [command]
  E) Investigate more

Recommendation: [A/B/C/D/E]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3 — Mitigation

Based on decision:
- Rollback → `dev-rollback.md`
- Hotfix → `dev-hotfix.md`
- Service restart:

```bash
# Docker
docker compose restart [service]

# Check logs
docker compose logs -f [service] --tail=100
```

Update incident status every 15 minutes:
```
📊 INCIDENT UPDATE — INC-[ID]
Time: [HH:MM]
Status: [Investigating / Mitigating / Monitoring]
Action taken: [what was done]
Next update: [time]
```

---

## PHASE 4 — Resolution

When incident is resolved:
```
✅ INCIDENT RESOLVED — INC-[ID]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resolved:   [time]
Duration:   [total time]
Root cause: [what caused it]
Fix:        [what resolved it]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 5 — Post-Mortem Document

Agent writes `docs/postmortem-[INC-ID].html`:

```
1. Incident Summary
   - Timeline of events
   - Impact (users affected, duration, severity)

2. Root Cause Analysis
   - What caused the incident
   - Why it was not caught before production

3. Contributing Factors
   - What made it worse or harder to detect

4. Resolution
   - What fixed it
   - How long it took

5. Action Items
   - [Action] | Owner | Due date | Priority
   - Prevent recurrence
   - Improve detection
   - Improve response time

6. Lessons Learned
   - What we did well
   - What we can improve

7. SLA Impact
   - Downtime calculation
   - User impact estimate
```

Post-mortem Gate:
```
⛔ POST-MORTEM REVIEW
Share doc → wait for team acknowledgment
Create action item GitHub issues
```
