#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# Dev Starter — Publish Release
# Maintainer only — NOT included in user install/update
#
# Usage:
#   bash scripts/publish.sh 1.2.0 "Short description"
#   bash scripts/publish.sh            ← prompts for version
# ─────────────────────────────────────────────────────

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CURRENT_BRANCH=$(git branch --show-current)

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}  Dev Starter — Publish Release             ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# ─── Preflight checks ───────────────────────────────
if [ "$CURRENT_BRANCH" != "develop" ]; then
  echo -e "${RED}Error: Must be on 'develop' branch. Currently on '$CURRENT_BRANCH'${NC}"
  exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo -e "${RED}Error: Uncommitted changes found. Commit or stash first.${NC}"
  git status --short
  exit 1
fi

# Pull latest
echo -e "${CYAN}Pulling latest develop...${NC}"
git pull origin develop

# ─── Get version ─────────────────────────────────────
CURRENT_VERSION="unknown"
if [ -f "VERSION" ]; then
  CURRENT_VERSION=$(cat VERSION | tr -d '[:space:]')
fi
echo -e "${YELLOW}Current version:${NC} v$CURRENT_VERSION"

if [ -n "${1:-}" ]; then
  NEW_VERSION="$1"
else
  echo ""
  read -p "New version (e.g. 1.1.0): " NEW_VERSION
fi

# Validate version format
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo -e "${RED}Error: Version must be semver format (e.g. 1.1.0)${NC}"
  exit 1
fi

if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
  echo -e "${RED}Error: New version is same as current ($CURRENT_VERSION)${NC}"
  exit 1
fi

# ─── Get description ─────────────────────────────────
if [ -n "${2:-}" ]; then
  DESCRIPTION="$2"
else
  read -p "Release description (short): " DESCRIPTION
fi

echo ""
echo -e "${YELLOW}Publishing: v$CURRENT_VERSION → v$NEW_VERSION${NC}"
echo -e "${YELLOW}Description: $DESCRIPTION${NC}"
echo ""
read -p "Continue? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
  echo "Cancelled."
  exit 0
fi

# ─── Step 1: Update VERSION file ─────────────────────
echo ""
echo -e "${CYAN}[1/6] Updating VERSION...${NC}"
echo "$NEW_VERSION" > VERSION
git add VERSION
git commit -m "Bump version to $NEW_VERSION"
git push origin develop

# ─── Step 2: Merge develop → main ────────────────────
echo -e "${CYAN}[2/6] Merging develop → main...${NC}"
git checkout main
git pull origin main
git merge develop -m "Release v$NEW_VERSION — $DESCRIPTION"
git push origin main

# ─── Step 3: Create tag ──────────────────────────────
echo -e "${CYAN}[3/6] Creating tag v$NEW_VERSION...${NC}"
git tag -a "v$NEW_VERSION" -m "v$NEW_VERSION — $DESCRIPTION"
git push origin "v$NEW_VERSION"

# ─── Step 4: Create GitHub Release ───────────────────
echo -e "${CYAN}[4/6] Creating GitHub Release...${NC}"

CHANGELOG_SECTION=""
if [ -f "CHANGELOG.md" ]; then
  # Extract the section for this version from CHANGELOG.md
  CHANGELOG_SECTION=$(awk "/^## v$NEW_VERSION/,/^## v[0-9]/" CHANGELOG.md | head -n -1)
fi

if [ -z "$CHANGELOG_SECTION" ]; then
  CHANGELOG_SECTION="## v$NEW_VERSION

$DESCRIPTION

See [CHANGELOG.md](CHANGELOG.md) for details."
fi

gh release create "v$NEW_VERSION" \
  --title "v$NEW_VERSION — $DESCRIPTION" \
  --notes "$CHANGELOG_SECTION

---
**Update:** Run \`/update\` in Claude Code to get this version."

# ─── Step 5: Back to develop ─────────────────────────
echo -e "${CYAN}[5/6] Switching back to develop...${NC}"
git checkout develop

# ─── Step 6: Done ────────────────────────────────────
echo -e "${CYAN}[6/6] Verifying...${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Published: v$NEW_VERSION                  ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  Tag:     v$NEW_VERSION"
echo -e "  Release: https://github.com/clickzika/dev-starter/releases/tag/v$NEW_VERSION"
echo -e "  Branch:  main (updated)"
echo -e "  Current: develop"
echo ""
echo -e "${YELLOW}Users can update with: /update${NC}"
echo ""
