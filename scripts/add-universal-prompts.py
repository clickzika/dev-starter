#!/usr/bin/env python3
"""Add Universal Prompt blocks to all SKILL.md files for multi-AI support."""

import os
import re

SKILLS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "skills")

# Mapping: skill dir name → (sdlc_or_agent_path, description, category)
SKILL_MAP = {
    # Core workflows — SDLC routing
    "devstarter-new":       ("sdlc/devstarter-starter.md", "Start a new project from scratch with full SDLC setup", "workflow"),
    "devstarter-existing":  ("sdlc/devstarter-existing.md", "Onboard an existing project into the DevStarter workflow system", "workflow"),
    "devstarter-change":    ("sdlc/devstarter-change.md", "Add a feature, remove a feature, or fix a bug with guided gates", "workflow"),
    "devstarter-audit":     ("sdlc/devstarter-audit.md", "Audit and review a project for quality, security, and health", "workflow"),
    "devstarter-document":  ("sdlc/devstarter-document.md", "Generate or regenerate project documents (BRD, API, DB, UX)", "workflow"),
    "devstarter-context":   ("sdlc/devstarter-context.md", "Refresh and sync project context across all docs and memory", "workflow"),
    "devstarter-export":    ("sdlc/devstarter-export.md", "Export DevStarter project for backup or transfer", "workflow"),
    "devstarter-import":    ("sdlc/devstarter-import.md", "Import a DevStarter project from a backup archive", "workflow"),
    "devstarter-sprint":    ("sdlc/devstarter-sprint.md", "Run sprint planning with task breakdown and Notion/GitHub sync", "workflow"),
    "devstarter-release":   ("sdlc/devstarter-release.md", "Release and deploy: develop → SIT → UAT → main → tag", "workflow"),
    "devstarter-hotfix":    ("sdlc/devstarter-hotfix.md", "Apply a critical production bug fix bypassing normal flow", "workflow"),
    "devstarter-rollback":  ("sdlc/devstarter-rollback.md", "Roll back production to the previous stable version", "workflow"),
    "devstarter-incident":  ("sdlc/devstarter-incident.md", "Run incident response: detect, contain, resolve, and report", "workflow"),
    "devstarter-dependency":("sdlc/devstarter-dependency.md", "Update and audit project dependencies safely", "workflow"),
    "devstarter-env":       ("sdlc/devstarter-env.md", "Set up a local development environment from scratch", "workflow"),
    "devstarter-secrets":   ("sdlc/devstarter-secrets.md", "Audit, rotate, and manage secrets securely", "workflow"),
    "devstarter-monitor":   ("sdlc/devstarter-monitor.md", "Set up monitoring, alerting, and observability", "workflow"),
    "devstarter-gitsetup":  ("sdlc/devstarter-gitsetup.md", "Initialize Git, Gitflow, branch protection, and remotes", "workflow"),
    "devstarter-migrate":   ("sdlc/devstarter-migrate.md", "Migrate a project to a new tech stack", "workflow"),
    "devstarter-onboard":   ("sdlc/devstarter-onboarding.md", "Onboard a new team member with docs, access, and orientation", "workflow"),
    "devstarter-handover":  ("sdlc/devstarter-handover.md", "Hand over a project to another team or person", "workflow"),
    "devstarter-retro":     ("sdlc/devstarter-retrospective.md", "Run a blameless sprint retrospective", "workflow"),
    "devstarter-consult":   ("sdlc/devstarter-consult.md", "Get expert architecture and strategy advice before building", "workflow"),
    "devstarter-debug":     ("sdlc/devstarter-debug.md", "Run a senior-dev hypothesis-driven investigation to root-cause a bug", "workflow"),
    "devstarter-review":    ("sdlc/devstarter-review.md", "Run an interactive code review with multi-agent feedback", "workflow"),
    "devstarter-doctor":    ("sdlc/devstarter-doctor.md", "Run a DevStarter install health check and fix issues", "workflow"),
    "devstarter-adr":       ("sdlc/devstarter-adr.md", "Create an Architecture Decision Record for a technical choice", "workflow"),
    "devstarter-compliance":("sdlc/devstarter-compliance.md", "Run a compliance audit (WCAG, GDPR, HIPAA, SOC 2, PCI-DSS, ISO 27001)", "workflow"),
    "devstarter-postmortem":("sdlc/devstarter-postmortem.md", "Run a blameless post-mortem with 5 Whys root cause analysis", "workflow"),
    "devstarter-profile":   ("sdlc/devstarter-profile.md", "Run a proactive performance investigation", "workflow"),
    "devstarter-mcp":       ("sdlc/devstarter-mcp.md", "Set up and configure MCP servers for AI tool integrations", "workflow"),
    "devstarter-council":   ("sdlc/devstarter-council.md", "Run a multi-agent council review for critical decisions", "workflow"),
    "devstarter-verification-loop": ("sdlc/devstarter-verification-loop.md", "Run an automated verification loop to validate changes", "workflow"),
    "devstarter-update":    ("update.sh", "Update DevStarter to the latest version", "utility"),
    "devstarter-menu":      ("devstarter-menu.md", "Show the DevStarter project launcher menu with all 30+ commands", "utility"),
    "devstarter-agents":    ("agents/", "List all specialist agents and their capabilities", "utility"),
    "devstarter-registry":  ("", "Quick reference for all DevStarter slash commands", "utility"),
    "update":               ("update.sh", "Update DevStarter to the latest version (alias for /devstarter-update)", "utility"),
    # Agent direct-invoke skills
    "devstarter-ba":        ("agents/devstarter-ba.md", "Business Analyst — requirements, BRD, and user stories", "agent"),
    "devstarter-backend":   ("agents/devstarter-backend.md", "Backend Engineer — API, services, and server-side logic", "agent"),
    "devstarter-dba":       ("agents/devstarter-dba.md", "Database Architect — schema design, migrations, and queries", "agent"),
    "devstarter-devops":    ("agents/devstarter-devops.md", "DevOps Engineer — CI/CD, infra, Docker, and deployments", "agent"),
    "devstarter-docs":      ("agents/devstarter-docs.md", "Technical Writer — docs, API references, and changelogs", "agent"),
    "devstarter-frontend":  ("agents/devstarter-frontend.md", "Frontend Engineer — UI components, state, and routing", "agent"),
    "devstarter-mlops":     ("agents/devstarter-mlops.md", "MLOps Engineer — ML pipelines, model serving, and monitoring", "agent"),
    "devstarter-mobile":    ("agents/devstarter-mobile.md", "Mobile Engineer — Flutter, React Native, and native apps", "agent"),
    "devstarter-pm":        ("agents/devstarter-pm.md", "Project Manager — sprint planning, tracking, and stakeholder comms", "agent"),
    "devstarter-qa":        ("agents/devstarter-qa.md", "QA Engineer — testing strategy, automation, and coverage", "agent"),
    "devstarter-security":  ("agents/devstarter-security.md", "Security Engineer — OWASP, auth, secrets, and threat modeling", "agent"),
    "devstarter-techlead":  ("agents/devstarter-techlead.md", "Tech Lead — architecture, code review, and ADRs", "agent"),
    "devstarter-uxui":      ("agents/devstarter-uxui.md", "UX/UI Designer — design system, prototypes, and accessibility", "agent"),
}

UNIVERSAL_PROMPT_MARKER = "## 🌐 Universal Prompt"

def get_workflow_name_from_header(content):
    """Extract workflow name from # header."""
    lines = content.strip().split("\n")
    if lines and lines[0].startswith("#"):
        # Strip leading #, /, and whitespace
        return lines[0].lstrip("#").lstrip("/").strip()
    return ""

def build_universal_prompt_block(skill_name, skill_info):
    """Build the Universal Prompt block for a skill."""
    file_path, description, category = skill_info

    if category == "workflow":
        file_ref = f"`{file_path}`"
        start_instruction = "type 'start' or describe your request"
    elif category == "agent":
        file_ref = f"`{file_path}`"
        start_instruction = "describe what you need the agent to help with"
    else:  # utility
        file_ref = f"`{file_path}`" if file_path else "N/A"
        start_instruction = "type 'start'"

    command = f"/{skill_name}" if skill_name != "update" else "/update"

    block = f"""
---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `{command}` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — {description}

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\\.claude (Windows)
Full workflow / agent spec: read {file_ref} from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: {start_instruction}
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
"""
    return block


def process_skill_file(skill_dir, skill_name):
    """Add Universal Prompt block to a SKILL.md if not already present."""
    skill_md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.exists(skill_md):
        return False, "SKILL.md not found"

    with open(skill_md, "r", encoding="utf-8") as f:
        content = f.read()

    # Skip if already has Universal Prompt block
    if UNIVERSAL_PROMPT_MARKER in content:
        return True, "already has Universal Prompt block (skipped)"

    # Get skill info
    skill_info = SKILL_MAP.get(skill_name)
    if not skill_info:
        return False, f"no mapping found for '{skill_name}'"

    # Build the block
    block = build_universal_prompt_block(skill_name, skill_info)

    # Append to end of file
    updated_content = content.rstrip() + "\n" + block

    with open(skill_md, "w", encoding="utf-8") as f:
        f.write(updated_content)

    return True, "added Universal Prompt block"


def main():
    if not os.path.isdir(SKILLS_DIR):
        print(f"ERROR: skills dir not found: {SKILLS_DIR}")
        return

    results = {"success": [], "skipped": [], "failed": []}

    for skill_dir_name in sorted(os.listdir(SKILLS_DIR)):
        skill_dir = os.path.join(SKILLS_DIR, skill_dir_name)
        if not os.path.isdir(skill_dir):
            continue

        ok, msg = process_skill_file(skill_dir, skill_dir_name)
        entry = f"  {skill_dir_name}: {msg}"

        if ok and "skipped" in msg:
            results["skipped"].append(entry)
        elif ok:
            results["success"].append(entry)
        else:
            results["failed"].append(entry)

    print(f"\n✅ Updated ({len(results['success'])}):")
    for r in results["success"]:
        print(r)

    if results["skipped"]:
        print(f"\n⏭️  Skipped — already done ({len(results['skipped'])}):")
        for r in results["skipped"]:
            print(r)

    if results["failed"]:
        print(f"\n❌ Failed ({len(results['failed'])}):")
        for r in results["failed"]:
            print(r)

    total = len(results["success"]) + len(results["skipped"]) + len(results["failed"])
    print(f"\nDone. {len(results['success'])} updated, {len(results['skipped'])} skipped, {len(results['failed'])} failed / {total} total.")


if __name__ == "__main__":
    main()
