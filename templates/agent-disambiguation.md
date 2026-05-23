# Agent Disambiguation Guide

When two agents or skills seem to do the same thing, use this table.

---

## Architecture: @techlead vs @architect vs @code-architect

| Agent | Use when |
|-------|---------|
| `@techlead` | Reviewing overall technical direction, delegating to other agents, cross-cutting decisions, AI/LLM choices |
| `@architect` | Designing service boundaries, microservices topology, system-level ADRs, event-driven architecture |
| `@code-architect` | Planning HOW to implement a specific feature in the existing codebase — what files, what patterns, what order |

> Rule: system design → @architect · feature implementation plan → @code-architect · everything else → @techlead

---

## Planning: @pm vs @planner vs /devstarter-sprint

| Item | Use when |
|------|---------|
| `@pm` | Managing the project — tracking progress, stakeholder communication, sprint ceremonies, Notion/Jira updates |
| `@planner` | Decomposing one large task into smaller subtasks — no project management, pure decomposition |
| `/devstarter-sprint` | Running a full sprint planning session — backlog grooming, estimation, assignment, sprint goal |

> Rule: one task → @planner · sprint ceremony → /devstarter-sprint · ongoing project management → @pm

---

## Security: @security vs @security-reviewer

| Agent | Use when |
|-------|---------|
| `@security` | Threat modeling, auth strategy, secrets management policy, OWASP architecture review |
| `@security-reviewer` | Code review with a security lens — finds injection, insecure deserialization, missing auth checks in PRs |

> Rule: "how should we design auth?" → @security · "is this PR secure?" → @security-reviewer

---

## Documentation: @docs vs @doc-updater vs @docs-lookup

| Agent | Use when |
|-------|---------|
| `@docs` | Write or rewrite documentation on explicit request — API reference, guides, runbooks |
| `@doc-updater` | Scan recent code changes, find stale docs, update proactively without being asked |
| `@docs-lookup` | Fetch live library/framework documentation mid-session via Context7 MCP |

> Rule: "write docs for X" → @docs · "check if docs are stale" → @doc-updater · "what's the Next.js 14 API?" → @docs-lookup

---

## Code Review: @code-reviewer vs language-specific reviewers

| Agent | Use when |
|-------|---------|
| `@code-reviewer` | Mixed-language repo, unknown stack, or just want auto-detection and delegation |
| `@ts-reviewer`, `@go-reviewer`, `@py-reviewer`, etc. | You know the language and want deep expertise — framework conventions, idiomatic patterns, language-specific gotchas |

> Rule: if you know the stack, use the specialist. Generic only for polyglot repos.

---

## Build Errors: @build-resolver vs language-specific resolvers

Same pattern as code reviewers:
- `@build-resolver` — auto-detects stack, delegates
- `@ts-build-resolver`, `@go-build-resolver`, etc. — faster, deeper for known stacks

---

## DevOps vs SRE: @devops vs @sre

| Agent | Use when |
|-------|---------|
| `@devops` | CI/CD pipelines, Docker, Kubernetes, infrastructure provisioning, deployment automation |
| `@sre` | SLI/SLO definition, error budgets, alerting strategy, reliability reviews, incident runbooks |

> Rule: "help me deploy this" → @devops · "help me make this reliable + measurable" → @sre

---

## Decision Making: /devstarter-consult vs /devstarter-council vs /devstarter-adr

| Skill | Use when |
|-------|---------|
| `/devstarter-consult` | You want a single expert opinion with structured analysis — outputs intake file for /devstarter-change |
| `/devstarter-council` | Decision is genuinely ambiguous and you want multiple competing perspectives (Architect/Skeptic/Pragmatist/Critic) |
| `/devstarter-adr` | Decision is already made — just need to record it formally as an ADR |

> Rule: uncertain → /devstarter-consult → if still uncertain → /devstarter-council → decided → /devstarter-adr

---

## Project Review: /devstarter-audit vs /devstarter-review vs /devstarter-doctor

| Skill | Use when |
|-------|---------|
| `/devstarter-audit` | Full project assessment — architecture, security, performance, docs, CI/CD all at once |
| `/devstarter-review` | PR/code review — 3-pass (TechLead + QA + Security) on specific changes |
| `/devstarter-doctor` | Health check — is DevStarter installed correctly? Are all configs present? |

> Rule: whole project → /devstarter-audit · specific PR → /devstarter-review · DevStarter setup issues → /devstarter-doctor

---

## Incident: /devstarter-incident vs /devstarter-rollback vs /devstarter-postmortem

These are sequential, not alternatives:
1. `/devstarter-incident` — active incident: triage → comms → mitigation
2. `/devstarter-rollback` — if mitigation takes >1h: revert first, fix later
3. `/devstarter-postmortem` — 48h after resolution: blameless RCA + action items

> Rule: these run in order, not in competition.

---

## Data Science vs MLOps: @datascience vs @mlops vs @mle-reviewer

| Agent | Use when |
|-------|---------|
| `@datascience` | EDA, feature engineering, model selection, A/B testing, statistical analysis |
| `@mlops` | Production ML: training pipelines, model serving, monitoring, drift detection, retraining |
| `@mle-reviewer` | Code review of ML code — data leakage, reproducibility, metric validity, notebook hygiene |

> Rule: research/modeling → @datascience · production/deployment → @mlops · reviewing ML code → @mle-reviewer

---

## Networking: @network-architect vs @network-config-reviewer vs @network-troubleshooter vs @homelab-architect

| Agent | Use when |
|-------|---------|
| `@network-architect` | Design network topology — API gateway, service mesh, CDN, load balancing |
| `@network-config-reviewer` | Review Cisco/Juniper/OPNsense router and switch configs |
| `@network-troubleshooter` | Diagnose connectivity issues — OSI layer by layer, read-only |
| `@homelab-architect` | Design home/small-lab network — VLANs, Pi-hole, WireGuard, NAS |

> Rule: design → @network-architect · review config → @network-config-reviewer · something broke → @network-troubleshooter · home setup → @homelab-architect
