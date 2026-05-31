# devstarter-debug.md — Senior Dev Problem Analysis

> **TL;DR** — Senior-dev hypothesis-driven investigation with 5 Whys root-cause gate · **Lifecycle** Build · **Gates** 1

## Model: Opus (`claude-opus-4-7`)
> Deep reasoning required — run `/model opus` before this workflow.

Use when you have a bug and do NOT yet know where in the code it lives. Ends with a precise root cause + surgical fix plan.

---

**Config:** Read `devstarter-config.yml` for all project settings.

---

## ⚠️ CRITICAL RULES

### Rule 1 — Evidence Before Hypothesis
Never form a theory before gathering facts.
Read error messages, logs, and code FIRST. Hypothesize SECOND.

### Rule 2 — Root Cause, Not Symptom
Adding a try/catch around a crash is a symptom fix.
Finding WHY the crash happens is a root cause fix.
This workflow does not end until root cause is confirmed.

### Rule 3 — 5 Whys Gate (enforced in Phase 3)
Do NOT write any code until ≥1 hypothesis is confirmed with evidence.
If no hypothesis reaches "Confirmed" status → request more data from user.

### Rule 4 — Smallest Possible Change
The fix touches the minimum code necessary.
No opportunistic refactoring during a debug session.

### Rule 5 — Consult Only — No Code Changes
This runbook is investigation and planning ONLY.
Code changes happen in `/devstarter-change fix-bug`, not here.

### Rule 6 — Recite the Debug Mantra
Before Phase 0, recite the four-step mantra from `skills/devstarter-debug-mantra/SKILL.md` **verbatim** in the first response. Then apply the four steps in order across Phases 1–4:
1. Reproducibility (Phase 0 Q5 + Phase 1 evidence)
2. Fail path (Phase 2 execution path map)
3. Falsify the hypothesis (Phase 3 disprove-first scoring)
4. Every run is a breadcrumb (Phase 3 ledger of hypotheses + verifications)

If user says "skip the mantra" → skip the recital but still apply the four steps silently.

---

## FIRST ACTION — Inline Arg Handling

**If `/devstarter-debug` was called with a file path arg:**
1. Read the file
2. Extract: symptom description, error messages, steps to reproduce
3. Pre-fill Phase 0 answers from file content
4. Show Phase 0 summary (pre-filled) and confirm before continuing

**If `/devstarter-debug` was called with plain text:**
1. Use text as the answer to Phase 0 Q1 (symptom description)
2. Skip Q1, continue with Q2–Q5

**If no args:**
1. Start Phase 0 from Q1

---

## PHASE 0 — Problem Intake

### Step 0.0 — Mantra Recital (Rule 6)

Recite **verbatim** as the first thing in your first response:

> **Mantra:**
> 1. **First is reproducibility.** Can the issue be reproduced reliably?
> 2. **Know the fail path.** Debugger first; then source trace + knob enumeration; then in-code instrumentation.
> 3. **Question your hypothesis.** What would disprove it?
> 4. **Every run is a breadcrumb.** Cross-reference all of them.

Then begin Phase 0 intake.

### Step 0.1 — Intake Questions

Use `AskUserQuestion` for each group. Collect:

**Q1. What is the symptom?**
(free text — describe what you see: error message, wrong output, crash, missing data)

**Q2. What is the expected behavior?**
(free text — what SHOULD happen instead)

**Q3. When did this start?**
1. After a specific deploy / commit
2. After a config or environment change
3. Always existed (regression from start)
4. Unknown / intermittent

**Q4. What environment?**
1. Local development
2. Staging / UAT
3. Production
4. All environments

**Q5. Can you reproduce it consistently?**
1. Yes — steps known
2. Intermittent — sometimes reproducible
3. No — only seen in logs

After collecting answers, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 PROBLEM STATEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Symptom:   [what the user sees]
Expected:  [what should happen]
Started:   [when]
Env:       [environment]
Repro:     [yes / intermittent / no]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 1 — Evidence Gathering

**STOP: Read everything before writing a single line of analysis.**

### Step 1.0 — Knowledge Vault Recall (if `obsidian.enabled`)

If `obsidian.enabled: true` and `obsidian.vault_path` is set in
`devstarter-config.yml`, run the **Vault Recall Procedure** from
`~/.claude/sdlc/devstarter-knowledge.md` before forming hypotheses: derive
keywords from the symptom + suspected category, grep the vault, and surface the
top 1–3 prior root causes (other projects included). Treat any match as a lead,
not proof — still gather this project's own evidence (Rule 1). If the vault is
off or nothing matches, say so in one line and continue.

### Step 1.1 — Read Error Messages

If the user provided an error message or stack trace in Phase 0, read it carefully:
- Note the exact error type and message
- Note the file path and line number in the stack trace
- Note the call chain (which function called which)

### Step 1.2 — Recent Git History

Run: `git log --oneline -20`

Look for:
- Any commits in the last 24–72 hours
- Commits that touch areas related to the symptom
- Dependency updates, config changes, environment changes

### Step 1.3 — Recent Code Changes

If a suspect commit was found in Step 1.2, run:
`git show [commit-sha] --stat` → what files changed?
`git diff [commit-sha]^..[commit-sha] -- [relevant-file]` → what exactly changed?

If no suspect commit, run:
`git diff HEAD~5 -- [area-related-to-symptom]` → broad recent changes

### Step 1.4 — Log Output

If the user has log output, error logs, or console output, ask them to paste it.
Read every line. Note:
- Timestamps — when exactly did the error start?
- Error codes, HTTP status codes, exception classes
- Any "null", "undefined", "NullPointerException", "TypeError" patterns
- Any repeated errors (loop? cascade?)

### Step 1.5 — Evidence Summary

After gathering all evidence, produce:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 EVIDENCE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error type:      [exception class / HTTP code / behavior]
Error message:   [exact text]
Stack trace tip: [file:line where it first appears]

Recent changes (relevant):
  [commit sha] [message] — [suspect? yes/no]
  [commit sha] [message] — [suspect? yes/no]

Timeline:
  [HH:MM or date] — [what happened]

Initial suspects:
  → [file or component 1]
  → [file or component 2]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 2 — Code Archaeology

**Follow the execution path from entry point to failure. Read entire files, not snippets.**

### Step 2.1 — Locate the Entry Point

Where does the user's action/request enter the system?
- For API bugs: find the route handler (grep for the URL path)
- For UI bugs: find the component or event handler (grep for the action)
- For background jobs: find the job class or cron trigger
- For data bugs: find where the data is written / read

Use Grep to locate: `grep -r "[error string or function name]" src/`

### Step 2.2 — Trace the Call Chain

Follow the execution from entry point toward the failure:

```
Entry Point (e.g. POST /api/login)
  → AuthController.login()       [read this file]
    → UserService.authenticate() [read this file]
      → UserRepository.findByEmail() [read this file]
        → ❌ FAILURE HERE
```

For each function in the chain:
- Read the complete function implementation
- Note: what does it return? what can it return null/undefined/error?
- Note: what assumptions does it make about its inputs?

### Step 2.3 — Data Flow Mapping

Trace the data (not just the functions):
- Where does the input data originate? (request body, database, cache, external API)
- Where does it transform? (validation, mapping, serialization)
- Where does it fail? (the data that causes the failure)

Note any:
- Missing null checks
- Type mismatches (string vs number, array vs object)
- Stale data (cache not invalidated, DB read-after-write gap)
- Race conditions (async operations, concurrent requests)

### Step 2.4 — Execution Path Map

Produce:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗺️  EXECUTION PATH MAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Entry:    [file:line — entry point]
  ↓
Step 1:   [file:line — function / method]
  ↓
Step 2:   [file:line — function / method]
  ↓
Step 3:   [file:line — function / method]
  ↓
❌ Fail:  [file:line — where failure occurs]

Data flow:
  Input:  [what data enters]
  At step N: [how data transforms]
  At fail:   [what the data looks like when it breaks]

Suspect locations:
  1. [file:line] — [reason it's suspect]
  2. [file:line] — [reason it's suspect]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 3 — Root Cause Analysis (5 Whys)

**This is the most important phase. Do NOT skip to Phase 4 without a Confirmed hypothesis.**

### Step 3.1 — Form Hypotheses

Based on the evidence and execution path map, form 2–4 hypotheses:

```
Hypothesis 1: [specific claim about what causes the failure]
Hypothesis 2: [alternative explanation]
Hypothesis 3: [another possibility]
```

### Step 3.2 — Apply 5 Whys to Each Hypothesis

For each hypothesis, apply the 5 Whys:

```
Why did [symptom] happen?
→ Because [cause 1]

Why did [cause 1] happen?
→ Because [cause 2]

Why did [cause 2] happen?
→ Because [cause 3]

Why did [cause 3] happen?
→ Because [cause 4]  ← often the real root cause

Why did [cause 4] happen?
→ Because [root cause — the thing that if fixed, prevents recurrence]
```

### Step 3.3 — Score Each Hypothesis

```
Hypothesis 1: [claim]
  Evidence for:    [what supports this]
  Evidence against: [what contradicts this]
  Can we verify?   [what would prove/disprove this — read a specific file or run a command]
  Status: ✅ Confirmed / ❓ Possible / ❌ Ruled out

Hypothesis 2: [claim]
  ...
```

**Verification methods:**
- Read the suspect file at the suspect line
- Check if a value can ever be null at that point
- Check if a recent commit changed the behavior at that exact line
- Check if a test exists for this path (and if it would catch this)

### Step 3.4 — 5 Whys Gate ⛔

```
⛔ GATE — ROOT CAUSE GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Required: ≥1 hypothesis with status = ✅ Confirmed

If NO hypothesis is Confirmed:
  → Do NOT proceed to Phase 4
  → Ask user for more information:
    "I need more evidence to confirm the root cause.
     Can you provide: [specific log / enable debug mode /
     run this command and share output]?"
  → Loop back to Phase 1 with new evidence
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3.5 — Root Cause Declaration

Once a hypothesis is Confirmed:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔬 ROOT CAUSE CONFIRMED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Root Cause:
  [one clear, specific statement of what is wrong]
  e.g. "UserService.authenticate() returns null when email
        is not found, but the caller assumes it always returns
        a User object — line 47 of auth.controller.ts dereferences
        the result without a null check."

Evidence:
  [the specific code, log line, or commit that proves this]

Confidence: High / Medium / Low
Reason for confidence: [why you're sure / what uncertainty remains]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 4 — Surgical Fix Plan

**Design the fix BEFORE implementing it. Smallest change that addresses the root cause.**

### Step 4.1 — Identify the Exact Change

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 SURGICAL FIX PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File:       [path/to/file.ts]
Line range: [line X to line Y]

What to change:
  BEFORE: [current code — paste exact lines]
  AFTER:  [proposed code — paste exact replacement]

Why this fixes the root cause:
  [direct connection between root cause and the fix]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4.2 — Blast Radius Analysis

Before committing to this fix, assess what else it touches:

**Callers:** Who calls the function being changed?
→ Grep for all callers: `grep -r "[function name](" src/`
→ Does the fix change the function's return type or signature?
→ Does the fix change the function's behavior for other callers?

**Tests:** What tests cover this code path?
→ Find test file: `grep -r "[function or class name]" tests/`
→ Do existing tests catch the bug? (If no → why not?)
→ Does the fix break any existing tests?

**Data:** Does the fix change how data is read or written?
→ If yes — is there a migration needed?
→ If yes — does it affect existing data in the database?

**Dependencies:** Does the fix require changes to multiple files?
→ List each file that MUST change for the fix to work
→ Any file that does NOT need to change — do NOT change it

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💥 BLAST RADIUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Callers affected:     [N files / "none — internal only"]
Tests that cover it:  [list test names or "none found"]
Data impact:          [migration needed? yes/no]
Additional files:     [list or "none — single file fix"]

Regression risk:      Low / Medium / High
Reason:               [why]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4.3 — Alternative Fix Considered

Document at least one alternative fix and why it was rejected:

```
Alternative considered:
  [description of alternative approach]
  Rejected because: [specific reason — symptom fix, too broad, breaks callers, etc.]
```

---

## PHASE 5 — Save + Handoff

### Step 5.1 — Generate Slug

Generate slug from the problem description: lowercase, hyphens, max 4 words.
Example: "login-null-pointer", "cart-total-wrong", "auth-token-expired"

### Step 5.2 — Save Diagnosis File

Save the complete diagnosis to:
`memory/debug-[YYYY-MM-DD]-[slug].md`

File content template:
```markdown
# Debug Diagnosis — [slug]

Generated: [YYYY-MM-DD]
Advisor: @devstarter-techlead + @devstarter-qa

## Problem Statement
[Phase 0 output]

## Evidence Summary
[Phase 1 output]

## Execution Path Map
[Phase 2 output]

## Root Cause
[Phase 3 declaration — confirmed hypothesis]

## Surgical Fix Plan
File: [path]
Lines: [X–Y]
Change: [before/after code]

## Blast Radius
[Phase 4.2 output]

## Recommended test to add
Given [precondition]
When  [action that triggers the bug]
Then  [expected behavior after fix]

---
To implement: /devstarter-change memory/debug-[YYYY-MM-DD]-[slug].md
```

### Step 5.3 — Show Diagnosis Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🩺 DIAGNOSIS COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Root Cause:
  [one-line root cause statement]

Fix:
  File: [path:line]
  Change: [one-line description of what to change]

Blast Radius:  [Low / Medium / High]
Confidence:    [High / Medium / Low]

Saved: memory/debug-[YYYY-MM-DD]-[slug].md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5.4 — Ask Next Action

Use `AskUserQuestion` with:
- question: "Diagnosis complete. What would you like to do?"
- options: ["implement now", "save diagnosis only", "need more info", "write bug post-mortem (after fix lands)"]

**If "implement now":**
1. Confirm file is saved to `memory/debug-[YYYY-MM-DD]-[slug].md`
2. Read `~/.claude/sdlc/devstarter-change.md`
3. Read `~/.claude/sdlc/devstarter-change-bug.md`
4. Jump to C-PHASE 2 (Impact Analysis) — skip all bug intake questions
5. Pre-fill from diagnosis file:
   - Bug title ← slug
   - Root cause ← Phase 3 declaration
   - File:line ← Phase 4.1 fix plan
   - Tests needed ← recommended test from Phase 5.2
6. Announce:
   ```
   🚀 Launching /devstarter-change fix-bug with diagnosis context
   📂 Intake: memory/debug-[YYYY-MM-DD]-[slug].md
   ⏭️  Skipping bug intake — going straight to Impact Analysis
   ```
7. **After `/devstarter-change` lands the fix and validation passes**, prompt:
   ```
   ✅ Fix landed + validated.

   Required inputs for bug post-mortem are now all satisfied:
     - Reliable repro ✓ (Phase 0 Q5 + Phase 1 evidence)
     - Root cause known ✓ (Phase 3 declaration)
     - Fix identified ✓ (PR / commit from /devstarter-change)
     - Fix validated ✓ (tests pass)

   Run /devstarter-bug-postmortem to draft the engineering RCA?
   ```
   If yes → invoke `/devstarter-bug-postmortem` with `memory/debug-[YYYY-MM-DD]-[slug].md` as input.

**If "save diagnosis only":**
```
💾 Saved: memory/debug-[YYYY-MM-DD]-[slug].md

To implement later:
  /devstarter-change memory/debug-[YYYY-MM-DD]-[slug].md
```

**If "need more info":**
- Ask: "What additional information would help? (e.g. specific log output, enable debug mode, run a specific query)"
- Collect the new information → loop back to Phase 1 with extended evidence
- Re-run Phase 2–4 with updated evidence

**If "write bug post-mortem (after fix lands)":**
- Prerequisite check — refuse if any missing:
  - [ ] Reliable repro (from Phase 1)
  - [ ] Root cause known (from Phase 3 declaration)
  - [ ] Fix identified (PR / commit SHA — ask user for it)
  - [ ] Fix validated (test/repro now passes — ask user to confirm)
- If all 4 satisfied → invoke `/devstarter-bug-postmortem memory/debug-[YYYY-MM-DD]-[slug].md`. Diagnosis file feeds Root Cause + How It Was Found sections directly.
- If any missing → list what's missing, do NOT draft. Tell user to run `/devstarter-change` first, then return to this option.

---

## EXAMPLES

```
/devstarter-debug users cannot log in after the deploy yesterday

→ Phase 0: symptom=login fails, started=yesterday's deploy, env=production
→ Phase 1: git log shows auth middleware updated in commit abc1234
→ Phase 2: trace POST /auth/login → AuthMiddleware → JWT verify → token expired
→ Phase 3: Hypothesis: JWT secret was rotated but sessions weren't invalidated
            5 Whys: expired secret → config change → deploy → sessions signed with old key
            Status: ✅ Confirmed (git show abc1234 shows SECRET= changed)
→ Phase 4: Fix in auth.middleware.ts:line 34 — verify with both old + new secret during rollover
→ Phase 5: Save + offer to /devstarter-change
```

```
/devstarter-debug cart total shows wrong amount when applying coupon

→ Phase 0: symptom=wrong total, expected=discount applied, started=unknown
→ Phase 1: no recent commits touch cart; grep finds CartService.calculateTotal()
→ Phase 2: trace: applyCoupon() → calculateTotal() → discount applied AFTER tax
→ Phase 3: Hypothesis: discount applies to post-tax total instead of pre-tax
            5 Whys: wrong order in calculateTotal → business rule missing from spec → never tested
            Status: ✅ Confirmed (read CartService.calculateTotal() line 89)
→ Phase 4: Fix line 89 — move discount before tax calculation
→ Phase 5: Save + implement now
```
