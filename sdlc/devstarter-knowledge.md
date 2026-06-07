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

### Rule 2 — Redact before write (SECURITY — no exceptions)
Before any note is written, the emit step itself **scrubs it inline** against the secret / PII / internal-infra deny-list (Step E4) — the redaction is performed by this skill, not delegated. `@devstarter-opensource-sanitizer` is the source of the pattern set and the optional post-write *verifier* (it scans and FAILs on any remaining secret); it does not do the inline stripping. If `obsidian.sanitize` is `false` AND `obsidian.transport` is `network` → **refuse to write** and tell the user why (a public share must not receive raw notes).

### Rule 3 — One note per file, unique name (network-safe)
Never edit an existing shared note. Always write a new, uniquely-named file. This avoids concurrent-write corruption on a network share.

### Rule 4 — Frontmatter schema is mandatory
Recall only works if every note carries the schema below. A note without it is a write-only dead end — fill every required key.

---

## VAULT EMIT PROCEDURE (shared — referenced by other skills)

### Step E1 — Resolve target path
1. Read `obsidian.vault_path`, `obsidian.subdir`, `obsidian.transport`, `obsidian.folder_structure` from `devstarter-config.yml`.
2. If `vault_path` is empty → emit is not configured; tell the user to set it (see `docs/obsidian-vault-guide.md`) and skip.
3. Resolve target dir by `folder_structure`:
   - `flat` (default): Target dir = `<vault_path>/<subdir>/`
   - `hierarchical`: Target dir = `<vault_path>/<subdir>/<type-folder>/` where type-folder is:
     | `type` frontmatter | Folder |
     |---|---|
     | `bug-note` | `bugs/` |
     | `technique` | `techniques/` |
     | `rca` | `rcas/` |
     | `project-snapshot` | `snapshots/` |
   Create the folder if missing.
4. Filename = `<YYYY-MM-DD>-<project-slug>-<note-slug>.md` (lowercase, hyphenated, unique — append `-2`, `-3` on collision). This satisfies Rule 3.

### Step E2 — Pick template
| Source | Template |
|--------|----------|
| `/devstarter-bug-postmortem` | `~/.claude/templates/obsidian/bug-note.md` |
| `/devstarter-postmortem` (incident) | `~/.claude/templates/obsidian/rca-note.md` |
| `/devstarter-knowledge` (technique) | `~/.claude/templates/obsidian/technique-note.md` |

### Step E3 — Fill placeholders
Fill every `{{PLACEHOLDER}}` from the source content. `{{AUTHOR}}` = Name from install-root `~/.claude/USER.md` Identity section (fallback `IT Dept`) — never an agent alias. `{{PROJECT}}` = `project.name` from `devstarter-config.yml`. `{{DATE}}` = today. Resolve `language` / `framework` from `stack` in config. Choose `root_cause_category` from the recall vocabulary (see Schema below) — reuse an existing category string when one fits, so notes cluster.

### Step E4 — Redact inline (Rule 2)
Scan the filled note text against the deny-list below (the pattern set documented by `@devstarter-opensource-sanitizer`) and redact in place **before** writing:

| Class | Patterns (redact the match, keep context) |
|-------|-------------------------------------------|
| Secrets | `sk-[A-Za-z0-9]{20,}`, `ghp_[A-Za-z0-9]{36}`, `AKIA[A-Z0-9]{16}`, JWT `eyJ[A-Za-z0-9_-]{10,}`, private keys `-----BEGIN ... PRIVATE KEY-----`, conn strings `(postgresql\|mysql\|mongodb)://[^@]+@`, generic `(password\|secret\|token\|key)\s*=\s*['"][^'"]{8,}` |
| PII | corporate-domain emails, employee names, internal ticket/employee IDs |
| Internal infra | hostnames `.internal`/`.corp`/`.local`, private IPs `10.` `192.168.` `172.(16–31).`, internal service URLs |
| Other | unpatched-vulnerability detail that would aid an attacker |

For each match: replace the sensitive value with `[REDACTED]` while keeping the surrounding context readable (e.g. `Authorization: Bearer [REDACTED]`). If a match cannot be redacted without destroying the note's meaning → **stop, show the user, do not write**. After redacting, you MAY run `@devstarter-opensource-sanitizer` over the target dir to verify clean (it FAILs on any remaining secret). When `transport: network`, this step is mandatory — a note that still trips the deny-list must not be written.

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
