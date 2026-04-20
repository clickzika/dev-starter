# devstarter-doctor.md — Install Health Check

## Model: Haiku (`claude-haiku-4-5-20251001`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## Purpose

Verify that the DevStarter installation is complete and healthy.
Run after `install.sh`, `update.sh`, or when something feels broken.

---

## Checks

Run all checks and report status:

### 1 — Core Files
```
~/.claude/VERSION                 → readable
~/.claude/devstarter-menu.md      → exists
~/.claude/USER.md                 → exists + not default template
~/.claude/.env                    → exists (secrets configured)
~/.claude/setup.sh                → exists + executable
~/.claude/update.sh               → exists + executable
```

### 2 — Agents (13 required + 13 aliases)
```
agents/devstarter-pm.md           → exists
agents/devstarter-techlead.md     → exists
agents/devstarter-ba.md           → exists
agents/devstarter-backend.md      → exists
agents/devstarter-frontend.md     → exists
agents/devstarter-dba.md          → exists
agents/devstarter-qa.md           → exists
agents/devstarter-security.md     → exists
agents/devstarter-devops.md       → exists
agents/devstarter-uxui.md         → exists
agents/devstarter-docs.md         → exists
agents/devstarter-mobile.md       → exists
agents/devstarter-mlops.md        → exists
agents/pm.md                      → exists (alias)
agents/techlead.md                → exists (alias)
... (all 13 aliases)
agents/custom/                    → exists (custom agent folder)
```

### 3 — Commands (25 required)
Check all `~/.claude/commands/devstarter-*.md` files exist.

### 4 — SDLC Runbooks (key files)
```
sdlc/devstarter-change.md         → exists
sdlc/devstarter-checkpoint.md     → exists
sdlc/devstarter-release.md        → exists
sdlc/devstarter-existing.md       → exists
```

### 5 — Config
```
devstarter-config.yml             → exists in project root (if in a project)
~/.claude/templates/              → exists
~/.claude/scripts/                → exists
```

---

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🩺 DEVSTARTER HEALTH CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version:  [VERSION file content]
Location: ~/.claude/

Core files:      ✅ [N]/6 present
Agents:          ✅ [N]/26 present
Commands:        ✅ [N]/25 present
SDLC runbooks:   ✅ [N]/4 key files present
Config:          ✅ / ⚠️ devstarter-config.yml [found/not found]

❌ MISSING:
  [list any missing files]

⚠️ WARNINGS:
  [USER.md is default template — run setup.sh]
  [.env missing — run setup.sh]

Overall: ✅ Healthy / ⚠️ Needs attention / ❌ Broken
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If any ❌ found → suggest fix:
- Missing files → `bash ~/.claude/update.sh`
- USER.md default → `bash ~/.claude/setup.sh`
- .env missing → `bash ~/.claude/setup.sh`
- devstarter-config.yml missing → `/devstarter-existing` or create from template
