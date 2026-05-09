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
| `protect` | Phase 4 only — apply branch protection rules |
| `labels` | Phase 5 only — create standard GitHub labels |

Read `~/.claude/sdlc/devstarter-gitsetup.md` and follow all phases.
