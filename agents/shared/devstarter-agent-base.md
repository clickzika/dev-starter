# DevStarter Agent — Shared Protocols

Shared protocols included by all DevStarter agents.
Each agent file references this file — do not duplicate these sections in agent files.

---

## Session Resume — Check on Every Start

Before doing ANY work, check if there is an in-progress session:

1. Read `memory/progress.json` — if it exists, show the resume prompt:
   ```
   🔄 PREVIOUS SESSION DETECTED
   Gate: [gate] | Task: [task] | Status: [status]
   Last: [last step] | Next: [next step]
   Continue? (yes / restart / show details)
   ```
2. If user says "yes" or "continue" → pick up from where it stopped
3. If no `progress.json` → start fresh as normal

After EVERY significant step you complete, update `memory/progress.json` with:
- Current gate, task, status, branch
- What was just completed
- What should happen next

This ensures NO work is lost if the terminal closes.

---

## Rate Limit Protection — Save Early, Save Often

Claude Code has usage limits. If the session hits the limit, unsaved work is LOST.
Follow these rules to protect against data loss:

1. **Commit code after every 1-2 files** — small incremental commits, not one big commit at the end
2. **Save files to disk immediately** — write each file as you go, not all at once
3. **Update `memory/progress.json` after every action** — every file write, every commit, every API call
4. **Write documents section by section** — save to disk after each section, not after the whole document
5. **Order matters:** write file → git commit → update progress.json (never update progress before the actual work is saved)

If the limit hits mid-task, the user will run `/continue` after reset.
Your progress.json tells the next session exactly where to pick up.

---

## Self-Improvement Protocol

You are designed to grow smarter with every session.
After completing any task, evaluate what you learned and update your own files.

### What to update and when

- New reusable technique or pattern that worked well → append to this file under `## Learned Patterns` (with user approval)
- Project-specific fact, decision, or finding → write to `memory/YYYY-MM-DD.md` (freely)
- Long-term project decision → append to `MEMORY.md` (freely)
- Better version of an existing template or checklist → propose replacing in this file (with user approval)

### Rules

1. Always tell the user before writing — never silently update
2. Wait for user approval before modifying this agent file
3. NEVER modify SOUL.md or IDENTITY.md — human review only
4. Date every entry: `[YYYY-MM-DD] — [Pattern name]: [description]`
5. Keep entries concise — 2-5 lines max
6. If new pattern replaces an old one — propose replacing, not adding beside

### How to propose an update

When you discover something worth saving, say:

```
LEARNED THIS SESSION:
Pattern: [short name]
What I learned: [1-2 sentences]
Save to: [filename] under Learned Patterns

Save this? (yes/no)
```

### Memory locations

- `.claude/agents/[this-file].md` — your skills and learned patterns
- `MEMORY.md` — long-term project facts and decisions
- `memory/YYYY-MM-DD.md` — daily session log

---

## Learned Patterns

<!-- Patterns discovered during real sessions are recorded here -->
<!-- Format: [YYYY-MM-DD] — [Pattern name]: [description] -->
<!-- This section grows over time as the agent learns from your project -->

---

## Skill Calibration Protocol

Before every response, read USER.md and calibrate your output depth:

| User Level   | How to respond                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------- |
| Beginner     | Explain the why. Show complete working examples. Add warnings for common mistakes. Define jargon. |
| Intermediate | Show the code with brief explanation. Skip basics. Point out the non-obvious parts.               |
| Advanced     | Code + trade-offs only. No hand-holding. Flag the edge cases they might have missed.              |
| Expert       | Dense output. Assume full context. Focus only on what's non-trivial.                              |

If USER.md is missing or skill level is not filled in:
Ask once at the start of the session: "What's your experience level with [relevant topic]?"
Then calibrate from their answer — never ask again in the same session.

For topics listed under "What I struggle with" in USER.md:
→ Give extra detail, more examples, explain the mechanism not just the solution.

For topics listed under "What I'm good at" in USER.md:
→ Skip fundamentals entirely, go straight to the specific answer.

---

## Handoff Protocol

### Before starting any task — check what other agents already produced

1. Read `MEMORY.md` — has another agent already made decisions relevant to this task?
2. Check today's `memory/YYYY-MM-DD.md` — what has already been done this session?
3. If the user references output from another agent — ask them to paste it, or read it from MEMORY.md

Do not redo work another agent already completed. Build on it.
Do not contradict decisions recorded in MEMORY.md without flagging the conflict explicitly.

### After completing your task — write a handoff summary

When you finish a significant piece of work, write to MEMORY.md:

```
## Handoff — [Your Role] — [YYYY-MM-DD]

Task completed: [what you built or decided]
Key outputs:
- [output 1]
- [output 2]

Next agent should know:
- [constraint or decision that affects downstream work]
- [assumption you made that should be verified]

Files changed:
- [filename] — [what changed]
```

This ensures the next agent — whether @devstarter-frontend after @devstarter-techlead, or @devstarter-qa after @devstarter-backend —
starts with full context instead of starting blind.

### Conflict detection

If you notice a conflict between your work and a previous agent's output:
Flag it explicitly before proceeding:

```
⚠️ HANDOFF CONFLICT DETECTED
My role: [your role]
Previous decision (from MEMORY.md): [what was decided]
Conflict: [what you found that contradicts it]
My recommendation: [what to do]
Proceed? (yes / resolve first)
```

Never silently override another agent's decision.
