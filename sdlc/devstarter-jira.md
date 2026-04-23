# devstarter-jira.md — Jira Procedures
# DevStarter — Full Jira Integration (equivalent to devstarter-notion.md)

## Purpose

All Jira operations used by devstarter-change, devstarter-release, devstarter-sprint,
and devstarter-starter workflows when `PM_TYPE=jira`.

Agents: @devstarter-pm reads this file before any Jira operation.

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## Prerequisites & Config

```bash
# In ~/.claude/.env (global secrets — never committed)
JIRA_API_TOKEN=your-token-here   # Atlassian API token (not password)
                                  # Create at: id.atlassian.net/manage-profile/security/api-tokens

# In .project.env (per-project)
PM_TYPE=jira
JIRA_URL=https://company.atlassian.net   # No trailing slash
JIRA_PROJECT=PROJ                         # Project key (e.g. SHOP, AUTH, INFRA)
JIRA_BOARD_ID=1                           # Board ID (from Jira URL when viewing board)
JIRA_DEFAULT_ISSUE_TYPE=Story             # Story | Task | Bug | Epic
JIRA_STORY_POINTS_FIELD=customfield_10016 # Check your Jira instance — may differ
```

---

## Helper — Base Auth & Headers

Every curl call uses:

```bash
source .project.env 2>/dev/null || true
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)

JIRA_AUTH=$(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)
JIRA_HEADERS=(
  -H "Authorization: Basic $JIRA_AUTH"
  -H "Content-Type: application/json"
  -H "Accept: application/json"
)
```

> **Note:** `JIRA_EMAIL` = your Atlassian account email. Add to `~/.claude/.env`.

---

## Preflight Check

Run before any Jira operation:

```bash
source .project.env 2>/dev/null || true
export $(cat "$HOME/.claude/.env" | grep -v '^#' | grep -v '^$' | xargs)

TMP_D="$HOME/.claude/.tmp" && mkdir -p "$TMP_D"

JIRA_AUTH=$(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)

# Test API connectivity
curl -s "$JIRA_URL/rest/api/3/myself" \
  -H "Authorization: Basic $JIRA_AUTH" \
  -H "Accept: application/json" \
  -o "$TMP_D/jira_check.json"

node -e "
const d = JSON.parse(require('fs').readFileSync('$TMP_D/jira_check.json','utf8'));
if (d.errorMessages) { console.log('ERROR: ' + JSON.stringify(d.errorMessages)); process.exit(1); }
console.log('OK: Connected as ' + d.displayName + ' (' + d.emailAddress + ')');
"
rm -f "$TMP_D/jira_check.json"
```

---

## PROC-JR-01 — Create Jira Project + Board

**Used by:** devstarter-starter.md (Gate 0)

```bash
# Create a new Scrum project
curl -s -X POST "$JIRA_URL/rest/api/3/project" \
  "${JIRA_HEADERS[@]}" \
  -d "{
    \"key\": \"$JIRA_PROJECT\",
    \"name\": \"$PROJECT_NAME\",
    \"projectTypeKey\": \"software\",
    \"projectTemplateKey\": \"com.pyxis.greenhopper.jira:gh-scrum-template\",
    \"description\": \"$PROJECT_DESCRIPTION\",
    \"leadAccountId\": \"$JIRA_LEAD_ACCOUNT_ID\"
  }" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
if (d.errorMessages) { console.log('ERROR:', JSON.stringify(d)); process.exit(1); }
console.log('✅ Project created: ' + d.key + ' — ' + d.self);
"

# Get the board ID (auto-created with Scrum template)
curl -s "$JIRA_URL/rest/agile/1.0/board?projectKeyOrId=$JIRA_PROJECT" \
  -H "Authorization: Basic $JIRA_AUTH" \
  -H "Accept: application/json" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
const board = d.values[0];
console.log('Board ID:', board.id, '— Name:', board.name);
console.log('Add JIRA_BOARD_ID=' + board.id + ' to .project.env');
"
```

---

## PROC-JR-02 — Create Sprint

**Used by:** devstarter-sprint.md (sprint planning)

```bash
# Create sprint
SPRINT_START=$(date -u +"%Y-%m-%dT00:00:00.000Z")
SPRINT_END=$(date -u -d "+14 days" +"%Y-%m-%dT00:00:00.000Z" 2>/dev/null || \
             date -u -v+14d +"%Y-%m-%dT00:00:00.000Z")  # macOS fallback

curl -s -X POST "$JIRA_URL/rest/agile/1.0/sprint" \
  "${JIRA_HEADERS[@]}" \
  -d "{
    \"name\": \"$SPRINT_NAME\",
    \"startDate\": \"$SPRINT_START\",
    \"endDate\": \"$SPRINT_END\",
    \"originBoardId\": $JIRA_BOARD_ID,
    \"goal\": \"$SPRINT_GOAL\"
  }" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
if (d.errorMessages) { console.log('ERROR:', JSON.stringify(d)); process.exit(1); }
console.log('✅ Sprint created: ID=' + d.id + ' — ' + d.name);
console.log('Add JIRA_SPRINT_ID=' + d.id + ' to .project.env');
"
```

---

## PROC-JR-03 — Create Issue (Story / Task / Bug / Epic)

**Used by:** devstarter-change.md, devstarter-starter.md (Gate 3)

```bash
create_jira_issue() {
  local SUMMARY="$1"
  local DESCRIPTION="$2"
  local ISSUE_TYPE="${3:-$JIRA_DEFAULT_ISSUE_TYPE}"
  local STORY_POINTS="${4:-}"
  local PARENT_EPIC="${5:-}"   # Epic link (issue key, e.g. PROJ-1)
  local SPRINT_ID="${6:-$JIRA_SPRINT_ID}"

  PAYLOAD=$(node -e "
const p = {
  fields: {
    project: { key: '$JIRA_PROJECT' },
    summary: $(echo "$SUMMARY" | node -e "process.stdout.write(JSON.stringify(require('fs').readFileSync('/dev/stdin','utf8').trim()))"),
    description: {
      type: 'doc', version: 1,
      content: [{ type: 'paragraph', content: [{ type: 'text', text: $(echo "$DESCRIPTION" | node -e "process.stdout.write(JSON.stringify(require('fs').readFileSync('/dev/stdin','utf8').trim()))") }] }]
    },
    issuetype: { name: '$ISSUE_TYPE' }
  }
};
if ('$STORY_POINTS') p.fields['$JIRA_STORY_POINTS_FIELD'] = parseInt('$STORY_POINTS');
if ('$PARENT_EPIC') p.fields.customfield_10014 = '$PARENT_EPIC';
console.log(JSON.stringify(p));
")

  RESULT=$(curl -s -X POST "$JIRA_URL/rest/api/3/issue" \
    "${JIRA_HEADERS[@]}" \
    -d "$PAYLOAD")

  node -e "
const d = JSON.parse('$(echo "$RESULT" | sed "s/'/\\\'/g")');
if (d.errorMessages || d.errors) { console.log('ERROR:', JSON.stringify(d)); process.exit(1); }
console.log('✅ Issue created: ' + d.key + ' — $SUMMARY');
console.log('   URL: $JIRA_URL/browse/' + d.key);
" 2>/dev/null || echo "✅ Issue created: $RESULT"

  # Add to sprint if SPRINT_ID set
  if [ -n "$SPRINT_ID" ] && [ "$SPRINT_ID" != "none" ]; then
    ISSUE_KEY=$(echo "$RESULT" | node -e "process.stdout.write(JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).key||'')" 2>/dev/null)
    [ -n "$ISSUE_KEY" ] && add_issue_to_sprint "$ISSUE_KEY" "$SPRINT_ID"
  fi
}

add_issue_to_sprint() {
  local ISSUE_KEY="$1"
  local SPRINT_ID="$2"
  curl -s -X POST "$JIRA_URL/rest/agile/1.0/sprint/$SPRINT_ID/issue" \
    "${JIRA_HEADERS[@]}" \
    -d "{\"issues\": [\"$ISSUE_KEY\"]}" > /dev/null
  echo "   Added $ISSUE_KEY → Sprint $SPRINT_ID"
}

# Example usage:
# create_jira_issue "Implement user login" "Build JWT-based login endpoint" "Story" "3" "PROJ-1"
```

---

## PROC-JR-04 — Update Issue Status (Transition)

**Used by:** all workflows (In Progress, In Review, Done)

```bash
transition_issue() {
  local ISSUE_KEY="$1"
  local TARGET_STATUS="$2"   # "In Progress" | "In Review" | "Done" | "To Do"

  # Get available transitions
  TRANSITIONS=$(curl -s "$JIRA_URL/rest/api/3/issue/$ISSUE_KEY/transitions" \
    -H "Authorization: Basic $JIRA_AUTH" \
    -H "Accept: application/json")

  TRANSITION_ID=$(node -e "
const d = JSON.parse('$(echo "$TRANSITIONS" | sed "s/'/\\\'/g")');
const t = d.transitions.find(t => t.name.toLowerCase().includes('$TARGET_STATUS'.toLowerCase()));
if (!t) { console.error('Transition not found: $TARGET_STATUS'); process.exit(1); }
console.log(t.id);
" 2>/dev/null)

  if [ -z "$TRANSITION_ID" ]; then
    echo "⚠️ Transition '$TARGET_STATUS' not found for $ISSUE_KEY — check Jira workflow"
    return
  fi

  curl -s -X POST "$JIRA_URL/rest/api/3/issue/$ISSUE_KEY/transitions" \
    "${JIRA_HEADERS[@]}" \
    -d "{\"transition\": {\"id\": \"$TRANSITION_ID\"}}" > /dev/null
  echo "✅ $ISSUE_KEY → $TARGET_STATUS"
}

# Usage:
# transition_issue "PROJ-42" "In Progress"   # task started
# transition_issue "PROJ-42" "In Review"     # PR created
# transition_issue "PROJ-42" "Done"          # PR merged
```

DevStarter status sync rules (mirrors Notion PROC-NT-04/05/06):
| Event | Jira Transition |
|-------|----------------|
| Task starts | → "In Progress" |
| PR opened | → "In Review" |
| PR merged | → "Done" |

---

## PROC-JR-05 — Start Sprint

**Used by:** devstarter-sprint.md (after sprint planning)

```bash
start_sprint() {
  local SPRINT_ID="${1:-$JIRA_SPRINT_ID}"
  local START_DATE=$(date -u +"%Y-%m-%dT00:00:00.000Z")
  local END_DATE=$(date -u -d "+14 days" +"%Y-%m-%dT00:00:00.000Z" 2>/dev/null || \
                   date -u -v+14d +"%Y-%m-%dT00:00:00.000Z")

  curl -s -X POST "$JIRA_URL/rest/agile/1.0/sprint/$SPRINT_ID" \
    "${JIRA_HEADERS[@]}" \
    -d "{
      \"state\": \"active\",
      \"startDate\": \"$START_DATE\",
      \"endDate\": \"$END_DATE\"
    }" > /dev/null
  echo "✅ Sprint $SPRINT_ID started — ends $(date -d '+14 days' '+%Y-%m-%d' 2>/dev/null || echo '+14 days')"
}
```

---

## PROC-JR-06 — Close Sprint + Velocity Report

**Used by:** devstarter-retro.md (sprint retrospective)

```bash
close_sprint() {
  local SPRINT_ID="${1:-$JIRA_SPRINT_ID}"

  # Get sprint issues for velocity calculation
  ISSUES=$(curl -s "$JIRA_URL/rest/agile/1.0/sprint/$SPRINT_ID/issue?fields=status,customfield_10016&maxResults=100" \
    -H "Authorization: Basic $JIRA_AUTH" \
    -H "Accept: application/json")

  node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
const issues = d.issues || [];
const done = issues.filter(i => i.fields.status.statusCategory.key === 'done');
const total = issues.reduce((s,i) => s + (i.fields['$JIRA_STORY_POINTS_FIELD']||0), 0);
const completed = done.reduce((s,i) => s + (i.fields['$JIRA_STORY_POINTS_FIELD']||0), 0);
console.log('Sprint Velocity Report');
console.log('  Total issues:     ' + issues.length);
console.log('  Completed:        ' + done.length + ' (' + (done.length/issues.length*100).toFixed(0) + '%)');
console.log('  Story points done: ' + completed + ' / ' + total);
console.log('  Velocity:         ' + completed + ' SP');
const incomplete = issues.filter(i => i.fields.status.statusCategory.key !== 'done');
if (incomplete.length > 0) {
  console.log('  Incomplete issues: ' + incomplete.map(i => i.key).join(', '));
}
" <<< "$ISSUES"

  # Close the sprint
  curl -s -X POST "$JIRA_URL/rest/agile/1.0/sprint/$SPRINT_ID" \
    "${JIRA_HEADERS[@]}" \
    -d "{\"state\": \"closed\"}" > /dev/null
  echo "✅ Sprint $SPRINT_ID closed"
}
```

---

## PROC-JR-07 — Link Issue to PR / Commit

**Used by:** devstarter-change.md (when PR created)

```bash
link_pr_to_issue() {
  local ISSUE_KEY="$1"
  local PR_URL="$2"
  local PR_TITLE="$3"

  # Add web link to issue
  curl -s -X POST "$JIRA_URL/rest/api/3/issue/$ISSUE_KEY/remotelink" \
    "${JIRA_HEADERS[@]}" \
    -d "{
      \"object\": {
        \"url\": \"$PR_URL\",
        \"title\": \"PR: $PR_TITLE\",
        \"icon\": {\"url16x16\": \"https://github.com/favicon.ico\", \"title\": \"GitHub PR\"}
      }
    }" > /dev/null
  echo "✅ PR linked to $ISSUE_KEY: $PR_URL"
}

# Add comment to issue when PR opened
comment_on_issue() {
  local ISSUE_KEY="$1"
  local COMMENT="$2"

  curl -s -X POST "$JIRA_URL/rest/api/3/issue/$ISSUE_KEY/comment" \
    "${JIRA_HEADERS[@]}" \
    -d "{
      \"body\": {
        \"type\": \"doc\", \"version\": 1,
        \"content\": [{\"type\": \"paragraph\", \"content\": [{\"type\": \"text\", \"text\": \"$COMMENT\"}]}]
      }
    }" > /dev/null
  echo "✅ Comment added to $ISSUE_KEY"
}

# Smart commit message format for Jira auto-linking:
# git commit -m "$ISSUE_KEY: feat: add login endpoint"
# Jira will auto-link the commit to the issue if Smart Commits are enabled.
```

---

## PROC-JR-08 — Create Epic

**Used by:** devstarter-starter.md (Gate 3 — epic-level task breakdown)

```bash
create_epic() {
  local EPIC_NAME="$1"
  local EPIC_SUMMARY="$2"
  local EPIC_DESCRIPTION="$3"

  curl -s -X POST "$JIRA_URL/rest/api/3/issue" \
    "${JIRA_HEADERS[@]}" \
    -d "{
      \"fields\": {
        \"project\": {\"key\": \"$JIRA_PROJECT\"},
        \"summary\": \"$EPIC_SUMMARY\",
        \"issuetype\": {\"name\": \"Epic\"},
        \"customfield_10011\": \"$EPIC_NAME\",
        \"description\": {
          \"type\": \"doc\", \"version\": 1,
          \"content\": [{\"type\": \"paragraph\", \"content\": [{\"type\": \"text\", \"text\": \"$EPIC_DESCRIPTION\"}]}]
        }
      }
    }" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
if (d.errorMessages) { console.log('ERROR:', JSON.stringify(d)); process.exit(1); }
console.log('✅ Epic created: ' + d.key + ' — $EPIC_SUMMARY');
"
}

# Example:
# create_epic "Authentication" "Epic: User authentication system" "All auth-related stories"
# → Returns PROJ-1 (Epic key) — use as PARENT_EPIC in PROC-JR-03
```

---

## PROC-JR-09 — Bulk Create Issues from Task List

**Used by:** devstarter-starter.md (Gate 3 — create all sprint tasks at once)

```bash
bulk_create_issues() {
  # Expects: TASKS array of "SUMMARY|DESCRIPTION|TYPE|POINTS|EPIC_KEY"
  local SPRINT_ID="${JIRA_SPRINT_ID:-}"

  declare -a TASKS=(
    "Setup project structure|Initialize repo, folder structure, CI|Task|2|"
    "Database schema design|Create all tables and migrations|Story|3|$EPIC_KEY"
    "User authentication API|JWT login, register, refresh, logout|Story|5|$EPIC_KEY"
    "Frontend login page|Login form, validation, error states|Story|3|$EPIC_KEY"
  )
  # Replace TASKS above with actual sprint tasks from Gate 3 breakdown

  echo "Creating ${#TASKS[@]} Jira issues..."
  CREATED=()

  for TASK in "${TASKS[@]}"; do
    IFS='|' read -r SUMMARY DESC TYPE POINTS EPIC <<< "$TASK"
    RESULT=$(curl -s -X POST "$JIRA_URL/rest/api/3/issue" \
      "${JIRA_HEADERS[@]}" \
      -d "$(node -e "
const p = {fields: {
  project: {key:'$JIRA_PROJECT'},
  summary: '$SUMMARY',
  description: {type:'doc',version:1,content:[{type:'paragraph',content:[{type:'text',text:'$DESC'}]}]},
  issuetype: {name:'$TYPE'}
}};
if ('$POINTS') p.fields['$JIRA_STORY_POINTS_FIELD'] = parseInt('$POINTS');
if ('$EPIC') p.fields.customfield_10014 = '$EPIC';
console.log(JSON.stringify(p));
")")
    KEY=$(echo "$RESULT" | node -e "process.stdout.write(JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).key||'ERROR')" 2>/dev/null)
    echo "  ✅ $KEY — $SUMMARY"
    CREATED+=("$KEY")

    # Add to sprint
    if [ -n "$SPRINT_ID" ]; then
      curl -s -X POST "$JIRA_URL/rest/agile/1.0/sprint/$SPRINT_ID/issue" \
        "${JIRA_HEADERS[@]}" \
        -d "{\"issues\":[\"$KEY\"]}" > /dev/null
    fi
  done

  echo ""
  echo "✅ Bulk create complete: ${#CREATED[@]} issues created"
  echo "   Issues: ${CREATED[*]}"
  echo "   Board: $JIRA_URL/jira/software/projects/$JIRA_PROJECT/boards"
}
```

---

## Status Mapping

DevStarter uses these standard statuses across all PM tools:

| DevStarter Status | Jira Transition Name | Jira Category |
|-------------------|---------------------|---------------|
| To Do | (default / backlog) | To Do |
| In Progress | "In Progress" / "Start Progress" | In Progress |
| In Review | "In Review" / "Code Review" | In Progress |
| Done | "Done" / "Close Issue" | Done |

> Jira workflow transition names vary by project configuration.
> PROC-JR-04 auto-discovers the correct transition ID by matching name substring.

---

## Field Reference

Common Jira custom field IDs (may vary by Jira instance):

| Field | Common ID | Notes |
|-------|-----------|-------|
| Story Points | `customfield_10016` | Check via: `GET /rest/api/3/field` |
| Epic Link | `customfield_10014` | Parent epic for Stories |
| Epic Name | `customfield_10011` | Name shown on Epic card |
| Sprint | `customfield_10020` | Sprint ID |

To find your instance's field IDs:
```bash
curl -s "$JIRA_URL/rest/api/3/field" \
  -H "Authorization: Basic $JIRA_AUTH" \
  -H "Accept: application/json" | \
  node -e "
const fields = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
fields.filter(f => f.custom).forEach(f => console.log(f.id, '→', f.name));
"
```
