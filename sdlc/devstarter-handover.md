# dev-handover.md — Project Handover

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

When a team member leaves or transfers ownership:
```
claude
> Read ~/.claude/devstarter-handover.md and prepare handover from [Name] to [Name]
```

## When to use vs alternatives

- **Use /devstarter-handover** when: an existing owner is transferring ownership
  of a project / area / on-call rotation. Output: handover doc + access revocation
  + transfer plan.
- **Use /devstarter-onboard** instead when: a new person is joining and there's
  no specific predecessor — output is a personalized briefing + first-PR plan.
- **Use /devstarter-existing** instead when: the project is new to *you* (first
  time setting up DevStarter on it), but ownership isn't changing hands.

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
Revoke old member access (concrete steps below)
Commit: "chore: handover [area] from [Name] to [Name]"
```

### Access revocation checklist (read VCS_TYPE + PM_TYPE from devstarter-config.yml)

**VCS access (pick the row that matches `vcs.type`):**

| VCS_TYPE | Revoke command |
|----------|---------------|
| github   | `gh api -X DELETE repos/<org>/<repo>/collaborators/<user>` (or remove from team if granted via team membership) |
| gitlab   | `glab api -X DELETE projects/<id>/members/<user_id>` |
| svn      | Edit `authz` file on server; remove user from `[groups]` and project paths; redeploy |

**PM access (pick the row that matches `pm.type`):**

| PM_TYPE | Revoke step |
|---------|-------------|
| notion  | Workspace admin → Settings → Members → remove user from project page sharing |
| jira    | Site admin → User management → remove from project role; revoke API token |
| linear  | Workspace settings → Members → remove user from team |

**Other:**
- [ ] Rotate any shared secrets the old member knew (`.env`, deploy keys, API tokens, DB passwords)
- [ ] Remove from CI/CD secret stores if they had unique tokens
- [ ] Remove from monitoring / on-call paging (PagerDuty, Opsgenie)
- [ ] Remove from chat (Slack/LINE/Discord) project channels
- [ ] Update DNS / cloud account IAM if they had elevated cloud access
- [ ] Audit recent commits on protected branches for any pending pushes
- [ ] Confirm new owner has all the access the old owner had

> ⚠️ Secret rotation rule: if the departing member had access to ANY shared
> secret, that secret MUST be rotated, not just access-revoked. Cached
> credentials persist after access removal.
