# AWS Secrets Manager — Integration Guide
# DevStarter Enterprise Secrets Management

## When to Use AWS Secrets Manager

Best choice when:
- Already deployed on AWS
- Need automatic rotation with Lambda
- Using RDS, Redshift, DocumentDB (native rotation support)
- Want IAM-based access control (no separate auth system)

---

## Setup

### 1. Create a Secret

```bash
# String secret
aws secretsmanager create-secret \
  --name "{{PROJECT_NAME}}/production/db" \
  --description "Production database credentials" \
  --secret-string '{"username":"appuser","password":"{{DB_PASSWORD}}"}' \
  --tags Key=Project,Value={{PROJECT_NAME}} Key=Environment,Value=production

# From file
aws secretsmanager create-secret \
  --name "{{PROJECT_NAME}}/production/jwt" \
  --secret-string file://jwt-secret.json
```

### 2. IAM Policy (Least Privilege)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadProjectSecrets",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:{{AWS_REGION}}:{{AWS_ACCOUNT_ID}}:secret:{{PROJECT_NAME}}/*"
    }
  ]
}
```

Attach to:
- EC2 instance profile
- ECS task role
- Lambda execution role
- EKS service account (IRSA)

---

## Automatic Rotation

### Enable Rotation for RDS

```bash
# Uses AWS-managed Lambda rotation function
aws secretsmanager rotate-secret \
  --secret-id "{{PROJECT_NAME}}/production/db" \
  --rotation-rules AutomaticallyAfterDays=30 \
  --rotate-immediately
```

### Custom Rotation Lambda

```python
# lambda/rotate_secret.py
import boto3
import json
import logging

logger = logging.getLogger()
client = boto3.client('secretsmanager')

def lambda_handler(event, context):
    arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']

    if step == 'createSecret':
        create_secret(arn, token)
    elif step == 'setSecret':
        set_secret(arn, token)
    elif step == 'testSecret':
        test_secret(arn, token)
    elif step == 'finishSecret':
        finish_secret(arn, token)

def create_secret(arn, token):
    import secrets
    new_password = secrets.token_urlsafe(32)
    client.put_secret_value(
        SecretId=arn,
        ClientRequestToken=token,
        SecretString=json.dumps({'password': new_password}),
        VersionStages=['AWSPENDING']
    )
```

---

## Application Integration

### Node.js / TypeScript

```typescript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: '{{AWS_REGION}}' });

async function getSecret(secretName: string): Promise<Record<string, string>> {
  const response = await client.send(
    new GetSecretValueCommand({ SecretId: secretName })
  );
  return JSON.parse(response.SecretString!);
}

// Usage
const dbCreds = await getSecret('{{PROJECT_NAME}}/production/db');
const { username, password } = dbCreds;
```

### Python

```python
import boto3
import json

def get_secret(secret_name: str) -> dict:
    client = boto3.client('secretsmanager', region_name='{{AWS_REGION}}')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

db_creds = get_secret('{{PROJECT_NAME}}/production/db')
```

### GitHub Actions (OIDC — No Static AWS Keys)

```yaml
# .github/workflows/deploy.yml
permissions:
  id-token: write
  contents: read

steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::{{AWS_ACCOUNT_ID}}:role/github-actions-role
      aws-region: {{AWS_REGION}}

  - name: Read secrets
    run: |
      DB_PASSWORD=$(aws secretsmanager get-secret-value \
        --secret-id {{PROJECT_NAME}}/production/db \
        --query SecretString --output text | jq -r .password)
      echo "DB_PASSWORD=$DB_PASSWORD" >> $GITHUB_ENV
```

### ECS Task Definition

```json
{
  "containerDefinitions": [{
    "secrets": [
      {
        "name": "DB_PASSWORD",
        "valueFrom": "arn:aws:secretsmanager:{{AWS_REGION}}:{{AWS_ACCOUNT_ID}}:secret:{{PROJECT_NAME}}/production/db:password::"
      },
      {
        "name": "JWT_SECRET",
        "valueFrom": "arn:aws:secretsmanager:{{AWS_REGION}}:{{AWS_ACCOUNT_ID}}:secret:{{PROJECT_NAME}}/production/jwt:value::"
      }
    ]
  }]
}
```

### Kubernetes (External Secrets Operator)

```yaml
# k8s/external-secret.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{PROJECT_NAME}}-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: {{PROJECT_NAME}}-secrets
    creationPolicy: Owner
  data:
    - secretKey: db-password
      remoteRef:
        key: {{PROJECT_NAME}}/production/db
        property: password
    - secretKey: jwt-secret
      remoteRef:
        key: {{PROJECT_NAME}}/production/jwt
        property: value
```

---

## Terraform

```hcl
# Create secret
resource "aws_secretsmanager_secret" "db" {
  name        = "{{PROJECT_NAME}}/production/db"
  description = "Production database credentials"

  tags = {
    Project     = "{{PROJECT_NAME}}"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# IAM policy data source
data "aws_iam_policy_document" "secrets_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:{{PROJECT_NAME}}/*"]
  }
}
```

---

## Cost Reference (as of 2025)

| Item | Cost |
|------|------|
| Secret storage | $0.40/secret/month |
| API calls | $0.05 per 10,000 calls |
| Rotation (Lambda) | Lambda costs apply |

Tip: Cache secrets in memory (TTL 5 min) to reduce API call costs.
