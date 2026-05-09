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
