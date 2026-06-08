# /devstarter-vault-ingest — Analyze & Emit Existing Markdown to Vault

**Version:** v6.0.0
**Model:** Sonnet (session default — no Opus gate)
**Author:** @devstarter-docs

> **Scope:** This runbook handles two modes:
> - **Ingest mode** (`/devstarter-vault-ingest <file>`) — analyze, classify, link, and emit an existing MD file to the vault.
> - **Scaffold mode** (`/devstarter-vault-ingest --scaffold`) — create the hierarchical folder structure and MOC files only.

---

## Prerequisites

Before running either mode:

1. Read `devstarter-config.yml` — confirm `obsidian.enabled: true` and `obsidian.vault_path` is set.
2. If `obsidian.enabled: false` or `vault_path` is empty → stop and show:
   ```
   Obsidian vault not configured. Set obsidian.enabled: true and vault_path in devstarter-config.yml.
   See docs/obsidian-vault-guide.md for setup instructions.
   ```
3. Read `obsidian.folder_structure` (default: `flat`). Scaffold mode and hierarchical wikilinks require `hierarchical`.

---

## SCAFFOLD MODE — /devstarter-vault-ingest --scaffold

Creates the hierarchical folder structure and MOC pages. Safe to run on existing vaults — existing notes are not modified.

### Step S1 — Create folders

Create the following directories inside `<vault_path>/<subdir>/` (create if missing):
```
bugs/
techniques/
rcas/
snapshots/
_index/
```

### Step S2 — Create HOME.md

Write `<vault_path>/<subdir>/_index/HOME.md` (skip if already exists):

```markdown
---
type: moc
title: "DevStarter Knowledge Vault — Home"
date: {{DATE}}
---

# DevStarter Knowledge Vault

> Knowledge captured across all projects.

## Maps of Content

- [[_index/MOC-bugs]] — Bug notes & fixes
- [[_index/MOC-techniques]] — Techniques & patterns
- [[_index/MOC-rcas]] — Root cause analyses
- [[_index/MOC-projects]] — Project snapshots

## Recent Notes

\`\`\`dataview
table type, title, project, date
from "{{SUBDIR}}"
sort date desc
limit 20
\`\`\`
```

Replace `{{DATE}}` with today, `{{SUBDIR}}` with `obsidian.subdir`.

### Step S3 — Create 4 MOC files

Write the following files (skip each if already exists):

**`_index/MOC-bugs.md`**
```markdown
---
type: moc
title: "MOC — Bug Notes"
---

# Map of Content — Bug Notes

\`\`\`dataview
table title, project, date, tags
from "{{SUBDIR}}/bugs"
sort date desc
\`\`\`
```

**`_index/MOC-techniques.md`**
```markdown
---
type: moc
title: "MOC — Techniques"
---

# Map of Content — Techniques

\`\`\`dataview
table title, topic, project, date
from "{{SUBDIR}}/techniques"
sort topic asc, date desc
\`\`\`
```

**`_index/MOC-rcas.md`**
```markdown
---
type: moc
title: "MOC — Root Cause Analyses"
---

# Map of Content — Root Cause Analyses

\`\`\`dataview
table title, project, date, root_cause_category
from "{{SUBDIR}}/rcas"
sort date desc
\`\`\`
```

**`_index/MOC-projects.md`**
```markdown
---
type: moc
title: "MOC — Project Snapshots"
---

# Map of Content — Project Snapshots

\`\`\`dataview
table title, project, version, date
from "{{SUBDIR}}/snapshots"
sort date desc
\`\`\`
```

Replace `{{SUBDIR}}` with `obsidian.subdir` in all MOC files.

### Step S4 — Update devstarter-config.yml

If `obsidian.folder_structure` is not already `hierarchical`, prompt:

> "Set `folder_structure: hierarchical` in devstarter-config.yml to route new notes to the correct type folders? (yes / no — keep flat)"

If yes: update `devstarter-config.yml` `obsidian.folder_structure: hierarchical`.

### Step S5 — Confirm

Show:
```
✅ Vault scaffold complete

Created:
  <subdir>/bugs/
  <subdir>/techniques/
  <subdir>/rcas/
  <subdir>/snapshots/
  <subdir>/_index/
  <subdir>/_index/HOME.md
  <subdir>/_index/MOC-bugs.md
  <subdir>/_index/MOC-techniques.md
  <subdir>/_index/MOC-rcas.md
  <subdir>/_index/MOC-projects.md

Open HOME.md in Obsidian and set it as your vault startup note.
```

---

## INGEST MODE — /devstarter-vault-ingest <file>

### Phase 1 — Read & Analyze

#### Step I1 — Read input file

Read the file at `<file>`. If not found → stop and tell the user.

Determine the file extension:
- If `.md` → continue to Step I2 (no preprocessing needed).
- If `.html` or `.htm` → continue to Step I1b (HTML preprocessing).
- Otherwise → stop and tell the user: "Only `.md`, `.html`, and `.htm` files are supported."

#### Step I1b — HTML preprocessing (HTML/HTM files only)

Skip this step for `.md` files — go directly to I2.

For `.html`/`.htm` files: extract clean Markdown from the HTML before continuing to I2.

**Extraction rules:**

1. **Title** — use the text content of the first `<h1>` element; if none, use the `<title>` tag content (strip any " — DevStarter" suffix if present).
2. **Sections** — each `<section>`, `<main>`, or `<article>` block → `##` heading (use the block's inner `<h2>` or first heading as the heading text) followed by its content.
3. **Headings** — `<h2>` → `##`  |  `<h3>` → `###`
4. **Tables** — `<table>` → GFM pipe table (`| col | col |`)
5. **Code blocks** — `<pre><code class="lang-X">` → fenced `` ` `` ` `` ` `` X block; if no `class` attribute, use plain fenced block without language specifier.
6. **Paragraphs** — `<p>` content → plain text paragraph.
7. **Strip (do not emit)** — `<nav>`, `<header>`, `<footer>`, `<script>`, `<style>`, `<aside>` and all their contents; all HTML attributes except `class` on `<code>` elements (needed for language detection in rule 5).
8. **Compose** — assemble the extracted content as a clean Markdown string.

Feed this Markdown string into Step I2 as the source content (treating it as if it were the contents of a `.md` file). The original filename (without extension) is used for slug generation in Step I7.

#### Step I2 — Classify

Infer `type` from file content using this priority order:

| Signal in file | Inferred type |
|---|---|
| Contains error / stack trace / exception / symptom + fix | `bug-note` |
| Contains root_cause / postmortem / 5-whys / incident / timeline | `rca` |
| Contains how-to / pattern / technique / tip / approach / snippet | `technique` |
| Contains project / stack / overview / architecture / constraints | `project-snapshot` |
| Ambiguous (none or multiple match equally) | Show AskUserQuestion picker |

⛔ **GATE I-CLASSIFY** — If classification is ambiguous, show:

```
AskUserQuestion:
  question: "What type of note is this?"
  options:
    - "bug-note — Bug fix / known issue"
    - "technique — Pattern, tip, or how-to"
    - "rca — Root cause analysis / postmortem"
    - "project-snapshot — Project context overview"
```

#### Step I3 — Extract metadata

From file content, extract or infer:
- `title` — use the first H1 heading; if none, use the filename (slug form)
- `language` — infer from code blocks or explicit mentions (typescript, python, go, etc.)
- `framework` — infer from imports / stack mentions (react, fastapi, gin, none)
- `tags` — extract from existing frontmatter tags if present; else infer from keywords
- `topic` (technique only) — infer from content subject
- `root_cause_category` (bug-note/rca) — infer from content; choose from vocabulary: `null-deref`, `race-condition`, `auth-token-expiry`, `off-by-one`, `config-drift`, `network-timeout`, `schema-migration`, `memory-leak`, `dependency-conflict`, `permission-error`
- `symptom` (bug-note/rca) — one-line summary
- `source_ref` — the input file path (relative)

#### Step I4 — Propose frontmatter

⛔ **GATE I-FRONTMATTER** — Show proposed frontmatter via AskUserQuestion:

```
AskUserQuestion:
  question: "Proposed frontmatter for this note — approve or request changes."
  options:
    - "Approved — proceed to related note discovery"
    - "Request changes (describe in notes)"
```

Show the full proposed frontmatter YAML block above the question.

If "Request changes": apply the user's edits and re-show. Repeat until approved.

---

### Phase 2 — Related Note Discovery

#### Step I5 — Grep vault

Search `<vault_path>/<subdir>/` for related notes using:

1. Tag match: grep for any of the proposed `tags` values
2. Language match: grep for the `language` value
3. Category match (bug-note/rca): grep for `root_cause_category` value
4. Collect unique file matches — deduplicate by path

#### Step I6 — Propose wikilinks

From grep results, pick the top 1–5 most relevant matches (prefer same language/category).

Convert each matched path to a wikilink:
- `flat` mode: `[[<slug>]]` where slug = filename without `.md`
- `hierarchical` mode: `[[<folder>/<slug>]]` e.g. `[[bugs/auth-token-expiry]]`

Add these as the `## Links → Related:` list in the note body.

If no related notes found: set `Related: (none)` — do not skip the Links section.

---

### Phase 3 — Emit

#### Step I7 — Resolve target path (E1)

Follow Vault Emit Procedure E1 (from `sdlc/devstarter-knowledge.md`):
- Read `folder_structure` from config
- `flat`: write to `<vault_path>/<subdir>/`
- `hierarchical`: write to `<vault_path>/<subdir>/<type-folder>/`

Filename = `<YYYY-MM-DD>-<project-slug>-<note-slug>.md` (kebab-case, unique).

#### Step I8 — Build note

Compose the note from the appropriate template (`~/.claude/templates/obsidian/<type>-note.md`):
- Fill all `{{PLACEHOLDER}}` values from Phase 1 analysis
- Replace `Related: {{RELATED_WIKILINKS}}` with the wikilinks from Phase 2
- Keep all existing body content from the original file, placed under the appropriate section

#### Step I9 — Sanitize (E4)

Run Vault Emit Procedure E4 (deny-list redaction) on the composed note text.
If a match cannot be redacted without destroying meaning → stop and show the user. Do not write.

#### Step I10 — Write

Write the sanitized note to the resolved target path.

If `folder_structure: hierarchical` and the type is `bug-note`/`technique`/`rca`/`project-snapshot`:
- Also append a Dataview link line to the corresponding `_index/MOC-<type>.md` if it exists:
  `- [[<folder>/<slug>]] — {{TITLE}} ({{DATE}})`

---

### Phase 4 — Confirm

#### Step I11 — Show confirmation

```
✅ Note emitted to vault

  Path:   <vault_path>/<subdir>/[<folder>/]<filename>.md
  Type:   <type>
  Title:  <title>
  Tags:   <tags>

Linked notes:
  [[<wikilink1>]] — <title>
  [[<wikilink2>]] — <title>
  (or: none)

MOC updated: _index/MOC-<type>.md
```

---

## Wikilink convention (reference)

| Note type | Folder (hierarchical) | Wikilink format |
|---|---|---|
| bug-note | bugs/ | `[[bugs/auth-token-expiry]]` |
| technique | techniques/ | `[[techniques/postgres-advisory-lock]]` |
| rca | rcas/ | `[[rcas/cache-invalidation-race]]` |
| project-snapshot | snapshots/ | `[[snapshots/devstarter-v5-9-0]]` |

Slug rules: lowercase, hyphens only, no spaces, no underscores.
