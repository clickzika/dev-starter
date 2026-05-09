# /devstarter-debug — Senior Dev Problem Analysis

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-debug`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

Read `~/.claude/sdlc/devstarter-debug.md` and run the investigation.

## Inline Args

```
/devstarter-debug                              → start with intake questions
/devstarter-debug login fails after deploy     → use as problem description (skip Q1)
/devstarter-debug memory/bug-report.md        → read file as problem context
```
