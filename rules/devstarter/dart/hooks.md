# Dart Hooks (Claude Code)

## PostToolUse — Auto-format after edits
After editing `.dart` files, run `dart format`:
```json
{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command", "command": "dart format --fix $CLAUDE_TOOL_OUTPUT 2>/dev/null || true" }]
}
```

## PostToolUse — Run analysis after edits
```json
{
  "matcher": "Edit|Write",
  "hooks": [{ "type": "command", "command": "dart analyze --no-fatal-infos 2>/dev/null | tail -5 || true" }]
}
```

## PreToolUse — Warn before committing with analysis errors
```json
{
  "matcher": "Bash",
  "hooks": [{ "type": "command", "command": "echo $CLAUDE_TOOL_INPUT | grep -q 'git commit' && dart analyze --fatal-infos 2>/dev/null || true" }]
}
```
