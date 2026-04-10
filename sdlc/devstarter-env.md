# dev-env.md — Local Development Environment Setup

## Model: Haiku (`claude-haiku-4-5-20251001`)

## How to Use

When setting up a local dev environment from scratch:
```
claude
> Read ~/.claude/devstarter-env.md and setup my local environment
```

---

## PHASE 1 — Detect Current State

Agent checks what is already installed:

```bash
echo "=== System Check ===" && \
echo "OS: $(uname -s)" && \
echo "Node: $(node --version 2>/dev/null || echo NOT FOUND)" && \
echo "npm: $(npm --version 2>/dev/null || echo NOT FOUND)" && \
echo "dotnet: $(dotnet --version 2>/dev/null || echo NOT FOUND)" && \
echo "git: $(git --version 2>/dev/null || echo NOT FOUND)" && \
echo "docker: $(docker --version 2>/dev/null || echo NOT FOUND)" && \
echo "gh: $(gh --version 2>/dev/null || echo NOT FOUND)" && \
echo "claude: $(claude --version 2>/dev/null || echo NOT FOUND)"
```

Shows what is missing and needs to be installed.

---

## PHASE 2 — Install Prerequisites

Agent provides OS-specific install commands:

### Windows
```powershell
# Install Chocolatey first
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install git nodejs dotnet-sdk docker-desktop gh -y
```

### macOS
```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install git node dotnet-sdk docker gh
```

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y git curl
# Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
# .NET
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get install -y dotnet-sdk-8.0
# GitHub CLI
sudo apt-get install -y gh
```

---

## PHASE 3 — Project Setup

```bash
# Clone project
git clone https://github.com/[org]/[repo].git
cd [repo]

# Setup environment file
cp .env.example .env
echo "⚠️  Please fill in .env values (ask team lead for credentials)"

# Install dependencies
cd frontend && npm install && cd ..
cd backend && dotnet restore && cd ..

# Start services
docker compose up -d

# Verify
curl http://localhost:5000/health
curl http://localhost:4200
```

---

## PHASE 4 — IDE Setup

**VS Code extensions:**
```json
{
  "recommendations": [
    "ms-dotnettools.csdevkit",
    "angular.ng-template",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "ms-azuretools.vscode-docker",
    "eamodio.gitlens",
    "github.copilot"
  ]
}
```

Agent writes `.vscode/extensions.json` if not present.

**VS Code settings:**
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[csharp]": {
    "editor.defaultFormatter": "ms-dotnettools.csdevkit"
  },
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

---

## PHASE 5 — Verify Everything Works

```
[ ] git clone successful
[ ] .env filled with real values
[ ] docker compose up — all containers healthy
[ ] Backend /health returns 200
[ ] Frontend loads at localhost:4200
[ ] Can login with test account
[ ] All tests pass: dotnet test + ng test
[ ] Claude Code CLI installed and authenticated
[ ] GitHub CLI authenticated: gh auth status
```

---

## Common Issues + Fixes

| Problem | Likely cause | Fix |
|---------|-------------|-----|
| Port already in use | Another service running | `lsof -i :[port]` then kill |
| Docker permission denied | Not in docker group | `sudo usermod -aG docker $USER` then logout/login |
| dotnet not found | PATH not updated | Restart terminal |
| npm install fails | Node version mismatch | Use nvm to switch version |
| DB connection refused | MSSQL container not ready | Wait 30s, retry |
| Angular compile error | Node modules mismatch | Delete node_modules + npm install |
