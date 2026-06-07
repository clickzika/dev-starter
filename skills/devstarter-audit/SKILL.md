# /devstarter-audit — Audit & Review Project

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-8`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-audit`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

Read `~/.claude/sdlc/devstarter-audit.md` and audit this project.
Follow all phases and approval rules in that file.

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a description, e.g.:
```
/devstarter-audit security
/devstarter-audit full audit and fix everything
/devstarter-audit performance and dependencies, report only
```

**Then:**
1. Extract audit type(s) from the text (security/quality/performance/tests/dependencies/architecture/full)
2. Extract outcome from the text: "report" → type 1, "plan" → type 2, "fix" → type 3 (default: type 1)
3. Skip Q1 (use folder name), Q2 (extracted), Q3 (extracted), Q5 (assume staging)
4. Ask Q4 only ("any known issues?") if not mentioned — or skip if "full" audit was requested
5. Start the audit immediately

**If no args were provided** (user just typed `/devstarter-audit`):
→ Show the quick-picker as the first prompt (see SDLC file FIRST ACTION section).

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-audit` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Audit and review a project for quality, security, and health

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-audit.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
