# DevStarter Team Packs

Pre-defined agent groups for common project scenarios. Mention these agents together in your session to activate the right team.

---

## Web API / Backend Service
```
@techlead @backend @dba @security @devops @qa
```
- @techlead owns architecture decisions + ADRs
- @backend builds API layer, services, business logic
- @dba designs schema, writes migrations, optimizes queries
- @security reviews auth, OWASP, secrets handling
- @devops sets up CI/CD, Docker, deployment
- @qa owns test strategy, coverage gates

---

## Full-Stack Web App
```
@techlead @backend @frontend @uxui @dba @security @qa
```
- Add @uxui for design system, component specs, prototypes
- Add @frontend for React/Angular/Vue components and state

---

## Mobile App
```
@techlead @mobile @backend @qa
```
- @mobile covers Flutter or React Native
- @backend provides the API layer
- Add @uxui if designing screens from scratch

---

## ML / AI Product
```
@techlead @datascience @mlops @backend @security
```
- @datascience: EDA, feature engineering, model selection, A/B testing
- @mlops: training pipelines, model serving, monitoring, drift detection
- @backend: API wrapper around model serving
- @security: prompt injection, data privacy, model access controls

---

## Code Review Pass
Pick language reviewer + security check:
```
# TypeScript project:
@ts-reviewer @security-reviewer @qa

# Go project:
@go-reviewer @security-reviewer @qa

# Python/Django:
@django-reviewer @security-reviewer @qa

# Laravel/PHP:
@laravel-reviewer @security-reviewer @qa
```
- Language reviewer: architecture, patterns, N+1, type safety
- @security-reviewer: OWASP, injection, auth, secrets in code
- @qa: test coverage, missing edge cases

---

## Incident Response
```
@sre @devops @techlead
```
Use skills in sequence:
1. `/devstarter-incident` — triage, comms, mitigation
2. `/devstarter-rollback` — if fix takes >1h, rollback first
3. `/devstarter-postmortem` — 48h after resolution

---

## Architecture Decision
Choose one:
- **Single expert**: `/devstarter-consult` — get structured expert advice + save to file
- **Multi-voice**: `/devstarter-council` — Architect/Skeptic/Pragmatist/Critic debate
- **Record only**: `/devstarter-adr` — write ADR for a decision already made

---

## Open Source Release Pipeline
Run in sequence:
```
@oss-forker → @oss-sanitizer → @oss-packager
```
1. @oss-forker: strip secrets/PII/internal refs, generate .env.example
2. @oss-sanitizer: 20+ pattern scan, PASS/FAIL report
3. @oss-packager: generate README, setup.sh, CLAUDE.md, LICENSE, GH templates

---

## Autonomous Product Builder (GAN Harness)
Run in loop:
```
@gan-planner → @gan-generator → @gan-evaluator → (repeat)
```
1. @gan-planner: expand one-liner to full product spec
2. @gan-generator: implement features from spec
3. @gan-evaluator: Playwright browser test + rubric score → feedback to generator

---

## Network / Homelab Setup
```
@homelab-architect → @network-config-reviewer → @network-troubleshooter
```
- @homelab-architect: design (VLANs, DNS, WireGuard, Pi-hole)
- @network-config-reviewer: audit Cisco/Juniper/OPNsense configs
- @network-troubleshooter: OSI-layer diagnosis when something breaks

---

## Build Error Triage
Auto-select by stack:
| Stack | Use |
|-------|-----|
| TypeScript/Node | `@ts-build-resolver` |
| Go | `@go-build-resolver` |
| Java/Kotlin/Gradle | `@java-build-resolver` |
| Rust/Cargo | `@rust-build-resolver` |
| Flutter/Dart | `@flutter-build-resolver` |
| Python/Django | `@django-build-resolver` |
| C++/CMake | `@cpp-build-resolver` |
| Unknown stack | `@build-resolver` (auto-detects) |

---

## Quality Gate (before PR merge)
```
/devstarter-verification-loop
```
Then review with: `@pr-analyzer` (health + merge readiness) + `@pr-test-analyzer` (coverage quality)

---

## Documentation Sprint
```
@docs @doc-updater
```
- @docs: write/rewrite API docs, guides, runbooks on request
- @doc-updater: scan recent code changes, identify stale docs, update proactively
- Add `@docs-lookup` when you need live library docs mid-session (via Context7 MCP)
