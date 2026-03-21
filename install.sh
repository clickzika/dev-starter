#!/bin/bash
# install.sh — One-command installer for Dev Starter V1
#
# Usage (run from anywhere):
#   curl -sL https://raw.githubusercontent.com/clickzika/dev-starter/develop/install.sh | bash
#
# Or if you already cloned:
#   bash install.sh
#
# Works on: Windows (Git Bash/WSL), macOS, Linux

set -e

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

REPO_URL="https://github.com/clickzika/dev-starter.git"
BRANCH="develop"
CLAUDE_DIR="$HOME/.claude"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'devstarter')"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Dev Starter V1 — One-Command Installer     ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

# ─── Step 0: Check git is available ──────────────────
if ! command -v git &>/dev/null; then
  echo -e "${RED}❌ git is required. Install from https://git-scm.com${RESET}"
  exit 1
fi

# ─── Step 1: Clone to temp directory ─────────────────
echo -e "${CYAN}${BOLD}Step 1/4 — Downloading Dev Starter...${RESET}"

# Check if we're running from inside the cloned repo already
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
if [ -f "$SCRIPT_DIR/dev-menu.md" ] && [ -d "$SCRIPT_DIR/agents" ]; then
  echo -e "  ${GREEN}✅ Running from cloned repo: $SCRIPT_DIR${RESET}"
  SOURCE_DIR="$SCRIPT_DIR"
else
  echo -e "  Cloning from $REPO_URL..."
  git clone --branch "$BRANCH" --depth 1 --quiet "$REPO_URL" "$TMP_DIR/dev-starter"
  SOURCE_DIR="$TMP_DIR/dev-starter"
  echo -e "  ${GREEN}✅ Downloaded${RESET}"
fi
echo ""

# ─── Step 2: Backup existing ~/.claude/ if needed ────
echo -e "${CYAN}${BOLD}Step 2/4 — Preparing ~/.claude/...${RESET}"

mkdir -p "$CLAUDE_DIR"

# Check if there are existing files that would be overwritten
EXISTING_FILES=0
for check in agents commands sdlc templates dev-menu.md USER.md setup.sh; do
  if [ -e "$CLAUDE_DIR/$check" ]; then
    EXISTING_FILES=1
    break
  fi
done

if [ "$EXISTING_FILES" = "1" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backups/pre-install-$(date +%Y%m%d-%H%M%S)"
  echo -e "  ${YELLOW}Existing files found — backing up to:${RESET}"
  echo -e "  ${YELLOW}$BACKUP_DIR${RESET}"
  mkdir -p "$BACKUP_DIR"

  for item in agents commands sdlc templates dev-menu.md USER.md TEAM.md setup.sh .env.example; do
    if [ -e "$CLAUDE_DIR/$item" ]; then
      cp -r "$CLAUDE_DIR/$item" "$BACKUP_DIR/" 2>/dev/null || true
    fi
  done
  echo -e "  ${GREEN}✅ Backup saved${RESET}"
else
  echo -e "  ${GREEN}✅ Clean install — no existing files${RESET}"
fi
echo ""

# ─── Step 3: Copy files to ~/.claude/ ────────────────
echo -e "${CYAN}${BOLD}Step 3/4 — Installing files...${RESET}"

# Create directory structure
mkdir -p "$CLAUDE_DIR/agents/shared"
mkdir -p "$CLAUDE_DIR/agents/teams"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/sdlc"
mkdir -p "$CLAUDE_DIR/templates/docs"

# Copy agents
cp -r "$SOURCE_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
cp -r "$SOURCE_DIR/agents/shared/"*.md "$CLAUDE_DIR/agents/shared/" 2>/dev/null || true
cp -r "$SOURCE_DIR/agents/teams/"*.md "$CLAUDE_DIR/agents/teams/" 2>/dev/null || true

# Copy commands
cp -r "$SOURCE_DIR/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true

# Copy SDLC workflows
cp -r "$SOURCE_DIR/sdlc/"*.md "$CLAUDE_DIR/sdlc/" 2>/dev/null || true

# Copy templates
cp -r "$SOURCE_DIR/templates/"* "$CLAUDE_DIR/templates/" 2>/dev/null || true

# Copy root files (never overwrite .env if exists)
cp "$SOURCE_DIR/dev-menu.md" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/.env.example" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/setup.sh" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/README.md" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/LICENSE" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/.gitignore" "$CLAUDE_DIR/" 2>/dev/null || true

# Copy USER.md template (setup.sh will overwrite with wizard answers)
cp "$SOURCE_DIR/USER.md" "$CLAUDE_DIR/" 2>/dev/null || true

# Count installed files
FILE_COUNT=$(find "$CLAUDE_DIR" -name "*.md" -o -name "*.html" -o -name "*.sh" -o -name "*.template" | wc -l | tr -d ' ')
echo -e "  ${GREEN}✅ $FILE_COUNT files installed to ~/.claude/${RESET}"
echo ""

# ─── Step 4: Run setup.sh ────────────────────────────
echo -e "${CYAN}${BOLD}Step 4/4 — Running setup wizard...${RESET}"
echo ""

# Make setup.sh executable
chmod +x "$CLAUDE_DIR/setup.sh"

# Run setup (asks GitHub, Notion, Profile, Permissions)
bash "$CLAUDE_DIR/setup.sh"

# ─── Cleanup temp directory ──────────────────────────
if [ -d "$TMP_DIR/dev-starter" ]; then
  rm -rf "$TMP_DIR"
fi

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║         ✅ Installation Complete!             ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  To start:"
echo -e "  ${CYAN}claude${RESET}"
echo -e "  ${CYAN}> Read ~/.claude/dev-menu.md and help me get started${RESET}"
echo ""
