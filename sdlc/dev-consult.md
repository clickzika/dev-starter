# dev-consult.md — Consultation & Solution Advice

## How to Use

Place at `~/.claude/sdlc/dev-consult.md`

Use when you want to **discuss and get advice** without making any changes:
- Architecture decisions
- Technology choices
- Performance strategies
- Bug investigation approach
- Design patterns
- Trade-off analysis

```
/consult ระบบ payment ควรออกแบบยังไง
/consult เลือก Redis vs RabbitMQ สำหรับ job queue
/consult login ช้ามาก จะแก้ยังไงดี
```

---

## CRITICAL RULES

### Rule 1 — READ ONLY, NO CHANGES
- Do NOT create branches
- Do NOT modify any files
- Do NOT create GitHub issues or Notion tasks
- Do NOT write code
- This is **consultation only** — analyze, advise, discuss

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
| Architecture, design patterns | @techlead |
| API, backend logic | @backend |
| UI/UX, frontend | @frontend, @uxui |
| Database, queries, schema | @dba |
| Infrastructure, deploy, CI/CD | @devops |
| Security, auth, vulnerabilities | @security |
| Testing strategy | @qa |
| Mobile app | @mobile |
| Requirements, scope | @ba |
| Timeline, priority | @pm |

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

━━━ NEXT STEPS (if you decide to proceed) ━━━

  → /change [description]     — to implement as a feature
  → /fix [description]        — if this is fixing a bug
  → /[agent] [description]    — to get deeper agent-specific help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 4 — Follow-up Discussion

After delivering advice, the user may:
- Ask follow-up questions → answer within the same consultation (still no code changes)
- Say "ทำเลย" or "implement" → suggest the right command: `/change [description]`
- Say "thanks" or move on → end consultation

---

## EXAMPLES

```
User: /consult ระบบ notification ควรใช้ WebSocket หรือ SSE

AI: [reads @backend agent file + CLAUDE.md]
    [delivers options analysis: WebSocket vs SSE vs Polling]
    [recommends based on project stack and scale]
```

```
User: /consult database query ช้า ตาราง orders มี 2M rows

AI: [reads @dba agent file + docs/database-design.html]
    [analyzes: indexing, query optimization, partitioning, caching]
    [recommends based on current schema]
```

```
User: /consult จะ deploy แบบไหนดี มี 3 services

AI: [reads @devops agent file + CLAUDE.md]
    [options: Docker Compose vs K8s vs serverless]
    [recommends based on team size and budget]
```
