# dev-onboarding.md — New Member Onboarding

> **TL;DR** — Onboard a new team member with personalized briefing and first PR · **Lifecycle** Operate · **Gates** 0

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## When to use vs alternatives

- **Use /devstarter-onboard** when: a NEW person is joining the team for
  the first time. Output: personalized briefing + access setup + first-PR plan.
- **Use /devstarter-handover** instead when: an existing owner is transferring
  ownership to someone else (knowledge transfer + revocation, not setup).
- **Use /devstarter-existing** instead when: the project is new to *you* but
  not new to the team (first-time DevStarter setup on a repo, no team change).

---

## ⚠️ CRITICAL RULES
- Read CLAUDE.md + TEAM.md + USER.md before starting
- Do NOT share secrets — new member sets up their own credentials
- Create USER.md for the new member before anything else

---

## ⚡ Session Start — Vault Recall: Project Snapshot (v5.8.0+)

Before collecting new member info, check the knowledge vault for a project orientation note.

Read `obsidian.enabled` from `devstarter-config.yml`.
If `obsidian.enabled: false` or `obsidian:` block absent → silently skip; proceed to Phase 1.
If `obsidian.enabled: true` and `vault_path` is set:
  Run Vault Recall Procedure from `sdlc/devstarter-knowledge.md` with:
    - keywords: project.name, "project-snapshot"
    - grep target: `<vault_path>/<subdir>/`
    - filter frontmatter: `type: project-snapshot` AND `project: <project.name>`
    - sort by filename date descending → read the most recent match
  If a match is found, show:
  ```
  🏛️ Project snapshot (vault):
     Title:   <title>
     Version: <version>   Date: <date>
     Stack:   <stack>
     Arch:    <architecture_pattern>
     Repo:    <repo_url>
  → Use this as orientation context during onboarding.
  ```
  If no match: show one line — "No project snapshot in vault yet — run /devstarter-knowledge to add one." — then continue.

---

## PHASE 1 — Collect New Member Info

Ask ONE AT A TIME:

**Q1. What is the new member's name and role?**

**Q2. What is their GitHub username?**

**Q3. What is their skill level?**
1. Junior (< 2 years experience)
2. Mid (2–5 years)
3. Senior (5+ years)
4. Lead / Architect

**Q4. What is their primary tech stack experience?**
(free text — what they know well coming in)

**Q5. What areas will they own in this project?**
(free text — frontend / backend / devops / qa / etc.)

---

## PHASE 2 — Environment Setup Checklist

Agent walks new member through each step:

### Step 1 — Accounts + Access
```
[ ] GitHub — added to repo with correct role (read/write/admin)
[ ] Notion — invited to workspace + project board
[ ] Slack/LINE — added to project channels
[ ] .env file — copy from team member (never commit)
[ ] Password manager — add project credentials
```

### Step 2 — Local Dev Setup
```
[ ] Clone repo: git clone https://github.com/[org]/[repo]
[ ] Install prerequisites (from README.md)
[ ] Copy .env.example → .env and fill values
[ ] Run: docker compose up
[ ] Verify: http://localhost:[port] loads
[ ] Verify: API health endpoint responds
[ ] Run tests: all passing locally
```

### Step 3 — Tools
```
[ ] Install Claude Code CLI: npm install -g @anthropic-ai/claude-code
[ ] Copy ~/.claude/ folder from team (dev-*.md files)
[ ] Create personal USER.md at project root
[ ] Run: claude > Read CLAUDE.md and show me the project overview
```

### Step 4 — First PR
```
[ ] Pick a small "good first issue" from GitHub
[ ] Create feature branch
[ ] Make small change + tests
[ ] Open PR → get first review
[ ] Merge first contribution ✅
```

---

## PHASE 3 — Knowledge Transfer

Agent reads CLAUDE.md + docs/ and creates a personalized briefing:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PROJECT BRIEFING FOR [Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: [name + description]
Stack:   [tech stack]
Your area: [their ownership area]

Key docs to read first:
  1. CLAUDE.md — project spec + rules
  2. docs/brd.html — what we are building
  3. docs/api.html — API reference
  4. docs/schema.html — database design

Current status:
  Gate [N] — [what is in progress]
  Your first task: [recommended starter task]

People to know:
  [Name] — Tech Lead — ask for architecture questions
  [Name] — [Role] — ask for [area] questions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 4 — Create USER.md

Agent helps new member fill in their USER.md:
```
claude
> Read ~/.claude/USER.md template and help me fill it in
```

---

## PHASE 5 — Update TEAM.md

After onboarding complete, update TEAM.md:
- Add new member to Team Members table
- Add their ownership areas
- Commit: `chore: onboard [Name] as [Role]`

---

## Onboarding Checklist (save to Notion)

```
[ ] Accounts + access granted
[ ] Local environment running
[ ] Claude Code setup complete
[ ] USER.md created
[ ] Project briefing received
[ ] First PR merged
[ ] TEAM.md updated
[ ] Welcome message sent
```
