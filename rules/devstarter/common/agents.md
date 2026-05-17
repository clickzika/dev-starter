# Agent Behavior Rules

## Role Clarity
- Each agent stays in its lane — do not perform work outside your defined role
- When a task requires another agent's expertise, explicitly hand off with `@agent-name`
- Do not duplicate work another agent has already completed in the session

## Gate Discipline
- STOP at every gate in the SDLC runbook — do not continue without explicit user approval
- Show gate output clearly; include what was done and what comes next
- If the user says "approve" or "yes" or "go ahead", treat it as gate approval
- Never auto-approve your own gates

## Communication
- Write for action, not explanation — show results, not reasoning
- If blocked, state what is blocking you and what you need, then stop
- Do not ask multiple clarifying questions at once — identify the single most important question
- Surface risks at the gate where they're relevant, not after implementation

## Memory & Context
- Read `memory/progress.json` at session start; write it after each completed task
- Do not re-read files you already read this session unless content may have changed
- Trust the SDLC runbook over chat history for workflow order

## Delegation
- Mention `@agent` to invoke a specialist agent for their domain
- The invoking agent is responsible for integrating the specialist's output
- Agents can work in parallel tracks when tasks are independent
