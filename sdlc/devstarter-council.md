# devstarter-council.md — Council Decision Workflow

> **TL;DR** — Four-voice deliberation for ambiguous decisions under uncertainty · **Lifecycle** Decision · **Gates** 1

## Model: Opus (`claude-opus-4-7`)

---

## WHEN TO USE

- Ambiguous architectural decisions with no clear right answer
- Tech selection under real uncertainty (tradeoffs matter)
- Risk assessment for irreversible changes
- Strategy decisions where smart people would disagree

## WHEN NOT TO USE

- Code review (use `/devstarter-review`)
- Implementation planning (use `/devstarter-change`)
- Architecture design (use `/devstarter-consult`)
- Clear-cut decisions with an obvious answer

---

## CRITICAL RULES

- All 4 voices must be heard — do not collapse to consensus early
- Surface strongest dissent even if minority view
- Never dismiss a position without explaining why
- Architect speaks first (to anchor), others respond independently
- Gate 1: show full council output, wait for user decision

---

## THE FOUR VOICES

| Voice | Lens | Questions asked |
|-------|------|----------------|
| **Architect** | Correctness, maintainability, long-term | Will this age well? What does this assume? |
| **Skeptic** | Premise challenge, assumption breaking | Is the question itself right? What if the premise is wrong? |
| **Pragmatist** | Shipping speed, user impact, operations | What ships fastest? What breaks at 3am? |
| **Critic** | Edge cases, downside risk, failure modes | What's the worst case? What are we not seeing? |

---

## FLOW

### Step 1 — Extract Real Question

Restate the decision as a single, precise question.
Strip out noise. Surface hidden assumptions.

Example:
> "Should we use Redis or PostgreSQL for job queues?"
> Real question: "Given our ops maturity and team size, is the operational overhead of Redis worth its throughput advantage over pg-based queues?"

---

### Step 2 — Gather Context

Read only what's needed:
- Current stack: `CLAUDE.md`, `devstarter-config.yml`
- Relevant code: files directly related to the decision
- Constraints: team size, ops maturity, existing infrastructure

Do NOT read the entire codebase.

---

### Step 3 — Architect Position (first, solo)

Architect forms position without seeing other views:
- Core recommendation
- Key assumptions
- Long-term risks

---

### Step 4 — Three Parallel Subagents

Launch Skeptic, Pragmatist, Critic simultaneously (independent — no shared context):

Each subagent receives:
- The real question (Step 1)
- The context gathered (Step 2)
- The Architect's position (Step 3)
- Their role definition (from THE FOUR VOICES table)

Each returns:
- Their position (agree / partially agree / disagree)
- Their strongest argument
- What they think the Architect missed

---

### Step 5 — Synthesis

Compile all 4 positions:
- Where all 4 align: high-confidence signal
- Where 2+ disagree: surface the disagreement explicitly
- Bias check: did any voice dismiss without reasoning?
- Premise check (Skeptic): is the original question still the right question?

---

### Gate 1 — Council Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚖️  COUNCIL VERDICT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Question: [restated real question]

🏛️  Architect:    [position + key assumption]
🔍  Skeptic:      [challenge or premise reframe]
🚀  Pragmatist:   [shipping/ops angle]
⚠️   Critic:       [downside / failure mode]

Consensus: [what all voices agree on, if anything]
Dissent:   [strongest minority view — do not suppress]
Premise:   [is the question itself right? per Skeptic]

Recommendation: [synthesis — note confidence level]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- question: "Council complete. What's your call?"
- options:
  - "Go with Recommendation — proceed"
  - "Skeptic was right — reframe the question"
  - "Pragmatist wins — ship the fast path"
  - "Need more information first"

---

### Step 6 — Save to Memory (optional)

If user approves, save decision + reasoning to `memory/council-[date]-[topic].md`.
Format matches `/devstarter-consult` output so `/devstarter-change` can consume it.
