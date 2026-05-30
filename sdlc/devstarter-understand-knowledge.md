# devstarter-understand-knowledge.md — Analyze an LLM Wiki Knowledge Base

> **TL;DR** — Thin wrapper: verify the Understand-Anything plugin, then delegate to `/understand-knowledge` · **Lifecycle** Understand · **Gates** 0

## Model: inherit (platform default)

Use for: turning a Karpathy-pattern LLM wiki into a force-directed knowledge graph.

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

Pass the wiki path through verbatim:

```
/understand-knowledge $ARGS
```

If no path is given, ask the user for the wiki directory (must contain an `index.md`
with wikilinks/categories), then forward it. The plugin's `article-analyzer` extracts
entities, claims, and implicit relationships. Nothing further is required from DevStarter.
