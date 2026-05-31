# Change Log — obsidian-knowledge-vault
Change ID: CR-2026-05-31-001
Date: 2026-05-31
Type: Add Feature

### devstarter-config.yml + templates/devstarter-config.template.yml
- ADDED: obsidian: block — enabled, vault_path, transport (git|network), sanitize, subdir

### templates/obsidian/bug-note.md
- ADDED: Obsidian bug-note template — recall frontmatter (type/symptom/root_cause_category/language/framework/project) + wikilinks
### templates/obsidian/rca-note.md
- ADDED: incident RCA note template — severity + 5-Whys + contributing factors + frontmatter
### templates/obsidian/technique-note.md
- ADDED: technique/know-how note template — topic + approach + reuse + frontmatter

### sdlc/devstarter-knowledge.md
- ADDED: /devstarter-knowledge runbook + shared Vault Emit Procedure (E1–E5), Frontmatter Schema (recall contract), Vault Recall Procedure; sanitize-on-write rule; one-note-per-file rule
### skills/devstarter-knowledge/SKILL.md
- ADDED: thin router skill + universal prompt; opt-in + security notes

### skills/devstarter-bug-postmortem/SKILL.md
- ADDED: "Obsidian Vault Emit (optional)" section — emits sanitized bug-note when obsidian.enabled
### sdlc/devstarter-postmortem.md
- ADDED: PHASE 6 "Knowledge Vault emit (optional)" — sanitized rca-note emit
### sdlc/devstarter-debug.md
- ADDED: PHASE 1 Step 1.0 "Knowledge Vault Recall" — grep vault for prior root causes before hypotheses

### docs/adr/0002-obsidian-knowledge-vault.html
- ADDED: ADR-0002 (Accepted, bilingual) — decision record for the vault
### docs/obsidian-vault-guide.md
- ADDED: setup guide — git vs network transport, safe config, sanitize, recall queries
### docs/index.html
- MODIFIED: registered ADR-0002 under Architecture Decisions
### devstarter-menu.md
- ADDED: menu item 45 (Knowledge) + routing row → sdlc/devstarter-knowledge.md
### CLAUDE.md
- MODIFIED: Recently Shipped — v5.7.0 row
