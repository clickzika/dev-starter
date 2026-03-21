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

# Temp dir — must work for both Git Bash (curl) and Windows Node.js
TMP_D="$HOME/.claude/.tmp"
mkdir -p "$TMP_D"
# Convert to Windows path if running in Git Bash/MSYS (Node.js needs C:/Users/... not /c/Users/...)
if command -v cygpath &>/dev/null; then
  TMP_D_NODE="$(cygpath -m "$TMP_D")"
else
  TMP_D_NODE="$TMP_D"
fi

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

check_cmd_optional() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "  ${YELLOW}⚠️  '$1' not found${RESET} — $2 (optional)"
  else
    echo -e "  ${GREEN}✅ $1${RESET}"
  fi
}

MISSING=0
check_cmd git    "install from https://git-scm.com"
check_cmd gh     "install from https://cli.github.com"
check_cmd node   "install from https://nodejs.org"
check_cmd curl   "install from your package manager"
check_cmd_optional docker "install from https://docker.com"

if [ "$MISSING" = "1" ]; then
  echo ""
  echo -e "${RED}Please install required tools above, then run setup.sh again.${RESET}"
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
  -o $TMP_D/notion_test.json

NOTION_STATUS=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/notion_test.json', 'utf8'));
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
rm -f $TMP_D/notion_test.json
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
SETTINGS_FILE_NODE="$TMP_D_NODE/../settings.json"

# Create settings.json if doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Write permissions list to temp file (avoids /dev/stdin issues on Windows)
cat > "$TMP_D/perms.json" << 'PERMSEOF'
[
  "Bash(npm *)", "Bash(npx *)", "Bash(node *)",
  "Bash(git *)", "Bash(gh *)", "Bash(mkdir *)",
  "Bash(cp *)", "Bash(mv *)", "Bash(cat *)",
  "Bash(ls *)", "Bash(find *)", "Bash(grep *)",
  "Bash(curl *)", "Bash(echo *)", "Bash(rm *)",
  "Bash(chmod *)", "Bash(wc *)", "Bash(head *)",
  "Bash(tail *)", "Bash(sed *)", "Bash(awk *)",
  "Bash(sort *)", "Bash(date *)", "Bash(pwd)",
  "Bash(dotnet *)", "Bash(docker *)", "Bash(docker-compose *)",
  "Read", "Write", "Edit"
]
PERMSEOF

# Use Node.js to safely merge permissions without overwriting existing settings
node -e "
const fs = require('fs');
const path = require('path');
const settingsFile = '$SETTINGS_FILE_NODE';
const permsFile = '$TMP_D_NODE/perms.json';
const newPerms = JSON.parse(fs.readFileSync(permsFile, 'utf8'));

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

rm -f "$TMP_D/perms.json"

RESULT=$(node -e "
const fs = require('fs');
const s = JSON.parse(fs.readFileSync('$SETTINGS_FILE_NODE', 'utf8'));
console.log(s.permissions.allow.length);
")

echo -e "${GREEN}✅ Permissions configured: $RESULT rules in settings.json${RESET}"
echo -e "  Existing settings preserved — only new permissions added"
echo ""

# ─── USER.md Profile Setup ────────────────────────────
echo -e "${BOLD}━━━ Developer Profile ━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${CYAN}3 quick questions to calibrate all agents to your level.${RESET}"
echo ""

# Q1 — Experience level
echo -e "${BOLD}Q1. How long have you been coding?${RESET}"
echo "  1) Just started (< 1 year)"
echo "  2) 1-3 years"
echo "  3) 3-10 years"
echo "  4) 10+ years"
echo -n "  > "
read -r EXP_CHOICE
echo ""

case "$EXP_CHOICE" in
  1) DEFAULT_LEVEL="Beginner" ;;
  3) DEFAULT_LEVEL="Advanced" ;;
  4) DEFAULT_LEVEL="Expert" ;;
  *) DEFAULT_LEVEL="Intermediate" ;;
esac

# Q2 — Strong languages/frameworks
echo -e "${BOLD}Q2. What are you strongest at? (comma-separated)${RESET}"
echo -e "  ${YELLOW}Examples: JavaScript, Python, React, Docker, SQL, C#, Angular${RESET}"
echo -e "  ${YELLOW}These will be set to Advanced/Expert. Leave empty to skip.${RESET}"
echo -n "  > "
read -r STRONG_SKILLS
echo ""

# Q3 — Response language
echo -e "${BOLD}Q3. What language should agents respond in?${RESET}"
echo "  1) English"
echo "  2) Thai"
echo "  3) Both (Thai explanation + English code)"
echo -n "  > "
read -r LANG_CHOICE
echo ""

case "$LANG_CHOICE" in
  2) RESP_LANG="Thai"; CODE_LANG="English"; EXPLAIN_STYLE="Show full example"; ERROR_LANG="Translate to Thai"; STUCK_STYLE="Walk me through step by step" ;;
  3) RESP_LANG="Thai + English"; CODE_LANG="English"; EXPLAIN_STYLE="Show full example"; ERROR_LANG="Translate to Thai"; STUCK_STYLE="Walk me through step by step" ;;
  *) RESP_LANG="English"; CODE_LANG="English"; EXPLAIN_STYLE="Show full example"; ERROR_LANG="Keep in English"; STUCK_STYLE="Walk me through step by step" ;;
esac

# Determine strong skill level (one above default, capped at Expert)
case "$DEFAULT_LEVEL" in
  Beginner) STRONG_LEVEL="Intermediate" ;;
  Intermediate) STRONG_LEVEL="Advanced" ;;
  Advanced) STRONG_LEVEL="Expert" ;;
  Expert) STRONG_LEVEL="Expert" ;;
esac

# Generate USER.md using Node.js for reliable string handling
USER_FILE="$HOME/.claude/USER.md"
if command -v cygpath &>/dev/null; then
  USER_FILE_NODE="$(cygpath -m "$USER_FILE")"
else
  USER_FILE_NODE="$USER_FILE"
fi

node -e "
const fs = require('fs');
const defaultLevel = '$DEFAULT_LEVEL';
const strongLevel = '$STRONG_LEVEL';
const strongSkills = '$STRONG_SKILLS'.split(',').map(s => s.trim().toLowerCase()).filter(Boolean);
const respLang = '$RESP_LANG';
const codeLang = '$CODE_LANG';
const explainStyle = '$EXPLAIN_STYLE';
const errorLang = '$ERROR_LANG';
const stuckStyle = '$STUCK_STYLE';

// Map skill names to table entries
const langs = [
  'JavaScript', 'TypeScript', 'Python', 'C#', 'Go', 'Java', 'SQL'
];
const frameworks = [
  'React / Next.js', 'Angular', 'Vue', 'Node.js / Express',
  'ASP.NET Core', 'Flutter', 'Docker', 'Git / GitHub', 'CI/CD',
  'Cloud (Azure/AWS/GCP)'
];
const concepts = [
  'REST API design', 'Database design', 'Security (OWASP)',
  'Testing', 'System design'
];

function getLevel(name) {
  const lower = name.toLowerCase();
  for (const s of strongSkills) {
    if (lower.includes(s) || s.includes(lower.replace(/ *\\/.*/,'').replace(/ *\\(.*/,''))) {
      return strongLevel;
    }
  }
  return defaultLevel;
}

function makeTable(items) {
  const maxName = Math.max(...items.map(i => i.length), 10);
  let rows = '';
  items.forEach(item => {
    rows += '| ' + item.padEnd(maxName+1) + '| ' + getLevel(item).padEnd(13) + '|\\n';
  });
  return rows;
}

const md = \`# USER.md — Developer Skill Profile

## Purpose

This file tells all agents how to calibrate their output depth.
Place at \\\`~/.claude/USER.md\\\` for global use.
All agents read this file at session start.

**Quick setup:** Run \\\`bash ~/.claude/setup.sh\\\` — it asks 3 questions and fills this file automatically.
**Manual setup:** Edit the levels below directly.

---

## Identity

Name:         Dev
Role:         Developer
Time zone:    \${Intl.DateTimeFormat().resolvedOptions().timeZone}
Language:     \${respLang}

---

## Overall Level

overall: \${defaultLevel}

---

## Skill Levels

### Programming Languages
| Language    | Level         |
|-------------|---------------|
\${makeTable(langs)}
### Frameworks & Tools
| Tool                   | Level         |
|------------------------|---------------|
\${makeTable(frameworks)}
### Concepts
| Concept          | Level         |
|------------------|---------------|
\${makeTable(concepts)}
---

## Communication Preferences

Response language:    \${respLang}
Code comments:        \${codeLang}
Explanation style:    \${explainStyle}
Error messages:       \${errorLang}
When I am stuck:      \${stuckStyle}

---

## Agent Calibration Rules

When agents read this file, they MUST apply these rules:

| Level        | Agent behavior                                                         |
|--------------|------------------------------------------------------------------------|
| Beginner     | Explain the why. Full working examples. Warnings. Define all jargon.   |
| Intermediate | Brief explanation + code. Skip basics. Highlight non-obvious parts.    |
| Advanced     | Code + trade-offs. No hand-holding. Flag edge cases only.              |
| Expert       | Dense output. Assume full context. Focus on non-trivial only.          |

If USER.md is missing → agent asks once: \"What is your experience level with [topic]?\"
Then calibrates — never asks again in the same session.
\`;

fs.writeFileSync('$USER_FILE_NODE', md);
console.log('OK');
"

echo -e "${GREEN}✅ Developer profile saved: ~/.claude/USER.md${RESET}"
echo -e "  Overall level: ${CYAN}${DEFAULT_LEVEL}${RESET}"
if [ -n "$STRONG_SKILLS" ]; then
  echo -e "  Strong skills: ${CYAN}${STRONG_SKILLS}${RESET} → ${CYAN}${STRONG_LEVEL}${RESET}"
fi
echo -e "  Language:      ${CYAN}${RESP_LANG}${RESET}"
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
echo -e "  👤 Profile:         ${CYAN}~/.claude/USER.md (${DEFAULT_LEVEL})${RESET}"
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
