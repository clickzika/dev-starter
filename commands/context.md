# /context — Keep Project Context Fresh

Automatically scan the project and update CLAUDE.md with what's actually there.
Run this whenever the project has evolved and CLAUDE.md feels stale.

---

## How to use

```
/context scan       → Read the codebase and update CLAUDE.md
/context update     → Same as scan
/context diff       → Show what has changed since CLAUDE.md was last updated
/context reset      → Wipe CLAUDE.md and rebuild from scratch
```

---

## What this command does

When invoked, work through these steps in order:

### Step 1 — Read current CLAUDE.md

Note what is already documented. We only update what has changed.

### Step 2 — Scan the project structure

Look at:

- `package.json` / `pyproject.toml` / `go.mod` → actual tech stack and dependencies
- `tsconfig.json` → TypeScript configuration (strict mode? paths?)
- `.eslintrc` / `biome.json` → linting rules and standards
- `Dockerfile` / `docker-compose.yml` → container setup
- `.github/workflows/` → CI/CD pipeline stages
- `terraform/` or `infrastructure/` → cloud provider and services
- `src/` or `app/` structure → architecture pattern (feature-based? layer-based?)
- `prisma/schema.prisma` or `migrations/` → database type and ORM
- `README.md` → project description and setup instructions
- `.env.example` → what environment variables exist

### Step 3 — Compare against CLAUDE.md

Identify:

- What is in CLAUDE.md but no longer true (stale)
- What is in the codebase but missing from CLAUDE.md (gap)
- What has changed version or configuration (outdated)

### Step 4 — Propose updates

Show a clear diff of proposed changes:

```
CONTEXT UPDATE PROPOSED

STALE (in CLAUDE.md but no longer accurate):
- Tech Stack: "React 18" → should be "React 19"
- Database: "MySQL" → should be "PostgreSQL 16"

MISSING (in codebase but not in CLAUDE.md):
- New service: payment-service (found in docker-compose.yml)
- New env var: STRIPE_WEBHOOK_SECRET (found in .env.example)
- CI stage: security scan (found in .github/workflows/ci.yml)

UNCHANGED (no action needed):
- Node.js version: 20 ✅
- TypeScript strict mode ✅
- Test framework: Vitest ✅

Apply these updates to CLAUDE.md? (yes/no)
```

### Step 5 — Apply on confirmation

Update CLAUDE.md with the approved changes.
Add a `Last scanned: [date]` line at the bottom.

---

## When to run /context

Run this command:

- When you start working on a project after a long break
- After a major dependency update or architecture change
- When agents start giving advice that doesn't match your actual stack
- At the start of each new sprint as a hygiene step
- Whenever CLAUDE.md feels out of date

---

## Output format for CLAUDE.md update

After applying changes, confirm:

```
CONTEXT UPDATE COMPLETE ✅

CLAUDE.md updated:
- [N] stale entries corrected
- [N] missing entries added
- [N] entries unchanged

Last scanned: [YYYY-MM-DD]
All agents will use updated context in next session.
```
