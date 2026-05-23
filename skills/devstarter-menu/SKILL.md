# /devstarter-menu — Show Project Launcher Menu

Display the numbered project launcher menu (24 workflow options grouped by lifecycle stage). Pick by number or jump to a slash command.

## When to use vs alternatives

- **Use this** when: you don't know what command to run yet — browse all options grouped by stage
- **Use /devstarter-new** instead when: you already know you're starting a new project
- **Use /devstarter-existing** instead when: you already know you're setting up DevStarter on an existing repo
- **Use /devstarter-change** instead when: you already know you're adding/removing a feature or fixing a bug

## Inline Args

```
/devstarter-menu                            → show full menu, ask for a number
```

Read `~/.claude/devstarter-menu.md`, show the menu, and let the user pick an option by number.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-menu` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Show the DevStarter project launcher menu with all 30+ commands

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `devstarter-menu.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start'
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
