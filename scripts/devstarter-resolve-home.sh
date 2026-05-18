#!/bin/bash
# devstarter-resolve-home.sh — resolve the DevStarter install directory
#
# Source this file, then call: devstarter_resolve_home
# It sets two variables in the caller's shell:
#   DEVSTARTER_PROVIDER  — normalized provider name (default: claude)
#   DEVSTARTER_HOME      — install dir ($HOME/.claude for claude, else $HOME/.<provider>)
#
# Provider selection (in order):
#   1. $AI_PROVIDER environment variable
#   2. ai.provider from an existing devstarter-config.yml (if readable)
#   3. default: claude
#
# Regression guarantee: with AI_PROVIDER unset (or =claude), DEVSTARTER_HOME is
# exactly "$HOME/.claude" — identical to pre-Phase-2 behavior.

devstarter_resolve_home() {
  local provider="${AI_PROVIDER:-}"

  # Fallback: read ai.provider from config if env var not set
  if [ -z "$provider" ] && [ -n "${1:-}" ] && [ -f "$1" ]; then
    provider="$(grep -E '^\s*provider:' "$1" 2>/dev/null | head -1 | sed -E 's/.*provider:\s*//' | tr -d '\r"' | awk '{print $1}')"
  fi

  # Default
  [ -z "$provider" ] && provider="claude"

  # Normalize: lowercase, strip anything that is not a-z 0-9 - _
  provider="$(printf '%s' "$provider" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"
  [ -z "$provider" ] && provider="claude"

  # Guard against path traversal / absolute paths (tr above already removes / . )
  case "$provider" in
    claude) DEVSTARTER_HOME="$HOME/.claude" ;;
    *)      DEVSTARTER_HOME="$HOME/.$provider" ;;
  esac

  DEVSTARTER_PROVIDER="$provider"
  export DEVSTARTER_PROVIDER DEVSTARTER_HOME
}
