# dev-notion.md — Shared Notion Procedures

## Purpose

This file contains shared Notion procedures used by all dev workflows.
Agents read this file when Notion operations are needed.

## Cross-Platform Rules (Windows + macOS + Linux)

- JSON parsing: use `node -e` with `require('fs')` — NEVER use Python, jq, or bash grep
- curl JSON body: use double quotes with escaped inner quotes
- Temp files: write curl output to files (`-o file.json`) then parse with Node.js
- Always clean up temp files after use

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
  -o /tmp/notion_check.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/notion_check.json', 'utf8'));
if (data.status === 401) { console.log('ERROR:401'); process.exit(1); }
console.log('OK');
"
rm -f /tmp/notion_check.json
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
  -o /tmp/nt_search.json

PARENT_PAGE_ID=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/nt_search.json', 'utf8'));
const pages = (data.results || []).filter(p => {
  const title = ((p.properties && p.properties.title && p.properties.title.title) || [])
    .map(t => t.plain_text).join('');
  return title === '$PARENT_PAGE_NAME';
});
console.log(pages.length > 0 ? pages[0].id : 'NOT_FOUND');
")
rm -f /tmp/nt_search.json

if [ "$PARENT_PAGE_ID" = "NOT_FOUND" ]; then
  # Find any accessible page to create under
  curl -s -X POST https://api.notion.com/v1/search \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "{\"filter\": {\"property\": \"object\", \"value\": \"page\"}, \"page_size\": 1}" \
    -o /tmp/nt_any.json

  ANY_PAGE_ID=$(node -e "
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync('/tmp/nt_any.json', 'utf8'));
  console.log(data.results && data.results.length > 0 ? data.results[0].id : 'NO_PAGES');
  ")
  rm -f /tmp/nt_any.json

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
    -o /tmp/nt_new_parent.json

  PARENT_PAGE_ID=$(node -e "
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync('/tmp/nt_new_parent.json', 'utf8'));
  console.log(data.id || 'ERROR');
  ")
  rm -f /tmp/nt_new_parent.json
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
        {\"name\": \"@ba\"},        {\"name\": \"@techlead\"},
        {\"name\": \"@frontend\"},  {\"name\": \"@backend\"},
        {\"name\": \"@dba\"},       {\"name\": \"@qa\"},
        {\"name\": \"@devops\"},    {\"name\": \"@security\"},
        {\"name\": \"@uxui\"},      {\"name\": \"@pm\"},
        {\"name\": \"@mobile\"}
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
      \"GitHub Issue #\": {\"number\": {}},
      \"GitHub PR #\":    {\"number\": {}},
      \"Sprint\":         {\"select\": {\"options\": []}},
      \"Dependencies\":   {\"rich_text\": {}},
      \"Notes\":          {\"rich_text\": {}}
    }
  }" \
  -o /tmp/nt_db.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/nt_db.json', 'utf8'));
if (data.id) {
  console.log('DB_ID=' + data.id);
  console.log('DB_URL=' + (data.url || ''));
} else {
  console.log('ERROR=' + JSON.stringify(data).substring(0, 200));
}
"
rm -f /tmp/nt_db.json
```

Save `DB_ID` and `DB_URL` to `.project.env`.

---

## PROC-NT-03 — Create Task (one per task)

**Used by:** Gate 3 of all workflows after task breakdown approved

```bash
# Variables required:
# NOTION_DATABASE_ID, TASK_TITLE, TASK_GATE, TASK_ROLE,
# TASK_PRIORITY, TASK_EFFORT, TASK_NOTES, GITHUB_ISSUE_NUMBER

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
      \"GitHub Issue #\": {\"number\": $GITHUB_ISSUE_NUMBER},
      \"Notes\":          {\"rich_text\": [{\"text\": {\"content\": \"$TASK_NOTES\"}}]}
    }
  }" \
  -o /tmp/nt_task.json

TASK_ID=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/nt_task.json', 'utf8'));
console.log(data.id || 'ERROR');
")
rm -f /tmp/nt_task.json

echo "✅ Notion task created: $TASK_TITLE (ID: $TASK_ID)"
```

---

## PROC-NT-04 — Update Task Status

**Used by:** all workflows when task status changes

```bash
# Variables required: NOTION_TASK_ID, NEW_STATUS
# NEW_STATUS options: "To Do" | "In Progress" | "In Review" | "Done" | "Blocked"

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": {\"Status\": {\"select\": {\"name\": \"$NEW_STATUS\"}}}}" \
  -o /tmp/nt_update.json

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('/tmp/nt_update.json', 'utf8'));
console.log(data.id ? '✅ Status updated to: $NEW_STATUS' : 'ERROR: ' + JSON.stringify(data).substring(0, 100));
"
rm -f /tmp/nt_update.json
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
  -o /tmp/nt_pr.json

rm -f /tmp/nt_pr.json
echo "✅ Notion task updated: PR #$PR_NUMBER, Status → In Review"
```

---

## PROC-NT-06 — Mark Task Done

**Used by:** Gate 5 after PR merged

```bash
# Variables required: NOTION_TASK_ID

curl -s -X PATCH "https://api.notion.com/v1/pages/$NOTION_TASK_ID" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"properties\": {\"Status\": {\"select\": {\"name\": \"Done\"}}}}" \
  -o /tmp/nt_done.json

rm -f /tmp/nt_done.json
echo "✅ Notion task marked Done"
```

---

## Task Lifecycle Summary

```
Created  → Status: "To Do"        (PROC-NT-03)
Started  → Status: "In Progress"  (PROC-NT-04)
PR made  → Status: "In Review"    (PROC-NT-05)
Merged   → Status: "Done"         (PROC-NT-06)
Blocked  → Status: "Blocked"      (PROC-NT-04 with "Blocked")
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
