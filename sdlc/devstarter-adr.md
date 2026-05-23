# devstarter-adr.md — Architecture Decision Record (Standalone)

> **TL;DR** — Capture an Architecture Decision Record outside of a feature change · **Lifecycle** Design · **Gates** 1

## Model: Opus (`claude-opus-4-7`)
> Trade-off analysis + long-term thinking required — run `/model opus`.

**Config:** Read `devstarter-config.yml` for project settings.

## When to Use

Capture an architecture decision **outside** of a feature change. For
ADRs created *during* a feature change, that's already enforced via
`/devstarter-change` Gate A2 (v3.6.0). Use this command when:

- You're picking a tech stack / library / framework before any feature
- You need to record a process or infra decision (e.g., "switch from npm
  to pnpm")
- A historic decision is causing pain and you want to document the
  current direction (and possibly supersede the prior one)
- You're evaluating an option without committing yet (status = Proposed)

```
/devstarter-adr                                → interactive intake
/devstarter-adr "switch from MongoDB to Postgres"   → use as decision title
/devstarter-adr memory/consult-2026-05-09.md  → read consult file as context
```

---

## ⚠️ CRITICAL RULES

### Rule 1 — Use the TechLead ADR template
The template already exists in `~/.claude/agents/devstarter-techlead.md`
(ADR section). Do NOT invent a new format. Copy and fill.

### Rule 2 — ≥ 3 options considered
A decision with one option is a story, not an ADR. List at least 3 real
alternatives (status quo, the recommended option, and at least one other
viable choice). For each: concrete pros / cons / cost / fit-for-context.

### Rule 3 — Forces before recommendation
The "Context & Forces" section comes BEFORE the recommendation. Forces
are: constraints, regulations, team skills, runtime requirements,
existing tooling, budget. The decision must follow from the forces.

### Rule 4 — Record consequences honestly
Every decision creates downstream effects — positive AND negative. The
"Consequences" section names both. "There are no negatives" is a sign
the analysis is incomplete.

### Rule 5 — Do not silently supersede prior ADRs
If this ADR contradicts a prior one, mark the prior one Superseded with
a link to this one (and vice-versa). Future maintainers must be able to
see the chain.

---

## FIRST ACTION — Inline Arg Handling

**File arg:** read the file, extract context + decision question, pre-fill Phase 0.
**Plain text arg:** use as Phase 0 Q1 (decision title).
**No args:** start Phase 0 from Q1.

---

## PHASE 0 — Decision Intake

Use `AskUserQuestion`:

**Q1. What is the decision question?**
(free text — must be specific; e.g. "Which message queue: Redis Streams,
RabbitMQ, or Kafka?" — not "What infra should we use?")

**Q2. What is the scope?**
1. Single team / single service
2. Multiple services in this project
3. Org-wide / cross-project standard

**Q3. What's driving this now?**
1. New project / first major decision
2. Painful prior decision — superseding an existing ADR
3. New requirement / scale / regulation
4. Library / vendor end-of-life forcing a choice
5. Strategic shift unrelated to immediate pain

**Q4. Any prior ADR(s) related?**
1. Yes — list paths
2. No
3. Unknown — search for me

If Q4 = 3, grep `docs/adr/` for related keywords from Q1 and propose any
matches. If a contradicting ADR exists, flag it for explicit supersede
treatment in Phase 5.

---

## PHASE 1 — Context & Forces

Articulate the situation BEFORE proposing options. Output:

```
CONTEXT
Where we are now. What changed. Who's affected. What's in scope.
(2-4 paragraphs — concrete, not generic)

FORCES (constraints + requirements that shape the decision)
| Force | Description | Direction |
|-------|-------------|-----------|
| Functional | What it must do | E.g., "≥ 100k msgs/sec sustained" |
| Non-functional | Reliability / latency / cost | E.g., "P99 < 50ms; < $500/mo at expected load" |
| Operational | Who runs it | E.g., "no full-time SRE — must be managed service" |
| Skill | Team familiarity | E.g., "team knows Postgres; nobody knows Cassandra" |
| Regulatory | Compliance | E.g., "data must stay in EU region" |
| Strategic | Direction | E.g., "company-wide move toward serverless" |
| Existing | What's already in place | E.g., "Redis already in stack for cache" |
```

Forces should be unambiguous and ranked by importance. The decision in
Phase 3 must address the top forces — if the recommended option fails on
a top-3 force, that's a red flag.

---

## PHASE 2 — Options (≥ 3)

For each option, fill the same shape:

```
OPTION A — [name]
Summary: [1 sentence — what it is]
Pros: [3-5 concrete bullets]
Cons: [3-5 concrete bullets]
Cost: [$/mo or one-off; back-of-envelope is fine]
Operational fit: [who runs it; on-call burden]
Risk: [what's the worst-case failure mode]
References: [docs / benchmarks / case studies]
```

Always include "Status Quo / Do Nothing" as one option, even if obviously
inferior — it surfaces the *cost* of changing vs the *benefit*.

If the user can only think of 1–2 options, propose a third yourself based
on the Forces table. Often the third option turns out to be the right one
because it forces explicit comparison.

---

## PHASE 3 — Recommendation

```
RECOMMENDATION: Option [X] — [name]

WHY (referencing Forces from Phase 1):
- This option satisfies forces: [list top forces it addresses]
- It accepts trade-offs on: [list lesser forces it sacrifices]
- It's superior to Option [Y] because: [1-2 sentences]
- It's superior to Option [Z] because: [1-2 sentences]

CONFIDENCE: High / Medium / Low
WHAT WOULD CHANGE THE RECOMMENDATION:
- [scenario 1 that would flip to a different option]
- [scenario 2]
```

If confidence is Low, the ADR status should be **Proposed**, not Accepted —
schedule a revisit.

---

## PHASE 4 — Consequences

Honest accounting of downstream effects:

```
POSITIVE CONSEQUENCES (what this enables / improves)
- [bullet — concrete]
- [bullet]

NEGATIVE CONSEQUENCES (what this costs / forecloses / makes harder)
- [bullet — concrete]
- [bullet]

ONES WE'LL NEED TO REVISIT (assumptions that may not hold)
- [bullet] — revisit when [trigger event or date]
- [bullet] — revisit when [trigger event or date]
```

If the negative list is empty, the analysis is incomplete. Push back and
list at least 2 honest negatives.

---

## PHASE 5 — Supersedes / Related

Search `docs/adr/` for ADRs that touch the same topic. For each match:

- **Supersedes:** if the new ADR replaces a prior decision, mark the
  prior one Superseded by [this ADR ID] in its header AND link forward
  in this ADR's header.
- **Related:** if the new ADR coexists with prior decisions (different
  scope but same topic), link both ways without supersede.
- **Conflicts:** if the new ADR contradicts an Accepted prior ADR
  without explicit supersede — STOP and flag. Either supersede explicitly
  or revise this ADR to coexist.

---

## PHASE 6 — Generate ADR Number + Slug

ADR ID is sequential 4-digit zero-padded:
- Read `docs/adr/` and find the highest existing NNNN
- New ID = max + 1 (or 0001 if none exist)

Slug is short (max 5 words, lowercase, hyphens): `0042-message-queue-choice`.

---

## PHASE 7 — Save the ADR

Save to: `docs/adr/[NNNN]-[slug].html`

Use the **TechLead ADR template** from `~/.claude/agents/devstarter-techlead.md`
(ADR section). The template has the correct HTML/CSS layout matching the
project's other docs.

Required header metadata:
```
ID:        [NNNN]
Title:     [decision question]
Status:    Proposed | Accepted | Deprecated | Superseded by [ID]
Date:      [YYYY-MM-DD]
Deciders:  [@<alias> list]
Scope:     [single team / multiple services / org-wide]
Supersedes: [list of ADR IDs or "none"]
Superseded by: [ID or "—"]
Tags:      [domain tags — auth, data, infra, perf, etc.]
```

Then sections: Context & Forces, Options, Recommendation, Consequences,
Related, Revision History.

If `docs/adr/index.html` does not exist, create it. Append a row:

```
| ID | Title | Status | Date | Deciders | Tags |
| 0042 | Message queue: Redis Streams vs RabbitMQ vs Kafka | Accepted | 2026-05-09 | @techlead, @backend | infra, async |
```

---

## PHASE 8 — Approval Gate

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ ADR APPROVAL GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:    [NNNN]
Title: [title]
Status: [Proposed | Accepted]

Recommendation: Option [X] — [name]
Confidence: [High / Medium / Low]
Supersedes: [list or "none"]

  "approve as Accepted"  → status = Accepted, commit ADR
  "approve as Proposed"  → status = Proposed (revisit later), commit ADR
  "revise [notes]"       → adjust before committing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- question: "ADR ready. How do you want to record it?"
- options: ["approve as Accepted", "approve as Proposed", "revise"]

If "revise [notes]": apply notes, regenerate, return to gate.

After approval: commit the ADR file (and superseded files if any) on a
branch — Branch Guard says no edits on develop. Create
`feature/adr-[NNNN]-[slug]` if not already on a non-protected branch.

---

## PHASE 9 — Handoff

After commit, use `AskUserQuestion`:
- question: "ADR [NNNN] recorded. What next?"
- options:
  - "implement the decision now" → /devstarter-change to implement
  - "share + schedule revisit" → for Proposed ADRs, set a calendar
    reminder or task for the revisit trigger from Phase 4
  - "done" → close out

---

## When to use vs alternatives

- **Use this** when: capturing a decision *outside* a feature change
  (tech-stack pick, infra move, process change, library evaluation)
- **Use /devstarter-change** instead when: the decision is *part of* a
  feature change — Gate A2 already enforces ADR for non-trivial features
  (auth, multi-tenancy, schema, caching, payments, billing, external integrations)
- **Use /devstarter-consult** instead when: you want options + tradeoffs
  but aren't ready to commit to a decision yet (consult feeds into ADR)
- **Use /devstarter-audit** instead when: reviewing whether existing
  decisions are still appropriate (audit may surface ADRs that need
  superseding)
