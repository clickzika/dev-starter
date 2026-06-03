# Change Log — obsidian-project-snapshot
Change ID: CR-2026-06-03-001
Date: 2026-06-03
Type: Add Feature

### docs/obsidian-vault-guide.md
- MODIFIED: added Section 5 "Project Snapshot Notes (v5.8.0+)" — describes type: project-snapshot, emit triggers (new/release), frontmatter fields, /devstarter-onboard recall, 3 Dataview queries (all projects, project timeline, by stack), stacking design note

### sdlc/devstarter-onboarding.md
- MODIFIED: session start — added "Vault Recall: Project Snapshot" block before Phase 1; greps vault for type: project-snapshot matching current project; surfaces title/version/stack/arch/repo as orientation context; graceful no-match message

### sdlc/devstarter-release-verify.md
- MODIFIED: Phase 9.5 — added optional "Vault Emit — Versioned Project Snapshot" block after launch brief announce; reads obsidian.enabled, AskUserQuestion, runs E1-E5; version key in frontmatter; unique filename per release (Rule 3)

### sdlc/devstarter-starter-gates.md
- MODIFIED: Gate 0 — added optional "Vault Emit — Initial Project Snapshot" block after ✅ .project.env; reads obsidian.enabled, AskUserQuestion, runs E1-E5 with project-snapshot-note.md template

### templates/obsidian/project-snapshot-note.md
- ADDED: project-snapshot-note.md — new vault note template; type: project-snapshot; frontmatter: version, stack, architecture_pattern, key_decisions, constraints, repo_url; body: Project Overview, Tech Stack, Key Architecture Decisions, Constraints, Repository, Team Notes

### memory/change-log-obsidian-project-snapshot.md
- ADDED: Task 0 structural validation — confirmed templates/obsidian/ (3 existing), sdlc/devstarter-knowledge.md Vault Emit Procedure intact, devstarter-config.yml obsidian block present; live vault test deferred to Gate A-TEST per T1

<!-- Agents: append entries below during development. Format:
### path/to/file.ext
- ADDED: functionName — description
- MODIFIED: functionName — what changed
- FIXED: functionName — what was wrong, what was fixed
-->
