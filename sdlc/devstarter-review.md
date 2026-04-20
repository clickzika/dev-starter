# devstarter-review.md — Interactive Code Review

## Model: Opus (`claude-opus-4-6`)
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

Otherwise ask:
```
What do you want to review?
  1. PR #[number]
  2. Branch name
  3. Current uncommitted/staged changes
```

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

After output, user may:
- "fix blockers" → agent fixes 🔴 items directly
- "explain [item]" → deeper explanation of a finding
- "approve" → done, no action needed
