# /devstarter-env — Setup Local Environment

Configure your local dev environment: runtimes, Docker, .env file, IDE, smoke-test.

## When to use vs alternatives

- **Use this** when: setting up a local machine to run the project (first-time install, new laptop, fresh clone)
- **Use /devstarter-secrets** instead when: managing vault-backed credentials or rotating secrets (not local-only setup)
- **Use /devstarter-existing** instead when: this is your first time using DevStarter on this repo (broader project setup, includes env)

## Inline Args

```
/devstarter-env                             → interactive (detect stack, walk through setup)
/devstarter-env doctor                      → verify existing env (docker, ports, .env values)
/devstarter-env reset                       → tear down and rebuild local env (dangerous — confirms first)
```

Read `~/.claude/sdlc/devstarter-env.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-env` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Set up a local development environment from scratch

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-env.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
