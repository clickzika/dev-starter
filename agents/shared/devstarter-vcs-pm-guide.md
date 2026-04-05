# Shared Guide — Version Control & Project Management

All SDLC workflows (`dev-starter`, `dev-change`, `dev-release`, `dev-hotfix`, etc.) MUST read this guide
before running any VCS or PM operations.

---

## Step 1 — Load Project Config

```bash
source .project.env 2>/dev/null || true
```

If `.project.env` does not exist, assume defaults:
- `VCS_TYPE=github`
- `PM_TYPE=notion`
- `BRANCH_STRATEGY=gitflow`

---

## Step 2 — Version Control Operations

### Creating a branch

| VCS_TYPE | Command |
|----------|---------|
| `github` / `gitlab` / `bitbucket` | `git checkout develop && git pull && git checkout -b $BRANCH_NAME` |
| `azure-devops` | `git checkout main && git pull && git checkout -b $BRANCH_NAME` |
| `svn` | `svn copy $SVN_URL/$SVN_TRUNK $SVN_URL/$SVN_BRANCHES/$BRANCH_NAME -m "Create branch"` |
| `none` | Skip — no branching |

### Committing changes

| VCS_TYPE | Command |
|----------|---------|
| `github` / `gitlab` / `bitbucket` / `azure-devops` | `git add -A && git commit -m "$MSG"` |
| `svn` | `svn add --force . && svn commit -m "$MSG"` |
| `none` | Skip |

### Pushing / syncing

| VCS_TYPE | Command |
|----------|---------|
| `github` | `git push -u origin $BRANCH_NAME` |
| `gitlab` | `git push -u origin $BRANCH_NAME` |
| `bitbucket` | `git push -u origin $BRANCH_NAME` |
| `azure-devops` | `git push -u origin $BRANCH_NAME` |
| `svn` | Already committed to server (SVN is centralized) |
| `none` | Skip |

### Creating a Pull/Merge Request

| VCS_TYPE | Command |
|----------|---------|
| `github` | `gh pr create --title "$TITLE" --body "$BODY"` |
| `gitlab` | `glab mr create --title "$TITLE" --description "$BODY" --target-branch $DEV_BRANCH` |
| `bitbucket` | Manual — print URL: `https://bitbucket.org/$WORKSPACE/$REPO/pull-requests/new` |
| `azure-devops` | `az repos pr create --title "$TITLE" --description "$BODY" --target-branch $DEV_BRANCH` |
| `svn` | No PR — print: "Ready for code review. Branch: $SVN_URL/$SVN_BRANCHES/$BRANCH_NAME" |
| `none` | Skip |

### Merging

| VCS_TYPE | Command |
|----------|---------|
| `github` | `gh pr merge --squash --delete-branch` |
| `gitlab` | `glab mr merge --squash --remove-source-branch` |
| `bitbucket` | Manual — print merge URL |
| `azure-devops` | `az repos pr update --id $PR_ID --status completed --squash true --delete-source-branch true` |
| `svn` | `svn merge $SVN_URL/$SVN_BRANCHES/$BRANCH_NAME && svn commit -m "Merge $BRANCH_NAME"` |
| `none` | Skip |

### Creating an Issue / Work Item

| VCS_TYPE | Command |
|----------|---------|
| `github` | `gh issue create --title "$TITLE" --body "$BODY" --label "$LABEL"` |
| `gitlab` | `glab issue create --title "$TITLE" --description "$BODY" --label "$LABEL"` |
| `azure-devops` | `az boards work-item create --type "Bug" --title "$TITLE" --description "$BODY"` |
| `svn` | Skip — use PM_TYPE for tracking |
| `none` | Skip |

### Closing an Issue / Work Item

| VCS_TYPE | Command |
|----------|---------|
| `github` | `gh issue close $ISSUE_NUM --comment "$MSG"` |
| `gitlab` | `glab issue close $ISSUE_NUM --comment "$MSG"` |
| `azure-devops` | `az boards work-item update --id $ITEM_ID --state "Done"` |
| `svn` | Skip — use PM_TYPE for tracking |
| `none` | Skip |

---

## Step 3 — Project Management Operations

### Creating a task

| PM_TYPE | Method |
|---------|--------|
| `notion` | Use Notion MCP tools → `notion-create-pages` with NOTION_DATABASE_ID |
| `github-issues` | Same as VCS issue (already created above — skip duplicate) |
| `gitlab-issues` | Same as VCS issue (already created above — skip duplicate) |
| `jira` | `curl -X POST "$JIRA_URL/rest/api/3/issue" -H "Authorization: Basic $JIRA_API_TOKEN" ...` |
| `azure-boards` | `az boards work-item create ...` |
| `linear` | Use Linear API or MCP if available |
| `trello` | Use Trello API: `curl -X POST "https://api.trello.com/1/cards" ...` |
| `none` | Skip — print task summary to console only |

### Updating task to Done

| PM_TYPE | Method |
|---------|--------|
| `notion` | Use Notion MCP tools → `notion-update-page` → Status = "Done" |
| `github-issues` | Closed via VCS step above |
| `gitlab-issues` | Closed via VCS step above |
| `jira` | `curl -X POST "$JIRA_URL/rest/api/3/issue/$KEY/transitions" ...` → "Done" |
| `azure-boards` | `az boards work-item update --id $ID --state "Done"` |
| `linear` | Use Linear API → update state to "Done" |
| `trello` | Move card to "Done" list |
| `none` | Skip |

---

## Step 4 — Branching Strategy

### Branch naming

| BRANCH_STRATEGY | Feature branch | Fix branch |
|-----------------|---------------|------------|
| `gitflow` | `feature/short-name` | `fix/short-name` or `hotfix/short-name` |
| `trunk` | `feature/short-name` | `fix/short-name` |
| `simple` | No branch — commit to main | No branch — commit to main |
| `svn-standard` | `branches/feature-short-name` | `branches/fix-short-name` |

### Base branch

| BRANCH_STRATEGY | Branch from | Merge back to |
|-----------------|-------------|---------------|
| `gitflow` | `develop` | `develop` |
| `trunk` | `main` | `main` |
| `simple` | `main` | `main` (direct commit) |
| `svn-standard` | `trunk` | `trunk` |

---

---

## Step 5 — Secondary VCS Mirror (run after primary merge)

Check if secondary VCS is configured, then mirror:

```bash
source .project.env 2>/dev/null || true

mirror_to_secondary() {
  local SECONDARY=$1
  local REMOTE_VAR="${SECONDARY^^}_REMOTE_URL"
  echo "⏳ Mirroring to secondary VCS: $SECONDARY"

  case "$SECONDARY" in
    gitlab)
      if ! git remote | grep -q "^gitlab$"; then
        git remote add gitlab "$GITLAB_REMOTE_URL"
      fi
      for B in ${VCS_SYNC_BRANCHES:-main develop}; do
        git show-ref --verify --quiet refs/heads/$B && git push gitlab $B
      done
      git push gitlab --tags
      echo "✅ Mirrored → GitLab"
      ;;
    github)
      if ! git remote | grep -q "^github-mirror$"; then
        git remote add github-mirror "https://github.com/$GITHUB_USERNAME/$GITHUB_MIRROR_REPO.git"
      fi
      for B in ${VCS_SYNC_BRANCHES:-main develop}; do
        git show-ref --verify --quiet refs/heads/$B && git push github-mirror $B
      done
      git push github-mirror --tags
      echo "✅ Mirrored → GitHub"
      ;;
    bitbucket)
      if ! git remote | grep -q "^bitbucket$"; then
        git remote add bitbucket "https://bitbucket.org/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO.git"
      fi
      for B in ${VCS_SYNC_BRANCHES:-main develop}; do
        git show-ref --verify --quiet refs/heads/$B && git push bitbucket $B
      done
      git push bitbucket --tags
      echo "✅ Mirrored → Bitbucket"
      ;;
    svn)
      git svn dcommit
      echo "✅ Committed → SVN (git-svn)"
      ;;
    azure-devops)
      if ! git remote | grep -q "^azure$"; then
        git remote add azure "$AZURE_ORG/$AZURE_PROJECT/_git/$AZURE_REPO"
      fi
      for B in ${VCS_SYNC_BRANCHES:-main develop}; do
        git show-ref --verify --quiet refs/heads/$B && git push azure $B
      done
      git push azure --tags
      echo "✅ Mirrored → Azure DevOps"
      ;;
    none|"")
      echo "⏭ No secondary VCS configured — skipping"
      ;;
    *)
      echo "⚠️ Unknown VCS_SECONDARY: $SECONDARY — skipping"
      ;;
  esac
}

[ -n "$VCS_SECONDARY_1" ] && [ "$VCS_SECONDARY_1" != "none" ] && mirror_to_secondary "$VCS_SECONDARY_1"
[ -n "$VCS_SECONDARY_2" ] && [ "$VCS_SECONDARY_2" != "none" ] && mirror_to_secondary "$VCS_SECONDARY_2"
```

For detailed sync operations and conflict resolution:
→ Read `~/.claude/sdlc/devstarter-vcs-sync.md`

---

## Special Cases

### SVN Projects (legacy C#, Java, etc.)

When `VCS_TYPE=svn`:
- No PR workflow — use "ready for review" message instead
- Commit = push (SVN is centralized)
- Branch = `svn copy` (lightweight in SVN)
- Use PM_TYPE for task tracking (GitHub Issues not available)
- If `PM_TYPE=none` → just print summary to console

### No VCS / No PM Projects

When `VCS_TYPE=none` AND `PM_TYPE=none`:
- All code changes are made locally
- Print summary of files changed to console
- No branching, no commits, no PRs, no task tracking
- User manages version control manually

### Mixed setups

Some teams use:
- SVN for code + Jira for tasks → `VCS_TYPE=svn` + `PM_TYPE=jira`
- GitHub for code + Notion for tasks → `VCS_TYPE=github` + `PM_TYPE=notion`
- No VCS + Trello for tasks → `VCS_TYPE=none` + `PM_TYPE=trello`

All combinations are valid.

### Multi-VCS (primary + mirrors)

When a team uses multiple VCS simultaneously (e.g. GitHub primary + GitLab mirror + SVN archive):

```bash
# .project.env
VCS_TYPE=github          # primary — full PR/issue/branch workflow runs here
VCS_SECONDARY_1=gitlab   # mirror — pushed after every primary merge
VCS_SECONDARY_2=svn      # archive — committed after every primary merge
VCS_SYNC_BRANCHES=main develop
```

**Rule:** All SDLC operations (branching, PRs, issues, CI) run against `VCS_TYPE` only.
Secondary VCS receive pushes at the END of each workflow (Step 5).
Secondary VCS are never the source of truth — they receive, never initiate.

After any merge, agents MUST call Step 5 mirror function above.
For on-demand sync or conflict resolution: read `~/.claude/sdlc/devstarter-vcs-sync.md`.
