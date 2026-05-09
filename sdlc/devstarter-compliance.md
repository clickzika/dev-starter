# devstarter-compliance.md — Compliance Audit (WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS)

> **TL;DR** — Audit against WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001 · **Lifecycle** Operate · **Gates** 1

## Model: Sonnet (`claude-sonnet-4-6`)
> Template-driven checklist work; deeper reasoning happens in remediation
> ADRs, not the audit itself.

**Config:** Read `devstarter-config.yml` for project settings.

## How to Use

Run a compliance audit for a specific framework. Outputs a gap report,
remediation roadmap with owners + dates, and (for SOC 2 / HIPAA) an
evidence pack for external auditors.

```
/devstarter-compliance                       → interactive (pick framework + scope)
/devstarter-compliance wcag                  → WCAG 2.1 Level AA audit
/devstarter-compliance gdpr                  → GDPR data-mapping + DPIA
/devstarter-compliance hipaa                 → HIPAA PHI flow audit
/devstarter-compliance soc2                  → SOC 2 Type II evidence pack
/devstarter-compliance pci                   → PCI-DSS scope review
```

This command **identifies gaps and produces a roadmap**. It does not
implement fixes — that's a handoff to `/devstarter-change`.

---

## ⚠️ CRITICAL RULES

### Rule 1 — Scope ≤ assess ≤ fix
Phase 0 defines scope. Phase 1–3 assesses gaps. Phase 4–5 publishes the
roadmap. Implementation happens in `/devstarter-change` per finding.
Do not start implementing during the audit — gaps stay in the roadmap.

### Rule 2 — Findings have severity, owner, target date
"We need to improve consent flow" with no owner is theatre. Every
finding must have: severity (Critical / High / Medium / Low), owner
(named person — resolved later by PM), and target date.

### Rule 3 — Don't claim more than you have
A "Pass" verdict requires evidence (artifact link, test result, code
reference). "We probably do this" is not Pass — it's Unknown, which is
a finding that becomes "audit this further."

### Rule 4 — Honest about what's out of scope
If a feature isn't in scope (e.g., HIPAA only applies to the patient-
records subsystem), say so explicitly in the report. Auditors see
"out of scope" claims as signals to look harder; vague scope kills
trust.

### Rule 5 — Investigation only — code changes via /devstarter-change
This runbook produces a report and tickets. Implementation handoffs.

---

## FIRST ACTION — Inline Arg Handling

**Plain text (framework name):** use as Phase 0 Q1; skip framework picker.
**File arg:** read prior compliance report; pre-fill Phase 0 + comparison.
**No args:** start Phase 0 from Q1.

---

## PHASE 0 — Audit Scope

Use `AskUserQuestion`:

**Q1. Which framework?**
1. WCAG 2.1 Level AA (accessibility)
2. WCAG 2.2 Level AA (latest accessibility)
3. GDPR (EU data protection)
4. HIPAA (US healthcare PHI)
5. SOC 2 Type II (security/availability/confidentiality controls)
6. PCI-DSS (payment card data)
7. ISO 27001 (information security management)
8. Multiple — list them

**Q2. What's the audit scope?**
1. Full project
2. Specific subsystem (e.g., "patient records only" for HIPAA)
3. Specific user-facing surface (e.g., "checkout flow only" for PCI)
4. Specific data type (e.g., "billing data only" for GDPR)

**Q3. What triggered this audit?**
1. Pre-launch — must be compliant before going live
2. Annual recertification (SOC 2 Type II / ISO 27001)
3. Customer / contract requirement
4. Regulatory exposure increased (new region / new data type)
5. Proactive — no specific trigger, want a clear picture

**Q4. Is there a prior audit to compare against?**
1. Yes — file path
2. No — first audit

**Q5. Who is the named owner of this audit cycle?**
(free text — typically @security or @devops or @backend lead)

After collecting, show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  COMPLIANCE AUDIT — [framework]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Framework: [name + version]
Scope:     [project / subsystem / surface / data class]
Trigger:   [pre-launch / recert / customer / regulatory / proactive]
Prior:     [path or "first audit"]
Owner:     [@person]
Target completion: [date — set by Phase 4 SLA]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 1 — Run Framework Checklist

Load the appropriate framework checklist below and walk through each
item. For each: mark **Pass / Partial / Fail / N/A / Unknown**, attach
evidence (file path / artifact / test result), and note any open
questions.

### WCAG 2.1 Level AA

Run `axe-core` or `pa11y` first to catch automated issues, then
manually verify the rest:

```
PERCEIVABLE
[ ] 1.1.1 Non-text Content — alt text on all images
[ ] 1.2.1–1.2.5 Time-based Media — captions, audio descriptions
[ ] 1.3.1 Info & Relationships — semantic HTML, ARIA
[ ] 1.3.2 Meaningful Sequence — DOM order matches visual order
[ ] 1.3.3 Sensory Characteristics — instructions don't rely on shape/color alone
[ ] 1.3.4 Orientation — works in portrait + landscape
[ ] 1.3.5 Identify Input Purpose — autocomplete attributes
[ ] 1.4.1 Use of Color — color is not the only signal
[ ] 1.4.3 Contrast (Min) — 4.5:1 text, 3:1 large text
[ ] 1.4.4 Resize Text — works at 200% zoom
[ ] 1.4.5 Images of Text — avoid where possible
[ ] 1.4.10 Reflow — works at 320 CSS px wide without scroll
[ ] 1.4.11 Non-text Contrast — 3:1 for UI components and graphics
[ ] 1.4.12 Text Spacing — adjustable spacing doesn't break layout
[ ] 1.4.13 Hover/Focus Content — dismissible, hoverable, persistent

OPERABLE
[ ] 2.1.1 Keyboard — all functionality keyboard accessible
[ ] 2.1.2 No Keyboard Trap — focus can leave any component
[ ] 2.1.4 Character Key Shortcuts — can be turned off / remapped
[ ] 2.4.1 Bypass Blocks — skip-link present
[ ] 2.4.2 Page Titled — meaningful <title> per page
[ ] 2.4.3 Focus Order — logical
[ ] 2.4.4 Link Purpose — clear from text or context
[ ] 2.4.5 Multiple Ways — site map / search
[ ] 2.4.6 Headings & Labels — descriptive
[ ] 2.4.7 Focus Visible — visible focus ring
[ ] 2.5.1 Pointer Gestures — single-pointer alternatives
[ ] 2.5.2 Pointer Cancellation — abortable
[ ] 2.5.3 Label in Name — accessible name contains visible label
[ ] 2.5.4 Motion Actuation — alternative to motion input

UNDERSTANDABLE
[ ] 3.1.1 Language of Page — lang attribute
[ ] 3.1.2 Language of Parts — for foreign-language sections
[ ] 3.2.1 On Focus — no surprise context change
[ ] 3.2.2 On Input — no surprise context change
[ ] 3.2.3 Consistent Navigation — same order everywhere
[ ] 3.2.4 Consistent Identification — same elements named same way
[ ] 3.3.1 Error Identification — errors clearly identified
[ ] 3.3.2 Labels or Instructions — for inputs
[ ] 3.3.3 Error Suggestion — helpful suggestion when known
[ ] 3.3.4 Error Prevention — confirm/review/reverse for legal/financial

ROBUST
[ ] 4.1.1 Parsing — valid HTML
[ ] 4.1.2 Name, Role, Value — for assistive tech
[ ] 4.1.3 Status Messages — aria-live for async updates
```

### GDPR

```
LAWFULNESS
[ ] Lawful basis identified per processing activity (consent / contract /
    legitimate interest / legal obligation / vital interest / public task)
[ ] Privacy notice published, accurate, and accessible
[ ] Consent (where applicable) is explicit, granular, withdrawable

DATA SUBJECT RIGHTS
[ ] Right to access (data export endpoint or process)
[ ] Right to rectification (edit profile + downstream propagation)
[ ] Right to erasure (delete + cascade + soft-delete-with-purge schedule)
[ ] Right to restriction (suspend processing on request)
[ ] Right to portability (machine-readable export)
[ ] Right to object (opt-out flows for marketing/profiling)
[ ] Automated decision-making (Art 22) — opt-out + human review path
[ ] DSAR response SLA documented (30 days default)

DATA HANDLING
[ ] Data flow map exists (where PII enters, transforms, exits, is stored)
[ ] PII inventory: column-level catalog with retention period per field
[ ] Encryption at rest for PII tables / columns
[ ] Encryption in transit (TLS 1.2+ everywhere)
[ ] Pseudonymisation / anonymisation for analytics
[ ] Data minimisation reviewed (no unnecessary PII collected)
[ ] Retention enforced (auto-purge job tested and monitored)
[ ] Cross-border transfers — SCCs or adequacy decision in place

ACCOUNTABILITY
[ ] DPIA completed for high-risk processing
[ ] DPO appointed (if required)
[ ] Records of Processing Activities (Art 30) maintained
[ ] Sub-processor agreements in place (DPAs)
[ ] Breach notification procedure: 72-hour authority + customer comms
[ ] Staff training on GDPR for engineers + support
```

### HIPAA

```
PRIVACY RULE
[ ] PHI inventory: which tables/fields/files contain PHI
[ ] BAAs in place with all third parties touching PHI (cloud, email, support)
[ ] Minimum necessary access enforced (RBAC, no broad admin access to PHI)
[ ] Patient access procedure (45-day SLA for record requests)
[ ] Accounting of disclosures (audit log retained 6 years)

SECURITY RULE — Administrative
[ ] Risk analysis documented annually
[ ] Risk management plan with owner + dates
[ ] Sanction policy for staff violations
[ ] Workforce security: access authorization, clearance, termination
[ ] Information access management (RBAC review cadence)
[ ] Security awareness training (annual + onboarding)
[ ] Incident response procedure (PHI-specific)
[ ] Contingency plan (DR + backup + emergency mode)
[ ] Periodic evaluation cadence

SECURITY RULE — Physical
[ ] Facility access controls (cloud provider attestations OK)
[ ] Workstation use + security policies
[ ] Device + media controls (MDM, encryption, disposal)

SECURITY RULE — Technical
[ ] Access control: unique user ID, emergency access, auto-logoff, encryption
[ ] Audit controls: ALL PHI access logged, immutable, retained 6 years
[ ] Integrity controls: PHI alteration / destruction protected
[ ] Transmission security: TLS for PHI in motion
[ ] Encryption-at-rest for PHI

BREACH NOTIFICATION
[ ] 60-day notification procedure to affected individuals
[ ] 60-day notification procedure to HHS for breaches > 500 individuals
[ ] Media notification procedure for breaches > 500 in a state
```

### SOC 2 Type II

(Type II = controls operate effectively over a period — typically 6–12
months — not just at a point in time. Evidence pack is critical.)

```
CC1 — CONTROL ENVIRONMENT
[ ] Code of conduct + ethics policy
[ ] Org chart with security roles defined
[ ] Background checks for sensitive roles

CC2 — COMMUNICATION & INFORMATION
[ ] Security policies published + acknowledged (annual)
[ ] Customer-facing trust portal / status page

CC3 — RISK ASSESSMENT
[ ] Annual risk assessment
[ ] Threat modeling for new features (links to v3.6.0 backend agent)

CC4 — MONITORING ACTIVITIES
[ ] Continuous monitoring of controls
[ ] Internal audits + findings tracked

CC5 — CONTROL ACTIVITIES
[ ] Change management (PR review, approval, tests, deploy log)
[ ] Logical access controls (SSO, MFA, RBAC, JIT, periodic review)
[ ] Vendor management (DPAs, security questionnaires)

CC6 — LOGICAL & PHYSICAL ACCESS
[ ] MFA enforced for production access
[ ] SSO with IdP for all corp tools
[ ] Quarterly access review attested
[ ] Termination revokes access within 24h
[ ] Encryption at rest + in transit

CC7 — SYSTEM OPERATIONS
[ ] Vulnerability scanning (cadence + remediation SLA)
[ ] Patch management
[ ] Capacity / performance monitoring (links to /devstarter-monitor)
[ ] Incident response procedure exercised annually

CC8 — CHANGE MANAGEMENT
[ ] All prod changes via PR + review + approval
[ ] Emergency change procedure with retro
[ ] Separation of duties (deployer ≠ approver where required)

CC9 — RISK MITIGATION
[ ] Business continuity plan + DR tested annually
[ ] Cyber insurance documented

A — AVAILABILITY (if in scope)
[ ] SLA documented + measured
[ ] Capacity planning artifacts
[ ] Backup + restore tested annually

C — CONFIDENTIALITY (if in scope)
[ ] Data classification policy + tagging
[ ] DLP / egress controls
[ ] Confidential data deletion procedure

PI — PROCESSING INTEGRITY (if in scope)
[ ] Input validation + reconciliation
[ ] Error handling + correction procedures

P — PRIVACY (if in scope — overlaps with GDPR)
[ ] Privacy policy + consent
[ ] Data subject rights procedure
```

### PCI-DSS

```
SCOPE
[ ] Cardholder Data Environment (CDE) defined
[ ] Network segmentation isolates CDE
[ ] Tokenization / vaulting reduces scope where possible

CORE REQUIREMENTS (12 high-level)
[ ] R1 — firewall config protecting CDE
[ ] R2 — no default vendor passwords
[ ] R3 — stored cardholder data protected (encryption, key mgmt)
[ ] R4 — encryption in transit
[ ] R5 — anti-malware on CDE systems
[ ] R6 — secure systems + apps (SDLC, patching, change control)
[ ] R7 — access on need-to-know basis
[ ] R8 — unique IDs + MFA for CDE access
[ ] R9 — physical access restricted
[ ] R10 — track + monitor all access to CDE
[ ] R11 — regular security testing (vuln scan, pen test)
[ ] R12 — information security policy
```

### ISO 27001

(Annex A controls — 93 in 2022 version. Run `/devstarter-compliance iso27001`
for full checklist; abridged here.)

```
ORGANIZATIONAL CONTROLS — A.5.x (37 controls)
[ ] Policies, roles, segregation of duties, supplier security, etc.

PEOPLE CONTROLS — A.6.x (8 controls)
[ ] Screening, terms of employment, training, disciplinary process

PHYSICAL CONTROLS — A.7.x (14 controls)
[ ] Physical perimeters, secure areas, equipment, cabling

TECHNOLOGICAL CONTROLS — A.8.x (34 controls)
[ ] Endpoint, identity, access, crypto, secure dev, ops, network, app sec
```

---

## PHASE 2 — Gap Inventory

After walking the checklist, build a gap table. For each item NOT marked
Pass, classify:

| Severity | Definition | Example |
|----------|-----------|---------|
| 🔴 Critical | Regulatory exposure / customer impact / blocker for cert | "Data breach notification procedure missing" |
| 🟠 High    | Material gap; auditor will flag | "DPIA missing for marketing analytics" |
| 🟡 Medium  | Gap that auditor may flag depending on context | "RBAC review cadence undocumented" |
| 🟢 Low     | Improvement opportunity | "Privacy notice could be more readable" |

Output:
```
| ID | Framework | Item | Status | Severity | Evidence reviewed | Note |
|----|-----------|------|--------|----------|-------------------|------|
| G1 | WCAG 1.4.3 | Color contrast on /checkout | Fail | 🟠 High | axe-core report | "Submit" button is 3.2:1 |
| G2 | GDPR Art 30 | RoPA exists | Unknown | 🔴 Critical | none | No record found in docs/ |
| G3 | SOC 2 CC6 | Quarterly access review | Partial | 🟡 Medium | last review 2025-09 | Cadence drifted to ~6mo |
```

---

## PHASE 3 — Remediation Roadmap

For each gap, propose a fix with owner + size + target date + priority:

```
| ID | Fix | Owner | Size | Priority | Target | Cost |
|----|-----|-------|------|----------|--------|------|
| G1 | Update Tailwind config: increase --color-primary to meet 4.5:1 | @uxui | S | P0 | 2026-05-16 | 1h |
| G2 | Generate RoPA from data-flow map; publish docs/compliance/ropa.html | @security | M | P0 | 2026-05-23 | 1d |
| G3 | Add quarterly calendar reminder + access review template | @devops | S | P1 | 2026-06-06 | 2h |
```

**Discipline:** every gap must have a row. If a row has no owner / no
target date, it does NOT go in the roadmap — park it in "Open Questions"
until those are assigned.

Bundle by priority:
- **P0** — must fix before next audit cycle / before launch / for legal exposure
- **P1** — fix this quarter
- **P2** — fix next quarter / nice-to-have

---

## PHASE 4 — Evidence Pack (SOC 2 / HIPAA / ISO 27001 only)

For frameworks that require evidence ("Type II" attestation), assemble
artifact pointers per control. Example for SOC 2 CC6:

```
| Control | Evidence | Location | Period covered |
|---------|----------|----------|----------------|
| CC6.1 — MFA enforced | screenshot of IdP MFA policy + sample login audit | docs/compliance/soc2/cc6/mfa-evidence.pdf | 2025-12-01 → 2026-05-01 |
| CC6.2 — Quarterly access review | review attestations for Q4 2025 + Q1 2026 | docs/compliance/soc2/cc6/access-reviews/ | 2026-Q1 |
| CC6.3 — Termination revocation | last 5 termination tickets with revoke timestamps | docs/compliance/soc2/cc6/term-evidence.csv | 2026-Q1 |
```

If a control has insufficient evidence, mark it ⚠️ and add an entry to
the roadmap (e.g., "G4 — Set up automated access-review evidence
collection").

---

## PHASE 5 — Publish + Approval Gate

Save the report to:
`docs/compliance/[framework]-[YYYY-MM-DD].html`

Update / create `docs/compliance/index.html` with a row per audit:
```
| Date | Framework | Scope | Verdict | Open Critical | Open High | Owner |
| 2026-05-09 | WCAG 2.1 AA | full | Partial | 0 | 1 | @uxui |
| 2026-05-09 | GDPR | full | Partial | 1 | 2 | @security |
```

Show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ COMPLIANCE AUDIT GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Framework: [name]
Scope:     [scope]

Verdict:   ✅ Pass | ⚠️ Partial | ❌ Fail
Findings:
  🔴 Critical: [N]
  🟠 High:    [N]
  🟡 Medium:  [N]
  🟢 Low:     [N]

Top remediation actions:
  P0: [N items, target dates [range]]
  P1: [N items]
  P2: [N items]

Saved to: docs/compliance/[framework]-[date].html

  "approve and create tickets"   → file P0 + P1 in PM tool
  "approve report only"          → publish without tickets
  "revise [notes]"               → adjust before publishing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- question: "Compliance audit complete. What next?"
- options: ["approve and create tickets", "approve report only", "revise"]

---

## PHASE 6 — Create Remediation Tickets + Handoff

After approval, for each P0 + P1 finding, create a ticket via the PM
tool (read `pm.type` from `devstarter-config.yml`):

- **github-issues / github+notion:** PROC-GH-05 with label `compliance-[framework]`
- **notion:** PROC-NT-03 with property `Compliance audit = [framework]-[date]`
- **jira:** PROC-JR-08 with epic `compliance-[framework]`

Show:
```
✅ Compliance report published: docs/compliance/[framework]-[date].html
✅ [N] remediation tickets created ([P0 count] P0, [P1 count] P1)
   P0 target: [earliest target date]
   P1 target: [latest target date]
```

Then `AskUserQuestion`:
- question: "Tickets created. Implement the P0 critical items now?"
- options:
  - "implement P0 now" → /devstarter-change with the audit report file
    as intake; pick a P0 ticket to start
  - "share with team" → print URL + ticket list
  - "schedule recert" → for Type II audits, set a calendar reminder
    for next cycle (typically 6–12 months out)

---

## When to use vs alternatives

- **Use this** when: a specific compliance framework needs a structured
  audit (WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001)
- **Use /devstarter-audit** instead when: broad project audit (security
  + quality + drift + dependency hygiene) — different scope
- **Use /devstarter-security** instead when: OWASP-focused security
  review (subset of compliance scope, but deeper on app-layer threats)
- **Use /devstarter-adr** instead when: capturing a decision on which
  framework to pursue (consult or ADR feeds into this audit)

---

## Appendix — Recommended audit cadence

| Framework | Cadence | Trigger |
|-----------|---------|---------|
| WCAG | Quarterly + every PR (axe-core) | New UI |
| GDPR | Annual + DPIA per high-risk feature | New PII / region / processor |
| HIPAA | Annual risk assessment | New PHI scope / vendor |
| SOC 2 Type II | 6–12 month observation | Customer requirement / annual recert |
| PCI-DSS | Annual + quarterly scans | Cardholder data flow change |
| ISO 27001 | Annual surveillance + 3-yr recert | Cert holder |
