#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# Dev Starter — Update Script
# Pulls the latest version from GitHub and updates
# your ~/.claude/ installation.
# ─────────────────────────────────────────────────────

set -euo pipefail

REPO_URL="https://github.com/clickzika/dev-starter.git"
BRANCH="main"
CLAUDE_DIR="$HOME/.claude"
TMP_DIR="$(mktemp -d)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}  Dev Starter — Update                     ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# ─── Step 1: Check current version ──────────────────
CURRENT_VERSION="unknown"
if [ -f "$CLAUDE_DIR/VERSION" ]; then
  CURRENT_VERSION=$(cat "$CLAUDE_DIR/VERSION")
fi
echo -e "${YELLOW}Current version:${NC} $CURRENT_VERSION"

# ─── Step 2: Clone latest from main ─────────────────
echo -e "${CYAN}Fetching latest version...${NC}"
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" 2>/dev/null

if [ ! -f "$TMP_DIR/VERSION" ]; then
  echo -e "${RED}Error: Could not fetch latest version.${NC}"
  rm -rf "$TMP_DIR"
  exit 1
fi

LATEST_VERSION=$(cat "$TMP_DIR/VERSION")
echo -e "${YELLOW}Latest version:${NC}  $LATEST_VERSION"

# ─── Step 3: Check if update needed ─────────────────
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo ""
  echo -e "${GREEN}Already up to date! ($CURRENT_VERSION)${NC}"
  rm -rf "$TMP_DIR"
  exit 0
fi

echo ""
echo -e "${YELLOW}Updating: $CURRENT_VERSION → $LATEST_VERSION${NC}"
echo ""

# ─── Step 4: Backup user files ──────────────────────
echo -e "${CYAN}[1/4] Backing up your files...${NC}"
BACKUP_DIR="$CLAUDE_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup files that user may have customized
for f in CLAUDE.md USER.md settings.json settings.local.json .env; do
  if [ -f "$CLAUDE_DIR/$f" ]; then
    cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
    echo "  Backed up: $f"
  fi
done

# Backup memory folder
if [ -d "$CLAUDE_DIR/memory" ]; then
  cp -r "$CLAUDE_DIR/memory" "$BACKUP_DIR/memory"
  echo "  Backed up: memory/"
fi

echo -e "${GREEN}  Backup saved to: $BACKUP_DIR${NC}"

# ─── Step 5: Copy new files ─────────────────────────
echo -e "${CYAN}[2/4] Installing new files...${NC}"

# Folders to update (overwrite with latest)
for folder in agents commands sdlc templates; do
  if [ -d "$TMP_DIR/$folder" ]; then
    rm -rf "$CLAUDE_DIR/$folder"
    cp -r "$TMP_DIR/$folder" "$CLAUDE_DIR/$folder"
    echo "  Updated: $folder/"
  fi
done

# Root files to update (toolkit files only, not user files)
for f in update.sh install.sh setup.sh dev-menu.md VERSION CHANGELOG.md; do
  if [ -f "$TMP_DIR/$f" ]; then
    cp "$TMP_DIR/$f" "$CLAUDE_DIR/$f"
    echo "  Updated: $f"
  fi
done

# ─── Step 6: Preserve user files ────────────────────
echo -e "${CYAN}[3/4] Preserving your settings...${NC}"

# Never overwrite these user files
for f in CLAUDE.md USER.md settings.json settings.local.json .env; do
  if [ -f "$BACKUP_DIR/$f" ]; then
    cp "$BACKUP_DIR/$f" "$CLAUDE_DIR/$f"
    echo "  Preserved: $f"
  fi
done

# Never overwrite memory
if [ -d "$BACKUP_DIR/memory" ]; then
  cp -r "$BACKUP_DIR/memory" "$CLAUDE_DIR/memory"
  echo "  Preserved: memory/"
fi

# ─── Step 7: Done ───────────────────────────────────
echo -e "${CYAN}[4/4] Cleaning up...${NC}"
rm -rf "$TMP_DIR"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Updated: $CURRENT_VERSION → $LATEST_VERSION${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  Backup:    $BACKUP_DIR"
echo -e "  Changelog: $CLAUDE_DIR/CHANGELOG.md"
echo ""
echo -e "${YELLOW}Please restart Claude Code to use the new version.${NC}"
echo ""
