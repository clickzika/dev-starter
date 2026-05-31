---
name: devstarter-knowledge
description: Capture a reusable engineering note — technique, know-how, bug, or root cause — into a shared Obsidian knowledge vault, so it can be reused across projects. Notes are sanitized before write and carry a fixed frontmatter schema for cross-project recall. Trigger on /devstarter-knowledge, "save this to the vault", "capture this technique / know-how", "add this to our knowledge base", or after solving something worth keeping. For full bug/incident records prefer /devstarter-bug-postmortem or /devstarter-postmortem (they also emit to the vault).
---

# /devstarter-knowledge — Knowledge Vault Capture

Capture know-how, techniques, bugs, and root causes as Markdown notes in a shared Obsidian vault. The vault is reusable across every project — a technique or root cause found on one project surfaces on the next (e.g. `/devstarter-debug` greps the vault at session start).

> **Opt-in.** Requires the `obsidian:` block in `devstarter-config.yml` (`enabled: true` + `vault_path`). If off, the command shows how to enable it. See `docs/obsidian-vault-guide.md` and ADR-0002.

> **Security.** Every note is sanitized via `@devstarter-opensource-sanitizer` before write — no secrets, internal URLs, credentials, or customer data reach the shared vault. Mandatory when `transport: network`.

## When to use vs alternatives

- **Use this** for a quick, reusable note: a technique, a gotcha, a pattern, a know-how snippet.
- **Use /devstarter-bug-postmortem** for the full engineering record of a fixed bug (it also emits a vault note).
- **Use /devstarter-postmortem** for a blameless incident RCA (it also emits a vault note).

## Inline Args

```
/devstarter-knowledge                              → interactive (pick type, fill content)
/devstarter-knowledge use advisory locks for cron  → seed a technique note from the text
```

Read `~/.claude/sdlc/devstarter-knowledge.md` and run the command flow (preflight → intake → emit → confirm). That runbook also defines the shared Vault Emit Procedure, Frontmatter Schema, and Recall Procedure used by the postmortem / bug-postmortem / debug skills.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-knowledge` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Capture a reusable engineering note into a shared Obsidian knowledge vault

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow: read `sdlc/devstarter-knowledge.md` from your DevStarter install.

Requires the obsidian: block in devstarter-config.yml (enabled + vault_path).
Sanitize every note before writing it to the vault. Start: state the note or type 'start'.
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
