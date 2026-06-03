# Obsidian Knowledge Vault — Setup Guide

DevStarter can capture engineering knowledge — techniques, bugs, and root causes — as Markdown notes in a shared [Obsidian](https://obsidian.md) vault, reusable across every project. Decision record: [`adr/0002-obsidian-knowledge-vault.html`](adr/0002-obsidian-knowledge-vault.html).

**Capture points:** `/devstarter-knowledge` (ad-hoc), `/devstarter-bug-postmortem` (fixed-bug RCA), `/devstarter-postmortem` (incident RCA).
**Recall:** `/devstarter-debug` greps the vault at session start and surfaces prior matching root causes — across projects.

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

## 6. Quick start

```
1. Create + clone a git vault repo, install Obsidian Git.
2. Set the obsidian: block in devstarter-config.yml (transport: git).
3. /devstarter-knowledge "use a Postgres advisory lock to serialize cron across replicas"
   → sanitized technique note written to vault/knowledge/
4. Next time you /devstarter-debug a related issue, the note surfaces automatically.
```
