# devstarter-profile.md — Proactive Performance Investigation

## Model: Opus (`claude-opus-4-7`)
> Performance reasoning + tradeoff analysis required — run `/model opus`.

**Config:** Read `devstarter-config.yml` for project settings.

## How to Use

Investigate a performance issue *before* it becomes an incident. Different
from `/devstarter-debug` (correctness bug) and `/devstarter-incident`
(active production crisis).

```
/devstarter-profile                                  → interactive intake
/devstarter-profile checkout-page-slow              → use as area slug
/devstarter-profile memory/apm-trace-2026-05-09.md  → read profile data as context
```

Common triggers:
- APM dashboard shows P95 climbing over a week
- Slow-query alert fires below SEV threshold
- Lighthouse CI drops a route below the perf budget
- Customer reports "feels slow" without a hard error
- Quarterly proactive review of the hottest endpoints

---

## ⚠️ CRITICAL RULES

### Rule 1 — Measure before optimizing
No optimization is allowed before a measured baseline exists. The output
of Phase 2 must be a number (P95 ms, query ms, bundle KB, LCP ms) — not
"feels slow."

### Rule 2 — Identify, then decide
Phase 3 identifies bottlenecks. Phase 4 picks which to fix based on
impact-effort. Skipping Phase 4 leads to "we optimized something
unimportant while the real bottleneck still hurt customers."

### Rule 3 — Verify the fix actually worked
Phase 6 measures the same metric after the fix. If the post-fix number
isn't materially better, the fix is reverted and the analysis loops back
to Phase 3 (the bottleneck wasn't where we thought).

### Rule 4 — No micro-optimization without budget pressure
Optimizing a 10ms hotspot in a P99=2s flow is theatre. The bottleneck
must materially affect the SLO target identified in Phase 1.

### Rule 5 — Investigation only — code changes via /devstarter-change
This runbook produces a roadmap. Implementation is handed off.

---

## FIRST ACTION — Inline Arg Handling

**File arg:** read profile/trace data, pre-fill Phase 0 + Phase 2.
**Plain text:** use as Phase 0 Q1 (area slug).
**No args:** start Phase 0 from Q1.

---

## PHASE 0 — Performance Intake

Use `AskUserQuestion`:

**Q1. What is slow? (free text — area slug)**
e.g. "checkout API endpoint", "/dashboard render", "nightly batch job",
"list-products query"

**Q2. What's the SLO target for this area?**
1. Defined in `docs/api-reference.html` SLO table → use that
2. Defined in `docs/frontend-spec.html` Performance Budget → use that
3. Not defined yet — propose one based on user expectation
4. No SLO needed (offline / batch / dev-only)

**Q3. How is it being measured today?**
1. APM (Datadog / New Relic / Sentry / OpenTelemetry / etc.)
2. Database slow-query log
3. Frontend RUM (Lighthouse CI / Web Vitals / Chrome UX Report)
4. Custom metrics / Prometheus
5. Not measured — only customer reports

**Q4. What's the current measurement?**
(free text — current P50/P95/P99, query time, LCP, etc. with units)

**Q5. What's the trigger for this investigation?**
1. Trend (gradually worsening over weeks)
2. Spike (sudden change)
3. Customer complaint
4. Proactive review (no specific trigger)
5. SLO breach approaching

After collecting answers, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐌 PERF INVESTIGATION — [slug]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area:           [slug]
SLO target:     [from API/frontend spec or proposed]
Current metric: [P95/P99/etc with units]
Gap to SLO:     [+Xms over budget OR within budget but trending]
Trigger:        [trend/spike/complaint/proactive/SLO-pressure]
Measurement:    [APM tool / slow-query / RUM / custom]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If Q3 = "Not measured": **STOP and route** to `/devstarter-monitor` first.
You can't profile what you don't measure. Print:

```
⚠️ Cannot proceed — no measurement in place.
Run /devstarter-monitor to set up APM / slow-query / RUM, then re-run
/devstarter-profile after at least 24h of data has accumulated.
```

---

## PHASE 1 — Establish Baseline

Capture a reproducible baseline measurement:

**For backend / API endpoints:**
- P50 / P95 / P99 latency over the last 7 days (or representative window)
- Throughput (RPS) at the time of the slow measurement
- Error rate during the same window
- Specific operation breakdown (DB time / cache time / external call time / CPU)

**For database queries:**
- Slowest 10 queries by total time (count × per-call duration)
- EXPLAIN ANALYZE output for each
- Index usage and table sizes

**For frontend / browser:**
- LCP / FID / CLS / INP / TTFB on the affected route
- Bundle size for the route entry chunk
- Lighthouse audit scores
- Long-task count in the critical render path

**For batch / background jobs:**
- End-to-end duration over the last 7 runs
- Per-step duration breakdown
- Queue depth / lag at start of run

Save the baseline to:
`docs/perf/[YYYY-MM-DD]-[slug]/00-baseline.md` (or `.html` if other docs in the project use HTML)

---

## PHASE 2 — Profile to Find Bottlenecks

Capture profile data, not just metrics:

| Stack | Tool | Output |
|-------|------|--------|
| Node API | clinic.js / 0x flame graph | flame graph + top hot frames |
| Python | py-spy / cProfile | flame graph or sampled profile |
| Go | pprof CPU + heap | top 10 functions by CPU + alloc |
| Java | async-profiler | flame graph |
| DB | EXPLAIN (ANALYZE, BUFFERS) | query plan with actual times |
| Frontend | Chrome DevTools Performance + Lighthouse | trace + waterfall |
| Mobile | Xcode Instruments / Android Profiler | trace |

For each bottleneck candidate, capture:
- **Location:** file:line / table.column / network call / render path
- **Cost:** measured time (ms) or share of total (%)
- **Frequency:** once per request / per row / per render
- **Total impact:** cost × frequency in the user-visible flow

Save artifacts in `docs/perf/[YYYY-MM-DD]-[slug]/01-profile/` (flame graphs,
EXPLAIN output, screenshots).

---

## PHASE 3 — Bottleneck Inventory

Rank top bottlenecks by total impact. Use this table:

```
| # | Bottleneck | Cost (ms or %) | Frequency | Total impact | Confidence |
|---|------------|----------------|-----------|--------------|------------|
| 1 | products.find() N+1 in CartService | 12ms × 50 calls | Per request | 600ms / 850ms total = 71% | High (EXPLAIN confirms) |
| 2 | image-resize on response path | 200ms | Per request with images | 200ms = 24% | High (flame graph) |
| 3 | JSON serialize of nested user obj | 30ms | Per request | 30ms = 4% | Medium (trace estimate) |
```

**Discipline:** the top 1–2 bottlenecks should account for ≥ 70% of total
cost. If they don't, the profile data is too coarse — go deeper before
proceeding to Phase 4.

---

## PHASE 4 — Optimization Roadmap

For each bottleneck, propose concrete fixes with estimated impact and effort:

```
| ID | Bottleneck | Fix proposal | Estimated impact | Effort | Risk |
|----|------------|--------------|------------------|--------|------|
| F1 | N+1 in CartService | Eager-load products via single IN(..) query (PROC: switch find() → findByIds()) | -550ms (P95: 850 → 300) | M | Low — repository layer change, well-tested |
| F2 | image-resize on path | Move to async worker; serve placeholder + replace on load | -180ms (P95: 300 → 120) | L | Medium — UX shift; coordinate with @uxui |
| F3 | JSON nested user | Use serializer with field allowlist | -25ms | S | Low |
```

Prioritize using **impact / effort**:
- 🟢 **Quick wins** (S effort + High impact): F1
- 🟡 **Worth it** (M-L effort + High impact): F2
- ⚪️ **Maybe later** (any effort + Low impact): F3

Mark each fix:
- **In scope** — fix in next sprint
- **Backlog** — track but defer
- **Reject** — not worth the effort

If F1 alone gets the area within SLO, defer F2 + F3. Don't optimize past
the budget — that's gold-plating.

---

## PHASE 5 — Approval Gate

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ PROFILE INVESTIGATION GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Area:    [slug]
SLO:     [target]
Current: [measurement]   Gap: [amount]

Top bottlenecks (≥ 70% of cost):
  1. [B1] — [cost] — [confidence]
  2. [B2] — [cost] — [confidence]

Recommended fixes:
  ✅ F1 (in scope) — [-Xms / S effort / Low risk]
  ⏸️  F2 (backlog) — [-Yms / L effort / Medium risk]
  ❌ F3 (reject)   — [low impact, not worth effort]

Projected outcome if F1 + F2 ship: [P95 from X to Y, within SLO]

  "approve and implement F1"   → /devstarter-change with profile context
  "approve roadmap, ship later" → save report only
  "revise [notes]"             → re-investigate with different lens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- question: "Profile investigation complete. What next?"
- options: ["approve and implement F1", "approve roadmap, ship later", "revise"]

---

## PHASE 6 — Save Report + Handoff

Save the complete report to:
`docs/perf/[YYYY-MM-DD]-[slug]/report.html` (using standard template).

Include all phases (intake, baseline, profile artifacts referenced,
bottleneck inventory, optimization roadmap, projected outcome).

Update `docs/perf/index.html` with a row:
```
| Date | Area | SLO | Before | After (target) | Status |
| 2026-05-09 | checkout-page-slow | P95 < 500ms | P95 = 850ms | P95 ≤ 300ms (F1+F2) | Roadmap approved |
```

**If "approve and implement F1":**
1. Read `~/.claude/sdlc/devstarter-change.md`
2. Jump to A-PHASE 2 (Impact Analysis) — skip intake
3. Pre-fill from F1: file:line targets, expected impact, effort estimate
4. Announce: `🚀 Launching /devstarter-change with F1 from profile report`

**If "approve roadmap, ship later":**
Print the saved path and remind that fixes ship via /devstarter-change
when prioritized.

---

## PHASE 7 — Verification (post-implementation)

Once a fix has shipped (after `/devstarter-change` completes), re-run
the same measurement from Phase 1 over a representative window
(at least 24h of post-deploy data).

Update the report:
```
| Date | Area | SLO | Before | After (measured) | Verdict |
| 2026-05-09 | checkout-page-slow | P95 < 500ms | P95 = 850ms | P95 = 280ms ✅ | F1 worked; F2 deferred — already within SLO |
```

If post-fix is NOT materially better:
1. Revert the fix (if shipped)
2. Loop back to Phase 3 — the wrong bottleneck was identified
3. Capture deeper profile data
4. Re-issue the roadmap

---

## When to use vs alternatives

- **Use this** when: investigating a *performance* issue proactively or
  before it becomes an incident
- **Use /devstarter-incident** instead when: there's an active production
  crisis (SEV-1/2 from perf degradation)
- **Use /devstarter-debug** instead when: investigating a *correctness*
  bug (wrong output, crash) — not slowness
- **Use /devstarter-monitor** instead when: you don't have measurement
  in place yet (you can't profile what you don't measure)
- **Use /devstarter-audit** instead when: doing a broad project review
  (perf is one slice of many)
