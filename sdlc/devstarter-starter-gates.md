## Agent Pipeline & Gate Structure

```
GATE 0 — Project Setup                ← runs automatically before Gate 1
  DevOps → read ~/.claude/sdlc/devstarter-github.md
         → PROC-GH-01: create GitHub repo + branch strategy
         → PROC-GH-10: set branch protection rules on main
         → PROC-GH-14: create PR + Issue templates (.github/)
  PM     → read ~/.claude/sdlc/devstarter-notion.md
         → PROC-NT-01: find or create Notion parent page
         → PROC-NT-02: create project database (Task Board)
         → PROC-NT-07: create views (Board, By Epic, Sprint, All Tasks)
  DevOps → save .project.env (NOTION_DATABASE_ID, GITHUB_REPO)
  ──────────────────────────────────────────────────
  Show:
    ✅ GitHub: github.com/[user]/[PROJECT_NAME]
    ✅ Notion: [NOTION_BOARD_URL]
    ✅ Branch protection: main protected
    ✅ Templates: PR + Issue templates created
    ✅ Notion views: Board, By Epic, Sprint, All Tasks
  No approval needed — proceed to Gate 1 automatically

GATE 1 — Discovery                    ← HARD STOP: user must approve before Gate 2
  BA → ask Q1–Q31, write CLAUDE.md
  BA → write docs/brd.html (BRD + User Stories + Acceptance Criteria)
  BA + Tech Lead → write docs/srs.html (Software Requirements Specification)
  ──────────────────────────────────────────────────
  ⛔ STOP: Show BRD + SRS → wait for "approve" or "revise [notes]"

GATE 2 — Architecture & Design        ← HARD STOP: user must approve before Gate 3
  All agents read docs/brd.html + docs/srs.html first, then produce:

  **If Q3.1 = 1 (new backend) — Full Stack docs:**
  Tech Lead → architecture + task breakdown (no separate doc — feeds into all below)
  DBA       → docs/database-design.html (schema, ERD, migrations, indexes)
  Backend   → docs/api-reference.html (endpoints, request/response, auth, errors)
  Security  → docs/security-design.html (threat model, OWASP, auth architecture)
  DevOps    → docs/infrastructure-guide.html (cloud arch, CI/CD, deploy, monitoring)
  QA        → docs/test-strategy.html (test plan, coverage, environments)
  UX/UI     → docs/prototype/index.html + docs/prototype/components.html
              (read CLAUDE.md Q22-Q26 design prefs → design tokens → wireframes → component library)
  PM        → docs/project-plan.html (epics, milestones, timeline, risks, RACI)

  **If Q3.1 = 2 (existing API) — Client-Only docs + API Request Spec:**
  Tech Lead → architecture + task breakdown
  Backend   → docs/api-request.html ← NEW: spec ที่ต้องส่งให้ backend project เดิม
  Security  → docs/security-design.html (frontend security: XSS, CSRF, token storage)
  DevOps    → docs/infrastructure-guide.html (frontend deploy only)
  QA        → docs/test-strategy.html (frontend tests + API integration tests)
  UX/UI     → docs/prototype/index.html + docs/prototype/components.html
  PM        → docs/project-plan.html

  Skip: DBA (no database), docs/database-design.html (no schema)
  Skip: docs/api-reference.html (API is in the existing backend project)

  ┌─────────────────────────────────────────────────────────────┐
  │ docs/api-request.html — API REQUEST SPECIFICATION           │
  │                                                             │
  │ This document lists ALL endpoints this project needs        │
  │ from the existing backend API. It serves as:                │
  │  1. Contract between frontend project and backend project   │
  │  2. Input for `/devstarter-change` on the backend project              │
  │  3. Integration test reference                              │
  │                                                             │
  │ Format per endpoint:                                        │
  │  ─────────────────────────────────────────                  │
  │  Endpoint:     [METHOD] [path]                              │
  │  Purpose:      [what it does — 1 sentence]                  │
  │  Request:                                                   │
  │    Headers:    [auth, content-type]                         │
  │    Params:     [path params, query params]                  │
  │    Body:       [JSON schema with types + required fields]   │
  │    Example:    [sample request body]                        │
  │  Response:                                                  │
  │    Success:    [status code + JSON schema]                  │
  │    Example:    [sample response body]                       │
  │    Errors:     [possible error codes + messages]            │
  │  Auth:         [required role/scope or "public"]            │
  │  Notes:        [pagination, rate limit, etc.]               │
  │  ─────────────────────────────────────────                  │
  │                                                             │
  │ Also includes:                                              │
  │  • Summary table (all endpoints at a glance)                │
  │  • Data models used in request/response                     │
  │  • Auth flow (how this project obtains tokens)              │
  │  • Error handling strategy                                  │
  │                                                             │
  │ HOW TO USE THIS DOCUMENT:                                   │
  │  At the existing backend project, run:                      │
  │  > /devstarter-change เพิ่ม API ตาม [path]/docs/api-request.html      │
  │  Claude will read the spec and create all endpoints.        │
  └─────────────────────────────────────────────────────────────┘

  DOCUMENT PORTAL SETUP (MANDATORY):
  After all Gate 2 documents are generated:
  1. Copy `~/.claude/templates/docs/index.html` to `docs/index.html`
     → Replace all `{{PROJECT_NAME}}` with actual project name
     → Replace logo initials in `<div class="topbar-logo">` with project initials
     → Do NOT create index.html from scratch — MUST use the template file
  2. Verify `docs/prototype/components.html` exists (Component Library)
     → Must be real rendered HTML with Tailwind CSS — NOT text descriptions
     → Must include ALL 8 sections as specified in @devstarter-uxui agent file
     → Follow the MANDATORY HTML examples in agents/devstarter-uxui.md

  COMPLETION CHECK:
  If Q3.1 = 1: All 11 files must exist:
    docs/index.html (Document Portal — from template),
    docs/brd.html, docs/srs.html, docs/database-design.html,
    docs/api-reference.html, docs/security-design.html,
    docs/infrastructure-guide.html, docs/test-strategy.html,
    docs/prototype/index.html, docs/prototype/components.html,
    docs/project-plan.html

  If Q3.1 = 2: All 10 files must exist:
    docs/index.html (Document Portal — from template),
    docs/brd.html, docs/srs.html, docs/api-request.html,
    docs/security-design.html, docs/infrastructure-guide.html,
    docs/test-strategy.html, docs/prototype/index.html,
    docs/prototype/components.html, docs/project-plan.html

  PAIR REVIEW — cross-check between agents:
  ┌─────────────────────────────────────────────┐
  │ After all agents produce their output:      │
  │                                             │
  │ 1. Each agent reviews the other outputs     │
  │    for conflicts with their own:            │
  │    • TechLead vs DBA: schema fits arch?     │
  │    • TechLead vs Security: secure design?   │
  │    • Backend vs DBA: API matches schema?    │
  │    • UX/UI vs Backend: UI matches API?      │
  │    • DBA vs Security: data protection?      │
  │    • DevOps vs Backend: infra supports API? │
  │                                             │
  │ 2. If CONFLICTS found:                      │
  │    Show: AGREEMENTS ✅ + CONFLICTS ⚠️       │
  │    Each side proposes resolution             │
  │    Pick the better option with trade-off     │
  │    Update affected docs before showing gate  │
  │                                             │
  │ 3. If NO conflicts: proceed to gate         │
  └─────────────────────────────────────────────┘
  ──────────────────────────────────────────────────
  ⛔ STOP: Show all 9 docs + conflict resolutions (if any)
          → wait for "approve" or "revise [doc]"

GATE 3 — Foundation + Task Setup      ← HARD STOP: user must approve before Gate 4
  PM     → read ~/.claude/sdlc/devstarter-github.md → PROC-GH-04: create labels
  PM     → read ~/.claude/sdlc/devstarter-github.md → PROC-GH-11: create milestones (1 per epic)
  PM     → break tasks into Epic → Feature → Task list → show for approval
  ⛔ STOP: Show task list → wait for "task list approved"

  After approval:
  PM     → read ~/.claude/sdlc/devstarter-github.md → PROC-GH-05: create GitHub Issues (1 per task, assigned to milestone)
  PM     → read ~/.claude/sdlc/devstarter-notion.md → PROC-NT-03: create Notion tasks (link GitHub #, Epic, Role)
  PM     → PROC-NT-10: show project dashboard (progress summary)
  DevOps → scaffold Docker Compose, branch strategy
  Backend → scaffold project, DB connection, /health endpoint
  Frontend → scaffold project, API service, auth interceptor
  ──────────────────────────────────────────────────
  Show:
    ✅ [N] GitHub issues created (assigned to milestones)
    ✅ [N] Notion tasks created (Status: To Do)
    ✅ Scaffold complete
  ⛔ STOP → wait for "approve" or "revise [component]"

GATE 4 — Feature Development          ← Continuous Development (Rule 6 + Rule 7)

  ⚠️ IMPORTANT: After Gate 3 approval, develop ALL tasks continuously.
  Do NOT stop for per-task approval. Only stop at Gate 5 when ALL tasks are done.

  PARALLEL TRACKS (Rule 7):
  ┌─────────────────────────────────────────────────────────────┐
  │ Track A (Backend): @devstarter-dba + @devstarter-backend                          │
  │   DB migrations → API endpoints → unit tests                │
  │                                                             │
  │ Track B (Frontend): @devstarter-frontend + @devstarter-uxui                       │
  │   Components → Pages → integration with API                 │
  │                                                             │
  │ Track C (Infra): @devstarter-devops + @devstarter-security                        │
  │   CI/CD pipeline → Docker → security hardening              │
  │                                                             │
  │ ⚡ Tracks A+B+C run in parallel when independent            │
  │ ⚡ If Track B needs Track A output → complete A first        │
  └─────────────────────────────────────────────────────────────┘

  For EACH task:
    1. PM     → PROC-NT-04: update Notion task → "In Progress"
    2. DevOps → PROC-GH-06: create feature branch (feature/[issue#]-[slug])
    3. Develop:
       - Backend  → read docs/api-reference.html + docs/database-design.html → implement API
       - Frontend → read docs/prototype/index.html + docs/srs.html           → implement UI
       - (run in parallel when tasks are independent)
    4. DevOps → PROC-GH-07: create PR
    5. PR REVIEW — multi-dimensional review:
       ┌─────────────────────────────────────────────┐
       │ Architecture (@devstarter-techlead): fits existing design? over-engineered? │
       │ Code Quality (@devstarter-backend/@devstarter-frontend): error handling, all states?   │
       │ Security (@devstarter-security): input validation, auth, OWASP?            │
       │ Performance: N+1 queries? re-renders? bundle size?              │
       │ Testing (@devstarter-qa): unit + integration + E2E coverage?               │
       │ Docs (@devstarter-docs): new endpoints documented? changelog?              │
       └─────────────────────────────────────────────┘
       Severity: 🔴 BLOCKER (must fix) | 🟡 MAJOR (should fix) | 🟢 MINOR (suggestion)
       → If 🔴 BLOCKER found → agent fixes immediately, then continue
       → If 🟡 MAJOR found → fix now or note for later
       → If only 🟢 MINOR → continue to next task
    6. PM     → PROC-NT-05: update Notion task → "In Review", add PR #
    7. DevOps → PROC-GH-08: merge PR, close issue
       ⚠️ If merge conflict → follow PROC-GH-13 (conflict resolution)
    8. PM     → PROC-NT-06: update Notion task → "Done"
    → proceed to next task (NO STOP between tasks)

GATE 5 — Quality & Delivery           ← HARD STOP: user must approve before deploy
  QA       → read docs/brd.html → write + run tests → coverage report
  Security → read docs/security-design.html → OWASP checklist
  DevOps   → configure CI/CD pipeline → run pipeline
  Docs     → write README, API docs, deployment guide
  PM       → verify all Notion tasks → Done
  ──────────────────────────────────────────────────
  ⛔ STOP: Show test + security report → wait for "approve" to deploy

  After approval:
  DevOps → PROC-GH-15: determine semver (patch/minor/major)
  DevOps → PROC-GH-09: merge develop → main, tag with semver
  Show:
    ✅ All [N] GitHub issues closed
    ✅ All [N] Notion tasks → Done
    ✅ Merged to main, tagged [semver]
    🚀 Ready for production deployment
```

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


