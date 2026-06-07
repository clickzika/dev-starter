---
type: project-snapshot
title: "{{TITLE}}"
project: "{{PROJECT}}"
date: {{DATE}}
author: "{{AUTHOR}}"
version: "{{VERSION}}"                   # release tag at time of snapshot, e.g. v1.0.0 or initial
stack: [{{STACK}}]                       # e.g. ["typescript", "react", "postgres"]
architecture_pattern: "{{ARCH_PATTERN}}" # e.g. monolith, microservices, serverless, jamstack
key_decisions: [{{KEY_DECISIONS}}]       # brief list of major architectural/tech decisions
constraints: [{{CONSTRAINTS}}]           # e.g. ["must deploy on-prem", "team size: solo"]
repo_url: "{{REPO_URL}}"                 # e.g. https://github.com/org/repo
tags: [project-snapshot, "{{PROJECT}}"]
---

# {{TITLE}}

> Project snapshot at {{VERSION}} — stack: {{STACK}}. Captured {{DATE}}.

## Project Overview
{{PROJECT_OVERVIEW}}

## Tech Stack
{{STACK_DETAIL}}

## Key Architecture Decisions
{{KEY_DECISIONS_DETAIL}}

## Constraints
{{CONSTRAINTS_DETAIL}}

## Repository
- Repo: {{REPO_URL}}
- Branch strategy: {{BRANCH_STRATEGY}}
- CI/CD: {{CI_TYPE}}

## Team Notes
{{TEAM_NOTES}}

## Links
- Project: [[{{PROJECT}}]]

<!-- Sanitized on write (@oss-sanitizer): no secrets, internal URLs, credentials, or customer data. -->
<!-- Hierarchical vault path (folder_structure: hierarchical): <subdir>/snapshots/<filename>.md -->
