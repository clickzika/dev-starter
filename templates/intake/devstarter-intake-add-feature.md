# DevStarter — Add Feature Intake Template

> **How to use:**
> 1. Copy this file to your project folder (e.g. `newfeature.md`)
> 2. Fill in your answers — delete the placeholder lines
> 3. Run: `/devstarter-change newfeature.md`
>
> Claude will read the file, skip all intake questions, and go straight to impact analysis.

---

> **Instructions for Claude:**
> Read this template at the start of `/devstarter-change` when type = Add Feature (Q1=1),
> and when the feature being added is NEW (not modifying an existing feature).
> Present each section to the user ONE SECTION AT A TIME.
> Fill in answers as the user responds.
> After all sections are complete, save the filled copy to:
>   `memory/intake-add-feature-[YYYY-MM-DD].md`
> Then show INTAKE SUMMARY and wait for approval before proceeding to A-PHASE 2 (Impact Analysis).

---

## INTAKE: Add Feature Requirements

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ADD FEATURE INTAKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Let's define this feature clearly before we build it.
(Brief answers are fine — Claude will clarify as needed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Section 1 — Feature Identity

**1.1 Feature name** (short, e.g. "PDF Export", "Dark Mode", "Bulk Import"):
`_______________________________`

**1.2 One-line summary** — what does this feature do?
`_______________________________`

**1.3 Business objective** — why are we adding this now? What outcome does it drive?
`_______________________________`

---

### Section 2 — User Story

**2.1 Primary user** (role who will use this feature):
`_______________________________`

**2.2 User story:**
```
As a [role],
I want to [action],
So that [business value / outcome].
```

**2.3 Acceptance criteria** (Given/When/Then — minimum 2):

*Happy path:*
```
Given [precondition]
When  [user action]
Then  [expected result]
```

*Error / edge case:*
```
Given [precondition]
When  [user action]
Then  [expected result]
```

---

### Section 3 — Technical Scope

**3.1 Does this require new UI screens or components?**
- [ ] Yes — new screens/pages
- [ ] Yes — modifying existing screens
- [ ] No — backend/API only

If yes, describe the UI briefly:
`_______________________________`

**3.2 Does this require new API endpoints?**
- [ ] Yes — new endpoints
- [ ] Yes — modifying existing endpoints
- [ ] No — frontend only

If yes, describe the endpoints briefly:
`_______________________________`

**3.3 Does this require database changes?**
- [ ] Yes — new tables
- [ ] Yes — new fields on existing tables
- [ ] No — uses existing data only

If yes, describe the schema changes briefly:
`_______________________________`

**3.4 External dependencies** (new APIs, services, packages needed):
`_______________________________`

---

### Section 4 — Constraints & Boundaries

**4.1 What must NOT change** (regression guard — list anything this feature must not break):
```
-
-
```

**4.2 Explicit out of scope** (what this feature does NOT include):
```
-
-
```

**4.3 Is this a breaking change?** (changes existing API contracts, DB schema, or user flows)
- [ ] Yes — describe impact: `_______`
- [ ] No

---

### Section 5 — Priority & Effort

**5.1 Priority:**
- [ ] Critical — blocks other work
- [ ] High — needed this sprint
- [ ] Medium — next sprint
- [ ] Low — nice to have

**5.2 Estimated effort:**
- [ ] S — small (1–2 days)
- [ ] M — medium (3–5 days)
- [ ] L — large (1–2 weeks)
- [ ] XL — needs breaking into sub-features

**5.3 Dependencies** (other features or tasks that must be done first):
`_______________________________`

---

## INTAKE SUMMARY (Claude fills this after collecting all answers)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INTAKE COMPLETE — Add Feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature:    [name]
Summary:    [one-line]
User:       [role]
Priority:   [Critical / High / Medium / Low]
Effort:     [S / M / L / XL]

User Story:
  As a [role], I want [X], so that [Y].

Acceptance Criteria:
  ✅ [happy path]
  ✅ [error path]

Technical scope:
  UI:  [new screens / modify existing / no change]
  API: [new endpoints / modify existing / no change]
  DB:  [new tables / new fields / no change]

Out of scope: [list]
Breaking change: [yes/no]

Saved to: memory/intake-add-feature-[YYYY-MM-DD].md

  "approve"        → proceed to impact analysis
  "revise [notes]" → update any section above
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
