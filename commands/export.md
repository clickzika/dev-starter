# /export — Export Dev Starter for Backup or Transfer

Package all agents, commands, workflows, and templates into a zip file for backup or transfer to another computer.

---

## How to use

```
/export                    → export to Desktop
/export C:\backup          → export to specific folder
```

---

## Instructions for Claude

When this command is invoked:

### Step 1 — Determine output location

- If user provides a path → use that path
- Default → `~/Desktop/`
- Filename: `dev-starter-v1.zip`

### Step 2 — Verify all files exist

Run this check first:

```bash
echo "=== DEV STARTER FILE CHECK ==="
echo ""
echo "--- Agents (12) ---"
for f in ba backend dba devops docs frontend mobile pm qa security techlead uxui; do
  FILE="$HOME/.claude/agents/$f.md"
  [ -f "$FILE" ] && echo "  ✅ $f.md" || echo "  ❌ MISSING: $f.md"
done

echo ""
echo "--- Teams (5) ---"
for f in leadership engineering datateam platform quality; do
  FILE="$HOME/.claude/agents/teams/$f.md"
  [ -f "$FILE" ] && echo "  ✅ $f.md" || echo "  ❌ MISSING: $f.md"
done
[ -f "$HOME/.claude/agents/teams/README.md" ] && echo "  ✅ README.md" || echo "  ❌ MISSING: README.md"

echo ""
echo "--- Shared ---"
[ -f "$HOME/.claude/agents/shared/vcs-pm-guide.md" ] && echo "  ✅ vcs-pm-guide.md" || echo "  ❌ MISSING: vcs-pm-guide.md"

echo ""
echo "--- Commands (3) ---"
for f in context export import; do
  FILE="$HOME/.claude/commands/$f.md"
  [ -f "$FILE" ] && echo "  ✅ $f.md" || echo "  ❌ MISSING: $f.md"
done

echo ""
echo "--- Workflows (17+) ---"
for f in dev-menu dev-starter dev-change dev-audit dev-dependency dev-dod dev-env dev-existing dev-github dev-handover dev-hotfix dev-incident dev-migrate dev-monitor dev-notion dev-onboarding dev-release dev-retrospective dev-rollback dev-secrets dev-sprint; do
  FILE="$HOME/.claude/$f.md"
  [ -f "$FILE" ] && echo "  ✅ $f.md" || echo "  ❌ MISSING: $f.md"
done

echo ""
echo "--- Templates ---"
[ -f "$HOME/.claude/templates/CLAUDE.md.template" ] && echo "  ✅ CLAUDE.md.template" || echo "  ❌ MISSING: CLAUDE.md.template"
[ -f "$HOME/.claude/templates/project.env.template" ] && echo "  ✅ project.env.template" || echo "  ❌ MISSING: project.env.template"
[ -d "$HOME/.claude/templates/docs" ] && echo "  ✅ templates/docs/" || echo "  ❌ MISSING: templates/docs/"

echo ""
echo "--- Root Files ---"
[ -f "$HOME/.claude/CLAUDE.md" ] && echo "  ✅ CLAUDE.md" || echo "  ❌ MISSING: CLAUDE.md"
[ -f "$HOME/.claude/USER.md" ] && echo "  ✅ USER.md" || echo "  ❌ MISSING: USER.md"
[ -f "$HOME/.claude/TEAM.md" ] && echo "  ✅ TEAM.md" || echo "  ❌ MISSING: TEAM.md"
[ -f "$HOME/.claude/.env.example" ] && echo "  ✅ .env.example" || echo "  ❌ MISSING: .env.example"
[ -f "$HOME/.claude/setup.sh" ] && echo "  ✅ setup.sh" || echo "  ❌ MISSING: setup.sh"
[ -f "$HOME/.claude/README.md" ] && echo "  ✅ README.md" || echo "  ❌ MISSING: README.md"
[ -f "$HOME/.claude/LICENSE" ] && echo "  ✅ LICENSE" || echo "  ❌ MISSING: LICENSE"
```

### Step 3 — Create zip using PowerShell

**⚠️ IMPORTANT: Do NOT include `.env` — it contains secrets.**

```powershell
powershell.exe -NoProfile -Command '
$src = "$env:USERPROFILE\.claude"
$tmpDir = "$env:TEMP\devstarter_export"
if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }

# Create folder structure
New-Item -ItemType Directory -Path "$tmpDir\.claude\agents\shared" -Force | Out-Null
New-Item -ItemType Directory -Path "$tmpDir\.claude\agents\teams" -Force | Out-Null
New-Item -ItemType Directory -Path "$tmpDir\.claude\commands" -Force | Out-Null
New-Item -ItemType Directory -Path "$tmpDir\.claude\templates\docs" -Force | Out-Null

# Copy agents + teams + shared
Copy-Item "$src\agents\*.md" "$tmpDir\.claude\agents\" -ErrorAction SilentlyContinue
Copy-Item "$src\agents\shared\*.md" "$tmpDir\.claude\agents\shared\" -ErrorAction SilentlyContinue
Copy-Item "$src\agents\teams\*.md" "$tmpDir\.claude\agents\teams\" -ErrorAction SilentlyContinue

# Copy commands
Copy-Item "$src\commands\*.md" "$tmpDir\.claude\commands\" -ErrorAction SilentlyContinue

# Copy workflows (dev-*.md)
Copy-Item "$src\dev-*.md" "$tmpDir\.claude\" -ErrorAction SilentlyContinue

# Copy templates
Copy-Item "$src\templates\*" "$tmpDir\.claude\templates\" -Recurse -ErrorAction SilentlyContinue

# Copy root files (NOT .env)
foreach ($f in @("CLAUDE.md", "USER.md", "TEAM.md", ".env.example", "setup.sh", "README.md", "LICENSE", ".gitignore")) {
  if (Test-Path "$src\$f") { Copy-Item "$src\$f" "$tmpDir\.claude\" }
}

# Count files
$count = (Get-ChildItem $tmpDir -Recurse -File).Count

# Create zip
$OUTPUT_DIR = "[OUTPUT_PATH]"
$zipPath = Join-Path $OUTPUT_DIR "dev-starter-v1.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path "$tmpDir\*" -DestinationPath $zipPath -Force
Remove-Item $tmpDir -Recurse -Force

$info = Get-Item $zipPath
Write-Host "Files: $count"
Write-Host "Size: $([math]::Round($info.Length/1KB, 1)) KB"
Write-Host "Path: $($info.FullName)"
'
```

Replace `[OUTPUT_PATH]` with the user's chosen output directory (default: Desktop).

### Step 4 — Show summary

```
EXPORT COMPLETE ✅
━━━━━━━━━━━━━━━━━━
📦 File:     [output path]/dev-starter-v1.zip
📊 Size:     [X] KB
📄 Files:    [N] files exported
🔒 Secrets:  NOT included (.env excluded)

Contents:
  📁 agents/      — 12 specialist agents + 5 teams + shared guide
  📁 commands/    — 3 utility commands (context, export, import)
  📁 dev-*.md     — 17+ workflow runbooks
  📁 templates/   — CLAUDE.md, project.env, doc portal
  📄 Root files   — USER.md, TEAM.md, setup.sh, README.md, LICENSE

To import on new computer:
  1. Extract to ~/.claude/
  2. Copy .env.example → .env and fill in your credentials
  3. Run: gh auth login
  4. Run: bash ~/.claude/setup.sh
  5. Start: claude
```

---

## What is NOT exported (by design)

| Excluded | Reason |
|----------|--------|
| `.env` | Contains secrets (GitHub token, Notion key) |
| `memory/` | User-specific memories |
| `projects/` | Project-specific session data |
| `plugins/` | Installed separately via marketplace |
| `cache/` | Temporary data |
| `file-history/` | Session-specific |
| `plans/` | Session-specific |
| `tasks/` | Session-specific |
