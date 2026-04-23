# DevStarter — Fix Bug Intake Template

> **How to use:**
> 1. Copy this file to your project folder (e.g. `bug-login.md`)
> 2. Fill in your answers — delete the placeholder lines
> 3. Run: `/devstarter-change bug-login.md`
>
> Claude will read the file, detect this is a bug report, and go straight to root cause analysis.

---

> **Instructions for Claude:**
> Read this template at the start of `/devstarter-change` when type = Fix Bug (Q1=3).
> Present each section to the user ONE SECTION AT A TIME.
> Fill in answers as the user responds.
> After all sections are complete, save the filled copy to:
>   `memory/intake-fix-bug-[YYYY-MM-DD].md`
> Then show INTAKE SUMMARY and wait for approval before proceeding to C-PHASE 2 (Bug Analysis).
> The saved file replaces the freeform C-Q1 through C-Q6 questions.

---

## INTAKE: Bug Fix Requirements

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐛 BUG FIX INTAKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Let's capture the full bug report before diagnosing.
Clear reproduction steps = faster fix.
(Brief answers are fine — Claude will clarify as needed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Section 1 — Bug Identity

**1.1 Bug summary** (one sentence — what is wrong):
`_______________________________`

**1.2 Affected area** (feature, module, or page — e.g. "login flow", "PDF export", "checkout"):
`_______________________________`

**1.3 Severity:**
- [ ] Critical — system down or data loss occurring
- [ ] High — major feature broken, no workaround
- [ ] Medium — feature broken, workaround exists
- [ ] Low — minor issue, cosmetic or edge case

**1.4 Environment where bug occurs:**
- [ ] Production (live users affected)
- [ ] Staging
- [ ] Development only
- [ ] All environments

---

### Section 2 — Reproduction

**2.1 Steps to reproduce** (numbered, specific):
```
1.
2.
3.
```

**2.2 Is it reproducible?**
- [ ] Always — happens every time
- [ ] Sometimes — intermittent
- [ ] Hard to reproduce — only happened once / unknown steps

**2.3 Affected users:**
- [ ] All users
- [ ] Specific role: `_______`
- [ ] Specific condition: `_______`
- [ ] Unknown

---

### Section 3 — Expected vs Actual

**3.1 Expected behavior** — what SHOULD happen:
```
_______________________________
```

**3.2 Actual behavior** — what IS happening:
```
_______________________________
```

**3.3 Error messages or logs** (paste relevant output, or "none visible"):
> ⚠️ Sanitize before pasting — remove API keys, passwords, tokens, and personal data (emails, user IDs).
```
_______________________________
```

---

### Section 4 — Context

**4.1 When did this start?** (version, date, or "always been broken"):
`_______________________________`

**4.2 Recent changes that might be related** (recent deploys, config changes, data migrations):
`_______________________________`

**4.3 Suspected cause** (if known — or "unknown"):
`_______________________________`

**4.4 Workaround available?**
- [ ] Yes — describe: `_______`
- [ ] No

---

### Section 5 — Fix Acceptance Criteria

**5.1 How do we verify the bug is fixed?** (Given/When/Then):
```
Given [precondition]
When  [user action]
Then  [bug no longer occurs — specific expected result]
```

**5.2 Regression check** — what must still work after the fix:
```
-
-
```

---

## INTAKE SUMMARY (Claude fills this after collecting all answers)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INTAKE COMPLETE — Fix Bug
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bug:         [one-line summary]
Area:        [affected area]
Severity:    [Critical / High / Medium / Low]
Environment: [Production / Staging / Dev / All]

Reproduction:
  1. [step 1]
  2. [step 2]
  3. [step 3]
  Reproducible: [always / sometimes / unknown]

Expected:  [what should happen]
Actual:    [what is happening]
Error log: [error or "none"]

Suspected cause: [description or "unknown"]
Workaround:      [description or "none"]

Fix verified when:
  Given [X] → When [Y] → Then [Z]

Regression guard:
  🔒 [must still work]

Saved to: memory/intake-fix-bug-[YYYY-MM-DD].md

  "approve"        → proceed to bug analysis
  "revise [notes]" → update any section above
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
