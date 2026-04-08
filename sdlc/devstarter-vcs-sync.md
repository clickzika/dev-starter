# devstarter-vcs-sync.md — Multi-VCS Mirror & Sync
# DevStarter — Secondary VCS Operations Runbook

## Purpose

Sync changes from the primary VCS to one or more secondary VCS systems.
Run this after every merge to primary, or on a scheduled basis.

Used when `.project.env` has `VCS_SECONDARY_1` or `VCS_SECONDARY_2` defined.

---

**Config:** Read `devstarter-config.yml` for all project settings (`vcs.type`, `pm.type`, `ci.type`, `ai.provider`, etc.).


## When to Run

- After every `devstarter-change` feature merge to develop
- After every `devstarter-release` merge to main
- After every `devstarter-hotfix` merge to main
- On-demand: `/devstarter-vcs-sync` or read this file

---

## Step 1 — Load Config

```bash
source .project.env 2>/dev/null || true

echo "Primary VCS:     $VCS_TYPE"
echo "Secondary VCS 1: ${VCS_SECONDARY_1:-none}"
echo "Secondary VCS 2: ${VCS_SECONDARY_2:-none}"
echo "Sync branches:   ${VCS_SYNC_BRANCHES:-main develop}"
```

If both `VCS_SECONDARY_1` and `VCS_SECONDARY_2` are empty → skip sync, nothing to do.

---

## Step 2 — Mirror Operations by Secondary VCS Type

### Secondary = `gitlab` (push mirror)

```bash
# Ensure gitlab remote exists
if ! git remote | grep -q "gitlab"; then
  git remote add gitlab "$GITLAB_REMOTE_URL"
  echo "Added gitlab remote: $GITLAB_REMOTE_URL"
fi

# Push all sync branches to GitLab
for BRANCH in ${VCS_SYNC_BRANCHES:-main develop}; do
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    git push gitlab $BRANCH
    echo "✅ Mirrored $BRANCH → GitLab"
  fi
done

# Push tags
git push gitlab --tags
echo "✅ Tags mirrored → GitLab"
```

### Secondary = `github` (push mirror)

```bash
if ! git remote | grep -q "github-mirror"; then
  git remote add github-mirror "https://github.com/$GITHUB_USERNAME/$GITHUB_MIRROR_REPO.git"
fi

for BRANCH in ${VCS_SYNC_BRANCHES:-main develop}; do
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    git push github-mirror $BRANCH
    echo "✅ Mirrored $BRANCH → GitHub"
  fi
done
git push github-mirror --tags
```

### Secondary = `bitbucket` (push mirror)

```bash
if ! git remote | grep -q "bitbucket"; then
  git remote add bitbucket "https://bitbucket.org/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO.git"
fi

for BRANCH in ${VCS_SYNC_BRANCHES:-main develop}; do
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    git push bitbucket $BRANCH
    echo "✅ Mirrored $BRANCH → Bitbucket"
  fi
done
git push bitbucket --tags
```

### Secondary = `svn` (git-svn bridge)

```bash
# Requires: git-svn installed (git svn --version)
# First-time setup (run once):
#   git svn init $SVN_URL --trunk=trunk --branches=branches --tags=tags
#   git svn fetch

# Push current HEAD to SVN trunk
git svn dcommit
echo "✅ Committed git HEAD → SVN trunk"

# To push a specific branch:
# git checkout $BRANCH && git svn dcommit
```

### Secondary = `azure-devops` (push mirror)

```bash
if ! git remote | grep -q "azure"; then
  git remote add azure "$AZURE_ORG/$AZURE_PROJECT/_git/$AZURE_REPO"
fi

for BRANCH in ${VCS_SYNC_BRANCHES:-main develop}; do
  if git show-ref --verify --quiet refs/heads/$BRANCH; then
    git push azure $BRANCH
    echo "✅ Mirrored $BRANCH → Azure DevOps"
  fi
done
git push azure --tags
```

---

## Step 3 — Full Mirror (all-at-once, any provider)

For a complete push-mirror (all branches + tags):

```bash
# Option A: git push --mirror (overwrites everything on remote — use with care)
git push --mirror $SECONDARY_REMOTE_URL

# Option B: push only specific branches (safer)
git push $SECONDARY_REMOTE main develop --tags
```

---

## Step 4 — Automated Sync via GitHub Actions

Add to your CI pipeline to auto-sync on every push to main/develop:

```yaml
# .github/workflows/vcs-sync.yml
name: Mirror to Secondary VCS

on:
  push:
    branches: [main, develop]
    tags: ['v*']

jobs:
  mirror-gitlab:
    name: Mirror → GitLab
    runs-on: ubuntu-latest
    if: vars.VCS_SECONDARY_1 == 'gitlab' || vars.VCS_SECONDARY_2 == 'gitlab'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Push to GitLab
        run: |
          git remote add gitlab https://oauth2:${{ secrets.GITLAB_TOKEN }}@gitlab.com/${{ vars.GITLAB_PROJECT }}.git
          git push gitlab HEAD:${{ github.ref_name }}
          git push gitlab --tags

  mirror-svn:
    name: Sync → SVN
    runs-on: ubuntu-latest
    if: vars.VCS_SECONDARY_1 == 'svn' || vars.VCS_SECONDARY_2 == 'svn'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup git-svn
        run: sudo apt-get install -y git-svn

      - name: Init SVN bridge (first run only)
        run: |
          git svn init ${{ vars.SVN_URL }} --trunk=trunk

      - name: Commit to SVN
        env:
          SVN_USERNAME: ${{ secrets.SVN_USERNAME }}
          SVN_PASSWORD: ${{ secrets.SVN_PASSWORD }}
        run: |
          git svn dcommit --username $SVN_USERNAME --password $SVN_PASSWORD
```

---

## Conflict Resolution

When secondary VCS has diverged from primary:

```bash
# Pull from secondary first, resolve conflicts, then push
git fetch $SECONDARY_REMOTE
git merge $SECONDARY_REMOTE/main --allow-unrelated-histories
# Resolve conflicts
git push $SECONDARY_REMOTE main

# For SVN divergence:
git svn rebase   # pull SVN changes into git
# Resolve conflicts
git svn dcommit  # push back to SVN
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `remote: Permission denied` | Check token/credential for secondary remote |
| `git-svn: command not found` | `apt install git-svn` or `brew install git-svn` |
| `non-fast-forward` on mirror | Secondary has extra commits — fetch + rebase first |
| SVN `out of date` error | Run `git svn rebase` before `dcommit` |
| Tags not mirrored | Add `git push $REMOTE --tags` explicitly |

---

## Learned Patterns

<!-- Append new sync patterns discovered in sessions — ask user before modifying -->
