# dev-release.md — Release Checklist + Deployment

## How to Use

When ready to release a version:
```
claude
> Read ~/.claude/dev-release.md and prepare release v[X.Y.Z]
```

---

## PHASE 1 — Release Scope

**Q1. What version is this?**
(e.g. v1.0.0 / v1.2.0 / v2.0.0)
- Major (X) = breaking changes
- Minor (Y) = new features, backward compatible
- Patch (Z) = bug fixes only

**Q2. What environment?**
1. Staging (pre-production test)
2. Production (live users)

**Q3. What is the release window?**
(free text — date + time)

---

## PHASE 2 — Pre-Release Checklist

Agent verifies each item before allowing release:

### Code Quality
```
[ ] All Gate 4 features approved and merged to develop
[ ] No open critical/high bugs in GitHub
[ ] All tests passing in CI
[ ] Code coverage ≥ [threshold]%
[ ] npm audit / dotnet list package --vulnerable → clean
[ ] No TODO/FIXME comments in new code
```

### Documentation
```
[ ] CLAUDE.md Progress Tracker fully updated
[ ] docs/bugfix-log.html current
[ ] README.md accurate
[ ] API docs (Swagger) up to date
[ ] CHANGELOG.md updated with this version
[ ] Notion tasks → all Done
```

### Security
```
[ ] OWASP checklist verified
[ ] Secrets not in code (grep for hardcoded keys)
[ ] Environment variables documented
[ ] HTTPS configured in production
[ ] Docker images using specific version tags
```

### Database
```
[ ] All migrations tested on staging
[ ] Migration rollback script ready
[ ] Data backup taken before deploy
[ ] No breaking schema changes without migration
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE 1 — PRE-RELEASE APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checklist: [N]/[total] items passing
Failed items: [list]

  "approve"  → proceed to staging deploy
  "fix [item]" → fix then re-check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

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

## PHASE 5 — Local Staging Test

Before deploying to production, run the full app locally in **production mode** to catch issues early.

### Step 1 — Create staging environment file

```bash
# Create .env.staging (same structure as production but local values)
cat > .env.staging << 'EOF'
NODE_ENV=production
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/staging_db
JWT_SECRET=staging-secret-key-min-32-chars-long
API_URL=http://localhost:3000
CORS_ORIGIN=http://localhost:4000
EOF
```

### Step 2 — Create docker-compose.staging.yml

```yaml
# docker-compose.staging.yml — local production-like environment
# Uses production build but local ports and staging DB

services:
  db-staging:
    image: postgres:16-alpine
    ports:
      - "5433:5432"      # Different port from dev DB
    environment:
      POSTGRES_DB: staging_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - staging_pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 5

  backend-staging:
    build:
      context: ./backend
      dockerfile: Dockerfile
    depends_on:
      db-staging:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db-staging:5432/staging_db
      JWT_SECRET: staging-secret-key-min-32-chars-long
      NODE_ENV: production
    ports:
      - "3001:3000"      # Different port from dev

  frontend-staging:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    depends_on:
      - backend-staging
    environment:
      API_URL: http://backend-staging:3000
    ports:
      - "4001:80"        # Different port from dev

volumes:
  staging_pgdata:
```

### Step 3 — Run staging locally

```bash
# Build production images and start
docker compose -f docker-compose.staging.yml build
docker compose -f docker-compose.staging.yml up -d

# Run database migrations
docker compose -f docker-compose.staging.yml exec backend-staging \
  npx prisma migrate deploy
# Or .NET: dotnet ef database update
# Or Python: alembic upgrade head

# Verify all services are running
docker compose -f docker-compose.staging.yml ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STAGING READY"
echo "  Frontend: http://localhost:4001"
echo "  Backend:  http://localhost:3001"
echo "  Database: localhost:5433"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 4 — Automated Tests (Claude runs these)

```bash
# 4a. API health check
echo "--- API Health ---"
curl -sf http://localhost:3001/health && echo " ✅ API healthy" || echo " ❌ API down"

# 4b. Run unit tests against staging
echo "--- Unit Tests ---"
cd backend && npm test 2>&1 | tail -5
cd ..

# 4c. Run integration tests against staging DB
echo "--- Integration Tests ---"
cd backend && DATABASE_URL=postgresql://postgres:postgres@localhost:5433/staging_db \
  npm run test:integration 2>&1 | tail -5
cd ..

# 4d. Run E2E tests against staging frontend
echo "--- E2E Tests ---"
cd frontend && npx playwright test --reporter=list 2>&1 | tail -10
cd ..
# Or: npx cypress run --config baseUrl=http://localhost:4001

# 4e. Security quick check
echo "--- Security ---"
cd backend && npm audit --production 2>&1 | tail -3
cd ..

# 4f. Build verification
echo "--- Build Check ---"
docker compose -f docker-compose.staging.yml logs --tail=20 backend-staging | grep -i "error" && echo " ❌ Errors found" || echo " ✅ No errors in logs"
docker compose -f docker-compose.staging.yml logs --tail=20 frontend-staging | grep -i "error" && echo " ❌ Errors found" || echo " ✅ No errors in logs"
```

### Step 5 — Manual Smoke Test Checklist

After automated tests pass, verify manually:

```
[ ] http://localhost:4001 loads without errors
[ ] Login works (create test account or use seed data)
[ ] Core feature [1] works end-to-end
[ ] Core feature [2] works end-to-end
[ ] No errors in browser console (F12 → Console)
[ ] API responses are correct (no debug data leaking)
[ ] Images and assets load correctly
[ ] Responsive layout works (mobile/tablet/desktop)
```

### Step 6 — Show staging results

```
STAGING TEST RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
API Health:         ✅ 200 OK
Unit Tests:         ✅ [N] passed, 0 failed
Integration Tests:  ✅ [N] passed, 0 failed
E2E Tests:          ✅ [N] passed, 0 failed
Security Audit:     ✅ 0 vulnerabilities
Build Logs:         ✅ No errors
Manual Smoke Test:  [✅/❌] (user verifies)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```
⛔ GATE 2 — STAGING APPROVAL
All automated tests passed.
Manual smoke test: [status]

  "approve"  → proceed to production deploy
  "fix [issue]" → fix then re-test
```

### Step 7 — Cleanup staging

```bash
# After staging approved, tear down local staging
docker compose -f docker-compose.staging.yml down -v
echo "✅ Staging cleaned up"
```

---

## PHASE 6 — Production Deploy

```bash
# Read ~/.claude/sdlc/dev-github.md → PROC-GH-15 (semver) + PROC-GH-09 (merge)
git checkout main
git merge develop --no-ff -m "release: v[X.Y.Z]"
git tag "v[X.Y.Z]" -m "Release v[X.Y.Z]: [summary]"
git push origin main --tags
```

Then run the deploy strategy (Phase 4) against **production** environment.

```
⛔ GATE 3 — PRODUCTION DEPLOY APPROVAL (FINAL)
Type "DEPLOY v[X.Y.Z]" to confirm production release.
```

---

## PHASE 7 — Post-Deploy Verification

```
[ ] Production URL loads
[ ] Login works in production
[ ] Core features working
[ ] API /health returns 200
[ ] Database connection healthy
[ ] Monitor error rates for 30 minutes
[ ] Check server metrics (CPU, memory, response time)
[ ] SSL/HTTPS working
[ ] CORS working (frontend ↔ backend)
[ ] Notify team: "v[X.Y.Z] deployed successfully"
```

---

## PHASE 6 — Release Notes

Agent writes `docs/release-[vX.Y.Z].html`:
```
- Version + date
- What's new (features added)
- What's fixed (bugs resolved)
- What's removed (features deprecated)
- Breaking changes (if any)
- How to update (migration steps if needed)
```

Update Notion → add release entry.
Commit: `docs: release notes v[X.Y.Z]`

---

## Rollback Trigger

If anything goes wrong after production deploy:
```
claude
> Read ~/.claude/dev-rollback.md and rollback v[X.Y.Z]
```
