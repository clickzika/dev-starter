# dev-migrate.md — Migration Workflow

> **TL;DR** — Plan and execute a tech-stack migration with strangler-fig + ADR · **Lifecycle** Build · **Gates** 3

## Model: Opus (`claude-opus-4-7`)
> Deep reasoning required — run `/model opus` before this workflow.

## Instructions for Claude Code

This workflow is for migrating an existing project to a new tech stack,
framework version, database, or architecture pattern.

Follow all phases in order. Do NOT skip any phase.

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## ⚠️ CRITICAL RULES

### Rule 1 — Hard Approval Gates
STOP at every gate. Show output. Wait for "approve" or "revise [notes]".

### Rule 2 — Never Touch Production Until Gate 5
All migration work happens on a separate branch.
Never modify the main/production branch until Gate 5 is approved.

### Rule 3 — Always Read From Files
Read from disk before every task. Never rely on chat history.

### Rule 4 — Parallel Safety
Keep the old system running until the new system is verified.
Never delete old code until Gate 5 is approved.

---

## PHASE 1 — Migration Discovery

Ask these questions ONE AT A TIME:

**Q1. What is the project name?**
(free text)

---

**Q2. What are you migrating FROM?**
(free text — e.g. ".NET Framework 4.8 Web API", "MySQL 5.7", "AngularJS", "monolith")

---

**Q3. What are you migrating TO?**
(free text — e.g. ".NET 8 Minimal API", "PostgreSQL", "Angular 17", "microservices")

---

**Q4. What is the reason for migration?**
(select all that apply)
1. End of life / no longer supported
2. Performance improvement
3. Cost reduction
4. Security vulnerabilities in current stack
5. Developer experience / productivity
6. New feature requirements that current stack cannot support
7. Cloud / containerization readiness
8. Team skill alignment
9. Other (specify)

---

**Q5. What is the migration scope?**
1. Full migration — replace everything
2. Partial migration — migrate specific components only
3. Strangler fig — migrate incrementally, old and new run side by side
4. Database only — keep application code, change database
5. Frontend only — keep backend, replace UI framework
6. Backend only — keep frontend, replace API layer

---

**Q6. What is the risk tolerance?**
1. Low risk — must have zero downtime, full rollback plan
2. Medium risk — brief downtime acceptable, rollback within 1 hour
3. High risk — full cutover acceptable, team available during migration

---

**Q7. Is there an existing test suite?**
1. Yes — unit tests + integration tests
2. Yes — unit tests only
3. Yes — manual test scripts / UAT cases documented
4. No — no tests exist
5. Not sure

---

**Q8. What is the deployment target after migration?**
1. Docker self-hosted (docker-compose)
2. Docker + Nginx reverse proxy
3. Kubernetes
4. Azure App Service / Container Apps
5. AWS EC2 / ECS
6. Same as current — no change
7. Other (specify)

---

## PHASE 2 — Current System Analysis

Tech Lead reads the existing codebase:

1. Map all existing features and endpoints
2. Identify all database tables and relationships
3. Identify all external integrations and dependencies
4. Identify all configuration and environment variables
5. Identify all business rules embedded in code
6. Estimate migration complexity per component

Show analysis report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 MIGRATION ANALYSIS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM: [current stack]
TO:   [target stack]

Components to migrate:
  🟢 Simple   — [list: straightforward 1:1 migration]
  🟡 Medium   — [list: requires refactoring]
  🔴 Complex  — [list: significant rework needed]

Database tables:     [N] tables
API endpoints:       [N] endpoints
External services:   [list]
Environment vars:    [list]
Estimated effort:    [Low / Medium / High]

Breaking changes:
  - [change 1]
  - [change 2]

Risks:
  - [risk 1]
  - [risk 2]

  "approve"        → generate migration plan
  "revise [notes]" → correct the analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate 1 — Migration analysis complete. Approve to generate migration plan?"
- options: ["approve", "revise"]

⛔ GATE 1 — wait for approval before proceeding.

---

## PHASE 2.5 — GitHub + Notion Setup (after Gate 1 approved)

After Gate 1 approved, before generating migration plan:

1. Read `~/.claude/devstarter-github.md` → follow PROC-GH-02 (connect existing repo)
2. Read `~/.claude/devstarter-github.md` → follow PROC-GH-03 (create migration branch)
3. Read `~/.claude/devstarter-notion.md` → follow PROC-NT-01 + PROC-NT-02 (create migration task board)
4. Save `.project.env`

Show:
```
✅ GitHub: [repo URL]
✅ Migration branch: migration/[name]-[date]
✅ Notion: [board URL] — Migration Task Board ready
⚠️  main and develop are PROTECTED until Gate 7
→ Proceeding to migration plan...
```

---

## PHASE 3 — Migration Plan

After Gate 1 approved, Tech Lead generates the migration documents.

**First — the plain-language Kickoff (stakeholder + management sign-off).**
A migration is a large, long-lead-time commitment; before the technical plan,
produce a plain-language kickoff so stakeholders and management can approve the
direction. This is the PLAIN pair of the technical `migration-plan.html` — do
NOT duplicate the strategy detail; keep it business-level.

Read `~/.claude/templates/docs/devstarter-change-kickoff-template.html`. Create
folder `docs/migration/[slug]/` (slug = migration name, lowercase-hyphenated).
Fill `{{PLACEHOLDER}}` tokens, migration-framed:

| Placeholder | Source |
|-------------|--------|
| `{{CHANGE_TYPE}}` | `Migration` |
| `{{CONFIRMATION_HEADING}}` | `What We Will Migrate` |
| `{{FEATURE_NAME}}` | `[FROM] → [TO]` (from Q2/Q3) |
| `{{AUTHOR}}` | Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias |
| `{{PLAIN_SUMMARY}}` | 2–3 plain sentences: what is moving, why, expected outcome |
| `{{CONFIRMATION_DETAIL}}` | plain description of the FROM→TO change (no deep tech) |
| `{{CONFIRMATION_SECONDARY_TITLE}}` / `{{CONFIRMATION_SECONDARY}}` | `Migration Strategy` + plain note (strangler/big-bang/parallel) |
| `{{IN_SCOPE_LIST}}` / `{{OUT_OF_SCOPE_LIST}}` | components migrated vs kept (from Q5 + analysis) |
| `{{ACCEPTANCE_CRITERIA_LIST}}` | `<li>` — parity verified, zero data loss, rollback works |
| `{{BUSINESS_NEED}}` | from Q4 reasons, plain language |
| `{{WHO_BENEFITS}}` | teams/users benefiting |
| `{{IMPACT_IF_DEFERRED}}` | cost/risk of staying on current stack (EOL, security, cost) |
| `{{EFFORT}}` / `{{TIMELINE_ESTIMATE}}` | from analysis effort estimate |
| `{{RISK_LEVEL}}` / `{{RISK_DETAIL}}` | from Q6 risk tolerance + risk register summary |
| `{{SIGN_OFF_MEANING}}` | "Approving authorises the migration branch and the full migration plan to proceed." |
| `{{APPROVER_ROWS}}` | `<tr>` per approver (Requester, Manager/Sponsor) |

**Bilingual (MANDATORY):** EN + TH in every text block (Rule 8).
Save to `docs/migration/[slug]/kickoff.html`; register in docs/index.html under
"Migrations".

> ⚠️ Link fix: the kickoff template's "Next document" footer hard-links
> `plan.html` (same-folder, for change flows). The migration technical plan lives
> at top-level `docs/migration-plan.html`, so replace that href with
> `../../migration-plan.html` when filling the migration kickoff.

Then generate the technical migration documents below.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 2 APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate: 2 — Migration Plan

Output produced:
  📝 docs/migration/[slug]/kickoff.html  — plain-language sign-off (stakeholder + mgmt)
  📄 docs/migration-plan.html  — full migration strategy (technical)
  📄 docs/schema-mapping.html  — old schema → new schema mapping
  📄 docs/risk-register.html   — risks + mitigation

Migration strategy: [Strangler Fig / Big Bang / Parallel Run]
Branch: migration/[project-name]
Rollback plan: [description]

  "approve"        → create migration branch and begin
  "revise [notes]" → adjust the plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate 2 — Migration plan ready. Approve to create branch and begin migration?"
- options: ["approve", "revise"]

---

## PHASE 4 — Migration Execution Gates

### Gate 3 — Infrastructure Setup ⛔
- [ ] Read `~/.claude/devstarter-github.md` → PROC-GH-04: create labels
- [ ] PM: create GitHub issues for all migration tasks (PROC-GH-05)
- [ ] PM: create Notion tasks for all migration tasks (PROC-NT-03)
- [ ] Create migration branch: `migration/[project-name]`
- [ ] Setup new project scaffold on migration branch
- [ ] Setup new database (schema only, no data yet)
- [ ] Setup Docker Compose with both old and new services running
- [ ] Verify new scaffold builds and starts
- [ ] **GATE 3 APPROVAL** — show running services before proceeding

### Gate 4 — Data Migration ⛔
- [ ] DBA: write schema mapping (old → new)
- [ ] DBA: write migration scripts
- [ ] DBA: test migration scripts on copy of production data
- [ ] DBA: verify data integrity after migration
- [ ] DBA: write rollback scripts
- [ ] **GATE 4 APPROVAL** — show data integrity report before proceeding

### Gate 5 — Code Migration ⛔ (approve per component)
For each component (in dependency order):
- [ ] Migrate [component 1] → test → **COMPONENT APPROVAL**
- [ ] Migrate [component 2] → test → **COMPONENT APPROVAL**
- [ ] Migrate [component N] → test → **COMPONENT APPROVAL**

Each component approval format:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ COMPONENT APPROVAL: [component name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Migrated: [what was done]
Tests:    [passing / failing — show count]
Parity:   [old behavior vs new behavior verified]

  "approve"        → migrate next component
  "revise [notes]" → fix issues first
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Gate 5 — Component migration complete. Approve to migrate next component?"
- options: ["approve", "revise"]

### Gate 6 — Verification ⛔
- [ ] QA: run full test suite on migrated system
- [ ] QA: run parity tests (old vs new output comparison)
- [ ] Security: run security scan on new stack
- [ ] Performance: compare response times old vs new
- [ ] **GATE 6 APPROVAL** — show full verification report

### Gate 7 — Cutover ⛔ (point of no return)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 7 — CUTOVER APPROVAL (FINAL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  This is the point of no return.

Cutover plan:
  1. [step 1 with estimated time]
  2. [step 2 with estimated time]
  3. [step 3 with estimated time]

Rollback plan (if needed):
  1. [rollback step 1]
  2. [rollback step 2]

Estimated downtime: [X minutes / zero downtime]

Use `AskUserQuestion` with:
- question: "Gate 7 — POINT OF NO RETURN. Approve cutover to new system?"
- options: ["CUTOVER APPROVED", "cancel — stay on current system"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Only proceed when user types exactly "CUTOVER APPROVED".

---

## PHASE 5 — Post-Migration Management Brief

After successful cutover and verification, generate the plain-language
management brief — the PLAIN pair that closes the migration for stakeholders
(the technical record lives in migration-plan.html + the verification report).

Read `~/.claude/templates/docs/devstarter-change-mgmt-template.html`. Fill with
plain business language (no code, no stack detail):
- `{{CHANGE_TYPE}}` = `Migration`; `{{FEATURE_NAME}}` = `[FROM] → [TO]`
- `{{AUTHOR}}` = Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias
- `{{EXECUTIVE_SUMMARY}}` = what migrated, outcome, business value
- `{{SITUATION_BEFORE}}` / `{{SITUATION_AFTER}}` = old stack pain vs new stack gains
- `{{METRICS_ROWS}}` = before/after numbers (response time, cost, etc. from Gate 6)
- `{{RESIDUAL_RISK_DETAIL}}` / `{{ROLLBACK_CAPABILITY}}` = remaining risk + revert window
- `{{NEXT_STEPS_ROWS}}` = decommission old stack, monitoring, follow-ups

**Bilingual (MANDATORY):** EN + TH in every text block (Rule 8).
Save to `docs/migration/[slug]/mgmt-brief.html`; register in docs/index.html
alongside the kickoff. Symmetric family — Migration: kickoff (plain pre) +
migration-plan (technical pre); mgmt-brief (plain post) + verification (technical post).

---

## Progress Tracker Template

```
## Last Checkpoint
Status:         [IN PROGRESS / BLOCKED / WAITING APPROVAL]
Gate:           [current gate]
Branch:         migration/[project-name]
Last completed: [what was just done]
Next action:    [what to do next]
Files modified: [list]
Old system:     [RUNNING / STOPPED]
New system:     [NOT STARTED / BUILDING / RUNNING]
```

## Resume Instructions
1. Read memory/progress.json first
2. Identify current gate and branch
3. Check: is old system still running? Is new system intact?
4. Read relevant docs from disk (migration-plan.html, schema-mapping.html)
5. Announce: "📂 Resuming migration — Gate [N], branch [branch-name]"
6. Continue from "Next action" — never skip gate approvals
7. Run /compact when context gets long
