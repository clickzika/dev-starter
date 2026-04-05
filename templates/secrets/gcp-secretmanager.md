# GCP Secret Manager — Integration Guide
# DevStarter Enterprise Secrets Management

## When to Use GCP Secret Manager

Best choice when:
- Deployed on Google Cloud
- Using Workload Identity (no service account keys)
- Need per-version secret tracking
- IAM-native access control via service accounts

---

## Setup

### 1. Enable the API

```bash
gcloud services enable secretmanager.googleapis.com --project={{GCP_PROJECT}}
```

### 2. Create Secrets

```bash
# From string
echo -n "{{DB_PASSWORD}}" | gcloud secrets create {{PROJECT_NAME}}-db-password \
  --data-file=- \
  --project={{GCP_PROJECT}} \
  --labels=project={{PROJECT_NAME}},environment=production

# From file
gcloud secrets create {{PROJECT_NAME}}-jwt-secret \
  --data-file=jwt-secret.txt \
  --project={{GCP_PROJECT}}

# Add a new version (rotation)
echo -n "{{NEW_DB_PASSWORD}}" | gcloud secrets versions add {{PROJECT_NAME}}-db-password \
  --data-file=-
```

### 3. IAM Access

```bash
# Grant access to service account
gcloud secrets add-iam-policy-binding {{PROJECT_NAME}}-db-password \
  --member="serviceAccount:{{SERVICE_ACCOUNT_EMAIL}}" \
  --role="roles/secretmanager.secretAccessor" \
  --project={{GCP_PROJECT}}

# Grant to GKE Workload Identity
gcloud secrets add-iam-policy-binding {{PROJECT_NAME}}-db-password \
  --member="serviceAccount:{{GCP_PROJECT}}.svc.id.goog[{{K8S_NAMESPACE}}/{{K8S_SERVICE_ACCOUNT}}]" \
  --role="roles/secretmanager.secretAccessor"
```

---

## Application Integration

### Node.js / TypeScript

```typescript
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

const client = new SecretManagerServiceClient();

async function getSecret(secretId: string, version = 'latest'): Promise<string> {
  const name = `projects/{{GCP_PROJECT}}/secrets/${secretId}/versions/${version}`;
  const [secretVersion] = await client.accessSecretVersion({ name });
  return secretVersion.payload!.data!.toString();
}

const dbPassword = await getSecret('{{PROJECT_NAME}}-db-password');
```

### Python

```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()

def get_secret(secret_id: str, version: str = 'latest') -> str:
    name = f"projects/{{GCP_PROJECT}}/secrets/{secret_id}/versions/{version}"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode('utf-8')

db_password = get_secret('{{PROJECT_NAME}}-db-password')
```

### GitHub Actions (Workload Identity Federation — No Keys)

```yaml
# .github/workflows/deploy.yml
permissions:
  id-token: write
  contents: read

steps:
  - name: Authenticate to GCP
    uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: projects/{{GCP_PROJECT_NUMBER}}/locations/global/workloadIdentityPools/github/providers/github
      service_account: github-actions@{{GCP_PROJECT}}.iam.gserviceaccount.com

  - name: Read secrets
    uses: google-github-actions/get-secretmanager-secrets@v2
    id: secrets
    with:
      secrets: |-
        db_password:{{GCP_PROJECT}}/{{PROJECT_NAME}}-db-password
        jwt_secret:{{GCP_PROJECT}}/{{PROJECT_NAME}}-jwt-secret

  - name: Use secrets
    run: echo "Connected to DB with retrieved password"
    env:
      DB_PASSWORD: ${{ steps.secrets.outputs.db_password }}
```

### Cloud Run

```yaml
# cloudrun-service.yaml
apiVersion: serving.knative.dev/v1
kind: Service
spec:
  template:
    spec:
      serviceAccountName: {{SERVICE_ACCOUNT_EMAIL}}
      containers:
        - env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{PROJECT_NAME}}-db-password
                  key: latest
```

Or via `gcloud`:
```bash
gcloud run deploy {{SERVICE_NAME}} \
  --set-secrets="DB_PASSWORD={{PROJECT_NAME}}-db-password:latest" \
  --service-account={{SERVICE_ACCOUNT_EMAIL}}
```

### Kubernetes (Workload Identity + External Secrets)

```yaml
# k8s/secret-store.yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: gcp-secret-manager
spec:
  provider:
    gcpsm:
      projectID: {{GCP_PROJECT}}
      auth:
        workloadIdentity:
          clusterLocation: {{GCP_REGION}}
          clusterName: {{GKE_CLUSTER_NAME}}
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{PROJECT_NAME}}-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: gcp-secret-manager
    kind: ClusterSecretStore
  target:
    name: {{PROJECT_NAME}}-secrets
  data:
    - secretKey: db-password
      remoteRef:
        key: {{PROJECT_NAME}}-db-password
    - secretKey: jwt-secret
      remoteRef:
        key: {{PROJECT_NAME}}-jwt-secret
```

---

## Terraform

```hcl
resource "google_secret_manager_secret" "db_password" {
  secret_id = "{{PROJECT_NAME}}-db-password"
  project   = "{{GCP_PROJECT}}"

  replication {
    auto {}
  }

  labels = {
    project     = "{{PROJECT_NAME}}"
    environment = "production"
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret_iam_member" "app_accessor" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app.email}"
}
```

---

## Secret Rotation (Pub/Sub Notification)

```bash
# Enable rotation notification
gcloud secrets update {{PROJECT_NAME}}-db-password \
  --next-rotation-time="2025-07-01T00:00:00Z" \
  --rotation-period="2592000s" \  # 30 days
  --topics=projects/{{GCP_PROJECT}}/topics/secret-rotation
```

Subscribe a Cloud Function to `secret-rotation` topic to auto-rotate.

---

## Audit Logging

```bash
# Check who accessed a secret
gcloud logging read \
  'protoPayload.serviceName="secretmanager.googleapis.com"
   AND protoPayload.resourceName:"{{PROJECT_NAME}}-db-password"' \
  --project={{GCP_PROJECT}} \
  --limit=50 \
  --format=json
```
