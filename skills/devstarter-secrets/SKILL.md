# /devstarter-secrets — Secrets Management

Manage secrets across env-file / Vault / AWS Secrets Manager / Azure Key Vault / GCP Secret Manager. Includes rotation runbook.

## When to use vs alternatives

- **Use this** when: choosing a secrets backend, migrating off `.env`, rotating credentials, setting up CI secret injection
- **Use /devstarter-env** instead when: just setting up local `.env` file (not enterprise secrets management)
- **Use /devstarter-security** instead when: full security audit (OWASP, threat model) — secrets is one slice of that

## Inline Args

```
/devstarter-secrets                         → interactive (pick backend + scope)
/devstarter-secrets rotate                  → run rotation runbook for current backend
/devstarter-secrets migrate vault           → migrate from .env to HashiCorp Vault
```

Read `~/.claude/sdlc/devstarter-secrets.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-secrets` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Audit, rotate, and manage secrets securely

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-secrets.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
