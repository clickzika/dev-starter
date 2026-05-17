# Go Hooks (Claude Code)

## PostToolUse — goimports after edits
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_OUTPUT | grep -q '\\.go$' && goimports -w $CLAUDE_TOOL_OUTPUT 2>/dev/null || true"
  }]
}
```

## PostToolUse — go vet after edits
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_OUTPUT | grep -q '\\.go$' && go vet ./... 2>&1 | tail -5 || true"
  }]
}
```

## PreToolUse — go mod tidy reminder before commit
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_INPUT | grep -q 'git commit' && go mod tidy && echo 'go mod tidy: done' || true"
  }]
}
```
