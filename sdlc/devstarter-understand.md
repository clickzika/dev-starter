# devstarter-understand.md — Analyze Codebase → Knowledge Graph

> **TL;DR** — Thin wrapper: verify the Understand-Anything plugin, then delegate to `/understand` · **Lifecycle** Understand · **Gates** 0

## Model: inherit (platform default)

Use for: scanning a project into a knowledge graph of files, functions, classes, and dependencies.

---

**This is a delegating wrapper.** DevStarter does not re-implement codebase analysis —
it forwards to the **Understand-Anything** plugin, which installs alongside DevStarter
in the same `~/.claude/` home. See `docs/adr/0001-understand-anything-integration.html`
for the integration decision.

---

## PHASE 1 — UA Plugin Preflight (mandatory)

Before delegating, confirm the Understand-Anything plugin is installed.

1. Check for the plugin cache directory:
   ```bash
   ls ~/.claude/plugins/cache/understand-anything/ 2>/dev/null
   ```
   (Windows: `%USERPROFILE%\.claude\plugins\cache\understand-anything\`)
2. **If present** → proceed to PHASE 2.
3. **If missing** → ⛔ GATE: show the install prompt and STOP. Do not delegate.

   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⛔ Understand-Anything plugin not installed
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   /devstarter-understand delegates to the Understand-Anything plugin.
   Install it once, then re-run:

     /plugin marketplace add Lum1104/Understand-Anything
     /plugin install understand-anything

   Then run /devstarter-understand again.
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

   Use `AskUserQuestion`:
   - question: "Understand-Anything is required. Install it now?"
   - options: ["I've installed it — retry", "Stop here"]

   On "retry" → re-run PHASE 1. On "Stop here" → end.

---

## PHASE 2 — Delegate

Pass all user arguments through verbatim to the plugin command:

```
/understand $ARGS
```

Arguments supported by `/understand` (forwarded unchanged):
- `[path]` — scope analysis to a subdirectory
- `--language <code>` — localized graph + dashboard (en/zh/zh-TW/ja/ko/ru)
- `--auto-update` — install a post-commit hook to keep the graph fresh
- `--full` / `--review` — full re-analysis / full LLM graph review

The graph is written to `.understand-anything/knowledge-graph.json`. `/understand`
auto-triggers the dashboard on completion. Nothing further is required from DevStarter.
