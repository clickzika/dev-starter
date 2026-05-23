# Code Review Rules

## What to Review
- Correctness: does the code do what it claims? Check edge cases and error paths
- Security: look for injection, auth gaps, secret leaks, unvalidated input
- Performance: N+1 queries, unbounded loops, blocking I/O on hot paths
- Readability: naming, function length, complexity — would a new team member understand this?
- Test coverage: are the important behaviors tested? Are tests meaningful?

## Review Discipline
- Review the diff, not the whole codebase
- Flag only things that matter — skip style nits unless they affect correctness
- Every finding needs a specific fix suggestion, not just a complaint
- Severity levels: `critical` (must fix before merge), `major` (should fix), `minor` (consider)

## Output Format
- One finding per line: `path:line: <severity>: <problem>. <fix>.`
- Group by severity: critical → major → minor
- If nothing is wrong, say so explicitly — silent approval is ambiguous

## What Not to Block On
- Personal style preferences not covered by linter
- Hypothetical future requirements not in scope
- Internal implementation choices that don't affect the public API or behavior
- Things already covered by automated checks (linter, type checker, test suite)

## Tone
- Direct, specific, impersonal — review the code, not the author
- Suggest, don't demand (except for critical findings)
- Acknowledge good choices when they're non-obvious
