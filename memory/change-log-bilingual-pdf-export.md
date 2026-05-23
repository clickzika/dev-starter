# Change Log — bilingual-pdf-export
Change ID: CR-2026-05-23-002
Date: 2026-05-23
Type: Modify Feature

<!-- Agents: append entries below during development. Format:
### path/to/file.ext
- ADDED: functionName — description
- MODIFIED: functionName — what changed
- FIXED: functionName — what was wrong, what was fixed
-->

### ~/.claude/templates/docs/document-template.html
- ADDED: toggleLang() — language toggle function (EN↔TH via data-lang attribute + localStorage)
- ADDED: lang persistence IIFE — restores saved language on page load
- ADDED: .lang-btn / .pdf-btn CSS — topbar button styles
- ADDED: .lang-en / .lang-th CSS — show/hide rules for bilingual span pairs
- ADDED: [data-lang="th"] Sarabun font rule — applies Thai font when TH active
- ADDED: Google Fonts Sarabun link in <head>
- MODIFIED: @media print — added body overflow:auto, page-break rules, hide .lang-btn/.pdf-btn
- MODIFIED: .doc-header-right — added Export PDF and EN/TH lang toggle buttons

### ~/.claude/templates/docs/devstarter-change-plan-template.html
- ADDED: toggleLang(), lang persistence IIFE, .lang-btn/.pdf-btn CSS, bilingual CSS rules, Sarabun font
- MODIFIED: @media print — added overflow/page-break rules, hide lang/pdf buttons
- MODIFIED: .doc-header-right — added Export PDF and lang toggle buttons

### ~/.claude/templates/docs/devstarter-change-summary-template.html
- ADDED: toggleLang(), lang persistence IIFE, .lang-btn/.pdf-btn CSS, bilingual CSS rules, Sarabun font
- MODIFIED: @media print — added overflow/page-break rules, hide lang/pdf buttons
- MODIFIED: .doc-header-right — added Export PDF and lang toggle buttons

### ~/.claude/templates/docs/devstarter-change-mgmt-template.html
- ADDED: toggleLang(), lang persistence IIFE, .lang-btn/.pdf-btn CSS, bilingual CSS rules, Sarabun font
- MODIFIED: @media print — added overflow/page-break rules, hide lang/pdf buttons
- MODIFIED: .doc-header-right — added Export PDF and lang toggle buttons

### agents/shared/devstarter-agent-base.md
- ADDED: Bilingual Content Rule section — mandatory EN+TH span pairs for all generated documents, Thai translation quality requirement, static-chrome exception

### sdlc/devstarter-change.md
- MODIFIED: Rule 8 — added bilingual content bullet (mandatory EN+TH, span format, reference to agent-base rule)

### docs/feature/branch-guard-hook/plan.html
- MODIFIED: (full regeneration) added Sarabun font, lang toggle CSS/JS, PDF button, @media print, bilingual EN/TH spans on all text blocks

### docs/feature/branch-guard-hook/summary.html
- MODIFIED: (full regeneration) added Sarabun font, lang toggle CSS/JS, PDF button, @media print, bilingual EN/TH spans on all text blocks

### docs/feature/branch-guard-hook/mgmt-brief.html
- MODIFIED: (full regeneration) added Sarabun font, lang toggle CSS/JS, PDF button, @media print, bilingual EN/TH spans on all text blocks
