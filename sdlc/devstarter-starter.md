# dev-starter.md — Project Spec Intake Template

> **TL;DR** — New project bootstrap (master workflow with 5 gates) · **Lifecycle** Discovery · **Gates** 5 (in starter-gates)

## Model: Sonnet (`claude-sonnet-4-6`)

## ⚠️ CRITICAL RULES

### Rule 0 — Checkpoint
Read `~/.claude/sdlc/devstarter-checkpoint.md`: setup Cron at start, save `memory/progress.json` after every task, cleanup at end.

### Rule 1 — Hard Approval Gates
STOP at every gate. Show output. Wait for "approve" or "revise [notes]". Never continue without explicit approval.

### Rule 2 — Read From Files
Always read from disk before acting. Never rely on chat history. Before each task: read CLAUDE.md, devstarter-config.yml, memory/progress.json.

### Rule 3 — Read Agent File First
Before any agent produces output, read `~/.claude/agents/devstarter-[agent].md`. That file defines format, template, and quality gate. Output without reading is rejected.

---

### Rule 4 — Save Before Handing Off

Before announcing any handoff to the next agent:
1. Confirm file is written to disk
2. Confirm git commit is made
3. Update memory/progress.json
4. Only then announce handoff

```
💾 Saved: [filename]
🔀 Committed: [commit message]
📋 Progress updated: memory/progress.json
✅ Ready to hand off to: [next agent]
```

---

### Rule 5 — Notion Task Status MUST Be Updated
**Before starting any task:** PROC-NT-04 → Status: "In Progress"
**After creating PR:** PROC-NT-05 → Status: "In Review"
**After PR merged:** PROC-NT-06 → Status: "Done"
Never skip status updates. Each task MUST go through: To Do → In Progress → In Review → Done.

### Rule 6 — Continuous Development After Doc Approval
After all Gate 2 documents are approved, develop ALL tasks continuously without stopping for per-task approval.
Only show the final approval gate (Gate 5) after ALL tasks are complete.
Exception: Only stop if a 🔴 BLOCKER is found during PR review.

### Rule 7 — Parallel Tracks When Possible
Group tasks into parallel tracks by independence:
- **Track A (Backend):** DB + API tasks → @devstarter-dba, @devstarter-backend
- **Track B (Frontend):** UI + component tasks → @devstarter-frontend, @devstarter-uxui
- **Track C (Infra):** DevOps + security tasks → @devstarter-devops, @devstarter-security
Tasks within a track run in dependency order.
Tracks run in parallel when they have no cross-dependencies.
If Track B depends on Track A output (e.g. API response shape), complete Track A first.

### Rule 8 — Mode-Picker First, Then One Question at a Time

**The FIRST message to the user is ALWAYS the mode-picker (see FIRST ACTION section below).**
Never show rules, summaries, or questions before the mode-picker.

After the user picks a mode:
- Ask ONE question at a time — Q1 → wait → Q2 → wait → ...
- Show question number, question text, and options (if any)
- After user answers, confirm understanding, then ask the next question
- If a question is conditional (e.g. "ask only if Q4 includes 1"), skip it silently

Format for each question:
```
📋 Q[N] — [Question title]

[Question text]

[Options if any]
```

---

## Sub-file Loading Guide

Load sub-files on demand — do NOT pre-load all of them at once:

| When | Load |
|------|------|
| Starting intake (immediately) | `~/.claude/sdlc/devstarter-starter-intake.md` |
| After intake approval (PROJECT SUMMARY "approve") | `~/.claude/sdlc/devstarter-starter-gates.md` |
| Generating CLAUDE.md at Gate 1 | `~/.claude/sdlc/devstarter-starter-template.md` |

---

## ⚡ FIRST ACTION — Show This Before Anything Else

**Before asking any questions, before any rules output, the very first message to the user MUST be:**

```
👋 Let's build your project.

How do you want to start?

  1. ⚡ Quick    — 8 questions, pick a ready-made stack (~5 min)
  2. 🔧 Custom   — 15 questions, choose every piece yourself
  3. 💬 Describe — just tell me about your project, I'll handle the rest

> _
```

Use `AskUserQuestion` with:
- question: "Let's build your project. How do you want to start?"
- options: ["Quick — 8 questions, ready-made stack", "Custom — 15 questions, full control", "Describe — just tell me about it"]

Wait for the user to select. Nothing else before this prompt.

**Special case — inline args:**
If the user ran `/devstarter-new [some description]` (text after the command),
skip this prompt entirely. Treat the description as MODE 3 input and jump
directly to extraction → PROJECT SUMMARY.

---

## INTAKE MODE SELECTION

After user picks a mode, load `~/.claude/sdlc/devstarter-starter-intake.md` and follow:

| User types | Action |
|------------|--------|
| `1` | MODE 1 — Quick Start (Q1–Q8) |
| `2` | MODE 2 — Custom (Q1–Q15) |
| `3` | MODE 3 — Describe (1 free-text question) |
| Any other text | Treat as MODE 3 input directly — extract and show summary |

MODE 3 prompt (show when user picks 3):
```
📋 Describe your project — features, tech stack, users, anything you know.
   I'll extract the details and fill gaps with best practices.

   Example: "ecommerce site, React + Node.js, login, product catalog,
             cart, Stripe payments, admin panel, deploy Railway"

> _
```

---

