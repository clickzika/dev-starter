# /devstarter-agents — List Specialist Agents

Show the full DevStarter agent roster. Each agent is invoked via `@<alias>`
in any chat (no slash command needed) — Claude Code resolves aliases by
filename in `agents/`.

## Output

Show this table immediately, then ask which agent the user wants to consult:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎭 DevStarter Specialist Agents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUIREMENTS & PLANNING
  @ba         My Melody       Requirements, BRD, user stories, acceptance criteria
  @pm         Hello Kitty     Sprint planning, task tracking, retrospectives
  @techlead   Tuxedo Sam      Architecture, ADRs, AI/LLM decisions, tech leadership

BUILD
  @backend    Badtz-Maru      APIs, services, server logic, integrations
  @frontend   Cinnamoroll     UI components, state, performance, a11y
  @dba        Pochacco        Schema design, migrations, query optimization
  @mobile     Aggretsuko      Flutter, React Native, native iOS/Android
  @mlops                      ML pipelines, model serving, RAG, monitoring

QUALITY & OPS
  @qa         Keroppi         Test strategy, automation, coverage gates
  @security   Kuromi          OWASP, auth, secrets, threat modeling
  @devops     Pompompurin     CI/CD, infra, Docker, K8s, observability

DESIGN & DOCS
  @uxui       Kiki            Design tokens, prototypes, accessibility audit
  @docs       Gudetama        Technical writing, API docs, runbooks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

How to use:
  @<alias> <task>            — invoke directly in chat
  @devstarter-<name> <task>  — full-name form also works

Example:
  @ba write user stories for OAuth flow
  @techlead should we use Redis or RabbitMQ for job queue
  @qa design test strategy for cart checkout
```

If the user names an agent, read `~/.claude/agents/devstarter-<name>.md`
and act as that agent. Apply the full persona, deliverable templates, and
quality gates from the agent file.

## Inline Args

```
/devstarter-agents             → list all agents
/devstarter-agents qa          → list + immediately load @qa for the next task
/devstarter-agents pick        → show agents and ask which one to invoke
```

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-agents` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — List all specialist agents and their capabilities

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `agents/` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
