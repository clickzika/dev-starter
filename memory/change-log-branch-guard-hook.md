# Change Log — branch-guard-hook
Change ID: CR-2026-05-23-001
Date: 2026-05-23
Type: Add Feature

<!-- Agents: append entries below during development. Format:
### path/to/file.ext
- ADDED: functionName — description
- MODIFIED: functionName — what changed
- FIXED: functionName — what was wrong, what was fixed
-->

### scripts/hooks/pre-edit-branch-guard.js
- ADDED: main (stdin handler) — PreToolUse hook; reads stdin, checks git branch, blocks Edit/Write on protected branches with JSON decision; passes through on safe branch or non-git dir

### templates/hooks/hooks.json
- MODIFIED: hooks config — added PreToolUse array with Edit|Write matcher pointing to pre-edit-branch-guard.js

### agents/shared/devstarter-agent-base.md
- MODIFIED: Branch Guard section — added note referencing PreToolUse hook as technical safety net

### sdlc/devstarter-change.md
- MODIFIED: Rule 9 — added note referencing PreToolUse hook as secondary enforcement
