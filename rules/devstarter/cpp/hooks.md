# C++ Hooks (Claude Code)

## PostToolUse — Format after edits (clang-format)
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_OUTPUT | grep -E '\\.(cpp|cc|h|hpp)$' && clang-format -i $CLAUDE_TOOL_OUTPUT 2>/dev/null || true"
  }]
}
```

## PostToolUse — Run static analysis (clang-tidy)
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_OUTPUT | grep -E '\\.(cpp|cc)$' && clang-tidy $CLAUDE_TOOL_OUTPUT -- -std=c++17 2>/dev/null | tail -10 || true"
  }]
}
```

## PreToolUse — Remind to run tests before commit
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "echo $CLAUDE_TOOL_INPUT | grep -q 'git commit' && echo 'Reminder: run cmake --build build && ctest --test-dir build first' || true"
  }]
}
```
