# Azure Key Vault — Integration Guide
# DevStarter Enterprise Secrets Management

## When to Use Azure Key Vault

Best choice when:
- Already deployed on Azure
- Using Managed Identity (no credential management)
- Need Key + Certificate management alongside secrets
- Azure AD RBAC for access control

---

## Setup

### 1. Create Key Vault (Azure CLI)

```bash
# Create resource group if needed
az group create --name {{RESOURCE_GROUP}} --location {{AZURE_REGION}}

# Create Key Vault
az keyvault create \
  --name {{KEYVAULT_NAME}} \
  --resource-group {{RESOURCE_GROUP}} \
  --location {{AZURE_REGION}} \
  --sku standard \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --retention-days 90

# Tag it
az keyvault update \
  --name {{KEYVAULT_NAME}} \
  --resource-group {{RESOURCE_GROUP}} \
  --tags Project={{PROJECT_NAME}} Environment=production ManagedBy=terraform
```

### 2. Create Secrets

```bash
# Single value
az keyvault secret set \
  --vault-name {{KEYVAULT_NAME}} \
  --name "db-password" \
  --value "{{DB_PASSWORD}}"

# From file
az keyvault secret set \
  --vault-name {{KEYVAULT_NAME}} \
  --name "jwt-secret" \
  --file jwt-secret.txt

# With expiry
az keyvault secret set \
  --vault-name {{KEYVAULT_NAME}} \
  --name "api-key" \
  --value "{{API_KEY}}" \
  --expires "2026-01-01T00:00:00Z"
```

### 3. RBAC Assignment (Managed Identity)

```bash
# Get Key Vault resource ID
KV_ID=$(az keyvault show --name {{KEYVAULT_NAME}} --query id -o tsv)

# Assign "Key Vault Secrets User" to app managed identity
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee {{MANAGED_IDENTITY_PRINCIPAL_ID}} \
  --scope $KV_ID
```

---

## Application Integration

### Node.js / TypeScript

```typescript
import { DefaultAzureCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';

const credential = new DefaultAzureCredential(); // Uses Managed Identity in Azure
const client = new SecretClient(
  'https://{{KEYVAULT_NAME}}.vault.azure.net',
  credential
);

async function getSecret(name: string): Promise<string> {
  const secret = await client.getSecret(name);
  return secret.value!;
}

const dbPassword = await getSecret('db-password');
```

### Python

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(
    vault_url="https://{{KEYVAULT_NAME}}.vault.azure.net",
    credential=credential
)

def get_secret(name: str) -> str:
    return client.get_secret(name).value

db_password = get_secret("db-password")
```

### GitHub Actions (Federated Identity — No Passwords)

```yaml
# .github/workflows/deploy.yml
permissions:
  id-token: write
  contents: read

steps:
  - name: Azure Login (OIDC)
    uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

  - name: Read Key Vault secrets
    uses: azure/get-keyvault-secrets@v1
    with:
      keyvault: {{KEYVAULT_NAME}}
      secrets: 'db-password, jwt-secret, api-key'
    id: kv-secrets

  - name: Use secrets
    run: echo "DB_PASSWORD=${{ steps.kv-secrets.outputs.db-password }}"
```

### Azure Container Apps

```yaml
# container-app.yaml
properties:
  configuration:
    secrets:
      - name: db-password
        keyVaultUrl: https://{{KEYVAULT_NAME}}.vault.azure.net/secrets/db-password
        identity: {{MANAGED_IDENTITY_RESOURCE_ID}}
  template:
    containers:
      - env:
          - name: DB_PASSWORD
            secretRef: db-password
```

### Kubernetes (Azure Workload Identity + CSI Driver)

```yaml
# k8s/secret-provider-class.yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: {{PROJECT_NAME}}-secrets
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "{{MANAGED_IDENTITY_CLIENT_ID}}"
    keyvaultName: "{{KEYVAULT_NAME}}"
    tenantId: "{{AZURE_TENANT_ID}}"
    objects: |
      array:
        - |
          objectName: db-password
          objectType: secret
        - |
          objectName: jwt-secret
          objectType: secret
  secretObjects:
    - secretName: {{PROJECT_NAME}}-secrets
      type: Opaque
      data:
        - objectName: db-password
          key: DB_PASSWORD
```

---

## Terraform

```hcl
resource "azurerm_key_vault" "main" {
  name                = "{{KEYVAULT_NAME}}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = true
  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  tags = {
    Project     = "{{PROJECT_NAME}}"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id

  expiration_date = "2026-12-31T23:59:59Z"
}

resource "azurerm_role_assignment" "app_kv_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

---

## Key Rotation Alert

```bash
# List secrets expiring within 30 days
az keyvault secret list \
  --vault-name {{KEYVAULT_NAME}} \
  --query "[?attributes.expires != null && attributes.expires < '$(date -d '+30 days' -u +%Y-%m-%dT%H:%M:%SZ)'].{name:name, expires:attributes.expires}" \
  --output table
```
