# dev-audit.md — Audit & Review Workflow

## Instructions for Claude Code

This workflow audits an existing codebase for code quality,
security vulnerabilities, performance issues, test coverage,
documentation gaps, and technical debt.

Follow all phases in order. Do NOT skip any phase.

---

## ⚠️ CRITICAL RULES

### Rule 0 — Checkpoint & Auto-Resume (ALWAYS active)

Read `~/.claude/sdlc/devstarter-checkpoint.md` and follow the protocol:
1. **At start** — Setup Cron auto-resume (every 10 minutes)
2. **After every task** — Save checkpoint to `memory/progress.json`
3. **At end** — Cleanup (update status to completed, delete Cron)

---

### Rule 1 — Read Only Until Gate 3
During audit phases (Gates 1–2), agents READ ONLY.
Do NOT modify any code or files until the user approves the audit report
and explicitly requests fixes.

### Rule 2 — Hard Approval Gates
STOP at every gate. Show output. Wait for "approve" or "revise [notes]".

### Rule 3 — Always Read From Files
Read from disk before every task. Never rely on chat history.

### Rule 4 — Severity Levels
Every finding must have a severity:
- 🔴 Critical — must fix before any deployment
- 🟠 High     — fix in current sprint
- 🟡 Medium   — fix in next sprint
- 🔵 Low      — fix when convenient
- ⚪ Info     — awareness only, no action needed

---

## ⚡ FIRST ACTION — Show This Before Anything Else

**If no inline args were provided, the very first message to the user MUST be:**

```
What do you want to audit?

  1. 🔒 Security      — OWASP Top 10, auth, secrets
  2. 🔧 Code Quality  — structure, patterns, duplication
  3. ⚡ Performance   — N+1 queries, slow endpoints, caching
  4. 🧪 Tests         — coverage gaps, missing assertions
  5. 📦 Dependencies  — outdated + vulnerable packages
  6. 🏗️  Architecture  — layers, coupling, scalability
  7. 🔍 Full audit    — all of the above

Then: report only / report + fix plan / fix now?
```

Wait for the user to respond. Parse audit type(s) and outcome from the reply.
Nothing else before this prompt.

**Auto-detect (skip asking):**
- Q1 (project name) → use current folder name
- Q5 (target environment) → check for `.env.production`, CI/CD config, or assume staging

**Special case — inline args:** If the user ran `/devstarter-audit [text]`,
skip this prompt. Extract audit types and outcome from args and start immediately.

---

## PHASE 1 — Audit Scope

Ask these questions ONE AT A TIME:

**Q1. What is the project name?**
(auto-detected from folder name — only ask if ambiguous)

---

**Q2. What type of audit do you want?**
(answered via quick-picker or inline args — confirm if unclear)
1. Security audit (OWASP Top 10 + vulnerabilities)
2. Code quality audit (structure, patterns, maintainability)
3. Performance audit (bottlenecks, N+1 queries, slow endpoints)
4. Test coverage audit (what is tested, what is missing)
5. Documentation audit (missing docs, outdated docs)
6. Dependency audit (outdated packages, vulnerabilities)
7. Architecture audit (design patterns, coupling, scalability)
8. Full audit (all of the above)

---

**Q3. What is the intended outcome?**
(answered via quick-picker or inline args — confirm if unclear)
1. Report only — I want to understand the current state
2. Report + fix plan — I want a prioritized list of what to fix
3. Report + fix now — I want agents to fix issues immediately after audit

---

**Q4. Are there any areas you already know are problematic?**
(free text — or type "none" — always ask this, even with inline args)

---

**Q5. What is the target environment?**
(auto-detected from config — only ask if cannot determine)
1. Production system — needs zero-downtime fixes
2. Staging system — fixes can be tested before production
3. Development only — no production deployment yet

---

## PHASE 2 — Automated Discovery

Tech Lead reads the codebase systematically:

### Step 1 — Structure scan
```
📂 Scanning project structure...
📂 Reading config files...
📂 Reading entry points...
📂 Mapping dependencies...
```

### Step 2 — Run audit by selected type

#### Security Audit
Security agent checks:
- [ ] A01 Broken Access Control — are all endpoints protected?
- [ ] A02 Cryptographic Failures — hardcoded secrets? weak hashing?
- [ ] A03 Injection — raw SQL? unvalidated inputs?
- [ ] A04 Insecure Design — rate limiting? business logic in wrong layer?
- [ ] A05 Misconfiguration — CORS wildcard? debug mode in prod? stack traces?
- [ ] A06 Vulnerable Components — run `dotnet list package --vulnerable` / `npm audit`
- [ ] A07 Auth Failures — JWT expiry? refresh token in localStorage?
- [ ] A08 Data Integrity — package lock files present?
- [ ] A09 Logging — PII in logs? auth events logged?
- [ ] A10 SSRF — outbound URL validation?

#### Code Quality Audit
Tech Lead checks:
- [ ] Naming conventions consistent?
- [ ] Functions/methods too long? (>50 lines = warning)
- [ ] Duplicate code (DRY violations)?
- [ ] Magic numbers / hardcoded strings?
- [ ] Error handling present on all external calls?
- [ ] Async/await used correctly (no fire-and-forget without handling)?
- [ ] DTOs used for all API I/O?
- [ ] Business logic in correct layer?
- [ ] Dead code / unused imports?
- [ ] TODO/FIXME comments that were never resolved?

#### Performance Audit
Backend agent checks:
- [ ] N+1 query problems (loops with DB calls inside)?
- [ ] Missing database indexes on foreign keys and filter columns?
- [ ] Unbounded queries (no pagination on list endpoints)?
- [ ] Synchronous calls where async would be better?
- [ ] Large payloads returned when only subset needed?
- [ ] Caching opportunities (repeated identical queries)?
- [ ] Connection pool configured correctly?

#### Test Coverage Audit
QA agent checks:
- [ ] What percentage of code has unit tests?
- [ ] Are happy paths tested?
- [ ] Are edge cases and error paths tested?
- [ ] Are integration tests present for API endpoints?
- [ ] Are there E2E tests?
- [ ] Are there tests for auth and authorization?
- [ ] Do tests actually assert behavior (not just run without asserting)?

#### Documentation Audit
Docs agent checks:
- [ ] README exists and is accurate?
- [ ] API endpoints documented (Swagger / OpenAPI)?
- [ ] Setup / onboarding guide present?
- [ ] Deployment guide present?
- [ ] Complex business logic explained in comments?
- [ ] Database schema documented?
- [ ] Environment variables documented?
- [ ] Changelog maintained?

#### Dependency Audit
DevOps agent checks:
- [ ] Run `dotnet list package --outdated` (C#)
- [ ] Run `npm outdated` (Node.js)
- [ ] Run `pip list --outdated` (Python)
- [ ] Run `dotnet list package --vulnerable` (C#)
- [ ] Run `npm audit` (Node.js)
- [ ] Run `pip-audit` (Python)
- [ ] Are Docker base images using specific version tags (not `latest`)?
- [ ] Are lock files committed?

#### Architecture Audit
Tech Lead checks:
- [ ] Layers properly separated (API / Business / Data)?
- [ ] Circular dependencies present?
- [ ] God classes / god services (doing too much)?
- [ ] Feature coupling (changes in one feature break another)?
- [ ] Scalability: any stateful components that prevent horizontal scaling?
- [ ] External service calls abstracted behind interfaces?

---

## PHASE 3 — Audit Report

After completing all selected audits, show the full report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 1 — AUDIT REPORT APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate: 1 — Audit Complete
Completed by: [Agent(s)]

Output:
  📄 docs/audit-report.html — full findings

Summary:
  🔴 Critical:  [N] findings
  🟠 High:      [N] findings
  🟡 Medium:    [N] findings
  🔵 Low:       [N] findings
  ⚪ Info:      [N] findings

Top 3 critical findings:
  1. [finding] — [location] — [severity]
  2. [finding] — [location] — [severity]
  3. [finding] — [location] — [severity]

Please review the full report at docs/audit-report.html

  "approve"        → proceed to fix planning
  "revise [notes]" → re-examine specific areas
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE 1 — wait for approval. Do NOT fix anything yet.

---

## PHASE 4 — Fix Plan (if Q3 = 2 or 3)

After Gate 1 approved, Tech Lead generates prioritized fix plan:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 2 — FIX PLAN APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate: 2 — Fix Plan

Output:
  📄 docs/fix-plan.html — prioritized fix list

Sprint 1 — Critical fixes (fix now):
  [ ] [fix 1] — [agent] — [estimated effort]
  [ ] [fix 2] — [agent] — [estimated effort]

Sprint 2 — High priority:
  [ ] [fix 3] — [agent]
  [ ] [fix 4] — [agent]

Sprint 3 — Medium priority:
  [ ] [fix 5] — [agent]

Deferred (Low / Info):
  [ ] [fix 6] — [reason for deferring]

  "approve"        → begin Sprint 1 fixes
  "revise [notes]" → adjust priority or scope
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⛔ GATE 2 — wait for plan approval before writing any code.

---

## PHASE 5 — Fix Execution (if Q3 = 3)

Each fix follows gate approval:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ FIX APPROVAL: [fix description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Finding:  [original issue]
Severity: [🔴/🟠/🟡/🔵]
Fix:      [what was changed]
Files:    [list of changed files]
Tests:    [passing / added N new tests]

Verify the fix is correct before approving.

  "approve"        → commit fix and move to next
  "revise [notes]" → adjust the fix
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

All fixes use the Revision Protocol from dev-starter.md:
- Impact analysis before each fix
- Document updates cascade correctly
- Code changes last

---

## Audit Report HTML Template

Save to `docs/audit-report.html` with sections:

```
1. Executive Summary
   - Overall health score
   - Critical findings count by category
   - Top 3 risks

2. Security Findings (if selected)
   - OWASP A01–A10 checklist with pass/fail/warning
   - Each finding: location + severity + recommendation

3. Code Quality Findings (if selected)
   - Metrics: avg function length, duplication %, test coverage %
   - Each finding: location + severity + recommendation

4. Performance Findings (if selected)
   - Each finding: location + estimated impact + recommendation

5. Dependency Report (if selected)
   - Outdated packages table
   - Vulnerable packages table (🔴 critical)

6. Test Coverage Report (if selected)
   - Coverage % by module
   - Untested critical paths

7. Documentation Gaps (if selected)
   - Missing docs checklist
   - Outdated docs list

8. Architecture Assessment (if selected)
   - Layer separation score
   - Coupling issues
   - Scalability concerns

9. Prioritized Fix List
   - Grouped by sprint
   - Each fix: ID + description + severity + effort + owner

10. Appendix
    - Full raw output from automated tools
    - File-by-file findings
```

---

## Progress Tracker Template

```
## Last Checkpoint
Status:         [IN PROGRESS / WAITING APPROVAL]
Gate:           [current gate]
Audit types:    [list of selected audits]
Last completed: [what was just done]
Next action:    [what to do next]
Files modified: [list or "none — read only phase"]
```

## Resume Instructions
1. Read memory/progress.json first
2. Read docs/audit-report.html if Gate 1 already complete
3. Read docs/fix-plan.html if Gate 2 already complete
4. Announce: "📂 Resuming audit — Gate [N], reading from [filename]"
5. Continue from "Next action" — never skip gate approvals
6. Run /compact when context gets long
