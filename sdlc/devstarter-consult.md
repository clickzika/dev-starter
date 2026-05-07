# dev-consult.md — Consultation & Solution Advice

## Model: Opus (`claude-opus-4-7`)
> Deep reasoning required — run `/model opus` before this workflow.

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).

## How to Use

Place at `~/.claude/sdlc/devstarter-consult.md`

Use when you want to **discuss and get advice** without making any changes:
- Architecture decisions
- Technology choices
- Performance strategies
- Bug investigation approach
- Design patterns
- Trade-off analysis

```
/devstarter-consult ระบบ payment ควรออกแบบยังไง
/devstarter-consult เลือก Redis vs RabbitMQ สำหรับ job queue
/devstarter-consult login ช้ามาก จะแก้ยังไงดี
```

---

## CRITICAL RULES

### Rule 1 — CONSULT ONLY (no project changes)
- Do NOT create branches
- Do NOT modify **project** files
- Do NOT create GitHub issues or Notion tasks
- Do NOT write code
- One exception: write `memory/consult-[YYYY-MM-DD]-[slug].md` at Step 4 (intake handoff file only)
- This is **consultation only** — analyze, advise, discuss; implement only if user picks "implement now"

### Rule 2 — Read Agent File Before Advising
Before giving advice, read `~/.claude/agents/[agent].md` for the relevant agent(s).
Use their expertise and standards to inform the recommendation.

### Rule 3 — Read Project Context First
Before advising, read from disk:
```
- CLAUDE.md (if exists) — understand project stack + current state
- Relevant docs/ files — understand existing design decisions
```

---

## FLOW

### Step 0 — Enter Plan Mode

Use the `EnterPlanMode` tool immediately before any advice.
This signals to Claude Code that this session is analysis-only — no file edits, no commands.

### Step 1 — Understand the Question

If the user's question is clear enough, skip to Step 2.

Otherwise, ask ONE clarifying question:
```
Before I advise, I need to understand:
[one specific question about context, constraints, or goals]
```

Maximum 1 clarifying question. If still unclear, give best advice with stated assumptions.

---

### Step 2 — Identify Relevant Agents

Based on the topic, identify which agent(s) should advise:

| Topic | Agent(s) |
|-------|----------|
| Architecture, design patterns | @devstarter-techlead |
| API, backend logic | @devstarter-backend |
| UI/UX, frontend | @devstarter-frontend, @devstarter-uxui |
| Database, queries, schema | @devstarter-dba |
| Infrastructure, deploy, CI/CD | @devstarter-devops |
| Security, auth, vulnerabilities | @devstarter-security |
| Testing strategy | @devstarter-qa |
| Mobile app | @devstarter-mobile |
| Requirements, scope | @devstarter-ba |
| Timeline, priority | @devstarter-pm |

Read the relevant agent file(s) before advising.

---

### Step 3 — Deliver Advice

Format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 CONSULTATION: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Advisor: @[agent] (+ @[agent2] if multi-topic)

Context:
  [brief understanding of the current situation]

━━━ RECOMMENDATION ━━━

[clear recommendation in 2-5 sentences]

━━━ OPTIONS ANALYSIS ━━━

Option A: [name]
  ✅ Pros: [list]
  ❌ Cons: [list]
  📦 Effort: [S/M/L]
  🎯 Best when: [scenario]

Option B: [name]
  ✅ Pros: [list]
  ❌ Cons: [list]
  📦 Effort: [S/M/L]
  🎯 Best when: [scenario]

Option C: [name] (if applicable)
  ✅ Pros: [list]
  ❌ Cons: [list]
  📦 Effort: [S/M/L]
  🎯 Best when: [scenario]

━━━ SUGGESTED APPROACH ━━━

👉 Recommended: Option [X]
   Reason: [why this fits best given your project context]

━━━ NEXT STEPS ━━━

  → Step 4 will save this advice and offer to launch /devstarter-change directly
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 4 — Save Consultation

After delivering advice, use `ExitPlanMode` tool to return to normal mode.

Generate the slug from the topic (lowercase, hyphens, max 4 words).
Save the consultation to disk using the template at `~/.claude/templates/intake/devstarter-intake-consult.md`:

```
File: memory/consult-[YYYY-MM-DD]-[slug].md

Fill in:
  - change_type   ← detected from topic (Add/Modify/Fix Bug)
  - feature_name  ← slug
  - date          ← today
  - advisor       ← @agent(s) used
  - Section 1     ← user's original question + change type
  - Section 2     ← situation summary, root cause, affected files from analysis
  - Section 3     ← recommended option, reason, effort, risks
  - Section 4     ← acceptance criteria derived from NEXT STEPS advice
```

Then show the INTAKE SUMMARY block from the template (filled in) and use `AskUserQuestion` with:
- question: "Consultation complete. What would you like to do?"
- options: ["save advice only", "implement now", "ask follow-up"]

---

**If user picks "implement now":**
1. Confirm file is saved to `memory/consult-[YYYY-MM-DD]-[slug].md`
2. Read `~/.claude/sdlc/devstarter-change.md`
3. Jump directly to Impact Analysis — skip all intake questions (file arg already provides context)
4. Announce:
   ```
   🚀 Launching /devstarter-change with consultation context
   📂 Intake: memory/consult-[YYYY-MM-DD]-[slug].md
   ⏭️  Skipping intake — going straight to Impact Analysis
   ```

**If user picks "save advice only":**
Show:
```
💾 Saved: memory/consult-[YYYY-MM-DD]-[slug].md
To implement later: /devstarter-change memory/consult-[YYYY-MM-DD]-[slug].md
```

**If user picks "ask follow-up":**
Re-enter plan mode, answer the question (still no code changes), then loop back to Step 4.

---

## EXAMPLES

```
User: /devstarter-consult ระบบ notification ควรใช้ WebSocket หรือ SSE

AI: [reads @devstarter-backend agent file + CLAUDE.md]
    [delivers options analysis: WebSocket vs SSE vs Polling]
    [recommends based on project stack and scale]
```

```
User: /devstarter-consult database query ช้า ตาราง orders มี 2M rows

AI: [reads @devstarter-dba agent file + docs/database-design.html]
    [analyzes: indexing, query optimization, partitioning, caching]
    [recommends based on current schema]
```

```
User: /devstarter-consult จะ deploy แบบไหนดี มี 3 services

AI: [reads @devstarter-devops agent file + CLAUDE.md]
    [options: Docker Compose vs K8s vs serverless]
    [recommends based on team size and budget]
```
