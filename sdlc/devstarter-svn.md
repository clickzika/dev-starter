# devstarter-svn.md — Shared SVN Procedures

**Common VCS conventions (branch naming, labels, semver rules, conflict protocol):**
Read `~/.claude/sdlc/devstarter-vcs-common.md` — do not duplicate those definitions here.

## Purpose

This file contains SVN-specific procedures (`svn`, `git-svn` CLI) used by all DevStarter
workflows when `VCS_TYPE=svn` or `VCS_SECONDARY_1/2=svn` is set in `.project.env`.

Two usage modes:
1. **Primary VCS (`VCS_TYPE=svn`)** — SVN is the single source of truth, no git
2. **Secondary/mirror (`VCS_SECONDARY=svn`)** — git is primary, SVN receives git-svn commits

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## Prerequisites Check

```bash
# 1. Check SVN client
if ! command -v svn &>/dev/null; then
  echo "ERROR: svn not installed"
  echo "Install: sudo apt install subversion  OR  brew install subversion"
  exit 1
fi
svn --version --quiet

# 2. For git-svn bridge (secondary mode)
if ! git svn --version &>/dev/null 2>&1; then
  echo "WARNING: git-svn not installed"
  echo "Install: sudo apt install git-svn  OR  brew install git-svn"
fi

# 3. Load config
source .project.env 2>/dev/null || true
echo "SVN_URL:      ${SVN_URL:-NOT SET}"        # e.g. https://svn.company.com/repos/myproject
echo "SVN_USERNAME: ${SVN_USERNAME:-NOT SET}"
echo "SVN_TRUNK:    ${SVN_TRUNK:-trunk}"
echo "SVN_BRANCHES: ${SVN_BRANCHES:-branches}"
echo "SVN_TAGS:     ${SVN_TAGS:-tags}"
```

Required `.project.env` fields:
```bash
VCS_TYPE=svn                                         # or set as secondary
SVN_URL=https://svn.company.com/repos/myproject      # or svn+ssh:// or file:///
SVN_USERNAME=yourname
SVN_PASSWORD=yourpassword                            # or use SVN credential store
SVN_TRUNK=trunk
SVN_BRANCHES=branches
SVN_TAGS=tags
```

---

## MODE A — SVN as Primary VCS (no git)

Use this mode when the team works directly with SVN and does not use git.

---

## PROC-SV-01 — Create New SVN Repository

**Used by:** devstarter-starter.md (when VCS_TYPE=svn, self-hosted)

```bash
# Create repository on server (requires SSH access)
# Replace /var/svn with your SVN root directory
svnadmin create /var/svn/$PROJECT_NAME

# Create standard layout (trunk/branches/tags)
svn mkdir \
  file:///var/svn/$PROJECT_NAME/trunk \
  file:///var/svn/$PROJECT_NAME/branches \
  file:///var/svn/$PROJECT_NAME/tags \
  -m "chore: create standard repository layout"

echo "✅ SVN repository created at: /var/svn/$PROJECT_NAME"
echo "   Access via: svn+ssh://server/var/svn/$PROJECT_NAME"
```

For hosted SVN (e.g. VisualSVN Server, Assembla):
```bash
# No local svnadmin — create via web UI, then proceed to PROC-SV-02
```

---

## PROC-SV-02 — Checkout Working Copy

**Used by:** devstarter-starter.md, devstarter-existing.md

```bash
cd "$PARENT_DIR"

# Check out trunk into project directory
svn checkout "${SVN_URL}/${SVN_TRUNK}" "$PROJECT_NAME" \
  --username "$SVN_USERNAME"

cd "$PROJECT_NAME"
echo "✅ Working copy checked out: ${SVN_URL}/${SVN_TRUNK}"

# Verify
svn info
```

---

## PROC-SV-03 — Create Branch (feature work)

**Used by:** Gate 4 of all workflows

SVN branches are directory copies — instant on server side.

```bash
# Variables required: BRANCH_NAME (e.g. feature-login)

svn copy \
  "${SVN_URL}/${SVN_TRUNK}" \
  "${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}" \
  --username "$SVN_USERNAME" \
  -m "branch: create ${BRANCH_NAME} for issue #$ISSUE_NUMBER"

echo "✅ Branch created: ${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}"

# Switch working copy to new branch
svn switch "${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}"
echo "✅ Working copy switched to $BRANCH_NAME"
```

---

## PROC-SV-04 — Commit Changes

**Used by:** After every meaningful change

```bash
# Stage-less: svn add new files first, then commit all tracked changes

# Add new files (if any)
svn status | grep '?' | awk '{print $2}' | xargs -I{} svn add {}

# Commit
svn commit \
  --username "$SVN_USERNAME" \
  -m "feat: [description] (issue #$ISSUE_NUMBER)"

echo "✅ Committed to SVN"
svn info | grep "Last Changed Rev"
```

---

## PROC-SV-05 — Merge Branch to Trunk (equivalent of PR merge)

**Used by:** Gate 5 after work is reviewed

```bash
# Variables required: BRANCH_NAME, ISSUE_NUMBER

# Step 1: Update trunk working copy
svn checkout "${SVN_URL}/${SVN_TRUNK}" /tmp/svn-trunk-merge
cd /tmp/svn-trunk-merge

# Step 2: Find branch creation revision
BRANCH_REV=$(svn log --stop-on-copy -q "${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}" \
  | tail -2 | head -1 | awk '{print $1}' | tr -d 'r')

# Step 3: Merge branch changes into trunk
svn merge \
  -r "${BRANCH_REV}:HEAD" \
  "${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}" \
  --username "$SVN_USERNAME"

# Step 4: Resolve any conflicts, then commit merge
svn commit \
  --username "$SVN_USERNAME" \
  -m "merge: ${BRANCH_NAME} → trunk (issue #$ISSUE_NUMBER)"

echo "✅ Branch merged to trunk"

# Step 5: Delete merged branch
svn delete \
  "${SVN_URL}/${SVN_BRANCHES}/${BRANCH_NAME}" \
  --username "$SVN_USERNAME" \
  -m "chore: delete merged branch ${BRANCH_NAME}"

echo "✅ Branch deleted"
```

---

## PROC-SV-06 — Create Tag (release)

**Used by:** devstarter-release.md

```bash
# Variables required: VERSION (e.g. v1.2.0)

svn copy \
  "${SVN_URL}/${SVN_TRUNK}" \
  "${SVN_URL}/${SVN_TAGS}/${VERSION}" \
  --username "$SVN_USERNAME" \
  -m "release: tag ${VERSION}"

echo "✅ Release tag created: ${SVN_URL}/${SVN_TAGS}/${VERSION}"
```

---

## PROC-SV-07 — Revert / Rollback

**Used by:** devstarter-rollback.md

```bash
# Revert uncommitted local changes
svn revert --recursive .
echo "✅ Local changes reverted"

# Rollback a specific committed revision (reverse merge)
# Variables required: BAD_REV (revision to undo)
svn merge \
  -r "${BAD_REV}:$((BAD_REV - 1))" \
  "${SVN_URL}/${SVN_TRUNK}" \
  --username "$SVN_USERNAME"

svn commit \
  --username "$SVN_USERNAME" \
  -m "revert: undo r${BAD_REV} — [reason]"

echo "✅ r${BAD_REV} reverted and committed"
```

---

## PROC-SV-08 — View Log and Status

```bash
# Recent history
svn log -l 10 "${SVN_URL}/${SVN_TRUNK}" --username "$SVN_USERNAME"

# Changed files in a revision
svn log -v -r $REV "${SVN_URL}" --username "$SVN_USERNAME"

# Current working copy status
svn status

# Show diff before committing
svn diff
```

---

## MODE B — SVN as Secondary VCS (git-svn bridge)

Use this mode when git is the primary VCS and SVN receives mirrored commits
via `git-svn`. Set `VCS_SECONDARY_1=svn` or `VCS_SECONDARY_2=svn`.

---

## PROC-SV-09 — First-Time git-svn Setup (one-time)

**Run once** when adding SVN as a secondary mirror to an existing git repo.

```bash
cd "$PROJECT_DIR"

# Initialize git-svn connection (standard layout)
git svn init "$SVN_URL" \
  --trunk="$SVN_TRUNK" \
  --branches="$SVN_BRANCHES" \
  --tags="$SVN_TAGS" \
  --prefix=svn/

# Fetch SVN history (can take a while for large repos)
git svn fetch --username "$SVN_USERNAME"

echo "✅ git-svn initialized"
echo "   SVN remote refs available as: svn/trunk, svn/branches/*, svn/tags/*"
```

For new SVN repo with no prior history (mirror only):
```bash
# Skip fetch — just init the bridge
git svn init "$SVN_URL" --trunk="$SVN_TRUNK" --prefix=svn/
echo "✅ git-svn bridge initialized (no history fetch needed)"
```

---

## PROC-SV-10 — Push git Commits to SVN (mirror)

**Used by:** devstarter-vcs-sync.md Step 2, devstarter-change.md Rule 3b, devstarter-release.md

```bash
cd "$PROJECT_DIR"

# Ensure we are on the branch to mirror (usually main or develop)
git checkout "$SYNC_BRANCH"
git pull origin "$SYNC_BRANCH"

# Rebase onto SVN trunk to linearize history (required by git-svn)
git svn rebase --username "$SVN_USERNAME"

# Push commits to SVN
git svn dcommit --username "$SVN_USERNAME"

echo "✅ git commits pushed to SVN trunk"
```

If SVN has changes not in git (diverged):
```bash
# Pull SVN changes first
git svn rebase --username "$SVN_USERNAME"
# Resolve any conflicts
git svn dcommit --username "$SVN_USERNAME"
echo "✅ Rebased + pushed to SVN"
```

---

## PROC-SV-11 — Pull SVN Changes into git

**Used by:** When SVN has commits made directly (not via git-svn)

```bash
cd "$PROJECT_DIR"

git svn fetch --username "$SVN_USERNAME"
git svn rebase --username "$SVN_USERNAME"

echo "✅ SVN changes pulled into git"
git log --oneline -5
```

---

## PROC-SV-12 — Tag Release in SVN (from git tag)

**Used by:** devstarter-release.md — mirror release tag to SVN

```bash
# Variables required: VERSION (e.g. v1.2.0)

# Method 1: via git svn tag
git svn tag "$VERSION" --username "$SVN_USERNAME"

echo "✅ SVN tag created: ${SVN_URL}/${SVN_TAGS}/${VERSION}"
```

If `git svn tag` fails (not all setups support it):
```bash
# Method 2: manual svn copy
svn copy \
  "${SVN_URL}/${SVN_TRUNK}" \
  "${SVN_URL}/${SVN_TAGS}/${VERSION}" \
  --username "$SVN_USERNAME" \
  -m "release: tag ${VERSION} (mirrored from git)"

echo "✅ SVN tag created manually: ${SVN_URL}/${SVN_TAGS}/${VERSION}"
```

---

## PROC-SV-13 — Hotfix Mirror to SVN

**Used by:** devstarter-hotfix.md — after hotfix merged to main in git

```bash
cd "$PROJECT_DIR"

git checkout main
git pull origin main

git svn rebase --username "$SVN_USERNAME"
git svn dcommit --username "$SVN_USERNAME"

# Tag hotfix in SVN
svn copy \
  "${SVN_URL}/${SVN_TRUNK}" \
  "${SVN_URL}/${SVN_TAGS}/${HOTFIX_VERSION}" \
  --username "$SVN_USERNAME" \
  -m "hotfix: ${HOTFIX_VERSION}"

echo "✅ Hotfix mirrored to SVN and tagged ${HOTFIX_VERSION}"
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `svn: E170001: Authentication failed` | Check SVN_USERNAME/SVN_PASSWORD or run `svn auth` |
| `git svn: command not found` | `sudo apt install git-svn` or `brew install git-svn` |
| `git svn dcommit` fails — "out of date" | Run `git svn rebase` first, resolve conflicts, then retry |
| Merge conflict after `git svn rebase` | Resolve conflict files, `git add .`, `git rebase --continue` |
| Non-linear history error on dcommit | Squash commits first: `git rebase -i svn/trunk` |
| SVN `E155010: not a working copy` | You're in the wrong directory — `cd` to checkout root |
| Large repo fetch is slow | Use `--revision BASE:HEAD` to fetch only recent history |
| SVN externals not checked out | Run `svn update --set-depth infinity` |

---

## SVN vs git Quick Reference

| Concept | git | SVN |
|---------|-----|-----|
| Stage changes | `git add` | `svn add` (new files only) |
| Commit locally | `git commit` | `svn commit` (goes to server) |
| See status | `git status` | `svn status` |
| See history | `git log` | `svn log` |
| Create branch | `git checkout -b` | `svn copy trunk branches/X` |
| Switch branch | `git checkout X` | `svn switch URL/branches/X` |
| Merge branch | `git merge` | `svn merge -r REV:HEAD BRANCH_URL` |
| Tag release | `git tag` | `svn copy trunk tags/X` |
| Undo local | `git checkout .` | `svn revert --recursive .` |
| Rollback commit | `git revert` | `svn merge -r N:N-1` + `svn commit` |
