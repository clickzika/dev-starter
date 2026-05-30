# devstarter-understand-domain.md — Extract Business Domains & Flows

> **TL;DR** — Thin wrapper: verify the Understand-Anything plugin, then delegate to `/understand-domain` · **Lifecycle** Understand · **Gates** 0

## Model: inherit (platform default)

Use for: mapping code to business processes — domains, flows, and steps.

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

Pass all arguments through verbatim:

```
/understand-domain $ARGS
```

A knowledge graph must exist first (run `/devstarter-understand` if not). The plugin's
`domain-analyzer` agent extracts domains, flows, and steps. Nothing further is required
from DevStarter.
