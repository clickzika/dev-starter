# /devstarter-gitsetup — Git & Gitflow Setup

Set up git + GitFlow on a repo: branches (main/uat/develop), branch protection, standard labels, default branch.

## When to use vs alternatives

- **Use this** when: a repo needs git/GitFlow conventions installed (or repaired) — branches, protection, labels
- **Use /devstarter-new** instead when: starting a new project from scratch (gitsetup runs as part of /devstarter-new)
- **Use /devstarter-existing** instead when: setting up DevStarter on an existing repo (existing detects + repairs git config as needed)

## Inline Args

| Arg | Behaviour |
|-----|-----------|
| _(none)_ | Interactive — show setup plan and ask to confirm before running |
| `full` | Run all phases without confirmation prompts |
| `branches` | Phase 3 only — create/verify gitflow branches |
| `protect` | Phase 4 + 4.5 only — branch protection + post-merge cleanup config |
| `cleanup` | Phase 4.5 only — enable delete_branch_on_merge + global fetch.prune (+ optional `git sweep` alias) |
| `labels` | Phase 5 only — create standard GitHub labels |

Read `~/.claude/sdlc/devstarter-gitsetup.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-gitsetup` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Initialize Git, Gitflow, branch protection, and remotes

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-gitsetup.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
