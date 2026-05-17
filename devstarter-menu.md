# devstarter-menu.md — Claude Code Project Launcher

## How to Use

Place at `~/.claude/devstarter-menu.md`
Run in any project folder:
```
claude
> Read ~/.claude/devstarter-menu.md and help me get started
```

---

## Instructions for Claude Code

Show this menu and ask ONE question:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👋 Claude Code Project Launcher
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

── PROJECT SETUP ──────────────────────────────
  1. 🆕 New Project
  2. 📂 Existing Project
  3. 🔄 Migration (new tech stack)
  4. 🔍 Audit & Review

── DAILY WORK ─────────────────────────────────
  5. ✏️  Change (add / remove feature / fix bug)
  6. 📄 Document (generate / regenerate a doc)
  7. 🏃 Sprint Planning
  8. 📦 Dependency Update

── TEAM ───────────────────────────────────────
  9. 👤 Onboard New Member
  10. 🔁 Handover Project
  11. 📊 Sprint Retrospective

── PRODUCTION ─────────────────────────────────
  12. 🚀 Release + Deploy
  13. 🔥 Hotfix (critical production bug)
  14. ⏪ Rollback Production
  15. 🚨 Incident Response
  25. 📋 Post-Mortem (blameless, after SEV resolved)

── SETUP & INFRA ──────────────────────────────
  16. 💻 Setup Local Environment
  17. 🔐 Secrets Management
  18. 📡 Setup Monitoring
  19. 🌿 Git & Gitflow Setup

── AI / ML ────────────────────────────────────
  20. 🤖 New AI/ML Project
  21. 🔬 ML Workflow (train / evaluate / deploy)

── UTILITIES ──────────────────────────────────
  22. 🩺 Doctor (health check)
  23. 🔍 Review (PR / branch / current changes)
  24. 🐛 Debug (senior dev problem analysis)
  29. 🔄 Update DevStarter — `/devstarter-update` or `bash ~/.claude/update.sh`
  30. 🔌 MCP Setup — `/devstarter-mcp`

── ENGINEERING PRACTICE ───────────────────────
  26. 🏛️  ADR — Architecture Decision Record (standalone)
  27. ⚡ Profile (proactive performance investigation)
  28. 🛡️  Compliance (WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001)

── AGENTS ─────────────────────────────────────
  /devstarter-agents    List all specialist agents (BA, PM, TechLead, …)
                        Then invoke any of them directly with @<alias> <task>
                        e.g. @ba, @techlead, @qa, @security

  Standard (13):  @pm @techlead @ba @backend @frontend @dba @qa
                  @security @devops @uxui @docs @mobile @mlops
  Extended (full profile only):
                  @architect @datascience @sre @api @performance

Type the number of your choice, or /devstarter-agents to see the agent roster:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Route to correct file:

| # | File |
|---|------|
| 1 | `~/.claude/sdlc/devstarter-starter.md` |
| 2 | `~/.claude/sdlc/devstarter-existing.md` |
| 3 | `~/.claude/sdlc/devstarter-migrate.md` |
| 4 | `~/.claude/sdlc/devstarter-audit.md` |
| 5 | `~/.claude/sdlc/devstarter-change.md` |
| 6 | `~/.claude/sdlc/devstarter-document.md` |
| 7 | `~/.claude/sdlc/devstarter-sprint.md` |
| 8 | `~/.claude/sdlc/devstarter-dependency.md` |
| 9 | `~/.claude/sdlc/devstarter-onboarding.md` |
| 10 | `~/.claude/sdlc/devstarter-handover.md` |
| 11 | `~/.claude/sdlc/devstarter-retrospective.md` |
| 12 | `~/.claude/sdlc/devstarter-release.md` |
| 13 | `~/.claude/sdlc/devstarter-hotfix.md` |
| 14 | `~/.claude/sdlc/devstarter-rollback.md` |
| 15 | `~/.claude/sdlc/devstarter-incident.md` |
| 16 | `~/.claude/sdlc/devstarter-env.md` |
| 17 | `~/.claude/sdlc/devstarter-secrets.md` |
| 18 | `~/.claude/sdlc/devstarter-monitor.md` |
| 19 | `~/.claude/sdlc/devstarter-gitsetup.md` |
| 20 | `~/.claude/sdlc/devstarter-starter.md` (select ML stack) |
| 21 | `~/.claude/sdlc/devstarter-ml-workflow.md` |
| 22 | `~/.claude/sdlc/devstarter-doctor.md` |
| 23 | `~/.claude/sdlc/devstarter-review.md` |
| 24 | `~/.claude/sdlc/devstarter-debug.md` |
| 25 | `~/.claude/sdlc/devstarter-postmortem.md` |
| 26 | `~/.claude/sdlc/devstarter-adr.md` |
| 27 | `~/.claude/sdlc/devstarter-profile.md` |
| 28 | `~/.claude/sdlc/devstarter-compliance.md` |
| 29 | Run `bash ~/.claude/update.sh` |
| 30 | `~/.claude/sdlc/devstarter-mcp.md` |
