#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# Dev Starter — Publish Release
# Maintainer only — NOT included in user install/update
#
# Usage:
#   bash scripts/publish.sh 1.2.0 "Short description"
#   bash scripts/publish.sh            ← prompts for version
#
# Remotes:
#   origin  → dev-starter-dev.git  (full dev repo)
#   release → dev-starter.git      (public release repo)
#
# Folders excluded from the public release:
EXCLUDE_FROM_RELEASE=("docs" "memory")
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
git pull origin develop 2>/dev/null || true

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

VERSION_PRE_BUMPED=false
if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
  echo -e "${YELLOW}Note: VERSION already at $NEW_VERSION (pre-bumped in release commit — skipping bump step)${NC}"
  VERSION_PRE_BUMPED=true
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
if [ "$VERSION_PRE_BUMPED" = "true" ]; then
  echo -e "${GREEN}  VERSION already at $NEW_VERSION — skipping bump commit${NC}"
  git push origin develop 2>/dev/null || true
else
  echo "$NEW_VERSION" > VERSION
  git add VERSION
  git commit -m "Bump version to $NEW_VERSION"
  git push origin develop
fi

# ─── Step 2: Merge develop → main (local, full) ──────
echo -e "${CYAN}[2/6] Merging develop → main...${NC}"
git checkout main
git merge develop --no-ff -m "release: v$NEW_VERSION — $DESCRIPTION"
git push origin main

# ─── Step 3: Push clean release (strip dev-only folders) ───
echo -e "${CYAN}[3/6] Creating clean release branch for public repo...${NC}"
git checkout -b _release_clean main

for FOLDER in "${EXCLUDE_FROM_RELEASE[@]}"; do
  if [ -d "$FOLDER" ]; then
    git rm -r --cached "$FOLDER" > /dev/null 2>&1 || true
    echo -e "  Excluded: $FOLDER/"
  fi
done

if ! git diff --cached --quiet; then
  git commit -m "chore: strip dev-only folders for public release"
fi

git push release _release_clean:main --force-with-lease
git checkout main
git branch -D _release_clean

# ─── Step 4: Create tag ──────────────────────────────
echo -e "${CYAN}[4/6] Creating tag v$NEW_VERSION...${NC}"
git tag -a "v$NEW_VERSION" -m "v$NEW_VERSION — $DESCRIPTION"
git push release "v$NEW_VERSION"
git push origin "v$NEW_VERSION"

# ─── Step 5: Create GitHub Release ───────────────────
echo -e "${CYAN}[5/7] Creating GitHub Release...${NC}"

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

# Use release remote URL to determine the repo for gh release
RELEASE_REPO=$(git remote get-url release 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
if [ -z "$RELEASE_REPO" ]; then
  echo -e "${RED}Error: 'release' remote not found${NC}"
  exit 1
fi

gh release create "v$NEW_VERSION" \
  --repo "$RELEASE_REPO" \
  --title "v$NEW_VERSION — $DESCRIPTION" \
  --notes "$CHANGELOG_SECTION

---
**Update:** Run \`/update\` in Claude Code to get this version."

# ─── Step 6: Back to develop ─────────────────────────
echo -e "${CYAN}[6/7] Switching back to develop...${NC}"
git checkout develop

# ─── Step 7: Done ────────────────────────────────────
echo -e "${CYAN}[7/7] Verifying...${NC}"
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
