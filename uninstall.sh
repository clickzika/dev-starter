#!/bin/bash
# uninstall.sh — Remove DevStarter from ~/.claude/
#
# Usage:
#   bash uninstall.sh               # interactive, keeps user files
#   bash uninstall.sh --yes         # skip confirmation prompt
#   bash uninstall.sh --purge       # also delete USER.md, CLAUDE.md, memory/
#   bash uninstall.sh --hooks-only  # only remove hooks from settings.json
#
# What is KEPT by default (user-owned):
#   ~/.claude/USER.md
#   ~/.claude/CLAUDE.md
#   ~/.claude/settings.json  (DevStarter hooks removed if --hooks-only or --purge)
#   ~/.claude/settings.local.json
#   ~/.claude/.env
#   ~/.claude/mcp.json
#   ~/.claude/memory/
#   ~/.claude/agents/custom/
#
# What is REMOVED (DevStarter-owned):
#   ~/.claude/agents/       (except custom/)
#   ~/.claude/skills/
#   ~/.claude/sdlc/
#   ~/.claude/templates/
#   ~/.claude/scripts/
#   ~/.claude/rules/
#   ~/.claude/devstarter-menu.md
#   ~/.claude/update.sh  ~/.claude/install.sh  ~/.claude/setup.sh  ~/.claude/uninstall.sh
#   ~/.claude/README.md  ~/.claude/LICENSE  ~/.claude/.gitignore
#   ~/.claude/VERSION    ~/.claude/CHANGELOG.md  ~/.claude/.env.example

set -e

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Resolve install dir (provider-aware). This script lives at the root of the
# install dir, so its own location is authoritative; the resolver also honors
# $AI_PROVIDER for the curl-piped case.
_UNINST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
if [ -f "$_UNINST_DIR/scripts/devstarter-resolve-home.sh" ]; then
  . "$_UNINST_DIR/scripts/devstarter-resolve-home.sh"
  devstarter_resolve_home
  CLAUDE_DIR="$DEVSTARTER_HOME"
else
  CLAUDE_DIR="${AI_PROVIDER:+$HOME/.$AI_PROVIDER}"
  CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
fi
YES=0
PURGE=0
HOOKS_ONLY=0

# ─── Parse args ───────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --yes)        YES=1 ;;
    --purge)      PURGE=1; YES=1 ;;
    --hooks-only) HOOKS_ONLY=1 ;;
  esac
done

echo ""
echo -e "${BOLD}-------------------------------------------${RESET}"
echo -e "${BOLD}  DevStarter — Uninstaller${RESET}"
echo -e "${BOLD}-------------------------------------------${RESET}"
echo ""

# ─── Guard: check DevStarter is actually installed ──
if [ ! -f "$CLAUDE_DIR/devstarter-menu.md" ] && [ ! -d "$CLAUDE_DIR/agents" ]; then
  echo -e "${YELLOW}⚠️  DevStarter not found at $CLAUDE_DIR${RESET}"
  echo -e "  Nothing to remove."
  exit 0
fi

# ─── Hooks-only mode ─────────────────────────────
if [ "$HOOKS_ONLY" = "1" ]; then
  echo -e "${CYAN}${BOLD}Removing DevStarter hooks from settings.json...${RESET}"
  SETTINGS="$CLAUDE_DIR/settings.json"
  if command -v node &>/dev/null && [ -f "$CLAUDE_DIR/scripts/uninstall-hooks.js" ]; then
    node "$CLAUDE_DIR/scripts/uninstall-hooks.js" "$SETTINGS"
  elif command -v node &>/dev/null; then
    # Fallback: inline removal if script not in claude dir
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
    if [ -f "$SCRIPT_DIR/scripts/uninstall-hooks.js" ]; then
      node "$SCRIPT_DIR/scripts/uninstall-hooks.js" "$SETTINGS"
    else
      echo -e "${YELLOW}⚠️  uninstall-hooks.js not found — remove hooks manually from $SETTINGS${RESET}"
    fi
  else
    echo -e "${YELLOW}⚠️  node not found — remove DevStarter hooks manually from $SETTINGS${RESET}"
    echo -e "  Look for commands containing: scripts/hooks/session-start, stop-format-typecheck, etc."
  fi
  echo ""
  echo -e "${GREEN}${BOLD}Done.${RESET}"
  exit 0
fi

# ─── Show what will be removed ───────────────────
echo -e "${BOLD}Will remove (DevStarter-owned):${RESET}"
echo -e "  ${RED}~/.claude/agents/${RESET}          (except agents/custom/)"
echo -e "  ${RED}~/.claude/skills/${RESET}"
echo -e "  ${RED}~/.claude/sdlc/${RESET}"
echo -e "  ${RED}~/.claude/templates/${RESET}"
echo -e "  ${RED}~/.claude/scripts/${RESET}"
echo -e "  ${RED}~/.claude/rules/${RESET}"
echo -e "  ${RED}~/.claude/devstarter-menu.md${RESET}  and other root files"
echo ""
echo -e "${BOLD}Will keep (user-owned):${RESET}"
echo -e "  ${GREEN}~/.claude/USER.md${RESET}"
echo -e "  ${GREEN}~/.claude/CLAUDE.md${RESET}"
echo -e "  ${GREEN}~/.claude/settings.json${RESET}    (DevStarter hooks removed)"
echo -e "  ${GREEN}~/.claude/.env${RESET}"
echo -e "  ${GREEN}~/.claude/mcp.json${RESET}"
echo -e "  ${GREEN}~/.claude/memory/${RESET}"
echo -e "  ${GREEN}~/.claude/agents/custom/${RESET}"
echo ""

if [ "$PURGE" = "1" ]; then
  echo -e "${RED}${BOLD}--purge mode: ALSO removing:${RESET}"
  echo -e "  ${RED}~/.claude/USER.md${RESET}"
  echo -e "  ${RED}~/.claude/CLAUDE.md${RESET}"
  echo -e "  ${RED}~/.claude/memory/${RESET}"
  echo ""
fi

# ─── Confirm ─────────────────────────────────────
if [ "$YES" = "0" ]; then
  echo -e "${YELLOW}Proceed with uninstall? [y/N]${RESET} \c"
  read -r CONFIRM
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "Cancelled."
    exit 0
  fi
  echo ""
fi

# ─── Save custom agents before wipe ──────────────
SAVE_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'devstarter-uninstall')"
if [ -d "$CLAUDE_DIR/agents/custom" ]; then
  cp -r "$CLAUDE_DIR/agents/custom" "$SAVE_DIR/custom_agents" 2>/dev/null || true
fi

# ─── Remove DevStarter-owned directories ─────────
echo -e "${CYAN}Removing DevStarter files...${RESET}"

for dir in agents skills sdlc templates scripts rules; do
  if [ -d "$CLAUDE_DIR/$dir" ]; then
    rm -rf "$CLAUDE_DIR/$dir"
    echo -e "  Removed: $dir/"
  fi
done

# ─── Remove DevStarter root files ────────────────
for f in devstarter-menu.md update.sh install.sh uninstall.sh setup.sh \
          README.md LICENSE .gitignore VERSION CHANGELOG.md .env.example; do
  if [ -f "$CLAUDE_DIR/$f" ]; then
    rm -f "$CLAUDE_DIR/$f"
    echo -e "  Removed: $f"
  fi
done

# ─── Restore custom agents ────────────────────────
if [ -d "$SAVE_DIR/custom_agents" ]; then
  mkdir -p "$CLAUDE_DIR/agents/custom"
  cp -r "$SAVE_DIR/custom_agents/." "$CLAUDE_DIR/agents/custom/" 2>/dev/null || true
  echo -e "  ${GREEN}Restored: agents/custom/${RESET}"
fi
rm -rf "$SAVE_DIR"

# ─── Remove hooks from settings.json ─────────────
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ] && command -v node &>/dev/null; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
  HOOK_SCRIPT=""
  [ -f "$SCRIPT_DIR/scripts/uninstall-hooks.js" ] && HOOK_SCRIPT="$SCRIPT_DIR/scripts/uninstall-hooks.js"
  if [ -n "$HOOK_SCRIPT" ]; then
    node "$HOOK_SCRIPT" "$SETTINGS" 2>/dev/null || true
  fi
fi

# ─── Purge user files if --purge ─────────────────
if [ "$PURGE" = "1" ]; then
  echo ""
  echo -e "${RED}Purging user files...${RESET}"
  for f in USER.md CLAUDE.md; do
    if [ -f "$CLAUDE_DIR/$f" ]; then
      rm -f "$CLAUDE_DIR/$f"
      echo -e "  Removed: $f"
    fi
  done
  if [ -d "$CLAUDE_DIR/memory" ]; then
    rm -rf "$CLAUDE_DIR/memory"
    echo -e "  Removed: memory/"
  fi
fi

# ─── Done ────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}-------------------------------------------${RESET}"
echo -e "${GREEN}${BOLD}  DevStarter Removed${RESET}"
echo -e "${GREEN}${BOLD}-------------------------------------------${RESET}"
echo ""
echo -e "  Kept: USER.md, CLAUDE.md, .env, mcp.json, memory/, agents/custom/"
if [ "$PURGE" = "1" ]; then
  echo -e "  ${RED}Purged: USER.md, CLAUDE.md, memory/${RESET}"
fi
echo ""
echo -e "  Reinstall anytime:"
echo -e "  ${CYAN}curl -sL https://raw.githubusercontent.com/clickzika/dev-starter/main/install.sh | bash${RESET}"
echo ""
