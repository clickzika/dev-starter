# dev-autopr.md — Autonomous PR Review
# DevStarter — GitHub Actions + Claude AI Runbook

## Model: Haiku (`claude-haiku-4-5-20251001`)

## What is Autonomous PR Review?

Autonomous PR review uses GitHub Actions + Claude API to automatically
review every pull request without human prompting. The AI reviews the
code diff and posts findings as a PR comment within 30-60 seconds of
the PR being opened.

This moves DevStarter from **"prompt-driven"** (human types /change)
to **"event-driven"** (code push automatically triggers AI review).

---

## Setup

### Quick Setup (new project)

```bash
# 1. Add workflow
cp ~/.claude/templates/github/claude-pr-review.yml .github/workflows/claude-pr-review.yml

# 2. Add API key secret
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."

# 3. Commit
git add .github/workflows/claude-pr-review.yml
git commit -m "ci: add Claude AI autonomous PR review"
git push
```

### Detailed Setup

See `~/.claude/templates/github/claude-pr-review-setup.md` for:
- Model selection (Haiku vs Sonnet)
- Path filtering
- LiteLLM proxy integration
- Label automation
- Multi-language jobs

---

## What Claude Reviews

Every PR automatically checked for:

| Category | What's Checked |
|----------|---------------|
| Security | OWASP Top 10, auth checks, SQL injection, XSS, secret exposure |
| Performance | N+1 queries, missing indexes, synchronous operations, memory leaks |
| Code Quality | Error handling, logging, naming, complexity |
| Tests | Coverage gaps, missing error case tests |
| Architecture | Violation of project conventions (read from CLAUDE.md) |

---

## Review Workflow

```
Developer opens PR
      ↓
GitHub Actions triggers (< 30 seconds)
      ↓
Claude reads: diff + CLAUDE.md (project context)
      ↓
Claude posts structured review comment
      ↓
Labels added if security/performance issues found
      ↓
Human reviewer reads AI findings
      ↓
Developer addresses AI findings
      ↓
Human approves and merges
```

The AI review is **advisory** — humans still approve and merge.
AI findings do not block merge by default (can be enforced via branch protection).

---

## Enforce AI Review (Optional)

To require AI review before merge, add branch protection:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  -X PUT \
  -f required_status_checks[strict]=true \
  -f 'required_status_checks[contexts][]=AI Code Review' \
  -f enforce_admins=false \
  -f required_pull_request_reviews[required_approving_review_count]=1
```

Or in GitHub Settings → Branches → main → Require status checks:
- Check "AI Code Review" (the job name from claude-pr-review.yml)

---

## Cost Estimation

| Model | Cost per PR review | At 100 PRs/month |
|-------|-------------------|-----------------|
| Claude Haiku (default) | ~$0.003 | ~$0.30/month |
| Claude Sonnet | ~$0.10 | ~$10/month |

**Recommendation:** Use Haiku for standard reviews, Sonnet only for security-sensitive repos.

---

## Extending: More Autonomous Actions

The PR review workflow is the foundation. Extend autonomy with:

### Auto-create GitHub Issues from AI findings

```yaml
- name: Create issue for security finding
  if: contains(steps.review.outputs.review_text, 'SECURITY')
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      await github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: `Security finding in PR #${context.issue.number}`,
        body: `Automated security finding from PR review.\n\nPR: #${context.issue.number}\nDetails: see PR comment.`,
        labels: ['security', 'automated']
      });
```

### Auto-run tests when AI flags test gaps

```yaml
- name: Request test coverage report
  if: contains(steps.review.outputs.review_text, 'missing tests') || contains(steps.review.outputs.review_text, 'test coverage')
  run: |
    echo "AI flagged test coverage gap — running coverage report"
    npm run test:coverage
```

### Auto-generate missing tests (advanced)

```yaml
- name: Generate missing tests
  if: contains(steps.review.outputs.review_text, 'missing tests')
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: |
    # Call Claude again specifically to generate test stubs
    python scripts/generate-tests.py --diff pr_diff.txt --output tests/generated/
    git add tests/generated/
    git commit -m "test: auto-generated test stubs from AI review"
    git push
```

---

## Integration with DevStarter Agents

The autonomous PR review complements human agents:

| Trigger | What Runs |
|---------|-----------|
| PR opened/updated | GitHub Actions → Claude AI review (automatic) |
| `/change` command | Human-triggered → full agent workflow (SDLC gates) |
| Release branch | Human-triggered → `devstarter-release.md` pipeline |
| Security label added | Human review by `@devstarter-security` agent |

The AI review catches issues early. Human agents handle deeper work.

---

## Troubleshooting

```bash
# Check workflow run status
gh run list --workflow=claude-pr-review.yml

# View workflow logs
gh run view [run-id] --log

# Re-run failed review
gh run rerun [run-id]

# Test API key works
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-haiku-4-5-20251001","max_tokens":100,"messages":[{"role":"user","content":"hello"}]}'
```
