#!/bin/bash
# install.sh — One-command installer for Dev Starter V1
#
# Prefer a simpler install? Try:
#   npm:     npx devstarter init
#   Windows: Download DevStarter-Setup.exe from GitHub Releases
#            https://github.com/clickzika/dev-starter/releases/latest
#
# Bash install (Mac / Linux / Git Bash on Windows):
#   curl -sL https://raw.githubusercontent.com/clickzika/dev-starter/main/install.sh | bash
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
BRANCH="main"
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
if [ -f "$SCRIPT_DIR/devstarter-menu.md" ] && [ -d "$SCRIPT_DIR/agents" ]; then
  echo -e "  ${GREEN}✅ Running from cloned repo: $SCRIPT_DIR${RESET}"
  SOURCE_DIR="$SCRIPT_DIR"
else
  echo -e "  Cloning from $REPO_URL..."
  git clone --branch "$BRANCH" --depth 1 --quiet "$REPO_URL" "$TMP_DIR/dev-starter"
  SOURCE_DIR="$TMP_DIR/dev-starter"
  echo -e "  ${GREEN}✅ Downloaded${RESET}"
fi
echo ""

# ─── Step 2: Wipe DevStarter dirs, save user files ──
echo -e "${CYAN}${BOLD}Step 2/4 — Preparing ~/.claude/...${RESET}"

mkdir -p "$CLAUDE_DIR"

# Save user-owned files to temp before wipe
SAVE_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'devstarter-save')"
REINSTALL=0

for f in USER.md CLAUDE.md settings.json settings.local.json .env; do
  if [ -f "$CLAUDE_DIR/$f" ]; then
    cp "$CLAUDE_DIR/$f" "$SAVE_DIR/" 2>/dev/null && REINSTALL=1
  fi
done
if [ -d "$CLAUDE_DIR/memory" ]; then
  cp -r "$CLAUDE_DIR/memory" "$SAVE_DIR/" 2>/dev/null && REINSTALL=1
fi
if [ -d "$CLAUDE_DIR/agents/custom" ]; then
  mkdir -p "$SAVE_DIR/agents"
  cp -r "$CLAUDE_DIR/agents/custom" "$SAVE_DIR/agents/" 2>/dev/null && REINSTALL=1
fi

# Wipe DevStarter-owned dirs and root files
for dir in agents skills sdlc templates scripts; do
  rm -rf "$CLAUDE_DIR/$dir"
done
for f in devstarter-menu.md update.sh install.sh setup.sh README.md LICENSE .gitignore VERSION CHANGELOG.md .env.example; do
  rm -f "$CLAUDE_DIR/$f"
done

if [ "$REINSTALL" = "1" ]; then
  echo -e "  ${GREEN}✅ Reinstall — user files preserved${RESET}"
else
  echo -e "  ${GREEN}✅ Fresh install${RESET}"
fi
echo ""

# ─── Step 3: Copy files to ~/.claude/ ────────────────
echo -e "${CYAN}${BOLD}Step 3/4 — Installing files...${RESET}"

# Create directory structure
mkdir -p "$CLAUDE_DIR/agents/shared"
mkdir -p "$CLAUDE_DIR/agents/custom"
mkdir -p "$CLAUDE_DIR/agents/teams"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/sdlc"
mkdir -p "$CLAUDE_DIR/templates/docs"

# Copy agents
cp -r "$SOURCE_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
cp -r "$SOURCE_DIR/agents/shared/"*.md "$CLAUDE_DIR/agents/shared/" 2>/dev/null || true
cp -r "$SOURCE_DIR/agents/teams/"*.md "$CLAUDE_DIR/agents/teams/" 2>/dev/null || true

# Copy skills
cp -r "$SOURCE_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true

# Copy SDLC workflows
cp -r "$SOURCE_DIR/sdlc/"*.md "$CLAUDE_DIR/sdlc/" 2>/dev/null || true

# Copy templates
cp -r "$SOURCE_DIR/templates/"* "$CLAUDE_DIR/templates/" 2>/dev/null || true

# Copy scripts
mkdir -p "$CLAUDE_DIR/scripts"
cp -r "$SOURCE_DIR/scripts/"*.sh "$CLAUDE_DIR/scripts/" 2>/dev/null || true

# Copy root files (never overwrite .env if exists)
cp "$SOURCE_DIR/devstarter-menu.md" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/.env.example" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/setup.sh" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/update.sh" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/README.md" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/LICENSE" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/.gitignore" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/VERSION" "$CLAUDE_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/CHANGELOG.md" "$CLAUDE_DIR/" 2>/dev/null || true

# Copy USER.md template (setup.sh will overwrite with wizard answers)
cp "$SOURCE_DIR/USER.md" "$CLAUDE_DIR/" 2>/dev/null || true

# Count installed files
FILE_COUNT=$(find "$CLAUDE_DIR" -name "*.md" -o -name "*.html" -o -name "*.sh" -o -name "*.template" | wc -l | tr -d ' ')
echo -e "  ${GREEN}✅ $FILE_COUNT files installed to ~/.claude/${RESET}"

# Restore user-owned files and agents/custom/
for f in USER.md CLAUDE.md settings.json settings.local.json .env; do
  if [ -f "$SAVE_DIR/$f" ]; then
    cp "$SAVE_DIR/$f" "$CLAUDE_DIR/" 2>/dev/null || true
  fi
done
if [ -d "$SAVE_DIR/memory" ]; then
  rm -rf "$CLAUDE_DIR/memory"
  cp -r "$SAVE_DIR/memory" "$CLAUDE_DIR/memory" 2>/dev/null || true
fi
if [ -d "$SAVE_DIR/agents/custom" ]; then
  mkdir -p "$CLAUDE_DIR/agents/custom"
  cp -r "$SAVE_DIR/agents/custom/." "$CLAUDE_DIR/agents/custom/" 2>/dev/null || true
fi
rm -rf "$SAVE_DIR"
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
echo -e "  ${CYAN}> Read ~/.claude/devstarter-menu.md and help me get started${RESET}"
echo ""
