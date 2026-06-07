# Obsidian Knowledge Vault — Setup Guide

DevStarter can capture engineering knowledge — techniques, bugs, and root causes — as Markdown notes in a shared [Obsidian](https://obsidian.md) vault, reusable across every project. Decision record: [`adr/0002-obsidian-knowledge-vault.html`](adr/0002-obsidian-knowledge-vault.html).

**Capture points:** `/devstarter-knowledge` (ad-hoc), `/devstarter-bug-postmortem` (fixed-bug RCA), `/devstarter-postmortem` (incident RCA), `/devstarter-review` (code-quality findings), `/devstarter-audit` (audit-gap findings), `/devstarter-retro` (process lessons).
**Recall:** `/devstarter-debug` greps the vault at session start and surfaces prior matching root causes — across projects. `/devstarter-change` (add-feature) surfaces technique notes before impact analysis.

---

## 1. Enable it

Add the `obsidian:` block to your project's `devstarter-config.yml`:

```yaml
obsidian:
  enabled: true
  vault_path: "C:/Users/you/knowledge-vault"   # absolute path to the vault root
  transport: git           # git (recommended) | network
  sanitize: true           # REQUIRED when transport: network
  subdir: knowledge        # folder inside the vault for DevStarter notes
```

DevStarter writes notes to `<vault_path>/<subdir>/` as `<date>-<project>-<slug>.md`. One file per note, unique name — DevStarter never edits a shared note.

---

## 2. Choose a transport

### Option A — Git-backed vault (recommended for a team)

A normal git repo that is also an Obsidian vault. Gives version history, conflict merge, and attribution.

1. Create the vault repo once (any git host): `knowledge-vault`.
2. Each developer clones it locally and points `vault_path` at their clone.
3. Open the clone in Obsidian (it becomes a vault on first open).
4. Install the **Obsidian Git** community plugin to auto-commit/pull/push, or commit + push manually after DevStarter writes a note.

Why preferred: concurrent writers don't corrupt anything — git merges. Notes are attributable and revertable.

### Option B — Network drive (e.g. `P:\obsidiandev`)

Zero setup; non-developers can read instantly. **Riskier** — Obsidian officially advises against vaults on network/cloud drives.

If you use it, make it safe:
- `transport: network` and **`sanitize: true`** (DevStarter refuses to write to a network vault when sanitize is off).
- DevStarter writes only **unique-named files** — it never edits a shared note, which avoids most concurrent-write corruption.
- **Keep `.obsidian/` local, off the share.** Each person should open the vault with a per-user config. The shared drive holds notes, not the workspace cache. Multiple people opening the same `.obsidian/` on a share corrupts the metadata cache.

---

## 3. Security — scrub on write

Before any note is written, the emit step **scrubs it inline** against a deny-list — API keys, tokens, JWTs, private keys, connection strings, `password/secret/token/key = "..."`, corporate emails, internal hostnames (`.internal`/`.corp`/`.local`), private IP ranges, and real `.env` values. Matches are replaced with `[REDACTED]` (keeping context), and if a note can't be safely redacted it is not written. The pattern set is the one documented by `@devstarter-opensource-sanitizer`, which you can also run over the vault afterward to *verify* it is clean (it FAILs on any remaining secret).

A public share must never receive raw bug notes (stack traces and internal URLs leak otherwise). `sanitize: true` is mandatory for `transport: network` — DevStarter refuses to write to a network vault with it off.

---

## 4. How recall works

Notes carry a fixed frontmatter schema so they cluster and stay queryable:

```yaml
type: bug                       # bug | rca | technique
root_cause_category: auth-token-expiry
language: typescript
framework: react
project: billing-api
tags: [bug, auth-token-expiry, typescript]
```

Cross-project queries (Obsidian search or the [Dataview](https://github.com/blacksmithgu/obsidian-dataview) plugin):

| Goal | Query |
|------|-------|
| Every auth-expiry bug, any project | `root_cause_category: auth-token-expiry` |
| All caching techniques | `type: technique AND topic: caching` |
| The Go bug catalogue | `language: go AND type: bug` |

`/devstarter-debug` does this automatically: it greps `<vault_path>/<subdir>` for the current symptom + category and shows the top prior root causes before you form a hypothesis.

---

## 5. Project Snapshot Notes (v5.8.0+)

A **project-snapshot** note captures a project's full context at a point in time — tech stack, architecture decisions, constraints, repo URL, and team notes. It is the vault's "welcome to this project" entry: new team members can find it immediately, and multiple snapshots across releases form a browsable project evolution timeline.

### When they are emitted

| Trigger | When | Version field |
|---------|------|---------------|
| `/devstarter-new` Gate 0 completion | After scaffold: repo + config created | `"initial"` |
| `/devstarter-release` Phase 9.5 | After each major/minor release launch brief | current tag (e.g. `v5.8.0`) |

Both are **optional** (gated with AskUserQuestion) and silently skip when `obsidian.enabled: false`.

### Frontmatter fields

```yaml
type: project-snapshot
title: "My App — Initial Project Snapshot"
project: my-app
date: 2026-06-03
author: Natthaphat Wajanavisit
version: "initial"          # or "v5.8.0", "v2.1.0" etc.
stack: ["typescript", "react", "postgres"]
architecture_pattern: "monolith"
key_decisions: ["chose React over Vue for ecosystem", "postgres over MySQL for JSON support"]
constraints: ["team size: solo", "must deploy on-prem"]
repo_url: "https://github.com/org/repo"
tags: [project-snapshot, my-app]
```

### Recall: /devstarter-onboard

`/devstarter-onboard` automatically greps the vault for `type: project-snapshot` at session start and surfaces the most recent match as orientation context before onboarding steps begin. New team members see the project at a glance without reading CLAUDE.md manually.

### Dataview queries

Install the [Dataview](https://github.com/blacksmithgu/obsidian-dataview) plugin to run these queries:

**All project overviews:**
```dataview
table version, stack, architecture_pattern, date
from "knowledge"
where type = "project-snapshot"
sort date desc
```

**Project evolution timeline (one project):**
```dataview
table version, date, key_decisions
from "knowledge"
where type = "project-snapshot" and project = "my-app"
sort date asc
```

**All projects using a specific tech:**
```dataview
list
from "knowledge"
where type = "project-snapshot" and contains(stack, "typescript")
```

### Stacking design

DevStarter never overwrites a snapshot. Each emit creates a new unique file (Rule 3). This means:
- Old snapshots remain intact as historical record
- Querying by `date asc` shows how the project evolved
- A snapshot going stale does NOT corrupt data — the most recent is always the highest-version file

---

## 6. SDLC Vault Coverage Map (v5.9.0+)

Every DevStarter workflow that integrates with the vault — where it fires, what it captures, and what note type it produces.

| Command | Trigger | Direction | Note type | Topic / Category |
|---------|---------|-----------|-----------|-----------------|
| `/devstarter-new` | Gate 0 post-scaffold | Emit | project-snapshot | — |
| `/devstarter-release` | Phase 9.5 launch brief | Emit | project-snapshot | version key |
| `/devstarter-onboard` | Session start | Recall | project-snapshot | project match |
| `/devstarter-change` (add-feature) | Before A-PHASE 2 | Recall | technique | feature topic |
| `/devstarter-review` | After Phase 4 (if findings) | Emit | technique | code-quality |
| `/devstarter-audit` | After Phase 5 (critical/high) | Emit | rca | audit-gap |
| `/devstarter-retro` | After Phase 4 | Emit | technique | process |
| `/devstarter-debug` | Session start | Recall | bug / rca | symptom keywords |
| `/devstarter-bug-postmortem` | RCA complete | Emit | bug | root_cause_category |
| `/devstarter-postmortem` | RCA complete | Emit | rca | root_cause_category |
| `/devstarter-knowledge` | Ad-hoc | Emit | technique / bug / rca | any |

All emit points are **opt-in** (AskUserQuestion per run) and **silently skip** when `obsidian.enabled: false`.

### Dataview — technique notes by topic

```dataview
table topic, date, project
from "knowledge"
where type = "technique"
sort topic asc, date desc
```

### Dataview — full SDLC audit trail

```dataview
table type, topic, project, date
from "knowledge"
sort date desc
```

---

## 7. Hierarchical vault structure (folder_structure: hierarchical)

### Overview

By default the vault uses a **flat** layout (all notes in the `knowledge/` subdir).
Enable hierarchical mode to organize notes by type in separate folders with auto-generated MOC index pages.

```yaml
# devstarter-config.yml
obsidian:
  folder_structure: hierarchical   # flat (default) | hierarchical
```

### Folder layout

```
<vault_path>/<subdir>/
├── bugs/            ← type: bug-note
├── techniques/      ← type: technique
├── rcas/            ← type: rca
├── snapshots/       ← type: project-snapshot
└── _index/
    ├── HOME.md          ← Obsidian startup note (set as vault home)
    ├── MOC-bugs.md
    ├── MOC-techniques.md
    ├── MOC-rcas.md
    └── MOC-projects.md
```

### Scaffold command

Run `/devstarter-vault-ingest --scaffold` to create the folder structure.
This creates all 5 folders plus HOME.md and 4 MOC files. Existing notes are not touched.

### MOC pages (Dataview)

Each MOC file uses a Dataview query to auto-list notes in its folder:

```markdown
---
type: moc
title: "MOC — Bugs"
---

# Map of Content — Bug Notes

\`\`\`dataview
table title, project, date, tags
from "knowledge/bugs"
sort date desc
\`\`\`
```

HOME.md links all 4 MOCs and shows a combined recent-notes query.

### Wikilink convention

All wikilinks MUST use the `[[<folder>/<slug>]]` format with kebab-case slugs:

| Note type | Folder | Example wikilink |
|---|---|---|
| bug-note | bugs/ | `[[bugs/auth-token-expiry]]` |
| technique | techniques/ | `[[techniques/postgres-advisory-lock]]` |
| rca | rcas/ | `[[rcas/cache-invalidation-race]]` |
| project-snapshot | snapshots/ | `[[snapshots/devstarter-v5-9-0]]` |

Slug rules: lowercase, hyphens only, no spaces, no underscores.

### Emit path resolution (E1 — hierarchical mode)

When `folder_structure: hierarchical`, procedure E1 resolves the destination folder by note type:

| type field | Destination |
|---|---|
| `bug-note` | `<subdir>/bugs/` |
| `technique` | `<subdir>/techniques/` |
| `rca` | `<subdir>/rcas/` |
| `project-snapshot` | `<subdir>/snapshots/` |

When `folder_structure: flat` (default), E1 writes to `<subdir>/` as before — no change.

### Dataview — all notes by folder

```dataview
table type, title, project, date
from "knowledge/bugs" OR "knowledge/techniques" OR "knowledge/rcas" OR "knowledge/snapshots"
sort date desc
```

---

## 7b. /devstarter-vault-ingest — analyze and emit any MD file

### What it does

`/devstarter-vault-ingest <file>` reads any existing `.md` file, classifies it, proposes frontmatter, discovers related vault notes, and emits with auto-generated wikilinks — all confirmed at a gate before writing.

### 4-phase flow

| Phase | Action |
|---|---|
| 1 — Analyze | Read file; infer type/title/language/framework/tags; show proposed frontmatter via AskUserQuestion |
| 2 — Discover | Grep vault by tags + language + root_cause_category; surface 1–5 matches; propose `[[wikilinks]]` |
| 3 — Emit | Sanitize (E4 deny-list); write to `<subdir>/<type>s/<slug>.md`; update `_index/MOC-<type>.md` if hierarchical |
| 4 — Confirm | Show emitted path + list of linked notes |

### Usage

```
/devstarter-vault-ingest path/to/note.md
/devstarter-vault-ingest --scaffold        ← create folder structure only (no file input)
```

### Classification logic

The skill infers `type` from file content signals:

| Signal | Inferred type |
|---|---|
| Contains error/stack trace/symptom | `bug-note` |
| Contains root_cause / postmortem / 5-whys | `rca` |
| Contains how-to / pattern / technique / tip | `technique` |
| Contains project / stack / overview / architecture | `project-snapshot` |
| Ambiguous | AskUserQuestion picker shown |

---

## 8. Quick start

```
1. Create + clone a git vault repo, install Obsidian Git.
2. Set the obsidian: block in devstarter-config.yml (transport: git).
3. /devstarter-knowledge "use a Postgres advisory lock to serialize cron across replicas"
   → sanitized technique note written to vault/knowledge/
4. Next time you /devstarter-debug a related issue, the note surfaces automatically.
```
