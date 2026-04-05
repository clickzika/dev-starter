# dev-notion.md — Shared Notion Procedures

## Purpose

This file contains shared Notion procedures used by all dev workflows.
Agents read this file when Notion operations are needed.

## Cross-Platform Rules (Windows + macOS + Linux)

- JSON parsing: use `node -e` with `require('fs')` — NEVER use Python, jq, or bash grep
- curl JSON body: use double quotes with escaped inner quotes
- Temp files: write curl output to files (`-o file.json`) then parse with Node.js
- Always clean up temp files after use
- **Temp directory:** Always set up temp paths at the start of any script:
  ```bash
  TMP_D="$HOME/.claude/.tmp"
  mkdir -p "$TMP_D"
  # Windows Node.js needs C:/Users/... not /c/Users/...
  if command -v cygpath &>/dev/null; then
    TMP_D_NODE="$(cygpath -m "$TMP_D")"
  else
    TMP_D_NODE="$TMP_D"
  fi
  ```
  Use `$TMP_D` for curl/bash, use `$TMP_D_NODE` inside `node -e` readFileSync

---

## Prerequisites Check

```bash
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)

# Test Notion API key
curl -s -X POST https://api.notion.com/v1/search \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"page_size\": 1}" \
  -o $TMP_D/notion_check.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/notion_check.json', 'utf8'));
if (data.status === 401) { console.log('ERROR:401'); process.exit(1); }
console.log('OK');
"
rm -f $TMP_D/notion_check.json
```

If ERROR:401 → STOP: "Invalid NOTION_API_KEY. Run bash ~/.claude/setup.sh"

---

## PROC-NT-01 — Find or Create Parent Page

**Used by:** all workflows when setting up a new project board

```bash
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)
PARENT_PAGE_NAME="${NOTION_PARENT_PAGE:-Projects}"

# Search for parent page
curl -s -X POST https://api.notion.com/v1/search \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"query\": \"$PARENT_PAGE_NAME\", \"filter\": {\"property\": \"object\", \"value\": \"page\"}, \"page_size\": 5}" \
  -o $TMP_D/nt_search.json

PARENT_PAGE_ID=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_search.json', 'utf8'));
const pages = (data.results || []).filter(p => {
  const title = ((p.properties && p.properties.title && p.properties.title.title) || [])
    .map(t => t.plain_text).join('');
  return title === '$PARENT_PAGE_NAME';
});
console.log(pages.length > 0 ? pages[0].id : 'NOT_FOUND');
")
rm -f $TMP_D/nt_search.json

if [ "$PARENT_PAGE_ID" = "NOT_FOUND" ]; then
  # Find any accessible page to create under
  curl -s -X POST https://api.notion.com/v1/search \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "{\"filter\": {\"property\": \"object\", \"value\": \"page\"}, \"page_size\": 1}" \
    -o $TMP_D/nt_any.json

  ANY_PAGE_ID=$(node -e "
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_any.json', 'utf8'));
  console.log(data.results && data.results.length > 0 ? data.results[0].id : 'NO_PAGES');
  ")
  rm -f $TMP_D/nt_any.json

  if [ "$ANY_PAGE_ID" = "NO_PAGES" ]; then
    echo "ERROR: No Notion pages accessible."
    echo "Please share a page with your integration:"
    echo "  Open any Notion page → '...' → 'Add connections' → select your integration"
    exit 1
  fi

  # Create Projects parent page
  curl -s -X POST https://api.notion.com/v1/pages \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "{\"parent\": {\"page_id\": \"$ANY_PAGE_ID\"}, \"properties\": {\"title\": {\"title\": [{\"text\": {\"content\": \"$PARENT_PAGE_NAME\"}}]}}, \"icon\": {\"emoji\": \"🚀\"}}" \
    -o $TMP_D/nt_new_parent.json

  PARENT_PAGE_ID=$(node -e "
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_new_parent.json', 'utf8'));
  console.log(data.id || 'ERROR');
  ")
  rm -f $TMP_D/nt_new_parent.json
fi

echo "✅ Parent page ID: $PARENT_PAGE_ID"
```

---

## PROC-NT-02 — Create Project Database

**Used by:** all workflows after parent page is found

```bash
# Variables required: PARENT_PAGE_ID, PROJECT_NAME

curl -s -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{
    \"parent\": {\"page_id\": \"$PARENT_PAGE_ID\"},
    \"title\": [{\"text\": {\"content\": \"$PROJECT_NAME - Task Board\"}}],
    \"icon\": {\"emoji\": \"📋\"},
    \"properties\": {
      \"Title\":          {\"title\": {}},
      \"Status\":         {\"select\": {\"options\": [
        {\"name\": \"To Do\",      \"color\": \"default\"},
        {\"name\": \"In Progress\",\"color\": \"yellow\"},
        {\"name\": \"In Review\",  \"color\": \"blue\"},
        {\"name\": \"Done\",       \"color\": \"green\"},
        {\"name\": \"Blocked\",    \"color\": \"red\"}
      ]}},
      \"Gate\":           {\"select\": {\"options\": [
        {\"name\": \"Gate 1 — Discovery\",    \"color\": \"gray\"},
        {\"name\": \"Gate 2 — Design\",       \"color\": \"yellow\"},
        {\"name\": \"Gate 3 — Foundation\",   \"color\": \"orange\"},
        {\"name\": \"Gate 4 — Feature\",      \"color\": \"green\"},
        {\"name\": \"Gate 5 — Delivery\",     \"color\": \"blue\"}
      ]}},
      \"Role\":           {\"select\": {\"options\": [
        {\"name\": \"@devstarter-ba\"},        {\"name\": \"@devstarter-techlead\"},
        {\"name\": \"@devstarter-frontend\"},  {\"name\": \"@devstarter-backend\"},
        {\"name\": \"@devstarter-dba\"},       {\"name\": \"@devstarter-qa\"},
        {\"name\": \"@devstarter-devops\"},    {\"name\": \"@devstarter-security\"},
        {\"name\": \"@devstarter-uxui\"},      {\"name\": \"@devstarter-pm\"},
        {\"name\": \"@devstarter-mobile\"}
      ]}},
      \"Priority\":       {\"select\": {\"options\": [
        {\"name\": \"Critical\", \"color\": \"red\"},
        {\"name\": \"High\",     \"color\": \"orange\"},
        {\"name\": \"Medium\",   \"color\": \"yellow\"},
        {\"name\": \"Low\",      \"color\": \"gray\"}
      ]}},
      \"Effort\":         {\"select\": {\"options\": [
        {\"name\": \"S\", \"color\": \"green\"},
        {\"name\": \"M\", \"color\": \"yellow\"},
        {\"name\": \"L\", \"color\": \"red\"}
      ]}},
      \"Epic\":           {\"select\": {\"options\": []}},
      \"Start Date\":     {\"date\": {}},
      \"Completed Date\": {\"date\": {}},
      \"GitHub Issue #\": {\"number\": {}},
      \"GitHub PR #\":    {\"number\": {}},
      \"Sprint\":         {\"select\": {\"options\": []}},
      \"Dependencies\":   {\"rich_text\": {}},
      \"Notes\":          {\"rich_text\": {}}
    }
  }" \
  -o $TMP_D/nt_db.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_db.json', 'utf8'));
if (data.id) {
  console.log('DB_ID=' + data.id);
  console.log('DB_URL=' + (data.url || ''));
} else {
  console.log('ERROR=' + JSON.stringify(data).substring(0, 200));
}
"
rm -f $TMP_D/nt_db.json
```

Save `DB_ID` and `DB_URL` to `.project.env`.

---

## PROC-NT-03 — Create Task (one per task)

**Used by:** Gate 3 of all workflows after task breakdown approved

```bash
# Variables required:
# NOTION_DATABASE_ID, TASK_TITLE, TASK_GATE, TASK_ROLE,
# TASK_PRIORITY, TASK_EFFORT, TASK_EPIC, TASK_NOTES, GITHUB_ISSUE_NUMBER

curl -s -X POST https://api.notion.com/v1/pages \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{
    \"parent\": {\"database_id\": \"$NOTION_DATABASE_ID\"},
    \"properties\": {
      \"Title\":          {\"title\": [{\"text\": {\"content\": \"$TASK_TITLE\"}}]},
      \"Status\":         {\"select\": {\"name\": \"To Do\"}},
      \"Gate\":           {\"select\": {\"name\": \"$TASK_GATE\"}},
      \"Role\":           {\"select\": {\"name\": \"$TASK_ROLE\"}},
      \"Priority\":       {\"select\": {\"name\": \"$TASK_PRIORITY\"}},
      \"Effort\":         {\"select\": {\"name\": \"$TASK_EFFORT\"}},
      \"Epic\":           {\"select\": {\"name\": \"$TASK_EPIC\"}},
      \"GitHub Issue #\": {\"number\": $GITHUB_ISSUE_NUMBER},
      \"Notes\":          {\"rich_text\": [{\"text\": {\"content\": \"$TASK_NOTES\"}}]}
    }
  }" \
  -o $TMP_D/nt_task.json

TASK_ID=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_task.json', 'utf8'));
console.log(data.id || 'ERROR');
")
rm -f $TMP_D/nt_task.json

echo "✅ Notion task created: $TASK_TITLE (ID: $TASK_ID)"
```

---

## PROC-NT-04 — Update Task Status

**Used by:** all workflows when task status changes

```bash
# Variables required: NOTION_TASK_ID, NEW_STATUS
# NEW_STATUS options: "To Do" | "In Progress" | "In Review" | "Done" | "Blocked"

# Build properties JSON — always include Status
PROPS="{\"Status\": {\"select\": {\"name\": \"$NEW_STATUS\"}}"

# Auto-set Start Date when moving to "In Progress" (first time only)
if [ "$NEW_STATUS" = "In Progress" ]; then
  TODAY=$(date -u +"%Y-%m-%d")
  PROPS="$PROPS, \"Start Date\": {\"date\": {\"start\": \"$TODAY\"}}"
fi

PROPS="$PROPS}"

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": $PROPS}" \
  -o $TMP_D/nt_update.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_update.json', 'utf8'));
console.log(data.id ? '✅ Status updated to: $NEW_STATUS' : 'ERROR: ' + JSON.stringify(data).substring(0, 100));
"
rm -f $TMP_D/nt_update.json
```

---

## PROC-NT-05 — Update Task with PR Number

**Used by:** Gate 4 after PR is created

```bash
# Variables required: NOTION_TASK_ID, PR_NUMBER

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": {
    \"Status\":      {\"select\": {\"name\": \"In Review\"}},
    \"GitHub PR #\": {\"number\": $PR_NUMBER}
  }}" \
  -o $TMP_D/nt_pr.json

rm -f $TMP_D/nt_pr.json
echo "✅ Notion task updated: PR #$PR_NUMBER, Status → In Review"
```

---

## PROC-NT-06 — Mark Task Done

**Used by:** Gate 4 after PR merged

```bash
# Variables required: NOTION_TASK_ID

TODAY=$(date -u +"%Y-%m-%d")

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": {
    \"Status\":         {\"select\": {\"name\": \"Done\"}},
    \"Completed Date\": {\"date\": {\"start\": \"$TODAY\"}}
  }}" \
  -o $TMP_D/nt_done.json

rm -f $TMP_D/nt_done.json
echo "✅ Notion task marked Done (Completed: $TODAY)"
```

---

## Task Lifecycle Summary

```
Created  → Status: "To Do"                              (PROC-NT-03)
Started  → Status: "In Progress" + Start Date set       (PROC-NT-04)
PR made  → Status: "In Review"   + PR # set             (PROC-NT-05)
Merged   → Status: "Done"        + Completed Date set   (PROC-NT-06)
Blocked  → Status: "Blocked"                            (PROC-NT-04 with "Blocked")
```

---

## PROC-NT-07 — Create Database Views

**Used by:** dev-starter.md Gate 0 (after database created)

After PROC-NT-02 creates the database, create these views so humans can monitor progress:

### View 1 — Board by Status (default)
```
Use Notion MCP: notion-create-view
  database_id: $NOTION_DATABASE_ID
  data_source_id: [from fetch]
  name: "Board"
  type: board
  configure: GROUP BY "Status"
```

### View 2 — Board by Epic
```
Use Notion MCP: notion-create-view
  database_id: $NOTION_DATABASE_ID
  data_source_id: [from fetch]
  name: "By Epic"
  type: board
  configure: GROUP BY "Epic"; SHOW "Title", "Status", "Role", "GitHub Issue #"
```

### View 3 — Sprint Board
```
Use Notion MCP: notion-create-view
  database_id: $NOTION_DATABASE_ID
  data_source_id: [from fetch]
  name: "Sprint"
  type: board
  configure: GROUP BY "Sprint"; SHOW "Title", "Status", "Role", "Effort"
```

### View 4 — All Tasks (table)
```
Use Notion MCP: notion-create-view
  database_id: $NOTION_DATABASE_ID
  data_source_id: [from fetch]
  name: "All Tasks"
  type: table
  configure: SORT BY "Gate" ASC; SHOW "Title", "Status", "Epic", "Role", "Priority", "Effort", "Start Date", "Completed Date", "GitHub Issue #", "Sprint"
```

```
✅ 4 views created:
  📋 Board        — drag tasks across Status columns
  📦 By Epic      — see progress per epic
  🏃 Sprint       — current sprint board
  📊 All Tasks    — full table with dates and details
```

---

## PROC-NT-08 — Sprint Management

**Used by:** dev-sprint.md at the start of each sprint

### Step 1 — Create sprint option

```bash
# Add new sprint option to the Sprint property
# Variables required: SPRINT_NAME (e.g. "Sprint 1", "Sprint 2")

# Use Notion MCP: notion-update-data-source
#   data_source_id: [from fetch]
#   statements: ALTER COLUMN "Sprint" SET SELECT('Sprint 1', 'Sprint 2', ...)
```

### Step 2 — Assign tasks to sprint

```bash
# For each task assigned to this sprint:
# Variables required: NOTION_TASK_ID, SPRINT_NAME

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": {\"Sprint\": {\"select\": {\"name\": \"$SPRINT_NAME\"}}}}" \
  -o $TMP_D/nt_sprint.json

rm -f $TMP_D/nt_sprint.json
echo "✅ Task assigned to $SPRINT_NAME"
```

### Step 3 — Show sprint summary

```
SPRINT SETUP COMPLETE
━━━━━━━━━━━━━━━━━━━━
Sprint:     [SPRINT_NAME]
Tasks:      [N] tasks assigned
Breakdown:
  📦 [epic1]: [n] tasks
  📦 [epic2]: [n] tasks
By Role:
  @devstarter-backend:  [n] tasks
  @devstarter-frontend: [n] tasks
  @devstarter-dba:      [n] tasks

View sprint board: [NOTION_BOARD_URL]
```

---

## PROC-NT-09 — Query Tasks

**Used by:** any workflow that needs to check project status

### Query by Status

```bash
# Variables required: NOTION_DATABASE_ID, QUERY_STATUS

curl -s -X POST "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"filter\": {\"property\": \"Status\", \"select\": {\"equals\": \"$QUERY_STATUS\"}}}" \
  -o $TMP_D/nt_query.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_query.json', 'utf8'));
const tasks = data.results || [];
console.log('Found: ' + tasks.length + ' tasks with status: $QUERY_STATUS');
tasks.forEach(t => {
  const title = (t.properties.Title.title || []).map(x => x.plain_text).join('');
  const role = t.properties.Role?.select?.name || '-';
  const epic = t.properties.Epic?.select?.name || '-';
  console.log('  - [' + role + '] ' + title + ' (' + epic + ')');
});
"
rm -f $TMP_D/nt_query.json
```

### Query by Role

```bash
# Variables required: NOTION_DATABASE_ID, QUERY_ROLE (e.g. "@devstarter-backend")

curl -s -X POST "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"filter\": {\"property\": \"Role\", \"select\": {\"equals\": \"$QUERY_ROLE\"}}}" \
  -o $TMP_D/nt_query_role.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_query_role.json', 'utf8'));
const tasks = data.results || [];
console.log('Found: ' + tasks.length + ' tasks for role: $QUERY_ROLE');
tasks.forEach(t => {
  const title = (t.properties.Title.title || []).map(x => x.plain_text).join('');
  const status = t.properties.Status?.select?.name || '-';
  console.log('  - [' + status + '] ' + title);
});
"
rm -f $TMP_D/nt_query_role.json
```

### Query Blocked Tasks

```bash
# Variables required: NOTION_DATABASE_ID

curl -s -X POST "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"filter\": {\"property\": \"Status\", \"select\": {\"equals\": \"Blocked\"}}}" \
  -o $TMP_D/nt_blocked.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_blocked.json', 'utf8'));
const tasks = data.results || [];
if (tasks.length === 0) {
  console.log('✅ No blocked tasks');
} else {
  console.log('⚠️  ' + tasks.length + ' BLOCKED tasks:');
  tasks.forEach(t => {
    const title = (t.properties.Title.title || []).map(x => x.plain_text).join('');
    const notes = (t.properties.Notes?.rich_text || []).map(x => x.plain_text).join('');
    console.log('  🔴 ' + title + (notes ? ' — ' + notes : ''));
  });
}
"
rm -f $TMP_D/nt_blocked.json
```

---

## PROC-NT-10 — Project Dashboard

**Used by:** dev-starter.md Gate 3 (after tasks created), or anytime for status check

### Generate Progress Summary

```bash
# Variables required: NOTION_DATABASE_ID

# Fetch all tasks
curl -s -X POST "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{}" \
  -o $TMP_D/nt_all.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$TMP_D_NODE/nt_all.json', 'utf8'));
const tasks = data.results || [];
const total = tasks.length;

// Count by status
const byStatus = {};
tasks.forEach(t => {
  const s = t.properties.Status?.select?.name || 'Unknown';
  byStatus[s] = (byStatus[s] || 0) + 1;
});

// Count by epic
const byEpic = {};
tasks.forEach(t => {
  const e = t.properties.Epic?.select?.name || 'No Epic';
  const s = t.properties.Status?.select?.name || 'Unknown';
  if (!byEpic[e]) byEpic[e] = { total: 0, done: 0 };
  byEpic[e].total++;
  if (s === 'Done') byEpic[e].done++;
});

// Count by role
const byRole = {};
tasks.forEach(t => {
  const r = t.properties.Role?.select?.name || 'Unknown';
  const s = t.properties.Status?.select?.name || 'Unknown';
  if (!byRole[r]) byRole[r] = { total: 0, done: 0 };
  byRole[r].total++;
  if (s === 'Done') byRole[r].done++;
});

const done = byStatus['Done'] || 0;
const pct = total > 0 ? Math.round((done / total) * 100) : 0;

console.log('');
console.log('PROJECT DASHBOARD');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('Progress: ' + done + '/' + total + ' tasks (' + pct + '%)');
console.log('');
console.log('By Status:');
Object.entries(byStatus).forEach(([k, v]) => {
  const bar = '█'.repeat(Math.round((v / total) * 20));
  console.log('  ' + k.padEnd(14) + bar + ' ' + v);
});
console.log('');
console.log('By Epic:');
Object.entries(byEpic).forEach(([k, v]) => {
  const epct = Math.round((v.done / v.total) * 100);
  console.log('  ' + k.padEnd(24) + v.done + '/' + v.total + ' (' + epct + '%)');
});
console.log('');
console.log('By Role:');
Object.entries(byRole).forEach(([k, v]) => {
  console.log('  ' + k.padEnd(14) + v.done + '/' + v.total + ' done');
});
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
"
rm -f $TMP_D/nt_all.json
```

Output example:
```
PROJECT DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progress: 12/20 tasks (60%)

By Status:
  Done          ████████████ 12
  In Progress   ████ 4
  In Review     ██ 2
  To Do         ██ 2

By Epic:
  Auth & Users            5/5 (100%)
  Core Features           4/8 (50%)
  Reports & Export        3/5 (60%)
  Quality                 0/2 (0%)

By Role:
  @devstarter-backend      4/6 done
  @devstarter-frontend     4/6 done
  @devstarter-dba          2/3 done
  @devstarter-qa           1/3 done
  @devstarter-devops       1/2 done
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## .project.env Template

Save project-specific Notion config here (not in global .env):

```bash
# .project.env — Project config (auto-generated, do NOT commit)
NOTION_DATABASE_ID=[database ID from PROC-NT-02]
NOTION_BOARD_URL=[board URL from PROC-NT-02]
GITHUB_REPO=[GITHUB_USERNAME]/[PROJECT_NAME]
PROJECT_NAME=[project name]
```

Load in any script with:
```bash
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)
export $(cat ".project.env" | grep -v '^#' | grep -v '^$' | xargs)
```
