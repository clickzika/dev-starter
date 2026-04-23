## PHASE 3 — Deploy Preparation

### Step 1 — Environment Variables

Verify production environment variables are set (NEVER hardcode):

```
[ ] DATABASE_URL          — production database connection
[ ] JWT_SECRET            — strong random secret (≥32 chars)
[ ] API_URL               — production API endpoint
[ ] CORS_ORIGIN           — frontend production URL
[ ] NODE_ENV / ASPNETCORE_ENVIRONMENT = production
[ ] Cloud provider credentials configured
[ ] Any third-party API keys (Stripe, SendGrid, etc.)
```

### Step 2 — Determine Deploy Strategy

Read CLAUDE.md → Q29 (deploy target) and use the matching strategy:

```
Q29 answer              → Deploy strategy
─────────────────────────────────────────
Docker self-hosted      → Strategy A
Docker + Nginx          → Strategy A
Kubernetes              → Strategy B
Azure App Service       → Strategy C
AWS ECS / Fargate       → Strategy D
Google Cloud Run        → Strategy E
Vercel                  → Strategy F
Netlify                 → Strategy F
Cloudflare Pages        → Strategy F
Railway                 → Strategy G
GitHub Pages            → Strategy H
Git toolkit / library   → Strategy I
No CLAUDE.md / no Q29  → Strategy I (auto-detect)
```

---

## PHASE 4 — Deploy Execution

### Deploy Order (CRITICAL — always follow this sequence)

```
Step 1: 🗄️  Database    — run migrations first (schema must be ready)
Step 2: ⚙️  Backend     — deploy API (needs DB ready)
Step 3: 🌐 Frontend    — deploy UI last (needs API ready)
```

---

### Strategy A — Docker (self-hosted / VPS)

#### Step 1: Database migrations
```bash
# Run migrations inside backend container
docker compose -f docker-compose.prod.yml run --rm backend \
  npx prisma migrate deploy
# Or for .NET:
# docker compose run --rm backend dotnet ef database update
```

#### Step 2: Build and deploy
```bash
# Build all services
docker compose -f docker-compose.prod.yml build

# Stop old containers, start new ones
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d

# Verify
docker compose ps
docker compose logs --tail=50 backend
```

#### docker-compose.prod.yml example:
```yaml
services:
  db:
    image: postgres:16-alpine
    restart: always
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 5s
      retries: 5

  backend:
    build: ./backend
    restart: always
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASS}@db:5432/${DB_NAME}
      JWT_SECRET: ${JWT_SECRET}
      NODE_ENV: production
    ports:
      - "3000:3000"

  frontend:
    build: ./frontend
    restart: always
    depends_on:
      - backend
    ports:
      - "80:80"
      - "443:443"

volumes:
  pgdata:
```

---

### Strategy B — Kubernetes

#### Step 1: Database migrations
```bash
kubectl run migration --rm -it --image=$BACKEND_IMAGE \
  -- npx prisma migrate deploy
```

#### Step 2: Build + push images
```bash
# Build and push to container registry
docker build -t $REGISTRY/backend:v$VERSION ./backend
docker build -t $REGISTRY/frontend:v$VERSION ./frontend
docker push $REGISTRY/backend:v$VERSION
docker push $REGISTRY/frontend:v$VERSION
```

#### Step 3: Deploy
```bash
# Update image tags in manifests
kubectl set image deployment/backend backend=$REGISTRY/backend:v$VERSION
kubectl set image deployment/frontend frontend=$REGISTRY/frontend:v$VERSION

# Wait for rollout
kubectl rollout status deployment/backend
kubectl rollout status deployment/frontend
```

---

### Strategy C — Azure App Service

#### Step 1: Database migrations
```bash
# Azure SQL or PostgreSQL Flexible Server
az webapp ssh --name $APP_NAME --resource-group $RG
# Inside: npx prisma migrate deploy
```

#### Step 2: Deploy backend
```bash
# Option 1: Docker container
az webapp create --name $BACKEND_APP \
  --resource-group $RG \
  --plan $PLAN \
  --deployment-container-image-name $REGISTRY/backend:v$VERSION

# Option 2: Code deploy
cd backend
az webapp up --name $BACKEND_APP --runtime "NODE:18-lts"
```

#### Step 3: Deploy frontend
```bash
# Azure Static Web Apps (free for frontend)
cd frontend && npm run build
az staticwebapp create --name $FRONTEND_APP \
  --resource-group $RG \
  --source ./dist
```

---

### Strategy D — AWS ECS / Fargate

#### Step 1: Database migrations
```bash
aws ecs run-task --cluster $CLUSTER \
  --task-definition migration \
  --launch-type FARGATE \
  --overrides '{"containerOverrides":[{"name":"backend","command":["npx","prisma","migrate","deploy"]}]}'
```

#### Step 2: Update backend service
```bash
# Build + push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
docker build -t $ECR_REGISTRY/backend:v$VERSION ./backend
docker push $ECR_REGISTRY/backend:v$VERSION

# Update service
aws ecs update-service --cluster $CLUSTER --service backend \
  --force-new-deployment
```

#### Step 3: Frontend → CloudFront + S3
```bash
cd frontend && npm run build
aws s3 sync dist/ s3://$BUCKET --delete
aws cloudfront create-invalidation --distribution-id $CF_ID --paths "/*"
```

---

### Strategy E — Google Cloud Run

#### Step 1: Database migrations
```bash
# Cloud SQL with Cloud Run Jobs
gcloud run jobs execute migration --region $REGION
```

#### Step 2: Deploy backend
```bash
gcloud builds submit ./backend --tag gcr.io/$PROJECT/backend:v$VERSION
gcloud run deploy backend --image gcr.io/$PROJECT/backend:v$VERSION \
  --region $REGION --allow-unauthenticated
```

#### Step 3: Frontend → Firebase Hosting
```bash
cd frontend && npm run build
firebase deploy --only hosting
```

---

### Strategy F — Static Hosting (Vercel / Netlify / Cloudflare Pages)

Frontend-only deploy — backend must be deployed separately (Strategy A-E or G).

#### Vercel
```bash
cd frontend
npx vercel --prod
# Or: push to GitHub → Vercel auto-deploys
```

#### Netlify
```bash
cd frontend && npm run build
npx netlify deploy --prod --dir=dist
# Or: push to GitHub → Netlify auto-deploys
```

#### Cloudflare Pages
```bash
cd frontend && npm run build
npx wrangler pages deploy dist --project-name=$PROJECT_NAME
# Or: push to GitHub → Cloudflare auto-deploys
```

---

### Strategy G — Railway

```bash
# Railway auto-detects monorepo structure
# Set root directory per service in Railway dashboard:
#   Service 1: root = /backend
#   Service 2: root = /frontend
#   Database:  Railway managed PostgreSQL

# Deploy via push
git push origin main
# Railway auto-deploys all services
```

---

### Strategy H — GitHub Pages (static only)

```bash
cd frontend && npm run build

# Option 1: gh-pages branch
npx gh-pages -d dist

# Option 2: GitHub Actions (auto on push)
# .github/workflows/deploy.yml handles it
```

---

### Strategy I — Git Release (toolkit / library)

Use when the project is a CLI tool, SDK, or shared toolkit distributed via git
(no Docker, no cloud hosting). Supports two models — auto-detected at runtime.

**Model A — Dual-remote** (`release` remote exists)
```
origin/develop  → active development
release/main    → public/stable publish + tag
```

**Model B — Single-repo** (no `release` remote)
```
develop  → active development
main     → production + tag
```

#### Step 1 — Resolve push remote

Priority order: config file → git remote auto-detect → origin fallback.

```bash
# 1. Read from devstarter-config.yml (explicit wins)
CONFIG_REMOTE=$(grep 'release_remote:' devstarter-config.yml 2>/dev/null \
  | awk '{print $2}' | tr -d '"')

if [ -n "$CONFIG_REMOTE" ] && [ "$CONFIG_REMOTE" != '""' ] && [ "$CONFIG_REMOTE" != "~" ]; then
  PUSH_REMOTE="$CONFIG_REMOTE"
  echo "Config: release_remote=$PUSH_REMOTE — using from devstarter-config.yml"
elif git remote | grep -q "^release$"; then
  # 2. Fall back to auto-detect (release remote present but not in config)
  PUSH_REMOTE="release"
  echo "Auto-detected: release remote present — pushing to: release"
else
  # 3. Default: single-repo model
  PUSH_REMOTE="origin"
  echo "Default: no release remote — pushing to: origin"
fi
```

#### Step 2 — Bump version + update CHANGELOG

```bash
# Edit VERSION file (e.g. 1.3.0 → 1.4.0)
# Edit CHANGELOG.md — add entry for vX.Y.Z

# Commit version bump on develop
git add VERSION CHANGELOG.md
git commit -m "release: bump version to vX.Y.Z and update CHANGELOG"
git push origin develop
```

#### Step 3 — Merge develop → main

```bash
git checkout main
git merge develop --no-ff -m "release: vX.Y.Z — merge CHANGELOG + VERSION bump"
```

#### Step 4 — Tag the release

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

#### Step 5 — Push to correct remote

```bash
# Push main branch + tag
git push $PUSH_REMOTE main
git push $PUSH_REMOTE vX.Y.Z

# Model A only — keep develop in sync on origin
# (Model B: develop is already on origin from Step 2)
```

#### Step 6 — Return to develop

```bash
git checkout develop
echo "✅ Released vX.Y.Z → $PUSH_REMOTE/main"
```

#### Full script (copy-paste ready)

```bash
#!/usr/bin/env bash
set -e

VERSION="${1:?Usage: release.sh <version>  e.g. release.sh 1.4.0}"

# Resolve push remote: config → auto-detect → fallback
CONFIG_REMOTE=$(grep 'release_remote:' devstarter-config.yml 2>/dev/null \
  | awk '{print $2}' | tr -d '"')

if [ -n "$CONFIG_REMOTE" ] && [ "$CONFIG_REMOTE" != '""' ] && [ "$CONFIG_REMOTE" != "~" ]; then
  PUSH_REMOTE="$CONFIG_REMOTE"
elif git remote | grep -q "^release$"; then
  PUSH_REMOTE="release"
else
  PUSH_REMOTE="origin"
fi

echo "▶ Releasing v$VERSION → $PUSH_REMOTE"

# Ensure clean working tree
git diff --exit-code || { echo "❌ Uncommitted changes — commit first"; exit 1; }

# Merge develop → main and tag
git checkout main
git merge develop --no-ff -m "release: v$VERSION — merge CHANGELOG + VERSION bump"
git tag -a "v$VERSION" -m "Release v$VERSION"

# Push
git push "$PUSH_REMOTE" main
git push "$PUSH_REMOTE" "v$VERSION"

# Back to develop
git checkout develop
echo "✅ v$VERSION released to $PUSH_REMOTE/main"
```

