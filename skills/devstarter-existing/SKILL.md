# /devstarter-existing — Setup Existing Project

Read `~/.claude/sdlc/devstarter-existing.md` and setup this project.
Follow all phases and approval rules in that file.
Generates `devstarter-config.yml` (primary config) and `.project.env` (bash compat layer).

---

## Inline Args Handling (FIRST — check before anything else)

If the user invoked this command with a description, e.g.:
```
/devstarter-existing I want to add a payment feature
/devstarter-existing onboard me to this codebase
/devstarter-existing fix the auth bugs and improve test coverage
```

**Then:**
1. Treat the argument as the user's intent (replaces Q2)
2. Auto-scan the project for: CLAUDE.md, docs/, tech stack (replaces Q3–Q5)
3. Skip Q1 (use current folder name as project name) and Q3–Q5 (auto-detected)
4. Show codebase discovery report immediately, then proceed

**If no args were provided** (user just typed `/devstarter-existing`):
→ Show the quick-picker as the first prompt (see SDLC file FIRST ACTION section).

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-existing` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Onboard an existing project into the DevStarter workflow system

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-existing.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
