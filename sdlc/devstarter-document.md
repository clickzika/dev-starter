# devstarter-document.md — Document Generator Workflow

## Model: Sonnet (`claude-sonnet-4-6`)

## Purpose

Generate or regenerate a specific project document at any time —
independently of the full new-project or onboarding workflow.

Use this when:
- A document needs to be updated after a schema/API/feature change
- A document was skipped during setup and needs to be created now
- You want to refresh a single doc without re-running an entire gate workflow

```
/devstarter-document brd        → regenerate docs/brd.html
/devstarter-document api        → regenerate docs/api-reference.html
/devstarter-document schema     → regenerate docs/database-design.html
/devstarter-document test       → regenerate docs/test-strategy.html
/devstarter-document security   → regenerate docs/security-design.html
/devstarter-document infra      → regenerate docs/infrastructure-guide.html
/devstarter-document prototype  → regenerate docs/prototype/
/devstarter-document plan       → regenerate docs/project-plan.html
/devstarter-document all        → regenerate all of the above
```

---

## CRITICAL RULES

### Rule 1 — Read Agent File Before Producing Any Document
Before generating any document, read the responsible agent's file:

| Doc type | Agent file to read first |
|----------|--------------------------|
| brd, srs | `~/.claude/agents/devstarter-ba.md` |
| api | `~/.claude/agents/devstarter-backend.md` |
| schema | `~/.claude/agents/devstarter-dba.md` |
| test | `~/.claude/agents/devstarter-qa.md` |
| security | `~/.claude/agents/devstarter-security.md` |
| infra | `~/.claude/agents/devstarter-devops.md` |
| prototype | `~/.claude/agents/devstarter-uxui.md` |
| plan | `~/.claude/agents/devstarter-pm.md` |

Announce before every document:
```
🤖 Acting as [@agent]
📖 Reading agent spec: ~/.claude/agents/[agent].md ✓
📄 Output format: styled HTML — docs/[filename].html
📋 Producing: [document name]
```

### Rule 2 — Read Project Context First
Before generating any document, read from disk:
```
📂 Reading:
- CLAUDE.md ✓ (project stack, conventions, features)
- docs/[filename].html ✓ (existing content to UPDATE — or "not found, creating fresh")
```

If CLAUDE.md does not exist → STOP and tell user to run `/devstarter-existing` first.

### Rule 3 — Document Standards (MANDATORY)
- All documents MUST use `~/.claude/templates/docs/document-template.html` as base
- Save to `docs/` folder
- `docs/index.html` MUST be updated/created after every document (use `~/.claude/templates/docs/index.html`)
- Prototype output (`docs/prototype/components.html`) MUST include all 8 mandatory sections

### Rule 4 — Create or Update (never silently overwrite)
Before generating, announce whether you are:
- **Creating fresh** — file does not exist yet
- **Updating** — file exists, you will update/regenerate sections

If updating: preserve any existing sections not covered by the current codebase scan.
Add a Revision History row at the bottom of the document.

### Rule 5 — Approval Gate
After generating, always show an approval gate:
```
⛔ GATE — DOCUMENT REVIEW
Document: [filename]
Action:   [Created fresh / Updated]

  "approve"        → register in docs/index.html + commit
  "revise [notes]" → regenerate with corrections
```

---

## FIRST ACTION — Show This Before Anything Else (no inline args)

If user typed `/devstarter-document` with no arguments:

```
Which document do you want to generate?

  1. 📋 BRD             — docs/brd.html
  2. 📐 SRS             — docs/srs.html
  3. 🔌 API Reference   — docs/api-reference.html
  4. 🗄️  DB Schema       — docs/database-design.html
  5. 🧪 Test Strategy   — docs/test-strategy.html
  6. 🔒 Security Design — docs/security-design.html
  7. 🏗️  Infra Guide     — docs/infrastructure-guide.html
  8. 🖼️  UI Prototype    — docs/prototype/
  9. 📅 Project Plan    — docs/project-plan.html
  10. 🔄 All documents  — regenerate everything

Or type the doc name: "brd", "api", "schema", "test", "security", "infra", "prototype", "plan", "all"
```

---

## PHASE 1 — Discover Project Context

### Step 1.1 — Read CLAUDE.md
Extract:
- Tech stack (language, framework, database, ORM)
- API endpoints (if api doc requested)
- Feature list (for brd/srs)
- Existing docs (check docs/ folder)

### Step 1.2 — Scan Codebase (if CLAUDE.md is missing key info)
Supplement from code when CLAUDE.md lacks detail:
- Routes/controllers → for API doc
- Models/entities → for schema doc
- Existing test files → for test strategy
- Infrastructure files (Dockerfile, CI yml) → for infra doc

### Step 1.3 — Announce findings
```
📂 Context loaded:
  Stack:    [detected]
  Docs dir: [exists / will be created]
  Target:   [filename] — [creating fresh / updating]
```

---

## PHASE 2 — Generate Document

Route to the correct agent and generation logic:

### DOC: brd — Business Requirements Document
**Agent:** @devstarter-ba
**Read:** `~/.claude/agents/devstarter-ba.md`
**Output:** `docs/brd.html`

Generate using BRD Quick Structure from agent file:
1. Executive Summary
2. Scope (in scope / out of scope / assumptions / constraints)
3. Stakeholders (matrix + RACI)
4. AS-IS State (current system behavior)
5. TO-BE State (desired behavior, business rules)
6. Functional Requirements (by feature area, with REQ IDs)
7. Non-Functional Requirements (performance, security, compliance)
8. Data Requirements (entities, rules, integrations)
9. Open Issues Log
10. Glossary

---

### DOC: srs — Software Requirements Specification
**Agent:** @devstarter-ba
**Read:** `~/.claude/agents/devstarter-ba.md`
**Output:** `docs/srs.html`

Generate using IEEE 830 structure:
1. Introduction (purpose, scope, definitions)
2. Overall Description (product perspective, functions, users)
3. Functional Requirements (use cases with Given-When-Then)
4. Non-Functional Requirements (performance, security, reliability)
5. System Constraints
6. Appendix (glossary, index)

---

### DOC: api — API Reference
**Agent:** @devstarter-backend
**Read:** `~/.claude/agents/devstarter-backend.md`
**Output:** `docs/api-reference.html`

Scan codebase for:
- All route definitions (method + path)
- Request parameters, body schema, headers
- Response schemas (success + error)
- Auth requirements per endpoint
- Rate limiting rules

Generate per endpoint:
```
METHOD  /path/to/endpoint
Auth:   [required / optional / none]
Params: [query params with types]
Body:   [JSON schema]
Response 200: [schema]
Response 4xx: [error codes + messages]
```

---

### DOC: schema — Database Design
**Agent:** @devstarter-dba
**Read:** `~/.claude/agents/devstarter-dba.md`
**Output:** `docs/database-design.html`

Scan for:
- Models/entities (ORM files, migration files, raw SQL)
- Relationships (foreign keys, join tables)
- Indexes and constraints

Generate:
1. ERD diagram (Mermaid)
2. Table definitions (columns, types, constraints, indexes)
3. Migration history (if migration files found)
4. Query patterns (common queries, optimization notes)

---

### DOC: test — Test Strategy
**Agent:** @devstarter-qa
**Read:** `~/.claude/agents/devstarter-qa.md`
**Output:** `docs/test-strategy.html`

Scan for:
- Existing test files and frameworks
- CI/CD pipeline test stages
- Coverage configuration

Generate:
1. Test scope and objectives
2. Test types (unit / integration / E2E / load / security)
3. Test framework configuration
4. Coverage targets per layer
5. Test data strategy
6. CI/CD integration

---

### DOC: security — Security Design
**Agent:** @devstarter-security
**Read:** `~/.claude/agents/devstarter-security.md`
**Output:** `docs/security-design.html`

Generate:
1. Threat model
2. Authentication & authorization design
3. OWASP Top 10 checklist (for this stack)
4. Secrets management approach
5. Data protection (encryption at rest/transit)
6. Security headers and CORS policy
7. Incident response outline

---

### DOC: infra — Infrastructure Guide
**Agent:** @devstarter-devops
**Read:** `~/.claude/agents/devstarter-devops.md`
**Output:** `docs/infrastructure-guide.html`

Scan for: Dockerfile, docker-compose, CI yml, terraform, k8s manifests

Generate:
1. Architecture overview (diagram)
2. Environment setup (local / staging / production)
3. CI/CD pipeline walkthrough
4. Container / cloud configuration
5. Monitoring & alerting setup
6. Runbooks (deploy, rollback, scale)

---

### DOC: prototype — UI Prototype
**Agent:** @devstarter-uxui
**Read:** `~/.claude/agents/devstarter-uxui.md`
**Output:** `docs/prototype/index.html` + `docs/prototype/components.html`

Generate:
- `components.html` — MANDATORY 8 sections:
  Typography, Colors, Buttons, Forms, Data Display,
  Navigation, Feedback, Layout
- `index.html` — screen wireframes for all major user flows
- Use design tokens from CLAUDE.md (Q22–Q26) or infer from existing CSS

---

### DOC: plan — Project Plan
**Agent:** @devstarter-pm
**Read:** `~/.claude/agents/devstarter-pm.md`
**Output:** `docs/project-plan.html`

Generate:
1. Project summary and milestones
2. Sprint breakdown (if sprints found in Notion/Jira)
3. Resource plan (agents / roles)
4. Risk register
5. Definition of Done

---

### DOC: all — All Documents
Generate each doc above in this order:
1. brd → 2. schema → 3. api → 4. security → 5. infra → 6. test → 7. prototype → 8. plan

After each doc, save immediately. Do NOT wait until all are done.
Show progress:
```
✅ 1/8 brd — docs/brd.html (created/updated)
✅ 2/8 schema — docs/database-design.html
...
```

Show single approval gate after all 8 are complete.

---

## PHASE 3 — Register in docs/index.html

After generating each document:

### If docs/index.html does not exist:
Copy from `~/.claude/templates/docs/index.html` and replace `{{PROJECT_NAME}}`.

### If docs/index.html exists:
Add the new document to the document list if not already present.

---

## PHASE 4 — Approval Gate

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE — DOCUMENT REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Document: [filename]
Action:   [Created fresh / Updated]
Agent:    [@agent]

  "approve"        → commit + update docs/index.html
  "revise [notes]" → regenerate with corrections
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After approval:
- `git add docs/[filename].html`
- `git commit -m "docs: regenerate [doctype] via /devstarter-document"`

---

## Relationship to Other Commands

| Scenario | Use this instead |
|----------|-----------------|
| Starting a brand new project | `/devstarter-new` — docs auto-generated at Gate 1 & 2 |
| Onboarding existing project | `/devstarter-existing` — generates CLAUDE.md + core docs |
| CLAUDE.md is stale | `/devstarter-context` — updates CLAUDE.md only |
| Single doc is stale or missing | `/devstarter-document [type]` ← this command |
| All docs need refresh | `/devstarter-document all` ← this command |
