#!/bin/bash
# devstarter-invoke.sh — universal workflow runner for non-Claude AI tools
#
#   bash devstarter-invoke.sh                 # list all workflows
#   bash devstarter-invoke.sh menu            # same as above
#   bash devstarter-invoke.sh change          # print the Universal Prompt for /devstarter-change
#   bash devstarter-invoke.sh devstarter-new  # full name also accepted
#
# Output is a ready-to-paste prompt block. Pipe it or copy it into Codex,
# Gemini, Copilot, ChatGPT, Cursor, etc. Claude Code users should use the
# native /devstarter-* slash commands instead.

set -e

BOLD='\033[1m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"

# Resolve install dir (provider-aware); script lives at the install root.
if [ -f "$SCRIPT_DIR/scripts/devstarter-resolve-home.sh" ]; then
  . "$SCRIPT_DIR/scripts/devstarter-resolve-home.sh"
  devstarter_resolve_home
  HOME_DIR="$DEVSTARTER_HOME"
else
  HOME_DIR="${AI_PROVIDER:+$HOME/.$AI_PROVIDER}"
  HOME_DIR="${HOME_DIR:-$HOME/.claude}"
fi
# Prefer the install dir if it has skills/, else fall back to the script's own dir
[ -d "$HOME_DIR/skills" ] || HOME_DIR="$SCRIPT_DIR"
SKILLS_DIR="$HOME_DIR/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo -e "${YELLOW}No skills/ found at $SKILLS_DIR. Is DevStarter installed?${RESET}"
  exit 1
fi

list_workflows() {
  echo ""
  echo -e "${BOLD}DevStarter — Workflows (provider: ${DEVSTARTER_PROVIDER:-claude})${RESET}"
  echo -e "Run: ${CYAN}bash devstarter-invoke.sh <name>${RESET}"
  echo ""
  for d in "$SKILLS_DIR"/devstarter-*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    short="${name#devstarter-}"
    desc="$(grep -m1 '^# ' "$d/SKILL.md" 2>/dev/null | sed -E 's/^# *//' )"
    printf "  ${GREEN}%-22s${RESET} %s\n" "$short" "$desc"
  done
  echo ""
}

print_prompt() {
  local raw="$1"
  local name="$raw"
  case "$name" in
    devstarter-*) ;;
    *) name="devstarter-$name" ;;
  esac
  local skill="$SKILLS_DIR/$name/SKILL.md"
  if [ ! -f "$skill" ]; then
    echo -e "${YELLOW}Unknown workflow: $raw${RESET}"
    echo -e "Run ${CYAN}bash devstarter-invoke.sh menu${RESET} to see all workflows."
    exit 1
  fi

  echo ""
  echo -e "${BOLD}── Copy everything below into your AI tool ─────────────────${RESET}"
  echo ""

  # Extract the Universal Prompt fenced block if present, else the whole file.
  awk '
    /^## .* Universal Prompt/ { inblk=1 }
    inblk && /^```/ { fence++; if (fence==1) next; if (fence==2) exit }
    inblk && fence==1 { print }
  ' "$skill"

  echo ""
  echo -e "${BOLD}────────────────────────────────────────────────────────────${RESET}"
  echo -e "Full runbook: ${CYAN}${HOME_DIR}/sdlc/${name}.md${RESET} (read it if your AI can open files)"
  echo -e "Context file: ${CYAN}${HOME_DIR}/PROJECT.md${RESET}"
  echo ""
}

cmd="${1:-menu}"
case "$cmd" in
  menu|list|"" ) list_workflows ;;
  -h|--help)      list_workflows ;;
  *)              print_prompt "$cmd" ;;
esac
