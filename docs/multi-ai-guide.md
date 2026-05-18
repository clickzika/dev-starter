# DevStarter — Multi-AI Setup Guide

> Use DevStarter with Copilot, Gemini, ChatGPT, Cursor, or any AI assistant.

---

## What DevStarter Provides

DevStarter is a complete software development workflow system:
- **83 specialist AI agents** (BA, backend, QA, security, etc.)
- **51 slash commands** for SDLC workflows (new project, change, release, debug, etc.)
- **28+ SDLC runbooks** with gate-based approval flows
- **Battle-tested templates** for docs, CI/CD, secrets, and more

DevStarter was built for Claude Code but all **workflow content is AI-agnostic**.
Non-Claude AI users access it via the **Universal Prompt** blocks in each skill file.

---

## Prerequisites

1. **Install DevStarter** on your machine (one-time setup)
2. **Copy a Universal Prompt** from the relevant skill file
3. **Paste into your AI tool** and start the workflow

---

## Step 1 — Install DevStarter

### Provider-aware install (v5.0.0+)

Set `AI_PROVIDER` to install into a dedicated directory for your AI tool:

```bash
AI_PROVIDER=codex  bash install.sh     # installs to ~/.codex/
AI_PROVIDER=gemini bash install.sh     # installs to ~/.gemini/
bash install.sh                        # no var → ~/.claude/ (unchanged)
```

What changes for non-Claude providers:
- Install dir is `~/.<provider>/` instead of `~/.claude/`
- Lifecycle hooks are **skipped** (they are Claude Code-only; `--hooks` is ignored with a notice)
- A neutral **`PROJECT.md`** context file is generated (point your AI at it instead of `CLAUDE.md`)
- A **`devstarter-invoke.sh`** helper is installed for copy-paste prompts:

```bash
bash ~/.codex/devstarter-invoke.sh menu        # list all workflows
bash ~/.codex/devstarter-invoke.sh change      # print the prompt for /devstarter-change
```

When uninstalling or updating a non-Claude install, pass the same variable:

```bash
AI_PROVIDER=codex bash ~/.codex/update.sh
AI_PROVIDER=codex bash ~/.codex/uninstall.sh
```

### Standard install

Run the installer (Mac/Linux):
```bash
bash <(curl -s https://raw.githubusercontent.com/clickzika/dev-starter-dev/main/install.sh)
```

Or clone and install manually:
```bash
git clone https://github.com/clickzika/dev-starter-dev.git
cd dev-starter-dev
bash install.sh
```

This installs DevStarter files to `~/.claude/` (the install directory — works even without Claude Code).

**Windows:**
```powershell
# In PowerShell:
git clone https://github.com/clickzika/dev-starter-dev.git
cd dev-starter-dev
bash install.sh   # requires Git Bash or WSL
```

Install path: `~/.claude/` on Mac/Linux, `%USERPROFILE%\.claude` on Windows.

---

## Step 2 — Find Your Workflow

Browse the skill files to find the workflow you need:

| Workflow | File | What it does |
|----------|------|--------------|
| Start new project | `skills/devstarter-new/SKILL.md` | Full project scaffold with gates |
| Add / fix / remove | `skills/devstarter-change/SKILL.md` | Feature changes with impact analysis |
| Release + deploy | `skills/devstarter-release/SKILL.md` | develop → UAT → main → tag |
| Debug a bug | `skills/devstarter-debug/SKILL.md` | Hypothesis-driven root cause analysis |
| Audit project | `skills/devstarter-audit/SKILL.md` | Quality, security, and health review |
| Sprint planning | `skills/devstarter-sprint/SKILL.md` | Task breakdown + GitHub/Notion sync |
| Get architecture advice | `skills/devstarter-consult/SKILL.md` | Options analysis before building |
| Incident response | `skills/devstarter-incident/SKILL.md` | Detect, contain, resolve, report |
| Rollback | `skills/devstarter-rollback/SKILL.md` | Revert production safely |
| Hotfix | `skills/devstarter-hotfix/SKILL.md` | Critical fix bypassing normal flow |

Full list: see `skills/devstarter-registry/SKILL.md`

---

## Step 3 — Copy the Universal Prompt

Each SKILL.md ends with a `## 🌐 Universal Prompt` section. Copy it into your AI tool.

**Example** (from `skills/devstarter-change/SKILL.md`):
```
DevStarter — Add a feature, remove a feature, or fix a bug with guided gates

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-change.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

---

## AI-Specific Instructions

### GitHub Copilot Chat (VS Code)

1. Open the Copilot Chat panel (`Ctrl+Shift+I` or `Cmd+Shift+I`)
2. Start a new chat
3. Type: `Read the file ~/.claude/sdlc/devstarter-change.md and follow the workflow.`
   Or paste the Universal Prompt block directly
4. Copilot will read the SDLC runbook and guide you through the workflow

**Tip:** Use `@workspace` to give Copilot context about your project:
```
@workspace Read ~/.claude/sdlc/devstarter-debug.md and help me debug the login issue.
```

**Limitation:** Copilot cannot write to files or run git commands directly.
Use it for planning + guidance, then apply changes manually or via VS Code.

---

### Google Gemini (gemini.google.com or Gemini in Workspace)

1. Open Gemini chat
2. Paste the Universal Prompt from the skill file you want
3. If Gemini has file access (Gemini Advanced with Google Drive): upload the SDLC .md file
4. For workflows requiring file reads: paste the SDLC file content directly

**Tip for Gemini Advanced:**
```
I've uploaded devstarter-change.md. Read it and follow the workflow to help me add a new feature to my project.
```

**Without file access:**
```
Here is the DevStarter workflow I want to follow:
[paste content of sdlc/devstarter-change.md]

Now help me add a dark mode toggle to my React app.
```

---

### ChatGPT / OpenAI

1. Open ChatGPT (chat.openai.com)
2. Create a new conversation
3. Start with the System message or first message:
   ```
   You are running DevStarter workflows. When I ask you to run a workflow,
   I will provide the workflow content. Follow it exactly, stop at every
   ⛔ GATE, and wait for my approval before continuing.
   ```
4. Paste the SDLC runbook content or the Universal Prompt block

**GPT-4 with File Upload:**
Upload the `.md` files directly and ask GPT to follow them.

**Custom GPT option:**
Create a Custom GPT with the DevStarter agent-base.md as the system prompt:
- System prompt: content of `~/.claude/agents/shared/devstarter-agent-base.md`
- Knowledge files: upload the relevant SDLC runbooks

---

### Cursor

Cursor supports Claude natively, but you can also use it with other models.

**With Claude (recommended):**
Use the `/devstarter-*` commands directly — they work the same as Claude Code.

**With other models in Cursor:**
1. Open Cursor Chat (`Cmd+L` or `Ctrl+L`)
2. Paste the Universal Prompt from any SKILL.md
3. Reference files with `@file` syntax:
   ```
   @~/.claude/sdlc/devstarter-change.md — follow this workflow to add a feature
   ```

---

### Windsurf / Codeium

1. Open the AI chat panel
2. Paste the Universal Prompt from the relevant SKILL.md
3. Reference DevStarter files using the file picker or `@` mentions

---

### Any Other AI Tool

Use the **self-contained Universal Prompt approach**:

1. Find the SDLC runbook for the workflow you want (in `~/.claude/sdlc/`)
2. Copy the entire file content
3. Paste it into your AI chat as context:
   ```
   Here is a workflow I want you to follow. Read it carefully and run it:
   
   [paste sdlc/devstarter-change.md content here]
   
   I want to add a user authentication feature to my Node.js API.
   ```
4. The AI will guide you through the gates just like Claude Code would

---

## What Works Without Claude Code

| Feature | Works | Notes |
|---------|-------|-------|
| All SDLC workflows | ✅ | Paste SDLC runbook content as context |
| All 83 specialist agents | ✅ | Paste agent file content as system prompt |
| Gate-based approvals | ✅ | AI stops at each gate and waits |
| GitHub issue creation | ✅ | AI generates the `gh` commands for you |
| Notion task creation | ✅ | AI generates API calls or instructions |
| Slash commands (`/devstarter-*`) | ❌ | Claude Code only |
| Auto session resume | ❌ | No hooks — save context manually |
| Auto checkpoint (progress.json) | ❌ | No hooks — ask AI to track progress |
| Hooks (SessionStart, PostToolUse) | ❌ | Claude Code lifecycle only |
| MCP server integrations | ❌ | Claude Code + supported clients only |

---

## Using Specialist Agents

Each agent has its own skill file in `skills/devstarter-[name]/SKILL.md`.
The Universal Prompt block at the bottom of each tells you how to invoke it.

**Example — invoke the Security Agent in ChatGPT:**
```
Read ~/.claude/agents/devstarter-security.md (I'll paste it below) and act as
the DevStarter Security Agent (Kuromi). Review my authentication code for OWASP issues.

[paste content of ~/.claude/agents/devstarter-security.md]

Here is my auth code: [your code]
```

**All 13 core agents:**
BA · Backend · DBA · DevOps · Docs · Frontend · MLOps · Mobile · PM · QA · Security · TechLead · UX/UI

---

## Contributing

Found a missing AI tool? Open an issue or PR:
- GitHub: https://github.com/clickzika/dev-starter-dev
- Add your AI's instructions to this guide under `## AI-Specific Instructions`

---

## See Also

- `skills/devstarter-registry/SKILL.md` — all 51 commands and their SDLC targets
- `devstarter-config.yml` — configure your AI provider (`ai.provider: codex | gemini | etc.`)
- `templates/litellm/` — use LiteLLM to route any AI through a single proxy
