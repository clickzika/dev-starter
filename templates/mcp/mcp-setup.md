# MCP Server Setup Guide

This directory contains ready-to-use MCP (Model Context Protocol) server configs for Claude Code.

## How to activate

Copy the desired JSON config into `~/.claude/mcp.json` (or merge with existing):

```bash
# Activate GitHub MCP
cp ~/.claude/templates/mcp/github.json ~/.claude/mcp.json
```

Or run `/devstarter-mcp` to get an interactive picker.

---

## Available Configs

### github.json — GitHub MCP Server

Gives Claude Code direct access to GitHub repos, issues, PRs, and code search.

**Requires:**
- `GITHUB_TOKEN` env var — create at https://github.com/settings/tokens
- Scopes needed: `repo`, `read:org`

**Set env var:**
```bash
# Add to .env or export before running claude
export GITHUB_TOKEN=ghp_yourtoken
```

**Capabilities:**
- Read/create/update issues and PRs
- Search code, commits, and repos
- Read file contents from any repo

---

### postgres.json — PostgreSQL MCP Server

Gives Claude Code read access to a PostgreSQL database for schema inspection and query assistance.

**Requires:**
- `DATABASE_URL` env var in format: `postgresql://user:pass@host:5432/dbname`

**Set env var:**
```bash
export DATABASE_URL=postgresql://myuser:mypass@localhost:5432/mydb
```

**Capabilities:**
- List tables and schemas
- Describe table structure
- Run SELECT queries (read-only)

---

### sqlite.json — SQLite MCP Server

Gives Claude Code access to a local SQLite database file.

**Requires:**
- `SQLITE_DB_PATH` env var pointing to your `.db` file

**Set env var:**
```bash
export SQLITE_DB_PATH=/path/to/database.db
```

**Capabilities:**
- List tables
- Describe schema
- Run SELECT queries

---

### brave-search.json — Brave Search MCP Server

Gives Claude Code web search capabilities via Brave Search API.

**Requires:**
- `BRAVE_API_KEY` env var — get a free key at https://api.search.brave.com

**Set env var:**
```bash
export BRAVE_API_KEY=BSA_yourkey
```

**Capabilities:**
- Web search from within Claude Code
- News search
- Image search

---

### mssql.json — Microsoft SQL Server MCP Server

Gives Claude Code read access to a SQL Server database for schema inspection and query assistance.

> **Note:** Uses community package `mcp-server-mssql`. Verify the latest package name at npmjs.com before use.

**Requires:**
- `MSSQL_SERVER` — hostname or IP (e.g. `localhost` or `myserver.database.windows.net`)
- `MSSQL_DATABASE` — database name
- `MSSQL_USER` — SQL login username
- `MSSQL_PASSWORD` — SQL login password
- `MSSQL_PORT` — default `1433`
- `MSSQL_ENCRYPT` — default `true` (required for Azure SQL)

**Set env vars:**
```bash
export MSSQL_SERVER=localhost
export MSSQL_DATABASE=MyDatabase
export MSSQL_USER=sa
export MSSQL_PASSWORD=YourPassword
export MSSQL_PORT=1433
export MSSQL_ENCRYPT=false   # set true for Azure SQL
```

**Azure SQL connection example:**
```bash
export MSSQL_SERVER=myserver.database.windows.net
export MSSQL_DATABASE=MyDatabase
export MSSQL_USER=myadmin
export MSSQL_PASSWORD=YourPassword
export MSSQL_ENCRYPT=true
```

**Capabilities:**
- List tables, views, stored procedures
- Describe schema and column types
- Run SELECT queries (read-only)

---

### jira.json — Jira MCP Server

Gives Claude Code access to Jira issues, sprints, projects, and boards.

**Requires:**
- `JIRA_URL` — your Jira base URL (e.g. `https://yourcompany.atlassian.net`)
- `JIRA_EMAIL` — your Atlassian account email
- `JIRA_API_TOKEN` — create at https://id.atlassian.com/manage-profile/security/api-tokens

**Set env vars:**
```bash
export JIRA_URL=https://yourcompany.atlassian.net
export JIRA_EMAIL=you@example.com
export JIRA_API_TOKEN=yourtoken
```

**Capabilities:**
- List, search, create, and update issues
- Read sprint boards and backlogs
- Transition issue status

---

### firecrawl.json — Firecrawl MCP Server

Web scraping and crawling — converts any URL to clean Markdown for Claude.

**Requires:**
- `FIRECRAWL_API_KEY` — get at https://firecrawl.dev

**Set env var:**
```bash
export FIRECRAWL_API_KEY=fc-yourkey
```

**Capabilities:**
- Scrape single pages to Markdown
- Crawl entire sites
- Extract structured data from pages

---

### supabase.json — Supabase MCP Server

Gives Claude Code access to Supabase projects, databases, and management API.

**Requires:**
- `SUPABASE_URL` — your project URL (e.g. `https://xyz.supabase.co`)
- `SUPABASE_SERVICE_ROLE_KEY` — service role key from Supabase dashboard

**Set env vars:**
```bash
export SUPABASE_URL=https://xyz.supabase.co
export SUPABASE_SERVICE_ROLE_KEY=yourkey
```

**Capabilities:**
- Query tables, run SQL
- Manage auth users
- Access storage buckets

---

### memory.json — Memory MCP Server

Persistent knowledge graph memory — Claude remembers facts across sessions.

**Requires:** Nothing (local file-based storage)

**Capabilities:**
- Store and retrieve entities, relationships, and observations
- Build up persistent context across conversations

---

### omega-memory.json — Omega Memory MCP Server

Enhanced persistent memory with multi-strategy recall and priority scoring.

**Requires:** Nothing (local storage)

**Capabilities:**
- Episodic, semantic, and procedural memory layers
- Priority-based recall

---

### longhand.json — Longhand MCP Server

Note-taking and knowledge capture from within Claude Code.

**Requires:** Nothing

**Capabilities:**
- Create and retrieve notes
- Tag and search notes

---

### sequential-thinking.json — Sequential Thinking MCP Server

Forces structured step-by-step reasoning for complex problems.

**Requires:** Nothing

**Capabilities:**
- Break problems into numbered thought steps
- Revise reasoning mid-stream
- Produce final synthesis

---

### vercel.json — Vercel MCP Server

Deploy and manage Vercel projects from Claude Code.

**Requires:**
- `VERCEL_TOKEN` — create at https://vercel.com/account/tokens

**Set env var:**
```bash
export VERCEL_TOKEN=yourtoken
```

**Capabilities:**
- List and trigger deployments
- Manage environment variables
- Read deployment logs

---

### railway.json — Railway MCP Server

Deploy and manage Railway projects and services.

**Requires:**
- `RAILWAY_TOKEN` — create at https://railway.com/account/tokens

**Set env var:**
```bash
export RAILWAY_TOKEN=yourtoken
```

**Capabilities:**
- List projects and services
- Trigger deployments
- Read logs and metrics

---

### cloudflare.json — Cloudflare MCP Server

Manage Cloudflare Workers, KV, D1, and R2 from Claude Code.

**Requires:**
- `CLOUDFLARE_ACCOUNT_ID` — from Cloudflare dashboard sidebar
- `CLOUDFLARE_API_TOKEN` — create at https://dash.cloudflare.com/profile/api-tokens

**Set env vars:**
```bash
export CLOUDFLARE_ACCOUNT_ID=youraccount
export CLOUDFLARE_API_TOKEN=yourtoken
```

**Capabilities:**
- Deploy and manage Workers scripts
- Read/write KV namespaces
- Query D1 databases, list R2 buckets

---

### clickhouse.json — ClickHouse MCP Server

Gives Claude Code access to ClickHouse analytics databases.

**Requires:**
- `CLICKHOUSE_HOST` — hostname (e.g. `localhost` or cloud endpoint)
- `CLICKHOUSE_USER` — database user
- `CLICKHOUSE_PASSWORD` — database password

**Set env vars:**
```bash
export CLICKHOUSE_HOST=localhost
export CLICKHOUSE_USER=default
export CLICKHOUSE_PASSWORD=yourpassword
```

**Capabilities:**
- List tables and schemas
- Run SELECT queries
- Inspect materialized views

---

### exa-search.json — Exa Search MCP Server

AI-powered semantic web search — better than keyword search for research.

**Requires:**
- `EXA_API_KEY` — get at https://exa.ai

**Set env var:**
```bash
export EXA_API_KEY=yourkey
```

**Capabilities:**
- Semantic similarity search
- Find similar pages to a URL
- Search with date filters

---

### context7.json — Context7 MCP Server

Pulls up-to-date library documentation directly into Claude's context.

**Requires:**
- `CONTEXT7_API_KEY` — get at https://context7.com

**Set env var:**
```bash
export CONTEXT7_API_KEY=yourkey
```

**Capabilities:**
- Fetch current docs for any npm/PyPI package
- Resolve library + version to authoritative API docs

---

### magic-ui.json — Magic UI MCP Server

Generate Magic UI components from natural language descriptions.

**Requires:** Nothing

**Capabilities:**
- Scaffold animated React UI components
- Browse Magic UI component catalog

---

### filesystem.json — Filesystem MCP Server

Direct file system read/write access for Claude Code.

**Requires:** Nothing (uses project directory by default)

**Capabilities:**
- Read, write, move, delete files
- List directory contents
- Search file contents

---

### playwright.json — Playwright MCP Server

Browser automation and scraping using Playwright.

**Requires:** Nothing (installs browser on first use)

**Capabilities:**
- Navigate pages and click elements
- Fill forms and extract content
- Take screenshots

---

### fal-ai.json — Fal AI MCP Server

AI image, video, and audio generation via Fal.ai models.

**Requires:**
- `FAL_KEY` — get at https://fal.ai

**Set env var:**
```bash
export FAL_KEY=yourkey
```

**Capabilities:**
- Generate images with FLUX, SDXL, etc.
- Generate video clips
- Run other Fal AI models

---

### browserbase.json — Browserbase MCP Server

Cloud-hosted browser automation — no local browser needed.

**Requires:**
- `BROWSERBASE_API_KEY` — get at https://browserbase.com
- `BROWSERBASE_PROJECT_ID` — from Browserbase dashboard

**Set env vars:**
```bash
export BROWSERBASE_API_KEY=yourkey
export BROWSERBASE_PROJECT_ID=yourproject
```

**Capabilities:**
- Run Playwright scripts in the cloud
- Persistent sessions across requests
- Screenshot and PDF generation

---

### browser-use.json — Browser Use MCP Server

Local browser control agent powered by OpenAI.

**Requires:**
- `OPENAI_API_KEY` — get at https://platform.openai.com

**Set env var:**
```bash
export OPENAI_API_KEY=sk-yourkey
```

**Capabilities:**
- AI-driven browser navigation
- Form filling and data extraction
- Multi-step web tasks

---

### devfleet.json — DevFleet MCP Server

Connect Claude Code to a locally running DevFleet instance.

**Requires:** DevFleet running on `http://localhost:18801`

**Capabilities:**
- Access DevFleet tools and fleet management
- Local development fleet coordination

---

### token-optimizer.json — Token Optimizer MCP Server

Analyze and optimize Claude Code token usage.

**Requires:** Nothing

**Capabilities:**
- Compress large contexts
- Identify token-heavy patterns
- Suggest context reduction strategies

---

### laraplugins.json — LaraPlugins MCP Server

Browse and discover Laravel plugins from laraplugins.io.

**Requires:** Nothing (HTTP endpoint)

**Capabilities:**
- Search Laravel ecosystem packages
- Get plugin details and install instructions

---

### confluence.json — Confluence MCP Server

Read and write Atlassian Confluence pages and spaces.

**Requires:**
- `CONFLUENCE_BASE_URL` — your Confluence URL (e.g. `https://yourcompany.atlassian.net/wiki`)
- `CONFLUENCE_EMAIL` — your Atlassian account email
- `CONFLUENCE_API_TOKEN` — create at https://id.atlassian.com/manage-profile/security/api-tokens

**Set env vars:**
```bash
export CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki
export CONFLUENCE_EMAIL=you@example.com
export CONFLUENCE_API_TOKEN=yourtoken
```

**Capabilities:**
- Read pages and spaces
- Create and update pages
- Search Confluence content

---

### evalview.json — EvalView MCP Server

AI model evaluation and benchmarking from within Claude Code.

**Requires:**
- `OPENAI_API_KEY` — get at https://platform.openai.com

**Set env var:**
```bash
export OPENAI_API_KEY=sk-yourkey
```

**Capabilities:**
- Run evaluation datasets against models
- Compare model outputs
- Track evaluation metrics

---

## Merging multiple configs

If you want multiple MCP servers active at once, merge the `mcpServers` objects:

```json
{
  "mcpServers": {
    "github": { "...": "from github.json" },
    "postgres": { "...": "from postgres.json" }
  }
}
```

Or use `/devstarter-mcp` to select and merge automatically.

---

## Verifying activation

After placing your mcp.json, restart Claude Code. Run:

```
> /mcp
```

Active servers will appear in the list.
