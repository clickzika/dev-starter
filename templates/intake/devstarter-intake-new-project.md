# DevStarter — New Project Intake Template

> **How to use:**
> 1. Copy this file to your project folder (e.g. `prd.md`)
> 2. Fill in your answers — delete the placeholder lines
> 3. Run: `/devstarter-new prd.md`
>
> Claude will read the file, skip all intake questions, and go straight to setup.

---

> **Instructions for Claude:**
> Read this template at the start of `/devstarter-new` (before Q0-VCS).
> Present each section to the user ONE SECTION AT A TIME.
> Fill in answers as the user responds.
> After all sections are complete, save the filled copy to:
>   `memory/intake-new-project-[YYYY-MM-DD].md`
> Then show INTAKE SUMMARY and wait for approval before proceeding to Q0-VCS.

---

## INTAKE: New Project Requirements

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 NEW PROJECT INTAKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Before we start, let's capture your project requirements.
This ensures we build exactly what you need.
(You can answer briefly — Claude will expand as needed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Section 1 — Project Identity

**1.1 Project name:**
`_______________________________`

**1.2 One-line description** — what does it do and who uses it?
`_______________________________`

**1.3 Problem being solved** — what pain point or gap does this address?
`_______________________________`

---

### Section 2 — Target Users

**2.1 Primary users** (role/persona — e.g. "admin staff", "end customers", "internal devs"):
`_______________________________`

**2.2 Secondary users** (if any):
`_______________________________`

**2.3 Expected user volume** (approximate):
- [ ] Personal / internal (< 10 users)
- [ ] Small team (10–100 users)
- [ ] SMB (100–10,000 users)
- [ ] Large scale (10,000+ users)

---

### Section 3 — Core Features (MoSCoW)

List the features. Claude will apply MoSCoW priority.

**Must have** (launch blockers — can't go live without):
```
-
-
-
```

**Should have** (important but not launch blockers):
```
-
-
```

**Could have** (nice to have, post-launch):
```
-
```

**Won't have** (explicitly out of scope for v1):
```
-
```

---

### Section 4 — Technical Constraints

**4.1 Tech stack preferences** (leave blank to let Claude recommend):
- Frontend: `_______`
- Backend:  `_______`
- Database: `_______`
- Hosting:  `_______`

**4.2 Must integrate with** (external APIs, services, existing systems):
`_______________________________`

**4.3 Must NOT use** (banned tech, licensing constraints):
`_______________________________`

---

### Section 5 — Non-Functional Requirements

**5.1 Performance target** (e.g. "API < 200ms", "supports 1000 concurrent users", or "not critical"):
`_______________________________`

**5.2 Security requirements** (e.g. "OWASP Top 10", "SOC 2", "GDPR", or "basic auth only"):
`_______________________________`

**5.3 Uptime / availability** (e.g. "99.9%", "office hours only", "no requirement"):
`_______________________________`

---

### Section 6 — Success Criteria

**6.1 How do we know the project succeeded?** (measurable outcome):
`_______________________________`

**6.2 Launch criteria** — what must be true before we go live?
`_______________________________`

---

### Section 7 — Constraints

**7.1 Timeline / deadline** (hard deadline or "flexible"):
`_______________________________`

**7.2 Budget / resource constraints** (optional):
`_______________________________`

**7.3 Compliance / regulatory requirements** (e.g. HIPAA, PCI-DSS, or "none"):
`_______________________________`

---

### Section 8 — Explicit Out of Scope

List what is NOT included in this project to prevent scope creep:
```
-
-
```

---

## INTAKE SUMMARY (Claude fills this after collecting all answers)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INTAKE COMPLETE — New Project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:      [name]
Description:  [one-line]
Users:        [primary users]
Scale:        [user volume tier]

Must-have features ([N]):
  - [feature 1]
  - [feature 2]

Stack:        [frontend / backend / DB]
Integrations: [list or "none"]
Deadline:     [date or "flexible"]
Out of scope: [list]

Saved to: memory/intake-new-project-[YYYY-MM-DD].md

  "approve"        → proceed to VCS + PM setup (Q0)
  "revise [notes]" → update any section above
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
