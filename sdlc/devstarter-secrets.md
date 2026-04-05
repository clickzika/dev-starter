# dev-secrets.md — Secrets Management

## How to Use

When managing secrets, API keys, and credentials:
```
claude
> Read ~/.claude/devstarter-secrets.md and help me manage secrets
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

---

## PHASE 6 — Enterprise Secrets Backend Selection

When project requires SOC 2, ISO 27001, PCI DSS, or HIPAA compliance,
migrate from `.env` files to an enterprise secrets backend.

**Select backend based on cloud:**

| Deployment | Backend | Setup Guide |
|------------|---------|-------------|
| AWS | AWS Secrets Manager | `~/.claude/templates/secrets/aws-secrets-setup.md` |
| Azure | Azure Key Vault | `~/.claude/templates/secrets/azure-keyvault-setup.md` |
| GCP | GCP Secret Manager | `~/.claude/templates/secrets/gcp-secretmanager.md` |
| Multi-cloud / On-prem | HashiCorp Vault | `~/.claude/templates/secrets/vault-setup.md` |

**SECRETS_BACKEND field in `.project.env`:**

```bash
# .project.env
SECRETS_BACKEND=aws-secrets-manager   # aws-secrets-manager | azure-keyvault | gcp-secret-manager | vault | env-file
SECRETS_BACKEND_URL=                  # Vault URL or Key Vault name (if applicable)
SECRETS_BACKEND_REGION=               # AWS region / Azure location / GCP region
```

---

## PHASE 7 — Migration from .env to Enterprise Backend

```
MIGRATION CHECKLIST: .env → Enterprise Secrets Backend
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pre-migration:
[ ] Inventory all secrets in .env / .env.production
[ ] Classify: which are static values vs. which need rotation
[ ] Identify which services consume each secret
[ ] Choose backend (Phase 6 guide)

Migration:
[ ] Create secrets in backend (do NOT reuse old passwords — generate new)
[ ] Update application code to read from SDK (not process.env)
[ ] Configure IAM/RBAC — per service, per environment
[ ] Enable auto-rotation for DB passwords and JWT keys
[ ] Enable audit logging → ship to SIEM
[ ] Test in staging: secrets load correctly, no fallback to .env

Cutover:
[ ] Deploy updated app to production
[ ] Verify all secrets load from backend (check logs)
[ ] Remove .env.production from servers (do not just gitignore — delete)
[ ] Revoke old static credentials after 48h verification window

Post-migration:
[ ] Enable secret expiry alerts (30-day warning)
[ ] Document secrets registry in docs/secrets-registry.html
[ ] Update runbooks with new rotation procedures
[ ] Schedule first rotation test (within 30 days)
```

---

## PHASE 8 — Secrets Registry Document

Agent writes `docs/secrets-registry.html` using the standard document template:

```
For each secret:
  Name:             [VARIABLE_NAME or secret path]
  Backend:          [AWS Secrets Manager / Azure KV / GCP SM / Vault / .env]
  Path / ARN:       [backend-specific identifier — no values]
  Purpose:          [what the secret is used for]
  Services:         [which microservices / apps consume it]
  Rotation:         [every N days / manual / auto]
  Owner:            [team or person responsible]
  Last rotated:     [YYYY-MM-DD]
  How to rotate:    [link to runbook or procedure]
  Compliance tags:  [SOC2-CC6.1 / PCI-Req8 / HIPAA / etc.]
  ⚠️  Value:        NEVER document here — reference only
```

---

## PHASE 9 — Secret Rotation Runbook

```
SECRET ROTATION RUNBOOK
━━━━━━━━━━━━━━━━━━━━━━━

Trigger: Scheduled (see rotation schedule) OR security incident

Step 1 — Notify team
  Post in #engineering: "Starting rotation for [SECRET_NAME] — brief deploy required"

Step 2 — Generate new value
  JWT/signing keys: openssl rand -base64 64
  Passwords: openssl rand -base64 32 (meets complexity requirements)
  API keys: use provider's key generation UI/API

Step 3 — Add new version to backend (keep old active)
  AWS: aws secretsmanager put-secret-value --secret-id [path] --secret-string [new]
  Azure: az keyvault secret set --vault-name [name] --name [secret] --value [new]
  GCP: echo -n [new] | gcloud secrets versions add [name] --data-file=-
  Vault: vault kv put secret/[path] key=[new]

Step 4 — Deploy update (dual-read period: app accepts old AND new)
  Deploy to staging → verify → deploy to production

Step 5 — Revoke old version (after 2h verification window)
  AWS: aws secretsmanager update-secret-version-stage (mark old as DEPRECATED)
  Azure: az keyvault secret set-attributes --enabled false (old version)
  GCP: gcloud secrets versions disable [name] --version [old-version-id]
  Vault: vault lease revoke [old-lease-id]

Step 6 — Update registry
  Update docs/secrets-registry.html → Last rotated: [today]

Step 7 — Confirm and close
  Post in #engineering: "Rotation complete for [SECRET_NAME]"
```
