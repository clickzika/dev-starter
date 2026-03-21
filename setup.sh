#!/bin/bash
# setup.sh — First-time Claude Code global setup
# Run once: bash ~/.claude/setup.sh

set -e

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

ENV_FILE="$HOME/.claude/.env"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Claude Code — First Time Setup v1.0    ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ─── Check prerequisites ──────────────────────────────
echo -e "${CYAN}${BOLD}Checking prerequisites...${RESET}"

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "  ${RED}❌ '$1' not found${RESET} — $2"
    MISSING=1
  else
    echo -e "  ${GREEN}✅ $1${RESET}"
  fi
}

MISSING=0
check_cmd git    "install from https://git-scm.com"
check_cmd gh     "install from https://cli.github.com"
check_cmd node   "install from https://nodejs.org"
check_cmd curl   "install from your package manager"
check_cmd docker "install from https://docker.com (optional)"

if [ "$MISSING" = "1" ]; then
  echo ""
  echo -e "${RED}Please install missing tools above, then run setup.sh again.${RESET}"
  exit 1
fi

echo ""

# ─── Load existing .env if present ───────────────────
if [ -f "$ENV_FILE" ]; then
  echo -e "${YELLOW}Existing ~/.claude/.env found. Values shown as defaults.${RESET}"
  source "$ENV_FILE" 2>/dev/null || true
  echo ""
fi

# ─── Helper: ask with default ─────────────────────────
ask() {
  local PROMPT="$1"
  local DEFAULT="$2"
  echo -e "${CYAN}${BOLD}${PROMPT}${RESET}"
  if [ -n "$DEFAULT" ]; then
    echo -e "${YELLOW}  Current: ${DEFAULT}${RESET}"
    echo -n "  New value (Enter to keep): "
  else
    echo -n "  > "
  fi
  read -r INPUT
  if [ -z "$INPUT" ] && [ -n "$DEFAULT" ]; then
    REPLY="$DEFAULT"
  else
    REPLY="$INPUT"
  fi
  echo ""
}

# ─── GitHub Setup ─────────────────────────────────────
echo -e "${BOLD}━━━ GitHub ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

ask "GitHub username? (e.g. johndoe)" "${GITHUB_USERNAME:-}"
GITHUB_USERNAME="$REPLY"

# Verify GitHub CLI auth
echo -e "${CYAN}Checking GitHub CLI authentication...${RESET}"
if ! gh auth status &>/dev/null; then
  echo -e "${YELLOW}Not authenticated. Running gh auth login...${RESET}"
  gh auth login
fi
echo -e "${GREEN}✅ GitHub CLI authenticated${RESET}"
echo ""

ask "Default projects root folder?" "${PROJECTS_ROOT:-$HOME/Projects}"
PROJECTS_ROOT="$REPLY"
mkdir -p "$PROJECTS_ROOT"

# ─── Notion Setup ─────────────────────────────────────
echo -e "${BOLD}━━━ Notion ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}To get your Notion API key:${RESET}"
echo "  1. Go to https://www.notion.so/my-integrations"
echo "  2. Click 'New integration'"
echo "  3. Name it 'Claude Code', select your workspace"
echo "  4. Copy the Internal Integration Token"
echo "  5. Share at least one Notion page with this integration"
echo ""

ask "Notion API key? (starts with secret_)" "${NOTION_API_KEY:-}"
NOTION_API_KEY="$REPLY"

# Test Notion API key
echo -e "${CYAN}Testing Notion API key...${RESET}"
curl -s -X POST https://api.notion.com/v1/search \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"page_size\": 1}" \
  -o /tmp/notion_test.json

NOTION_STATUS=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/notion_test.json', 'utf8'));
console.log(data.status || 'ok');
")

if [ "$NOTION_STATUS" = "401" ]; then
  echo -e "${RED}❌ Invalid Notion API key. Please check and run setup.sh again.${RESET}"
  exit 1
elif [ "$NOTION_STATUS" = "ok" ]; then
  echo -e "${GREEN}✅ Notion API key valid${RESET}"
else
  echo -e "${YELLOW}⚠️  Could not verify Notion key (status: $NOTION_STATUS) — saved anyway${RESET}"
fi
rm -f /tmp/notion_test.json
echo ""

# ─── Notion Parent Page ───────────────────────────────
ask "Notion parent page name for projects? (default: Projects)" "${NOTION_PARENT_PAGE:-Projects}"
NOTION_PARENT_PAGE="$REPLY"

# ─── Merge Permissions into settings.json ─────────────
echo -e "${BOLD}━━━ Permissions ━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${CYAN}Setting up auto-approve permissions for common commands...${RESET}"
echo -e "${YELLOW}This prevents Claude from asking 'Allow?' for every command.${RESET}"
echo ""

SETTINGS_FILE="$HOME/.claude/settings.json"

# Permissions to add (won't duplicate if already present)
PERMISSIONS_TO_ADD=(
  "Bash(npm *)"
  "Bash(npx *)"
  "Bash(node *)"
  "Bash(git *)"
  "Bash(gh *)"
  "Bash(mkdir *)"
  "Bash(cp *)"
  "Bash(mv *)"
  "Bash(cat *)"
  "Bash(ls *)"
  "Bash(find *)"
  "Bash(grep *)"
  "Bash(curl *)"
  "Bash(echo *)"
  "Bash(rm *)"
  "Bash(chmod *)"
  "Bash(wc *)"
  "Bash(head *)"
  "Bash(tail *)"
  "Bash(sed *)"
  "Bash(awk *)"
  "Bash(sort *)"
  "Bash(date *)"
  "Bash(pwd)"
  "Bash(dotnet *)"
  "Bash(docker *)"
  "Bash(docker-compose *)"
  "Read"
  "Write"
  "Edit"
)

# Create settings.json if doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Use Node.js to safely merge permissions without overwriting existing settings
node -e "
const fs = require('fs');
const settingsFile = '$SETTINGS_FILE';
const newPerms = $(printf '%s\n' "${PERMISSIONS_TO_ADD[@]}" | node -e "
  const lines = require('fs').readFileSync('/dev/stdin','utf8').trim().split('\n');
  console.log(JSON.stringify(lines));
");

let settings = {};
try {
  settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
} catch(e) {
  settings = {};
}

// Ensure permissions.allow exists
if (!settings.permissions) settings.permissions = {};
if (!Array.isArray(settings.permissions.allow)) settings.permissions.allow = [];

// Merge — add only if not already present
let added = 0;
newPerms.forEach(p => {
  if (!settings.permissions.allow.includes(p)) {
    settings.permissions.allow.push(p);
    added++;
  }
});

fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2));
console.log('ADDED=' + added);
console.log('TOTAL=' + settings.permissions.allow.length);
"

RESULT=$(node -e "
const fs = require('fs');
const s = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));
console.log(s.permissions.allow.length);
")

echo -e "${GREEN}✅ Permissions configured: $RESULT rules in settings.json${RESET}"
echo -e "  Existing settings preserved — only new permissions added"
echo ""

# ─── Write .env ───────────────────────────────────────
mkdir -p "$HOME/.claude"

cat > "$ENV_FILE" << EOF
# Claude Code Global Config
# Generated by setup.sh on $(date '+%Y-%m-%d')
# ⚠️  Never commit this file — contains secrets

# GitHub
GITHUB_USERNAME=${GITHUB_USERNAME}
PROJECTS_ROOT=${PROJECTS_ROOT}

# Notion
NOTION_API_KEY=${NOTION_API_KEY}
NOTION_PARENT_PAGE=${NOTION_PARENT_PAGE:-Projects}
EOF

chmod 600 "$ENV_FILE"

echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║            ✅ Setup Complete!             ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  📄 Config saved to: ${CYAN}~/.claude/.env${RESET}"
echo -e "  🔓 Permissions:     ${CYAN}~/.claude/settings.json${RESET}"
echo -e "  📁 Projects folder: ${CYAN}${PROJECTS_ROOT}${RESET}"
echo -e "  🐙 GitHub user:     ${CYAN}${GITHUB_USERNAME}${RESET}"
echo -e "  📋 Notion parent:   ${CYAN}${NOTION_PARENT_PAGE}${RESET}"
echo ""
echo -e "${BOLD}🚀 Ready to start a project:${RESET}"
echo ""
echo "  claude"
echo "  > Read ~/.claude/dev-menu.md and help me get started"
echo ""
