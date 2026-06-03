# Change Log — obsidian-sdlc-wiring
Change ID: CR-2026-06-03-002
Date: 2026-06-03
Type: Add Feature

### docs/obsidian-vault-guide.md
- MODIFIED: updated capture/recall summary in intro paragraph; added Section 6 "SDLC Vault Coverage Map" with full table (11 commands), two Dataview queries; renumbered Quick start to Section 7

### sdlc/devstarter-retrospective.md
- MODIFIED: added "Vault Emit — Retrospective Lessons" block between Phase 4 and Phase 5; checks obsidian.enabled; AskUserQuestion; emits Q2+Q3+action items as type: technique, topic: process; one note per distinct lesson; silent skip when disabled

### sdlc/devstarter-audit.md
- MODIFIED: added "Vault Emit — Audit Findings" block before Audit Report HTML Template section; checks obsidian.enabled + audit has >=1 critical/high; AskUserQuestion; emits each as type: rca, root_cause_category: audit-gap; silent skip if only low/medium or disabled

### sdlc/devstarter-review.md
- MODIFIED: added "Vault Emit — Code Quality Findings" block after Phase 4; checks obsidian.enabled + review has >=1 MAJOR/BLOCKER; AskUserQuestion; emits per finding category as type: technique, topic: code-quality; silent skip if clean or disabled

### sdlc/devstarter-change-add.md
- MODIFIED: added "Vault Recall — Prior Patterns" block before A-PHASE 2; checks obsidian.enabled; greps vault for technique notes matching feature topic; surfaces top 1-3 matches; silent skip when disabled

<!-- Agents: append entries below during development. -->
