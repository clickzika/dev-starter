# dev-secrets.md — Secrets Management

## How to Use

When managing secrets, API keys, and credentials:
```
claude
> Read ~/.claude/dev-secrets.md and help me manage secrets
```

---

## ⚠️ ABSOLUTE RULES — Never Break These

1. NEVER commit secrets to git — ever
2. NEVER put secrets in CLAUDE.md, docs/, or any tracked file
3. NEVER log secrets — mask all sensitive values in logs
4. NEVER share secrets via chat, email, or Notion
5. NEVER hardcode secrets in source code
6. Rotate any secret that was accidentally exposed IMMEDIATELY

---

## Secret Categories

| Category | Examples | Storage |
|----------|---------|---------|
| Local dev | DB password, API keys | `.env` (gitignored) |
| CI/CD | Deploy keys, tokens | GitHub Secrets |
| Production | All prod credentials | Docker secrets / vault |
| Global | GitHub token, Notion key | `~/.claude/.env` |

---

## PHASE 1 — Secret Audit

Agent scans for exposed secrets:

```bash
# Check for common secret patterns in tracked files
git log --all --full-history -- "*.env" | head -20
grep -r "password\s*=\s*['\"][^'\"]\+['\"]" --include="*.cs" --include="*.json" .
grep -r "api.key\|apikey\|secret\|token" --include="*.cs" --include="*.ts" . \
  | grep -v ".gitignore\|node_modules\|.env.example"
```

If secrets found in git history → STOP and rotate immediately.

---

## PHASE 2 — .env Structure

Agent ensures proper .env setup:

```bash
# .env.example (committed — template only, no real values)
# Copy to .env and fill in real values

# Database
DB_CONNECTION=Server=localhost;Database=MyApp;...
DB_PASSWORD=

# Auth
JWT_SECRET=
JWT_EXPIRY_MINUTES=15

# External APIs
SENDGRID_API_KEY=
NOTION_API_KEY=
GITHUB_TOKEN=

# App
APP_ENV=development
APP_URL=http://localhost:5000
```

Rules:
- `.env.example` — committed, empty values, used as template
- `.env` — gitignored, real values, NEVER committed
- `.env.production` — gitignored, production values only

---

## PHASE 3 — CI/CD Secrets (GitHub Actions)

Agent shows how to add secrets to GitHub:

```bash
# Add secret via GitHub CLI
gh secret set JWT_SECRET --body "your-secret-here"
gh secret set DB_CONNECTION --body "connection-string"

# List configured secrets
gh secret list
```

In workflow file (safe — references only):
```yaml
env:
  JWT_SECRET: ${{ secrets.JWT_SECRET }}
  DB_CONNECTION: ${{ secrets.DB_CONNECTION }}
```

---

## PHASE 4 — Secret Rotation Protocol

When rotating a secret (scheduled or after incident):

```
1. Generate new secret value
2. Add NEW secret to all environments (keep OLD active temporarily)
3. Deploy update with new secret
4. Verify all services working with new secret
5. Revoke OLD secret
6. Update documentation (reference only, not value)
7. Notify team that rotation is complete
```

Rotation schedule (recommended):
- JWT secret: every 90 days
- API keys: every 180 days
- DB passwords: every 90 days or on team member departure

---

## PHASE 5 — Secret Documentation (No Values)

Agent writes `docs/secrets-registry.html`:

```
For each secret:
  Name:        [VARIABLE_NAME]
  Purpose:     [what it is used for]
  Where:       [which services use it]
  Rotation:    [how often]
  Owner:       [who manages it]
  Last rotated: [date]
  How to rotate: [link to provider docs]
  ⚠️  Value: NEVER document here
```

---

## Emergency: Secret Exposed

If a secret is accidentally committed or shared:

```
IMMEDIATE STEPS (do all within 5 minutes):
1. Revoke / rotate the exposed secret NOW
2. Force-push to remove from git history (if just committed):
   git filter-branch or git-filter-repo
3. Notify team
4. Check if secret was used maliciously (audit logs)
5. Generate new secret and deploy
6. Document the incident in bugfix-log.html
```
