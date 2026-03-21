# /import — Import Dev Starter from Backup

Restore agents, commands, workflows, and templates from a dev-starter-v1.zip backup.

---

## How to use

```
/import                                  → import from Desktop/dev-starter-v1.zip
/import C:\backup\dev-starter-v1.zip     → import from specific file
```

---

## Instructions for Claude

When this command is invoked:

### Step 1 — Find the zip file

- If user provides a path → use that path
- Default search order:
  1. `~/Desktop/dev-starter-v1.zip`
  2. `~/Downloads/dev-starter-v1.zip`
  3. Current directory `./dev-starter-v1.zip`
  4. Legacy name: `claudeteam.zip` (same search order)

If not found, ask: "Where is your dev-starter-v1.zip file?"

### Step 2 — Backup current config (safety)

Before overwriting, backup existing files:

```powershell
powershell.exe -NoProfile -Command '
$backup = "$env:USERPROFILE\.claude\backups\pre-import-$(Get-Date -Format yyyyMMdd-HHmmss)"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$dirs = @("agents", "commands", "templates")
foreach ($d in $dirs) {
  $src = "$env:USERPROFILE\.claude\$d"
  if (Test-Path $src) {
    Copy-Item $src "$backup\$d" -Recurse -Force
  }
}

# Backup dev-*.md workflow files
Get-ChildItem "$env:USERPROFILE\.claude\dev-*.md" -ErrorAction SilentlyContinue |
  ForEach-Object { Copy-Item $_.FullName "$backup\" }

# Backup root files
foreach ($f in @("CLAUDE.md", "USER.md", "TEAM.md")) {
  if (Test-Path "$env:USERPROFILE\.claude\$f") {
    Copy-Item "$env:USERPROFILE\.claude\$f" "$backup\"
  }
}

Write-Host "Backup saved to: $backup"
'
```

### Step 3 — Extract zip

```powershell
powershell.exe -NoProfile -Command '
$zipPath = "[ZIP_PATH]"
$dest = "$env:USERPROFILE"
Expand-Archive -Path $zipPath -DestinationPath $dest -Force
Write-Host "Extracted to $dest\.claude\"
'
```

Replace `[ZIP_PATH]` with the actual zip file path.

### Step 4 — Verify import

```bash
echo "=== IMPORT VERIFICATION ==="

echo "--- Agents ---"
count=$(ls "$HOME/.claude/agents/"*.md 2>/dev/null | wc -l)
echo "  $count agent files found (expected: 12)"

echo "--- Teams ---"
count=$(ls "$HOME/.claude/agents/teams/"*.md 2>/dev/null | wc -l)
echo "  $count team files found (expected: 6)"

echo "--- Commands ---"
count=$(ls "$HOME/.claude/commands/"*.md 2>/dev/null | wc -l)
echo "  $count command files found (expected: 3)"

echo "--- Workflows ---"
count=$(ls "$HOME/.claude/dev-"*.md 2>/dev/null | wc -l)
echo "  $count workflow files found (expected: 17+)"

echo "--- Templates ---"
count=$(find "$HOME/.claude/templates/" -type f 2>/dev/null | wc -l)
echo "  $count template files found"
```

### Step 5 — Check credentials

```bash
if [ -f "$HOME/.claude/.env" ]; then
  echo "✅ .env exists"
  grep -q "GITHUB_USERNAME=." "$HOME/.claude/.env" && echo "  ✅ GITHUB_USERNAME set" || echo "  ❌ GITHUB_USERNAME empty"
  grep -q "GITHUB_TOKEN=." "$HOME/.claude/.env" && echo "  ✅ GITHUB_TOKEN set" || echo "  ⚠️  GITHUB_TOKEN not set (use gh auth login instead)"
  grep -q "NOTION_API_KEY=." "$HOME/.claude/.env" && echo "  ✅ NOTION_API_KEY set" || echo "  ⚠️  NOTION_API_KEY not set (optional)"
  grep -q "PROJECTS_ROOT=." "$HOME/.claude/.env" && echo "  ✅ PROJECTS_ROOT set" || echo "  ⚠️  PROJECTS_ROOT not set (will use ~/Projects)"
else
  echo "❌ No .env file found"
  echo ""
  echo "Run: cp ~/.claude/.env.example ~/.claude/.env"
  echo "Then fill in your credentials."
fi
```

### Step 6 — Check GitHub CLI

```bash
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI authenticated"
  else
    echo "⚠️  GitHub CLI installed but not authenticated"
    echo "   Run: gh auth login"
  fi
else
  echo "❌ GitHub CLI not installed"
  echo "   Install: winget install GitHub.cli (Windows)"
  echo "   Install: brew install gh (macOS)"
fi
```

### Step 7 — Show summary

```
IMPORT COMPLETE ✅
━━━━━━━━━━━━━━━━━━
📦 Source:    [zip path]
📁 Backup:   [backup path]
📄 Imported:  [N] files

Status:
  ✅ 12 agents loaded
  ✅ 5 teams loaded
  ✅ 3 commands loaded
  ✅ 17+ workflows loaded
  ✅ Templates loaded
  [✅/❌] .env credentials
  [✅/❌] GitHub CLI

[If .env missing:]
⚠️ Action needed:
  1. cp ~/.claude/.env.example ~/.claude/.env
  2. Fill in your GitHub + Notion credentials
  3. Run: gh auth login

[If everything OK:]
🚀 Ready! Start with:
  claude
  > Read ~/.claude/dev-menu.md and help me get started
```
