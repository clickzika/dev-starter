# dev-dod.md — Definition of Done + Quality Gates

## Purpose

This file defines what "done" means at every level.
All agents check this file before marking any task complete.
Place at project root.

---

## Task Level — Done means:

```
Code
  [ ] Feature implemented as per docs/brd.html acceptance criteria
  [ ] Code follows standards in CLAUDE.md
  [ ] No hardcoded secrets or debug code
  [ ] No commented-out code left behind

Tests
  [ ] Unit tests written for new business logic
  [ ] Unit tests passing (all green)
  [ ] Integration tests passing
  [ ] No test skipped without documented reason

Review
  [ ] PR created with description
  [ ] At least 1 reviewer approved (see TEAM.md)
  [ ] All PR comments resolved
  [ ] Branch merged + deleted

Tracking
  [ ] GitHub issue closed
  [ ] Notion task → Done
  [ ] CLAUDE.md Progress Tracker ticked
```

---

## Feature Level — Done means:

All task-level checks PLUS:

```
Documentation
  [ ] docs/brd.html acceptance criteria all passing
  [ ] docs/api.html updated if endpoints added/changed
  [ ] docs/schema.html updated if DB changed
  [ ] docs/uxui.html updated if UI changed
  [ ] README.md updated if setup steps changed

Quality
  [ ] Feature tested in development environment end-to-end
  [ ] Edge cases tested (empty state, error state, max values)
  [ ] Accessible (keyboard nav, screen reader if applicable)
  [ ] Responsive (mobile + desktop if web app)

Security
  [ ] Auth/authorization enforced on new endpoints
  [ ] Input validation on all new request bodies
  [ ] No PII in logs from new code
  [ ] OWASP checklist item verified (if relevant)
```

---

## Sprint Level — Done means:

All feature-level checks PLUS:

```
Sprint closure
  [ ] All committed tasks Done or moved with documented reason
  [ ] Sprint retrospective completed
  [ ] Retrospective action items created in GitHub + Notion
  [ ] CLAUDE.md Last Checkpoint updated
  [ ] docs/retrospective-sprint-[N].html written
  [ ] Next sprint planned (dev-sprint.md)
```

---

## Release Level — Done means:

All sprint-level checks PLUS: see `dev-release.md` checklist.

---

## Agent Rules

Before announcing any task as complete, agents MUST verify:

1. Read this file
2. Check every applicable item for the task level
3. If any item is NOT checked → fix it before announcing done
4. Never mark done just because code is written
5. Show the DoD checklist in the gate approval message

Gate approval must include:
```
DoD Status:
  [x] Code complete
  [x] Tests passing
  [x] PR approved
  [x] GitHub closed
  [x] Notion → Done
  [ ] FAILED: [what is missing]
```
