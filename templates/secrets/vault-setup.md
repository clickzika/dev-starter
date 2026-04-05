# HashiCorp Vault — Integration Guide
# DevStarter Enterprise Secrets Management

## When to Use Vault

Use Vault when you need:
- Dynamic secrets (short-lived DB credentials generated on-demand)
- Fine-grained secret access per service/team
- Secret leasing + revocation
- Compliance audit trail (SOC 2, ISO 27001, HIPAA)
- Multi-cloud secret sync

---

## Quick Start (Docker Compose — Dev/Staging)

```yaml
# docker-compose.vault.yml
services:
  vault:
    image: hashicorp/vault:1.15
    ports:
      - "8200:8200"
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: dev-root-token   # DEV ONLY — never in prod
      VAULT_DEV_LISTEN_ADDRESS: 0.0.0.0:8200
    cap_add:
      - IPC_LOCK
    volumes:
      - vault-data:/vault/data
volumes:
  vault-data:
```

```bash
docker compose -f docker-compose.vault.yml up -d
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=dev-root-token
vault status
```

---

## Production Setup

### 1. Initialize Vault

```bash
export VAULT_ADDR=https://{{VAULT_DOMAIN}}:8200

# Initialize (generates unseal keys + root token)
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-init.json

# ⚠️ SECURE vault-init.json immediately — distribute key shares to 5 people
# NEVER commit vault-init.json to git
```

### 2. Enable Secret Engines

```bash
# KV v2 — generic secrets
vault secrets enable -path=secret kv-v2

# Database — dynamic credentials
vault secrets enable database

# PKI — TLS certificates
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
```

### 3. Configure Dynamic Database Credentials (PostgreSQL)

```bash
vault write database/config/{{DB_NAME}} \
  plugin_name=postgresql-database-plugin \
  allowed_roles="app-role" \
  connection_url="postgresql://{{VAULT_DB_USER}}:{{VAULT_DB_PASSWORD}}@{{DB_HOST}}:5432/{{DB_NAME}}" \
  username="{{VAULT_DB_USER}}" \
  password="{{VAULT_DB_PASSWORD}}"

vault write database/roles/app-role \
  db_name={{DB_NAME}} \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# App reads: vault read database/creds/app-role
```

### 4. Auth Methods

```bash
# For Kubernetes workloads
vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://{{K8S_API_SERVER}}" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# For GitHub Actions / CI
vault auth enable jwt
vault write auth/jwt/config \
  oidc_discovery_url="https://token.actions.githubusercontent.com" \
  bound_issuer="https://token.actions.githubusercontent.com"
```

### 5. Policies (Least Privilege)

```hcl
# policies/app-policy.hcl
path "secret/data/{{PROJECT_NAME}}/*" {
  capabilities = ["read"]
}

path "database/creds/app-role" {
  capabilities = ["read"]
}

path "pki/issue/{{PROJECT_NAME}}" {
  capabilities = ["create", "update"]
}
```

```bash
vault policy write {{PROJECT_NAME}}-app policies/app-policy.hcl
```

---

## Application Integration

### Node.js / TypeScript

```typescript
import vault from 'node-vault';

const client = vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,  // or use K8s auth
});

// Read a secret
const { data } = await client.read('secret/data/{{PROJECT_NAME}}/db');
const dbPassword = data.data.password;

// Read dynamic DB creds
const creds = await client.read('database/creds/app-role');
```

### Python

```python
import hvac

client = hvac.Client(url=os.environ['VAULT_ADDR'])
client.auth.kubernetes.login(role='app-role', jwt=open('/var/run/secrets/kubernetes.io/serviceaccount/token').read())

secret = client.secrets.kv.v2.read_secret_version(path='{{PROJECT_NAME}}/db')
db_password = secret['data']['data']['password']
```

### GitHub Actions (OIDC)

```yaml
# .github/workflows/deploy.yml
- name: Import secrets from Vault
  uses: hashicorp/vault-action@v3
  with:
    url: ${{ secrets.VAULT_ADDR }}
    method: jwt
    role: github-actions
    secrets: |
      secret/data/{{PROJECT_NAME}}/deploy API_KEY | DEPLOY_API_KEY ;
      secret/data/{{PROJECT_NAME}}/db PASSWORD | DB_PASSWORD
```

---

## Secret Rotation via Vault

```bash
# Rotate static secrets
vault kv put secret/{{PROJECT_NAME}}/api \
  key="$(openssl rand -base64 32)"

# Rotate database root credentials
vault write -force database/rotate-root/{{DB_NAME}}
```

---

## Audit Log Setup

```bash
vault audit enable file file_path=/var/log/vault/audit.log
vault audit enable syslog tag="vault" facility="AUTH"
```

---

## .env Integration (Dev Only)

```bash
# scripts/load-vault-secrets.sh
# Pulls secrets from Vault into local .env for development
# NEVER run this in production — use direct Vault reads instead

export VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}

DB_PASSWORD=$(vault kv get -field=password secret/{{PROJECT_NAME}}/db)
JWT_SECRET=$(vault kv get -field=value secret/{{PROJECT_NAME}}/jwt)

cat > .env <<EOF
DB_PASSWORD=${DB_PASSWORD}
JWT_SECRET=${JWT_SECRET}
EOF

echo ".env updated from Vault"
```

---

## Compliance Notes

| Requirement | Vault Feature |
|-------------|---------------|
| Secret access audit trail | Audit log → SIEM |
| Secret expiry enforcement | Leases + TTL |
| Dynamic credentials (no static DB passwords) | Database secrets engine |
| Encryption at rest | Vault storage encryption |
| Encryption in transit | TLS listener |
| Break-glass access | Root token (sealed until needed) |
| Secret versioning | KV v2 |
