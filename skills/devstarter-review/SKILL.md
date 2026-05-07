# /devstarter-review — Interactive Code Review

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-review`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

Read `~/.claude/sdlc/devstarter-review.md` and run the review.

## Inline Args
```
/devstarter-review          → review current changes (git diff HEAD)
/devstarter-review #42      → review PR #42
/devstarter-review branch   → review named branch vs develop
```
