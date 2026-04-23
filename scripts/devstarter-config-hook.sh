#!/bin/bash
# scripts/devstarter-config-hook.sh
# Claude Code PostToolUse hook — auto-syncs .project.env when devstarter-config.yml is edited.
# Registered in .claude/settings.json

INPUT=$(cat)

TOOL=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | sed 's/"tool_name":"//;s/"//')
FILE=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"//')

if [[ "$TOOL" =~ ^(Edit|Write)$ ]] && [[ "$FILE" == *"devstarter-config.yml"* ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$SCRIPT_DIR/config-sync.sh"
fi
