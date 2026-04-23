# DevStarter — Modify Feature Intake Template

> **How to use:**
> 1. Copy this file to your project folder (e.g. `change-login.md`)
> 2. Fill in your answers — delete the placeholder lines
> 3. Run: `/devstarter-change change-login.md`
>
> Claude will read the file, detect this is a modification (AS-IS/TO-BE), and go straight to impact analysis.

---

> **Instructions for Claude:**
> Read this template at the start of `/devstarter-change` when type = Add Feature (Q1=1),
> and when the user is MODIFYING or EXTENDING an existing feature (not adding a brand-new one).
> Detect from user description: keywords like "change", "update", "modify", "extend", "improve",
> or when user references an existing feature by name.
> Present each section to the user ONE SECTION AT A TIME.
> Fill in answers as the user responds.
> After all sections are complete, save the filled copy to:
>   `memory/intake-modify-feature-[YYYY-MM-DD].md`
> Then show INTAKE SUMMARY and wait for approval before proceeding to A-PHASE 2 (Impact Analysis).

---

## INTAKE: Modify Feature Requirements

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 MODIFY FEATURE INTAKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Let's document exactly what changes and what stays the same.
This prevents unintended regressions.
(Brief answers are fine — Claude will clarify as needed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Section 1 — Feature Being Modified

**1.1 Feature name** (existing feature being changed):
`_______________________________`

**1.2 Where is it located?** (file, component, or module name if known):
`_______________________________`

**1.3 Why is this change needed?** (business reason, user feedback, technical debt):
`_______________________________`

---

### Section 2 — Current vs Desired Behavior

**2.1 Current behavior (AS-IS)** — describe what the feature does TODAY:
```
_______________________________
_______________________________
```

**2.2 Desired behavior (TO-BE)** — describe what it should do AFTER the change:
```
_______________________________
_______________________________
```

**2.3 Gap / delta** — what specifically is different between AS-IS and TO-BE?
```
-
-
```

---

### Section 3 — Acceptance Criteria

**3.1 Acceptance criteria for the NEW behavior** (Given/When/Then — minimum 2):

*New behavior — happy path:*
```
Given [precondition]
When  [user action]
Then  [expected result]
```

*New behavior — error / edge case:*
```
Given [precondition]
When  [user action]
Then  [expected result]
```

**3.2 Regression criteria** — what OLD behavior must still work after the change:
```
Given [precondition]
When  [user action]
Then  [result must still be the same as before]
```

---

### Section 4 — Impact Assessment

**4.1 What must NOT change** (explicit regression guard):
```
-
-
```

**4.2 Is this a breaking change?** (changes API contracts, DB schema, or existing user flows)
- [ ] Yes — describe impact: `_______`
- [ ] No

**4.3 UI changes required?**
- [ ] Yes — describe: `_______`
- [ ] No

**4.4 API changes required?**
- [ ] Yes — describe: `_______`
- [ ] No

**4.5 Database changes required?**
- [ ] Yes — describe: `_______`
- [ ] No

**4.6 Tests that must be updated** (list test names or areas if known):
```
-
-
```

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

---

## INTAKE SUMMARY (Claude fills this after collecting all answers)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INTAKE COMPLETE — Modify Feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature:    [name] (existing)
Location:   [file/component]
Priority:   [Critical / High / Medium / Low]
Effort:     [S / M / L]

AS-IS:  [current behavior summary]
TO-BE:  [desired behavior summary]

Acceptance Criteria (new behavior):
  ✅ [happy path]
  ✅ [error path]

Regression Guard:
  🔒 [must still work]

Breaking change: [yes/no]
Technical scope:
  UI:  [yes/no + description]
  API: [yes/no + description]
  DB:  [yes/no + description]

Saved to: memory/intake-modify-feature-[YYYY-MM-DD].md

  "approve"        → proceed to impact analysis
  "revise [notes]" → update any section above
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
