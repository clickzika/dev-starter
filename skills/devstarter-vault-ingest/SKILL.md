---
name: devstarter-vault-ingest
description: Analyze any existing Markdown file, auto-classify it (bug / technique / rca / project-snapshot), propose frontmatter, discover related vault notes, and emit with auto-generated wikilinks. Trigger on /devstarter-vault-ingest, "analyze this file and add to vault", "ingest this note into obsidian", or "classify this markdown". Use --scaffold to create the hierarchical folder structure without ingesting a file.
---

# /devstarter-vault-ingest — Analyze & Emit Existing Markdown to Vault

Reads any `.md` or `.html`/`.htm` file, auto-classifies it, proposes frontmatter, discovers related notes in the vault via tag/language/category grep, and emits a sanitized, wikilinked note to the correct vault folder — all confirmed at a gate before writing. HTML files are preprocessed to clean Markdown (Step I1b) before classification.

> **Opt-in.** Requires `obsidian.enabled: true` + `vault_path` in `devstarter-config.yml`. If off, shows setup instructions. See `docs/obsidian-vault-guide.md` Section 7.

> **Security.** Sanitize procedure E4 runs before every write — no secrets, internal URLs, credentials, or customer data reach the vault.

## When to use vs alternatives

- **Use this** to ingest an *existing* Markdown or HTML file (meeting notes, personal notes, external docs, DevStarter-generated feature docs).
- **Use /devstarter-knowledge** for capturing a new technique or know-how snippet interactively.
- **Use /devstarter-bug-postmortem** for a full bug record after a fix (emits to vault automatically).
- **Use /devstarter-vault-ingest --scaffold** to create the hierarchical folder structure only.

## Inline Args

```
/devstarter-vault-ingest path/to/note.md       ← analyze + emit a .md file
/devstarter-vault-ingest path/to/doc.html      ← extract + emit an HTML file (preprocessed to MD)
/devstarter-vault-ingest --scaffold            ← create folder structure only (no file)
```

## Model Gate

This skill runs on the session model (Sonnet). No Opus gate required — classification and grep are within Sonnet's capabilities. If analysis is ambiguous, an AskUserQuestion picker resolves it before proceeding.

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-vault-ingest` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Analyze an existing Markdown file and emit it to the Obsidian knowledge vault

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-vault-ingest.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: provide the file path or type '--scaffold' to create folder structure only.
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.

---

Read `~/.claude/sdlc/devstarter-vault-ingest.md` and execute the workflow.
