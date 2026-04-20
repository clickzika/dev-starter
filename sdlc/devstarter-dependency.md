# dev-dependency.md — Dependency + Shared Library Updates

## Model: Sonnet (`claude-sonnet-4-6`)

## How to Use

When updating packages, shared libraries, or cross-project dependencies:
```
claude
> Read ~/.claude/devstarter-dependency.md and help me update dependencies
```

---

## PHASE 1 — Audit Current State

Agent runs audit across all project layers:

```bash
# Frontend (npm)
cd frontend
npm outdated
npm audit
npx depcheck   # find unused dependencies

# Backend (.NET)
cd backend
dotnet list package --outdated
dotnet list package --vulnerable
dotnet list package --deprecated

# Docker base images
grep "FROM " */Dockerfile | grep -v "AS"
```

Shows summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 DEPENDENCY AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Frontend (npm):
  🔴 Vulnerable:  [N] packages
  🟡 Outdated:    [N] packages
  ⚪ Unused:      [N] packages

Backend (.NET):
  🔴 Vulnerable:  [N] packages
  🟡 Outdated:    [N] packages
  🔵 Deprecated:  [N] packages

Docker images:
  🟡 Outdated:    [N] images
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 1b — WebSearch Enrichment

For every 🔴 Vulnerable and 🟡 Outdated package found above,
use `WebSearch` to fetch:
- Latest stable version number
- Active CVE IDs and severity (CVSS score)
- Breaking changes in the target version (if major bump)

Search query pattern:
```
[package-name] latest version CVE 2025
[package-name] [current-version] vulnerability
```

Append findings to the audit report:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 WEB-ENRICHED FINDINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[package]  current: [x.y.z] → latest: [a.b.c]
  CVEs: [CVE-ID] ([severity]) — [one-line description]
  Breaking changes: [yes/no — summary if yes]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Only search for packages flagged 🔴 or 🟡 — skip ⚪ unused ones.

---

## PHASE 2 — Prioritize Updates

| Priority | What to update | Why |
|----------|---------------|-----|
| 🔴 Immediate | Vulnerable packages (CVE) | Security risk |
| 🟡 This sprint | Major version updates | Breaking changes possible |
| 🔵 Next sprint | Minor + patch updates | Safe, low risk |
| ⚪ Optional | Unused packages → remove | Cleanup |

---

## PHASE 3 — Update Strategy

For each package update, agent follows:

### Patch updates (1.0.x → 1.0.y) — safe, auto-update
```bash
# npm
npm update
npm audit fix

# .NET
dotnet add package [PackageName] --version [latest-patch]
```

### Minor updates (1.x.0 → 1.y.0) — review changelog
```bash
# Check what changed
npm view [package] changelog
# Then update one at a time
npm install [package]@[version]
```

### Major updates (x.0.0 → y.0.0) — full review required
1. Read migration guide
2. Update in separate branch: `chore/update-[package]-v[N]`
3. Run all tests after each major update
4. One major update per PR (never batch)

---

## PHASE 4 — Test After Updates

```
[ ] All unit tests pass
[ ] All integration tests pass
[ ] Build succeeds (no compile errors)
[ ] Application starts without errors
[ ] Core features work (manual smoke test)
[ ] No new audit vulnerabilities introduced
```

```
⛔ GATE — Update approval
Show: what was updated + test results
Wait for "approve" before merging
```

---

## PHASE 5 — Shared Library Updates (Multi-project)

When a shared library used by multiple projects is updated:

```
1. Update the shared library
2. List all projects that depend on it:
   grep -r "[library-name]" */package.json */**.csproj

3. For each dependent project:
   a. Update the reference
   b. Run tests
   c. Create PR

4. Deploy in order (dependencies first)
5. Verify each project after deploy
```

Show cascade map before starting:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 SHARED LIBRARY UPDATE CASCADE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Library: [name] v[old] → v[new]
Affects:
  1. [Project A] — update first
  2. [Project B] — depends on A
  3. [Project C] — independent

Deploy order: A → B → C
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Dependency Update Schedule

Recommended cadence:
- Security/vulnerable: Immediately
- Patch updates: Monthly
- Minor updates: Quarterly
- Major updates: Per release cycle + research
- Docker images: With each release

Add to CI/CD:
```yaml
# GitHub Actions — weekly dependency check
on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday 9am

jobs:
  audit:
    steps:
      - run: npm audit
      - run: dotnet list package --vulnerable
      # Fail if any vulnerabilities found
```
