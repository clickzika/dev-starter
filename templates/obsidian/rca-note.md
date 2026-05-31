---
type: rca
title: "{{TITLE}}"
project: "{{PROJECT}}"
date: {{DATE}}
author: "{{AUTHOR}}"
status: resolved           # resolved | monitoring | recurring
severity: "{{SEVERITY}}"    # SEV-1 | SEV-2 | SEV-3
language: "{{LANGUAGE}}"
framework: "{{FRAMEWORK}}"
symptom: "{{SYMPTOM_ONE_LINE}}"
root_cause_category: "{{ROOT_CAUSE_CATEGORY}}"
tags: [rca, incident, "{{ROOT_CAUSE_CATEGORY}}"]
source: "{{SOURCE_REF}}"    # incident doc / postmortem path
---

# {{TITLE}}

> One-line: {{SYMPTOM_ONE_LINE}} — root cause: {{ROOT_CAUSE_ONE_LINE}}.

## Impact
{{IMPACT}}

## Root cause (5 Whys)
{{ROOT_CAUSE}}

## Contributing factors
{{CONTRIBUTING_FACTORS}}

## What fixed it / mitigations
{{FIX}}

## Prevention — reuse on other projects
{{PREVENTION_REUSE}}

## Links
- Project: [[{{PROJECT}}]]
- Category: [[{{ROOT_CAUSE_CATEGORY}}]]
- Related: {{RELATED_WIKILINKS}}

<!-- Sanitized on write (@oss-sanitizer): no secrets, internal URLs, credentials, or customer data. -->
