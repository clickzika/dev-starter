# TEAM.md — Team Structure + Ownership

## Purpose

Defines who owns what in this project.
Agents read this to know who to notify, who approves what,
and how to route questions or blockers.

Place at project root.

---

## Team Members

| Name | Role | GitHub | Notion | Timezone | Availability |
|------|------|--------|--------|----------|--------------|
| [Name] | Tech Lead | @[handle] | [email] | Asia/Bangkok | Mon–Fri 09–18 |
| [Name] | Frontend Dev | @[handle] | [email] | Asia/Bangkok | Mon–Fri 09–18 |
| [Name] | Backend Dev | @[handle] | [email] | Asia/Bangkok | Mon–Fri 09–18 |
| [Name] | QA | @[handle] | [email] | Asia/Bangkok | Mon–Fri 09–18 |

---

## Ownership Map

### Code Ownership
| Area | Owner | Backup |
|------|-------|--------|
| Frontend (Angular/React) | [Name] | [Name] |
| Backend API | [Name] | [Name] |
| Database / Migrations | [Name] | [Name] |
| DevOps / CI/CD | [Name] | [Name] |
| Security | [Name] | [Name] |
| Documentation | [Name] | [Name] |

### Decision Authority
| Decision Type | Who Approves |
|---------------|-------------|
| Architecture changes | Tech Lead |
| New dependencies (npm/NuGet) | Tech Lead |
| Production deployments | Tech Lead + PM |
| Database schema changes | DBA + Tech Lead |
| Security changes | Security Lead + Tech Lead |
| Feature scope changes | PM + Tech Lead |

### PR Review Rules
- All PRs require at least 1 reviewer
- Critical/security PRs require Tech Lead review
- Database migration PRs require DBA review
- PRs open > 48 hours without review → escalate to Tech Lead

---

## Communication Channels

| Channel | Used For |
|---------|----------|
| [Slack/LINE/#channel] | Daily communication |
| [Slack/LINE/#alerts] | Production alerts |
| GitHub Issues | Task tracking + bugs |
| Notion | Project documentation + task board |
| [Email/Calendar] | Meetings + releases |

---

## On-Call / Escalation

Production issue severity routing:

| Severity | Response Time | Who to Contact |
|----------|---------------|----------------|
| Critical (system down) | 15 min | Tech Lead → PM |
| High (major feature broken) | 2 hours | Feature owner |
| Medium (minor issue) | Next business day | Assigned dev |
| Low (cosmetic) | Next sprint | Backlog |

Emergency contacts:
- Tech Lead: [phone/LINE]
- PM: [phone/LINE]

---

## Agent Rules When Reading TEAM.md

- If a task involves a decision listed above → mention the approver before proceeding
- If a PR needs review → mention the correct reviewer
- If blocked → route to the correct escalation path
- Never assume a decision is approved without the listed authority
