## PHASE 5 — SIT (System Integration Testing)

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
⛔ GATE 2 — SIT APPROVAL
All automated tests passed.
Manual smoke test: [status]

  "SIT approved"  → proceed to UAT
  "fix [issue]" → fix then re-test
```

### Step 7 — Cleanup local staging

```bash
docker compose -f docker-compose.staging.yml down -v
echo "✅ Local staging cleaned up"
```

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## PHASE 6 — UAT (User Acceptance Testing)

### Step 1 — Merge develop → uat

```bash
# Read ~/.claude/sdlc/devstarter-github.md → PROC-GH-09 Step 1
git checkout uat
git pull origin uat
git merge develop --no-ff -m "release: merge develop to uat for testing"
git push origin uat
```

### Step 2 — Deploy UAT environment

Deploy using the same strategy from Phase 4 but targeting **UAT environment**:
- UAT uses **separate URL** from production (e.g. `uat.myapp.com` or `myapp-uat.pages.dev`)
- UAT uses **separate database** (copy of production schema, test data)
- UAT environment variables point to UAT services

```bash
# Docker example:
docker compose -f docker-compose.uat.yml up -d

# Or cloud: deploy uat branch to staging/preview slot
```

### Step 3 — User tests manually

```
UAT ENVIRONMENT READY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL:      [UAT_URL]
Branch:   uat
Version:  [pending v.X.Y.Z]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please test the following:
[ ] Login / Register
[ ] Core feature [1] — [description]
[ ] Core feature [2] — [description]
[ ] Core feature [3] — [description]
[ ] Edge cases and error handling
[ ] Mobile responsiveness (if applicable)
[ ] Data correctness (numbers, dates, calculations)

When done:
  "UAT approved"     → proceed to production
  "UAT fix [issue]"  → fix then re-deploy UAT
```

```
⛔ GATE 3 — UAT APPROVAL
User must test and type "UAT approved" to proceed.
Claude does NOT approve UAT — only the user can.
```

### Step 4 — Fix UAT issues (if any)

If user reports issues:
1. Fix on develop branch
2. Re-run Phase 5 (local test)
3. Re-merge develop → uat
4. Re-deploy UAT
5. User re-tests

---

## PHASE 7 — Production Deploy

```bash
# Read ~/.claude/sdlc/devstarter-github.md → PROC-GH-15 (semver) + PROC-GH-09 Step 2
git checkout main
git pull origin main
git merge uat --no-ff -m "release: v[X.Y.Z]"
git tag "v[X.Y.Z]" -m "Release v[X.Y.Z]: [summary]"
git push origin main --tags
```

Then run the deploy strategy (Phase 4) against **production** environment.

```
⛔ GATE 4 — PRODUCTION DEPLOY APPROVAL (FINAL)
Type "DEPLOY v[X.Y.Z]" to confirm production release.
```

---

## PHASE 8 — Post-Deploy Verification

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
```

---

## PHASE 9 — Release Notes

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

## PHASE 10 — Secondary VCS Mirror (if configured)

After successful production deploy, mirror main + tags to secondary VCS:

```bash
source .project.env 2>/dev/null || true

if [ -n "$VCS_SECONDARY_1" ] && [ "$VCS_SECONDARY_1" != "none" ]; then
  echo "⏳ Mirroring release to secondary VCS: $VCS_SECONDARY_1"
  # Run Step 5 from ~/.claude/agents/shared/devstarter-vcs-pm-guide.md
fi

if [ -n "$VCS_SECONDARY_2" ] && [ "$VCS_SECONDARY_2" != "none" ]; then
  echo "⏳ Mirroring release to secondary VCS: $VCS_SECONDARY_2"
fi
```

For full mirror commands per VCS type:
→ Read `~/.claude/sdlc/devstarter-vcs-sync.md`

---

## Rollback Trigger

If anything goes wrong after production deploy:
```
claude
> Read ~/.claude/devstarter-rollback.md and rollback v[X.Y.Z]
```
