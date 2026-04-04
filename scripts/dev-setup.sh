#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# Dev Starter — Developer Setup
# For maintainers/contributors only.
# Creates symlinks from this repo → ~/.claude/
# so edits in repo are reflected instantly.
#
# Usage:
#   cd dev-starter
#   bash scripts/dev-setup.sh
# ─────────────────────────────────────────────────────

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}  Dev Starter — Developer Setup             ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  Repo:   $REPO_DIR"
echo -e "  Target: $CLAUDE_DIR"
echo ""

# ─── Preflight ───────────────────────────────────────
if [ ! -f "$REPO_DIR/VERSION" ]; then
  echo -e "${RED}Error: Not in dev-starter repo. Run from repo root.${NC}"
  exit 1
fi

if [ ! -d "$REPO_DIR/agents" ] || [ ! -d "$REPO_DIR/commands" ]; then
  echo -e "${RED}Error: Missing agents/ or commands/ in repo.${NC}"
  exit 1
fi

mkdir -p "$CLAUDE_DIR"

# ─── Step 1: Backup existing folders ─────────────────
echo -e "${CYAN}[1/4] Backing up existing files...${NC}"
BACKUP_DIR="$CLAUDE_DIR/.backup/dev-setup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

BACKED_UP=0
for d in agents commands sdlc templates; do
  if [ -d "$CLAUDE_DIR/$d" ] && [ ! -L "$CLAUDE_DIR/$d" ]; then
    mv "$CLAUDE_DIR/$d" "$BACKUP_DIR/$d"
    echo -e "  Backed up: $d/"
    BACKED_UP=1
  elif [ -L "$CLAUDE_DIR/$d" ]; then
    echo -e "  ${YELLOW}Already symlinked: $d/ → $(readlink "$CLAUDE_DIR/$d")${NC}"
  fi
done

for f in devstarter-menu.md update.sh install.sh setup.sh VERSION CHANGELOG.md README.md LICENSE .gitignore .env.example; do
  if [ -f "$CLAUDE_DIR/$f" ] && [ ! -L "$CLAUDE_DIR/$f" ]; then
    cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f" 2>/dev/null || true
    BACKED_UP=1
  fi
done

if [ "$BACKED_UP" = "1" ]; then
  echo -e "  ${GREEN}Backup saved: $BACKUP_DIR${NC}"
else
  echo -e "  ${GREEN}Nothing to backup${NC}"
  rmdir "$BACKUP_DIR" 2>/dev/null || true
fi
echo ""

# ─── Step 2: Create folder symlinks ─────────────────
echo -e "${CYAN}[2/4] Symlinking folders...${NC}"
for d in agents commands sdlc templates; do
  if [ -L "$CLAUDE_DIR/$d" ]; then
    rm "$CLAUDE_DIR/$d"
  fi
  ln -s "$REPO_DIR/$d" "$CLAUDE_DIR/$d"
  echo -e "  ${GREEN}$d/${NC} → $REPO_DIR/$d"
done
echo ""

# ─── Step 3: Create file symlinks ───────────────────
echo -e "${CYAN}[3/4] Symlinking files...${NC}"
for f in devstarter-menu.md update.sh install.sh setup.sh VERSION CHANGELOG.md README.md LICENSE .gitignore .env.example; do
  if [ -f "$REPO_DIR/$f" ]; then
    rm -f "$CLAUDE_DIR/$f" 2>/dev/null || true
    ln -s "$REPO_DIR/$f" "$CLAUDE_DIR/$f"
    echo -e "  ${GREEN}$f${NC}"
  fi
done
echo ""

# ─── Step 4: Ensure user files exist ────────────────
echo -e "${CYAN}[4/4] Checking user files...${NC}"

# USER.md — create default if not exists
if [ ! -f "$CLAUDE_DIR/USER.md" ]; then
  if [ -f "$REPO_DIR/USER.md" ]; then
    cp "$REPO_DIR/USER.md" "$CLAUDE_DIR/USER.md"
    echo -e "  Created: USER.md (default — edit to your profile)"
  fi
else
  echo -e "  ${GREEN}USER.md exists — preserved${NC}"
fi

# .env — create from example if not exists
if [ ! -f "$CLAUDE_DIR/.env" ]; then
  if [ -f "$REPO_DIR/.env.example" ]; then
    cp "$REPO_DIR/.env.example" "$CLAUDE_DIR/.env"
    echo -e "  Created: .env (from .env.example — fill in your keys)"
  fi
else
  echo -e "  ${GREEN}.env exists — preserved${NC}"
fi

# memory/ — create if not exists
if [ ! -d "$CLAUDE_DIR/memory" ]; then
  mkdir -p "$CLAUDE_DIR/memory"
  echo -e "  Created: memory/"
else
  echo -e "  ${GREEN}memory/ exists — preserved${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Developer setup complete!                 ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  Edit files in: ${CYAN}$REPO_DIR${NC}"
echo -e "  Claude sees:   ${CYAN}$CLAUDE_DIR${NC} (via symlinks)"
echo ""
echo -e "  ${YELLOW}Workflow:${NC}"
echo -e "    1. Edit in repo → Claude sees instantly"
echo -e "    2. git commit + push to develop"
echo -e "    3. Ready to release? → bash scripts/publish.sh"
echo ""
