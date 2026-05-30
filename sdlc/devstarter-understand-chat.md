# devstarter-understand-chat.md — Ask Questions About the Codebase

> **TL;DR** — Thin wrapper: verify the Understand-Anything plugin, then delegate to `/understand-chat` · **Lifecycle** Understand · **Gates** 0

## Model: inherit (platform default)

Use for: natural-language questions about the project, answered from the knowledge graph.

---

**This is a delegating wrapper.** Forwards to the **Understand-Anything** plugin.
See `docs/adr/0001-understand-anything-integration.html`.

---

## PHASE 1 — UA Plugin Preflight (mandatory)

1. Check for the plugin cache directory:
   ```bash
   ls ~/.claude/plugins/cache/understand-anything/ 2>/dev/null
   ```
   (Windows: `%USERPROFILE%\.claude\plugins\cache\understand-anything\`)
2. **If present** → proceed to PHASE 2.
3. **If missing** → ⛔ GATE: show install prompt and STOP.

   ```
   ⛔ Understand-Anything plugin not installed.
   Install once, then re-run:
     /plugin marketplace add Lum1104/Understand-Anything
     /plugin install understand-anything
   ```

   Use `AskUserQuestion`:
   - question: "Understand-Anything is required. Install it now?"
   - options: ["I've installed it — retry", "Stop here"]

   On "retry" → re-run PHASE 1. On "Stop here" → end.

---

## PHASE 2 — Delegate

A knowledge graph must exist first (run `/devstarter-understand` if not).

**Invocation mechanism (important).** A slash command is a user-side CLI expansion —
the model cannot "type" it. Invoke the plugin command with the **Skill tool**,
forwarding the user's question verbatim:

- Skill name: `understand-anything:understand-chat` (plugin-namespaced form).
- If not found in the available-skills list, the plugin is not registered for this
  session — confirm the exact registered name against the live install (user-facing
  command: `/understand-chat`); a Claude Code restart after `/plugin install` is
  usually required.
- Forward the user's question text unchanged.

The plugin answers using the graph. Nothing further is required from DevStarter.
