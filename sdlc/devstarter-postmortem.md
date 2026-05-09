# devstarter-postmortem.md — Blameless Incident Post-Mortem

## Model: Opus (`claude-opus-4-7`)
> Deep narrative + causal reasoning required — run `/model opus` before this workflow.

**Config:** Read `devstarter-config.yml` for all project settings.

## How to Use

Run AFTER a SEV-1 / SEV-2 incident has been declared resolved. This workflow
is intentionally separate from sprint retro (`/devstarter-retro`) because
post-mortems require a different lens: timeline reconstruction, causal
analysis, and concrete prevention actions — not "what went well."

```
/devstarter-postmortem                                  → interactive intake
/devstarter-postmortem checkout-down 2026-05-09         → name + date inline
/devstarter-postmortem memory/incident-2026-05-09.md   → read incident notes as context
```

---

## ⚠️ CRITICAL RULES

### Rule 1 — Blameless
The output must never name a person as the cause. Causes are systems,
defaults, missing checks, and mental models — not individuals. If a person
made a mistake, the question is "what made the mistake easy to make?"

### Rule 2 — Truth Before Comfort
The post-mortem records what actually happened, including embarrassing or
inconvenient details (e.g., "monitoring was off because nobody renewed
the trial license"). Sanitized post-mortems prevent learning.

### Rule 3 — Every Action Item Has a Real Owner + Date
"Improve monitoring" with no owner is theatre. Every prevention action
must be: owned by a named person, dated by deadline, sized to fit in
≤ 2 sprints, and tracked as a real ticket (GitHub issue or Notion task).

### Rule 4 — Output Is a Living Doc
The post-mortem document is updated when action items complete. The
"Prevention" section gets a date next to each item when it ships.

### Rule 5 — Consult/Investigate Only — No Code Changes
This runbook produces a doc + action items. Implementation happens via
`/devstarter-change` with the post-mortem file as intake.

---

## FIRST ACTION — Inline Arg Handling

**File path arg:** read the file, extract incident details, pre-fill Phase 0.
**Plain text arg:** use as Phase 0 Q1 (incident name).
**No args:** start Phase 0 from Q1.

---

## PHASE 0 — Incident Intake

Use `AskUserQuestion` for each. Collect:

**Q1. What is the incident name (slug)?**
(free text — short identifier; e.g. "checkout-down", "auth-cascade")

**Q2. What was the severity?**
1. SEV-1 — full outage / data loss / safety incident
2. SEV-2 — major feature broken for many users
3. SEV-3 — partial degradation
4. Near-miss — caught before customer impact

**Q3. When did it start and end? (UTC)**
(free text — start datetime, detection datetime, mitigation datetime, resolution datetime)

**Q4. What was the customer impact?**
(free text — number of users affected, duration of impact, financial impact if known, contractual SLA breached?)

**Q5. Was this a repeat or related to a prior incident?**
1. Yes — and we have a prior post-mortem
2. Yes — but we never wrote one up
3. No — first time we've seen this

After collecting answers, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 INCIDENT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:         [slug]
Severity:     [SEV-N]
Started:      [UTC datetime]    Detected:  [UTC datetime + delta]
Mitigated:    [UTC datetime]    Resolved:  [UTC datetime]
Total impact duration: [hh:mm]
Customers affected:    [number / scope]
Repeat?:      [yes/no — link to prior PM if yes]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 1 — Timeline Reconstruction

Build the timeline from raw evidence (chat logs, alert history, deploy
logs, code diffs). Do NOT rely on memory.

**Sources to ingest** (whichever the project has):
- Slack/LINE/Discord channels around the incident window
- PagerDuty / Opsgenie alert history
- GitHub Actions / GitLab CI run history
- Deploy log (which versions were live before/after)
- APM dashboard screenshots / log queries
- Support tickets opened during the window

**Output: chronological timeline table:**
```
| UTC time | Actor | Action / Event |
|----------|-------|----------------|
| 14:02 | system | deploy-prod started (v3.4.0 → v3.4.1) |
| 14:08 | system | deploy-prod completed |
| 14:12 | alert | LCP > 5s alert fires for /checkout |
| 14:14 | engineer | acknowledges alert |
| 14:18 | engineer | identifies new image-resize lib in v3.4.1 |
| 14:22 | engineer | initiates rollback to v3.4.0 |
| 14:27 | system | rollback completes; LCP returns to baseline |
| 14:30 | engineer | declares mitigated |
| 15:00 | engineer | declares resolved (no recurrence in 30 min) |
```

Use **actor** = "system" / "alert" / "engineer" / "customer" — never names.

After timeline is built, show it and ask:
- "Are there any gaps you can't account for?" (often points to monitoring blind spots)
- "What would have made the timeline shorter at each step?"

---

## PHASE 2 — Causal Analysis (5 Whys)

Apply 5 Whys to the immediate trigger. Output the chain:

```
Trigger: customer-facing LCP > 5s on /checkout

Why?
→ The image-resize library introduced in v3.4.1 was synchronous on the
  request path.

Why was it on the request path?
→ The new "responsive product image" feature called the lib in the
  controller, not in a worker.

Why didn't anyone catch that in review?
→ The PR didn't have an explicit performance section; the reviewer
  focused on correctness.

Why doesn't review require a performance section?
→ The PR template has no performance checklist; the agent's review
  template doesn't enforce one for changes touching request handlers.

Why doesn't the agent enforce one?
→ The "request handler" file pattern isn't tagged as performance-
  sensitive in any tooling.

ROOT CAUSE: We have no automated signal that a code change touches
the request hot path. Reviews depend on individual reviewer attention
to spot it.
```

Push past the first plausible "why" — most teams stop at #2 ("the dev
should have caught it") which is blameful and useless.

---

## PHASE 3 — Contributing Factors

Beyond the linear cause chain, list contributing factors across categories.
Most incidents are *multi-factor* — a single root cause is rare.

```
TECHNICAL:
- [ ] Codepath / library / dep involved
- [ ] Configuration / feature flag state
- [ ] Infrastructure / network / capacity issues
- [ ] Data / migration / schema-related triggers

PROCESS:
- [ ] Review / approval gates that didn't catch it
- [ ] Deploy procedure / rollout strategy
- [ ] On-call / escalation path
- [ ] Communication during incident

OBSERVABILITY:
- [ ] Missing alerts (would have caught earlier)
- [ ] Misleading alerts (false positives that desensitized)
- [ ] Log / trace gaps that slowed diagnosis

ORGANIZATIONAL:
- [ ] Knowledge concentration (only one person knew X)
- [ ] Documentation gaps
- [ ] Time pressure / on-call fatigue
- [ ] Tool / vendor dependency
```

Mark each row Yes / No / N/A with one sentence of evidence.

---

## PHASE 4 — Customer & Communications Review

```
- What did customers see? (error messages, blank pages, wrong data, slow loads)
- When did we tell them? (status page update times, support ticket responses)
- What did we tell them? (full transparency vs vague vs nothing)
- Did we offer remediation? (credit, retry, manual fix)
- What's the long-term trust impact? (publicly visible, contractually binding)
```

If communication was poor, that becomes its own action item — even if
the technical fix is solid.

---

## PHASE 5 — Action Items (with owners + dates)

For each Contributing Factor marked Yes, propose ≥ 1 prevention action.
Every action item is:
- Owned by a named person (resolved later by the PM)
- Sized: S (≤ 2h) / M (≤ 1 day) / L (≤ 1 sprint) / XL (multi-sprint)
- Dated: target completion date
- Prioritized: P0 (next sprint mandatory) / P1 (within 2 sprints) / P2 (backlog)

```
| ID | Action | Owner | Size | Priority | Target | Status |
|----|--------|-------|------|----------|--------|--------|
| A1 | Add 'performance-sensitive' label to request-handler files; enforce perf section in PR template | @techlead | M | P0 | 2026-05-23 | open |
| A2 | Add APM alert: image-render time > 200ms on hot path | @devops | S | P0 | 2026-05-16 | open |
| A3 | Document image-pipeline architecture in docs/api-reference.html | @backend | S | P1 | 2026-06-06 | open |
| A4 | Status page integration with on-call paging | @devops | L | P1 | 2026-06-13 | open |
```

**Discipline:** if an action has no owner or no date, it does NOT go in
the table. Park it in "Open Questions" instead — vague actions guarantee
the next post-mortem will have the same root cause.

---

## PHASE 6 — Save the Document

Save the complete post-mortem to:
`docs/postmortems/[YYYY-MM-DD]-[slug].html`

Use the standard `~/.claude/templates/docs/document-template.html` layout.
Include all 5 phases + Customer & Communications + Action Items table.

Add a row to `docs/postmortems/index.html` (create if missing) with:
- Date | Slug | Severity | Action items P0 count (open / total) | Link

---

## PHASE 7 — Blameless Review Gate

Before sharing, run the blameless review check:

```
BLAMELESS REVIEW CHECKLIST
[ ] No person named as the cause anywhere in the doc
[ ] All "actor" entries in timeline are role-based (engineer, system, alert, customer)
[ ] Causes attributed to systems, gates, defaults — not human "should have"
[ ] Action items target systems/process/tooling, not "be more careful"
[ ] Truth-before-comfort: includes inconvenient findings, not just sanitized ones
[ ] Every Contributing Factor marked Yes has ≥ 1 corresponding action item
[ ] Every action item has owner + size + priority + target date
```

Use `AskUserQuestion`:
- question: "Post-mortem complete. Approve to publish + create action item tickets?"
- options: ["approve and create tickets", "revise [notes]", "save as draft only"]

⛔ GATE — wait for approval before creating tickets or marking the
incident "post-mortem complete."

---

## PHASE 8 — Create Action Item Tickets

After approval:

For each action item, create a tracking ticket via the project's PM tool
(read `pm.type` from `devstarter-config.yml`):

- **github-issues / github+notion:** PROC-GH-05 with label `post-mortem-action`
  and milestone matching priority (P0 → next-sprint milestone)
- **notion:** PROC-NT-03 with property `Post-mortem ID = [slug]`
- **jira:** PROC-JR-08 with epic = "post-mortem-actions" and sprint set per priority
- **none:** skip; print the action items as a markdown checklist for the user
  to track manually

Update the Action Items table in `docs/postmortems/[date]-[slug].html`
with each ticket URL. Show:

```
✅ Post-mortem published: docs/postmortems/[date]-[slug].html
✅ [N] action item tickets created
   P0: [N] tickets, target [date range]
   P1: [N] tickets, target [date range]
   P2: [N] tickets, target [date range]
```

---

## PHASE 9 — Handoff

Use `AskUserQuestion`:
- question: "Action items created. What next?"
- options:
  - "implement P0 actions now" → /devstarter-change with the post-mortem
    file as intake; pick a P0 action item to start with
  - "share with team for review" → print the doc URL + action item URLs
  - "schedule follow-up" → suggest a date 30 days out to review action
    item completion (the "did we actually do it?" check)

---

## When to use vs alternatives

- **Use this** when: a SEV-1 / SEV-2 incident or near-miss has been resolved
- **Use /devstarter-incident** instead when: an incident is ACTIVE — that's
  response, not retrospective
- **Use /devstarter-retro** instead when: closing a sprint (different lens —
  what worked vs what hurt; not causal analysis)
- **Use /devstarter-debug** instead when: investigating a non-incident bug
  (no production impact, no customer-facing event)

---

## Appendix — When to skip the post-mortem

Run a post-mortem for: SEV-1, SEV-2, repeat SEV-3 (same root cause within
90 days), and any near-miss that revealed a critical gap. Skip for: one-
off SEV-3 with obvious cause, planned maintenance with no surprise, or
routine deploy hiccups already captured in fitness-functions failures.

The cost of running a post-mortem when you didn't need one is one hour;
the cost of NOT running one when you should have is the next incident.
