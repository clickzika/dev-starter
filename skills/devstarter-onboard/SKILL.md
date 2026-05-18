# /devstarter-onboard — Onboard New Team Member

Onboard a new person joining the team — access setup, personalized briefing, first PR.

## When to use vs alternatives

- **Use this** when: a NEW person is joining the team (no specific predecessor)
- **Use /devstarter-handover** instead when: an existing owner is transferring ownership to someone (knowledge transfer + revocation, not new-hire setup)
- **Use /devstarter-existing** instead when: the project is new to *you* but not new to the team (first-time DevStarter setup, no team change)

## Inline Args

```
/devstarter-onboard                         → interactive (collect name + role + skill level)
/devstarter-onboard Alice senior backend    → name + role + area inline
```

Read `~/.claude/sdlc/devstarter-onboarding.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-onboard` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Onboard a new team member with docs, access, and orientation

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-onboarding.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
