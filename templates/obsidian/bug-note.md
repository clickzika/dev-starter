---
type: bug
title: "{{TITLE}}"
project: "{{PROJECT}}"
date: {{DATE}}
author: "{{AUTHOR}}"
status: fixed              # fixed | mitigated | known-issue
language: "{{LANGUAGE}}"    # e.g. typescript, python, go
framework: "{{FRAMEWORK}}"  # e.g. react, fastapi, none
symptom: "{{SYMPTOM_ONE_LINE}}"
root_cause_category: "{{ROOT_CAUSE_CATEGORY}}"  # e.g. null-deref, race-condition, auth-token-expiry, off-by-one, config-drift
tags: [bug, "{{ROOT_CAUSE_CATEGORY}}", "{{LANGUAGE}}"]
source: "{{SOURCE_REF}}"    # PR / commit / ticket / doc path
---

# {{TITLE}}

> One-line: {{SYMPTOM_ONE_LINE}} — fixed via {{FIX_ONE_LINE}}.

## Symptom
{{SYMPTOM}}

## Root cause
{{ROOT_CAUSE}}

## Fix
{{FIX}}

## Why it slipped through
{{WHY_SLIPPED}}

## Reuse note — applies elsewhere when
{{REUSE_WHEN}}

## Links
- Project: [[{{PROJECT}}]]
- Category: [[{{ROOT_CAUSE_CATEGORY}}]]
- Related: {{RELATED_WIKILINKS}}

<!-- Sanitized on write (@oss-sanitizer): no secrets, internal URLs, credentials, or customer data. -->
