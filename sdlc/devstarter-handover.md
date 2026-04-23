# dev-handover.md — Project Handover

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

When a team member leaves or transfers ownership:
```
claude
> Read ~/.claude/devstarter-handover.md and prepare handover from [Name] to [Name]
```

---

## PHASE 1 — Handover Scope

Ask ONE AT A TIME:

**Q1. Who is handing over? Who is receiving?**

**Q2. What is the reason?**
1. Team member leaving
2. Role change / promotion
3. Project transfer to new team
4. Temporary (leave / vacation)

**Q3. What is the handover deadline?**
(free text — date)

**Q4. What areas are being handed over?**
(select all that apply)
1. Full project ownership
2. Frontend only
3. Backend only
4. DevOps / infra only
5. Specific features only

---

## PHASE 2 — Knowledge Capture

Agent reads all project files and generates handover document:

### Codebase Overview
- Read CLAUDE.md → architecture + tech stack
- Read docs/ → all documentation
- Read TEAM.md → current ownership
- Scan codebase → identify complex/undocumented areas

### Knowledge Transfer Checklist
```
[ ] Architecture decisions documented (why not just what)
[ ] All environment variables documented
[ ] All external integrations documented (API keys, webhooks)
[ ] Deployment process documented step-by-step
[ ] Known issues + workarounds documented
[ ] Recurring tasks documented (cron jobs, manual steps)
[ ] Vendor/service contacts documented
[ ] Passwords/secrets transferred securely (NOT via git)
```

---

## PHASE 3 — Handover Document

Agent writes `docs/handover-[from]-to-[to]-[date].html`:

```
Sections:
1. Project overview (read from CLAUDE.md)
2. Current status (gate, in-progress tasks)
3. Architecture + key decisions
4. Environment setup guide
5. External services + credentials (reference only, not values)
6. Known issues + technical debt
7. Recurring tasks calendar
8. Who to contact for what
9. Open items requiring immediate attention
10. Recommended first 30 days plan for receiver
```

---

## PHASE 4 — Handover Gates

```
⛔ GATE 1 — Document review
Show handover doc → both parties approve

⛔ GATE 2 — Knowledge transfer session
List of topics to cover in 1:1 meeting

⛔ GATE 3 — Shadow period (if time allows)
[ ] Receiver shadows 1 deployment
[ ] Receiver handles 1 bug fix with support
[ ] Receiver runs 1 standup / meeting

⛔ GATE 4 — Final handover
Update TEAM.md → new owner
Revoke old member access (GitHub, Notion, .env)
Commit: "chore: handover [area] from [Name] to [Name]"
```
