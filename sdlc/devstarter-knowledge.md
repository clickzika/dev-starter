# devstarter-knowledge.md — Knowledge Vault Capture & Recall

> **TL;DR** — Capture know-how / bugs / root causes as Markdown notes into a shared Obsidian vault, reusable across projects · **Lifecycle** Cross-cutting · **Gates** 1 (write confirmation)

## Model: Sonnet (`claude-sonnet-4-6`)

**Config:** Read `devstarter-config.yml` → the `obsidian:` block governs all behavior here.

This runbook serves two roles:
1. The **`/devstarter-knowledge`** command — capture an ad-hoc technique / know-how note.
2. The **shared Vault spec** — the Emit Procedure, Frontmatter Schema, and Recall Procedure that `/devstarter-postmortem`, `/devstarter-bug-postmortem`, and `/devstarter-debug` reference. Decision record: `docs/adr/0002-obsidian-knowledge-vault.html`.

---

## ⚠️ CRITICAL RULES

### Rule 1 — Opt-in
If `obsidian.enabled` is `false` or the `obsidian:` block is absent → this feature is OFF. The `/devstarter-knowledge` command tells the user how to enable it; emit/recall steps in other skills silently skip.

### Rule 2 — Sanitize before write (SECURITY — no exceptions)
Every note passes through `@devstarter-opensource-sanitizer` **before** it is written to the vault: strip secrets, API keys, tokens, internal URLs/hostnames, credentials, customer/PII data, and unpatched-vulnerability detail. If `obsidian.sanitize` is `false` AND `obsidian.transport` is `network` → **refuse to write** and tell the user why (a public share must not receive raw notes).

### Rule 3 — One note per file, unique name (network-safe)
Never edit an existing shared note. Always write a new, uniquely-named file. This avoids concurrent-write corruption on a network share.

### Rule 4 — Frontmatter schema is mandatory
Recall only works if every note carries the schema below. A note without it is a write-only dead end — fill every required key.

---

## VAULT EMIT PROCEDURE (shared — referenced by other skills)

### Step E1 — Resolve target path
1. Read `obsidian.vault_path`, `obsidian.subdir`, `obsidian.transport` from `devstarter-config.yml`.
2. If `vault_path` is empty → emit is not configured; tell the user to set it (see `docs/obsidian-vault-guide.md`) and skip.
3. Target dir = `<vault_path>/<subdir>/`. Create it if missing.
4. Filename = `<YYYY-MM-DD>-<project-slug>-<note-slug>.md` (lowercase, hyphenated, unique — append `-2`, `-3` on collision). This satisfies Rule 3.

### Step E2 — Pick template
| Source | Template |
|--------|----------|
| `/devstarter-bug-postmortem` | `~/.claude/templates/obsidian/bug-note.md` |
| `/devstarter-postmortem` (incident) | `~/.claude/templates/obsidian/rca-note.md` |
| `/devstarter-knowledge` (technique) | `~/.claude/templates/obsidian/technique-note.md` |

### Step E3 — Fill placeholders
Fill every `{{PLACEHOLDER}}` from the source content. `{{AUTHOR}}` = Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias. `{{PROJECT}}` = `project.name` from `devstarter-config.yml`. `{{DATE}}` = today. Resolve `language` / `framework` from `stack` in config. Choose `root_cause_category` from the recall vocabulary (see Schema below) — reuse an existing category string when one fits, so notes cluster.

### Step E4 — Sanitize (Rule 2)
Pass the filled note through `@devstarter-opensource-sanitizer`. Apply its redactions. If it flags content it cannot safely redact → stop, show the user, do not write.

### Step E5 — Write + confirm
Write the file to the target path. Show:
```
🧠 Vault note written: <vault_path>/<subdir>/<filename>
   type: <type>  category: <root_cause_category>  project: <project>
   sanitized: yes
```
If `transport: git` → remind (do not auto-run): `commit + push the vault repo to share it`.

---

## FRONTMATTER SCHEMA (recall contract)

Every emitted note MUST carry these keys (templates already include them):

| Key | Required | Purpose / vocabulary |
|-----|----------|----------------------|
| `type` | yes | `bug` \| `rca` \| `technique` |
| `title` | yes | human title |
| `project` | yes | source project name |
| `date` | yes | YYYY-MM-DD |
| `author` | yes | install-root USER.md Name (fallback `IT Dept`) |
| `language` | yes | `typescript` \| `python` \| `go` \| … |
| `framework` | yes | `react` \| `fastapi` \| `none` \| … |
| `symptom` | bug/rca | one-line observed failure |
| `root_cause_category` | bug/rca | clustering key — e.g. `null-deref`, `race-condition`, `auth-token-expiry`, `off-by-one`, `config-drift`, `n-plus-one`, `cache-staleness` |
| `topic` | technique | `caching` \| `auth` \| `ci-pipeline` \| `deployment` \| … |
| `tags` | yes | array; first tag = `type` |
| `source` | yes | PR / commit / ticket / doc path |

Cross-project queries this enables (Obsidian search / Dataview):
- `root_cause_category: auth-token-expiry` → every auth-expiry bug across all projects
- `type: technique AND topic: caching` → all caching techniques
- `language: go AND type: bug` → Go bug catalogue

---

## VAULT RECALL PROCEDURE (shared — used by `/devstarter-debug`)

When `obsidian.enabled` and `vault_path` is set, before forming hypotheses:
1. Derive 2–4 keywords from the symptom + suspected category.
2. Grep the vault for matches (frontmatter + body):
   ```
   grep -ril "<keyword>" "<vault_path>/<subdir>"
   ```
   Prefer matches on `root_cause_category` and `symptom`.
3. Read the top 1–3 matching notes. Surface them:
   ```
   🔁 Prior knowledge (vault):
     • <title> (<project>, <date>) — category: <root_cause_category>
       → <one-line root cause + whether the same fix may apply>
   ```
4. Treat as a lead, not proof — still gather this project's own evidence (Debug Rule 1).
If nothing matches, say so in one line and continue.

---

## `/devstarter-knowledge` COMMAND FLOW (ad-hoc technique note)

### Step 0 — Preflight
Read `obsidian.enabled`. If OFF → show:
```
Knowledge Vault is off. Enable it in devstarter-config.yml:
  obsidian: { enabled: true, vault_path: "<path>", transport: git, sanitize: true }
See docs/obsidian-vault-guide.md (git vs network setup).
```
and stop.

### Step 1 — Intake (one at a time)
- Q1. Note type? → `technique` (default) | `bug` | `rca`. (For bug/rca, suggest `/devstarter-bug-postmortem` or `/devstarter-postmortem` for the full record; this command is for quick capture.)
- Q2. Title + one-line summary.
- Q3. The content: problem, approach, when-to-use (technique) — or symptom/root-cause/fix (bug).
- Q4. `topic` or `root_cause_category` (offer the vocabulary from the Schema; reuse an existing string when possible).

Inline arg: `/devstarter-knowledge <text>` → use text as Q2/Q3 seed, skip Q1 (default technique).

### Step 2 — Emit
Run the **Vault Emit Procedure** (E1–E5) with the technique template.

### Step 3 — Confirm
Show the write confirmation block (E5). Done — no branch, no PR (this is a knowledge capture, not a code change).

---

## EXAMPLES
```
/devstarter-knowledge use a single Postgres advisory lock to serialize cron jobs across replicas
→ technique note: topic=deployment, language=<stack>, sanitized, written to vault/knowledge/
```
```
(inside /devstarter-debug) symptom "JWT rejected after deploy"
→ recall greps vault, surfaces prior auth-token-expiry note from project "billing-api"
```
