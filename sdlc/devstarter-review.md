# devstarter-review.md — Interactive Code Review

> **TL;DR** — Interactive 3-reviewer code review (TechLead / QA / Security) · **Lifecycle** Build · **Gates** 0

## Model: Opus (`claude-opus-4-8`)
> Deep reasoning required — run `/model opus` before this workflow.

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## Purpose

Run a structured code review in the current session before pushing or merging.
Use for self-review, pre-PR checks, or reviewing a teammate's PR.

---

## PHASE 1 — Identify What to Review

If inline arg provided, auto-detect mode:
- `#[N]`        → Mode A: PR review
- `[branchname]` → Mode B: branch review
- (nothing)     → Mode C: current changes

Otherwise use `AskUserQuestion` with:
- question: "What do you want to review?"
- options: ["PR #[number]", "Branch name", "Current uncommitted/staged changes"]

---

## PHASE 2 — Fetch Diff

### Mode A — PR
```bash
gh pr view [N] --json title,body,headRefName,baseRefName
gh pr diff [N]
```

### Mode B — Branch
```bash
git log develop...[branch] --oneline
git diff develop...[branch]
```

### Mode C — Current changes
```bash
git diff HEAD
git status
```

Show summary before reviewing:
```
📋 Reviewing: [PR title / branch / "current changes"]
   Files changed: [N]
   Lines: +[N] -[N]
```

---

## PHASE 3 — Parallel Review

Three reviewers analyse the diff simultaneously:

**@devstarter-techlead — Architecture**
- Does this fit the existing design?
- Over-engineered for the problem?
- Breaking changes not flagged?
- Naming, structure, separation of concerns

**@devstarter-qa — Quality & Testing**
- Are new code paths tested?
- Edge cases covered? (empty, null, max, error)
- Any regression risk to existing tests?
- Is the happy path the only path tested?

**@devstarter-security — Security (OWASP)**
- Input validation on all new inputs?
- Auth/authorization enforced on new endpoints?
- No secrets, tokens, or PII in code or logs?
- SQL injection, XSS, IDOR risks?

### Severity bar (apply consistently)

🔴 **BLOCKER** — must fix before merge. One of:
- Security vulnerability (auth bypass, injection, data leak, secret in code)
- Correctness bug in the changed path (will break in prod)
- Data loss / corruption risk (irreversible migration without rollback)
- Public API contract break without deprecation
- Test missing for changed business logic

🟡 **MAJOR** — strongly recommended, can ship if owner accepts the debt:
- Performance regression in hot path (>20% slower)
- Architectural drift from documented patterns (no ADR)
- Missing edge-case test for non-trivial logic
- Significant maintainability concern (duplicated logic, leaky abstraction)

🟢 **MINOR** — nice-to-have, owner discretion:
- Naming, formatting, micro-optimization
- Suggestion of a cleaner pattern
- Doc improvement

---

## PHASE 4 — Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CODE REVIEW — [title / branch / current]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files: [N changed]  Lines: +[N] -[N]

🔴 BLOCKERS ([N]) — must fix before merge
  [file:line] [description]

🟡 MAJOR ([N]) — strongly recommended
  [file:line] [description]

🟢 MINOR ([N]) — optional improvements
  [file:line] [description]

━━━ VERDICT ━━━
  ✅ Approved — no blockers
  ⚠️  Approved with notes — [N] major items to address
  ❌ Request changes — [N] blockers must be fixed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion` with:
- question: "Code review complete. What would you like to do?"
- options: ["approve", "post comments to PR", "fix blockers", "explain finding"]

### Post-review actions

**If "approve"** (Mode A only — PR review):
```bash
gh pr review [N] --approve --body "Reviewed by /devstarter-review — no blockers."
```
For Mode B/C: just print the verdict; no GitHub action.

**If "post comments to PR"** (Mode A only):
For each finding, post a line-level comment via `gh api`:
```bash
gh pr review [N] --comment --body "<full review block>"
```
Then ask whether to also approve / request-changes:
- 0 blockers → offer `gh pr review [N] --approve`
- ≥1 blocker → offer `gh pr review [N] --request-changes`

**If "fix blockers"**:
Read `~/.claude/sdlc/devstarter-change.md` and route to fix-bug operation
(C-PHASE 2 — Bug Analysis), pre-filling each blocker as a separate bug
intake. Skip the bug intake questions; the review findings are the input.

**If "explain finding"**:
Ask which finding number, then expand:
- Why it matters (impact, risk class)
- Concrete example of failure mode
- How to fix (file:line, pattern to apply)
- Whether a test exists; if not, propose one

---

## When to use vs alternatives

- **Use /devstarter-review** when: you want a structured 3-reviewer pass
  on a specific PR / branch / current diff, before merging.
- **Use /devstarter-audit** instead when: you want a full-project scan
  (security, quality, dependency hygiene, doc drift) — not a single diff.
- **Use /devstarter-debug** instead when: you have a bug to investigate,
  not a diff to review.
