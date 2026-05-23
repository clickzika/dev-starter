# /devstarter-review — Interactive Code Review

Run a structured 3-reviewer pass (TechLead / QA / Security) on a PR / branch / current diff. Outputs Blocker / Major / Minor findings with severity definitions and post-review actions.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-review`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: reviewing a specific *diff* (PR / branch / current changes) before merge
- **Use /devstarter-audit** instead when: scanning the *whole project* (security + quality + drift), not a single diff
- **Use /devstarter-debug** instead when: the goal is to *root-cause a bug* (not evaluate a diff)

## Inline Args

```
/devstarter-review          → review current changes (git diff HEAD)
/devstarter-review #42      → review PR #42
/devstarter-review branch   → review named branch vs develop
```

Read `~/.claude/sdlc/devstarter-review.md` and run the review.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-review` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run an interactive code review with multi-agent feedback

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-review.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
