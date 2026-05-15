#!/usr/bin/env bash
# build-dist.sh — Bundle DevStarter files into dist/ for npm + Inno Setup packaging.
# Excludes dev-only files: memory/, .env, .git, scripts/build-dist.sh itself.
# Idempotent — safe to re-run; dist/ is wiped and rebuilt each time.
#
# Usage:
#   bash scripts/build-dist.sh
#
# Output: dist/ directory ready for:
#   - npm publish  (package.json references dist/ via files[])
#   - Inno Setup   (installer/setup.iss sources from dist/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$ROOT_DIR/dist"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

log() { echo -e "${CYAN}→${RESET} $1"; }
ok()  { echo -e "${GREEN}✅${RESET} $1"; }

log "Cleaning dist/..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

DIRS=("agents" "skills" "sdlc" "templates")
for dir in "${DIRS[@]}"; do
  if [ -d "$ROOT_DIR/$dir" ]; then
    cp -r "$ROOT_DIR/$dir" "$DIST_DIR/$dir"
    ok "Copied $dir/"
  fi
done

FILES=("devstarter-menu.md" "USER.md" "setup.sh" "install.sh" "VERSION" "CHANGELOG.md")
for file in "${FILES[@]}"; do
  if [ -f "$ROOT_DIR/$file" ]; then
    cp "$ROOT_DIR/$file" "$DIST_DIR/$file"
    ok "Copied $file"
  fi
done

# Make shell scripts executable
find "$DIST_DIR" -name "*.sh" -exec chmod +x {} \;

log "Generating file count..."
FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
ok "dist/ ready — $FILE_COUNT files"
echo ""
echo "  Use for npm:        npm publish"
echo "  Use for Inno Setup: installer/setup.iss sources from dist/"
