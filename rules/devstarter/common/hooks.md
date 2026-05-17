# Claude Code Hooks Rules

## What Hooks Are
Hooks are shell commands that run automatically in response to Claude Code tool events.
They are configured in `.claude/settings.json` under the `hooks` key.

## Hook Types
- `PreToolUse` — runs before a tool executes; can block the tool by exiting non-zero
- `PostToolUse` — runs after a tool executes; for logging, formatting, side effects
- `Notification` — runs when Claude Code sends a notification
- `Stop` — runs when Claude Code finishes a response

## When to Use Hooks
- Auto-format files after edits (PostToolUse on Write/Edit)
- Enforce linting before commits (PreToolUse on Bash for git commit)
- Log tool usage for audit trails
- Auto-sync config files after changes
- Send notifications on task completion

## Hook Design Rules
- Hooks must be fast — blocking hooks delay every tool call
- Hooks must be idempotent — they may run multiple times
- A failing PreToolUse hook blocks the tool — use sparingly and intentionally
- Log hook output to a file, not stdout (stdout appears in Claude's context)

## Settings Format
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "prettier --write $TOOL_OUTPUT_FILE 2>/dev/null || true" }]
      }
    ]
  }
}
```

## Security
- Never pass user-provided content into hook commands unescaped
- Review hook commands before adding — they run with full shell access
- Keep hook scripts in `scripts/hooks/` and reference by path
