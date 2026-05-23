# /devstarter-release — Release + Deploy

Standard release flow: develop → SIT → UAT → main → deploy + tag.

## When to use vs alternatives

- **Use this** when: shipping a planned release (CHANGELOG ready, gates can run in order)
- **Use /devstarter-hotfix** instead when: a critical production bug needs to bypass the normal flow
- **Use /devstarter-rollback** instead when: production needs to revert to the previous version

## Inline Args

```
/devstarter-release                         → interactive (prompt for version + scope)
/devstarter-release 3.6.0                   → release v3.6.0 (skip version question)
/devstarter-release 3.6.0 minor-feature     → version + short description
```

Read `~/.claude/sdlc/devstarter-release.md` and follow all phases and gate approvals (DEV → SIT → UAT → DEPLOY).

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-release` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Release and deploy: develop → SIT → UAT → main → tag

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-release.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
