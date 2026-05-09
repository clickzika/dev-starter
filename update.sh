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
for folder in agents skills sdlc templates; do
  if [ -d "$TMP_DIR/$folder" ]; then
    rm -rf "$CLAUDE_DIR/$folder"
    cp -r "$TMP_DIR/$folder" "$CLAUDE_DIR/$folder"
    echo "  Updated: $folder/"
  fi
done

# Migration: remove commands/ if skills/ now exists (v2.x → v3.x)
if [ -d "$CLAUDE_DIR/skills" ] && [ -d "$CLAUDE_DIR/commands" ]; then
  rm -rf "$CLAUDE_DIR/commands"
  echo "  Migrated: commands/ removed (replaced by skills/)"
fi

# Restore agents/custom/ from backup (never overwrite user custom agents)
if [ -d "$BACKUP_DIR/agents/custom" ]; then
  mkdir -p "$CLAUDE_DIR/agents/custom"
  cp -r "$BACKUP_DIR/agents/custom/." "$CLAUDE_DIR/agents/custom/"
  echo "  Preserved: agents/custom/"
else
  mkdir -p "$CLAUDE_DIR/agents/custom"
fi

# Root files to update (toolkit files only, not user files)
for f in update.sh install.sh setup.sh devstarter-menu.md VERSION CHANGELOG.md; do
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

# ─── Step 7: Migration notes for major version jumps ───
echo -e "${CYAN}[4/4] Cleaning up...${NC}"
rm -rf "$TMP_DIR"

# Compare major.minor of old vs new — print breaking-change notes if jumping
old_major=$(echo "$CURRENT_VERSION" | cut -d. -f1)
old_minor=$(echo "$CURRENT_VERSION" | cut -d. -f2)
new_major=$(echo "$LATEST_VERSION" | cut -d. -f1)
new_minor=$(echo "$LATEST_VERSION" | cut -d. -f2)

print_breaking_changes() {
  # Argument: $1 = "from-major.minor" (e.g. "3.4")
  case "$1" in
    "3.4"|"3.3"|"3.2"|"3.1"|"3.0"|"2."*|"1."*)
      echo -e "${YELLOW}  ⚠️  Removed in v3.5:${NC} 13 thin agent slash-commands (devstarter-pm,"
      echo -e "${YELLOW}      devstarter-techlead, etc.) — use ${GREEN}@pm${YELLOW}, ${GREEN}@techlead${YELLOW}, etc."
      echo -e "${YELLOW}      directly, or run ${GREEN}/devstarter-agents${YELLOW} to see the roster."
      echo ""
      ;;
  esac
  case "$1" in
    "3.5"|"3.4"|"3.3"|"3.2"|"3.1"|"3.0"|"2."*|"1."*)
      echo -e "${YELLOW}  ⚠️  Stricter in v3.6:${NC} Gate A2 (Doc Quality Preflight) and Gate A4"
      echo -e "${YELLOW}      (Fitness Functions + 26-item PR Review Checklist) now block on"
      echo -e "${YELLOW}      missing SLO / Threat Model / OpenAPI / WCAG / ADR. Existing"
      echo -e "${YELLOW}      features in develop may need a docs catch-up before next change."
      echo ""
      echo -e "${YELLOW}  ⚠️  New CI template in v3.6:${NC} ${CYAN}templates/github/fitness-functions.yml${NC}"
      echo -e "${YELLOW}      Copy it to your project's ${CYAN}.github/workflows/${YELLOW} and add"
      echo -e "${YELLOW}      ${GREEN}'Fitness Functions / All checks'${YELLOW} as a required status check."
      echo ""
      ;;
  esac
  case "$1" in
    "3.6"|"3.5"|"3.4"|"3.3"|"3.2"|"3.1"|"3.0"|"2."*|"1."*)
      echo -e "${YELLOW}  ✨ New in v3.7:${NC} 4 new commands"
      echo -e "${YELLOW}      ${GREEN}/devstarter-postmortem${YELLOW}, ${GREEN}/devstarter-adr${YELLOW},"
      echo -e "${YELLOW}      ${GREEN}/devstarter-profile${YELLOW}, ${GREEN}/devstarter-compliance${NC}"
      echo -e "${YELLOW}      Plus ${GREEN}--quick${YELLOW} flag on ${GREEN}/devstarter-change${YELLOW} for scoped reading."
      echo ""
      ;;
  esac
}

# Detect a "big jump" — different major or different minor
if [ "$CURRENT_VERSION" != "unknown" ] && \
   [ "$old_major.$old_minor" != "$new_major.$new_minor" ]; then
  echo ""
  echo -e "${CYAN}═══════════════════════════════════════════${NC}"
  echo -e "${CYAN}  Migration notes: $CURRENT_VERSION → $LATEST_VERSION${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════${NC}"
  echo ""
  print_breaking_changes "$old_major.$old_minor"
  echo -e "${CYAN}  Stale files removed:${NC} update replaced agents/, skills/, sdlc/,"
  echo -e "${CYAN}  templates/ entirely (rm -rf + cp -r). Any deleted skill or runbook"
  echo -e "${CYAN}  from prior versions is now properly cleaned. Custom agents in"
  echo -e "${CYAN}  agents/custom/ were preserved from your backup.${NC}"
  echo ""
  echo -e "  Full changelog: ${CYAN}$CLAUDE_DIR/CHANGELOG.md${NC}"
  echo ""
fi

echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Updated: $CURRENT_VERSION → $LATEST_VERSION${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  Backup:    $BACKUP_DIR"
echo -e "  Changelog: $CLAUDE_DIR/CHANGELOG.md"
echo ""
echo -e "${YELLOW}Please restart Claude Code to use the new version.${NC}"
echo ""
