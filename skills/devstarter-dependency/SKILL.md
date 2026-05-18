# /devstarter-dependency — Update Dependencies

Audit and update project dependencies (npm / pip / go.mod / etc.) with safety checks.

## When to use vs alternatives

- **Use this** when: routine dependency hygiene (security patches, version bumps, lockfile refresh)
- **Use /devstarter-audit** instead when: you want a full project audit (security + quality + drift), not just dependencies
- **Use /devstarter-secrets** instead when: rotating credentials or vault-managed secrets (different concern)

## Inline Args

```
/devstarter-dependency                      → interactive (pick scope: security / minor / major)
/devstarter-dependency security             → security patches only (npm audit fix, etc.)
/devstarter-dependency minor                → minor + patch updates (skip majors)
```

Read `~/.claude/sdlc/devstarter-dependency.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-dependency` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Update and audit project dependencies safely

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-dependency.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
