# Claude AI PR Review — Setup Guide
# DevStarter — Autonomous GitHub Actions PR Review

## What This Does

Every time a PR is opened or updated, Claude automatically:
1. Reads the diff (up to 30KB) and your CLAUDE.md for project context
2. Reviews for: security vulnerabilities, performance issues, code quality, test coverage
3. Posts a structured Markdown review as a PR comment
4. Adds `security-review-needed` label if security issues found

**Cost:** ~$0.003 per PR review using Claude Haiku (fast + cheap).
Upgrade to Claude Sonnet in the workflow for deeper reviews (~$0.10/PR).

---

## Setup (5 minutes)

### Step 1: Copy workflow to your project

```bash
cp ~/.claude/templates/github/claude-pr-review.yml .github/workflows/claude-pr-review.yml
```

### Step 2: Add Anthropic API key to GitHub Secrets

```bash
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."
# Verify:
gh secret list
```

Or manually: GitHub repo → Settings → Secrets and variables → Actions → New repository secret
- Name: `ANTHROPIC_API_KEY`
- Value: your Anthropic API key

### Step 3: Commit and push

```bash
git add .github/workflows/claude-pr-review.yml
git commit -m "ci: add Claude AI PR review workflow"
git push
```

### Step 4: Open a test PR

Create a test branch and open a PR. Claude will post a review within ~30 seconds.

---

## Customization

### Change the review model

Edit `.github/workflows/claude-pr-review.yml`:

```yaml
# Faster + cheaper (default)
model: "claude-haiku-4-5-20251001"

# More thorough
model: "claude-sonnet-4-6"
```

### Restrict to specific file paths

```yaml
on:
  pull_request:
    paths:
      - 'src/**'
      - 'backend/**'
      # Ignores: docs/, *.md, config files
```

### Use LiteLLM proxy instead of direct API

Replace the `Call Claude API for review` step with:

```yaml
- name: Call AI for review (via LiteLLM)
  env:
    LITELLM_API_KEY: ${{ secrets.LITELLM_API_KEY }}
    LITELLM_BASE_URL: ${{ secrets.LITELLM_BASE_URL }}
  run: |
    RESPONSE=$(curl -s "$LITELLM_BASE_URL/chat/completions" \
      -H "Authorization: Bearer $LITELLM_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$(jq -n \
        --arg diff "$DIFF" \
        '{
          model: "claude-sonnet",
          max_tokens: 2048,
          messages: [...]
        }')")
```

### Skip review for certain authors (bots)

```yaml
jobs:
  claude-review:
    if: |
      github.event.pull_request.draft == false &&
      github.event.pull_request.user.login != 'dependabot[bot]' &&
      github.event.pull_request.user.login != 'renovate[bot]'
```

### Add more labels

```yaml
- name: Add performance label
  if: contains(steps.review.outputs.review_text, 'N+1') || contains(steps.review.outputs.review_text, 'performance')
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      await github.rest.issues.addLabels({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        labels: ['performance-review-needed']
      });
```

---

## Review Output Format

Claude posts comments in this structure:

```markdown
## 🤖 Claude AI Code Review

### Summary
Brief overview of what the PR does and overall assessment.

### 🔴 Security
- [HIGH] `src/api/users.ts:42` — Missing authorization check on DELETE endpoint.
  Any authenticated user can delete any user's record. Add ownership verification.

### 🟡 Performance
- [MEDIUM] `src/services/order.service.ts:87` — N+1 query in order items loop.
  Batch with `findMany({ where: { orderId: { in: orderIds } } })` instead.

### 🟢 Code Quality
- `src/utils/validate.ts` — Good use of Zod schema validation.
- `tests/` — Unit tests cover happy path. Consider adding error case tests.

### Tests
- 3 new test files added. Coverage appears adequate for new functionality.

### Suggestions
1. Add rate limiting to the new /export endpoint
2. Consider extracting the email sending logic into a separate service

### Verdict: REQUEST_CHANGES
```

---

## Advanced: Separate Review Jobs per Language

For multi-language repos, run parallel specialized reviews:

```yaml
jobs:
  review-backend:
    if: contains(github.event.pull_request.changed_files, 'backend/')
    # ... reviews with backend-focused prompt

  review-frontend:
    if: contains(github.event.pull_request.changed_files, 'frontend/')
    # ... reviews with frontend-focused prompt

  review-infrastructure:
    if: contains(github.event.pull_request.changed_files, '.github/') || contains(github.event.pull_request.changed_files, 'terraform/')
    # ... reviews with infra/security-focused prompt
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `API key not found` | Check `ANTHROPIC_API_KEY` is set in repo secrets |
| Review not posted | Check workflow permissions: `pull-requests: write` |
| Review truncated | PR diff > 30KB — consider splitting large PRs |
| 402 Payment Required | Check Anthropic account billing |
| Review on every commit | Normal — workflow runs on `synchronize` event |
