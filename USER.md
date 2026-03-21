# USER.md — Developer Skill Profile

## Purpose

This file tells all agents how to calibrate their output depth.
Place at `~/.claude/USER.md` for global use.
All agents read this file at session start.

**Quick setup:** Run `bash ~/.claude/setup.sh` — it asks 3 questions and fills this file automatically.
**Manual setup:** Edit the levels below directly.

---

## Identity

Name:         Dev
Role:         Developer
Time zone:    UTC
Language:     English

---

## Overall Level

overall: Intermediate

---

## Skill Levels

### Programming Languages
| Language   | Level        |
|------------|--------------|
| JavaScript | Intermediate |
| TypeScript | Intermediate |
| Python     | Intermediate |
| C#         | Intermediate |
| Go         | Intermediate |
| Java       | Intermediate |
| SQL        | Intermediate |

### Frameworks & Tools
| Tool                  | Level        |
|-----------------------|--------------|
| React / Next.js       | Intermediate |
| Angular               | Intermediate |
| Vue                   | Intermediate |
| Node.js / Express     | Intermediate |
| ASP.NET Core          | Intermediate |
| Flutter               | Intermediate |
| Docker                | Intermediate |
| Git / GitHub          | Intermediate |
| CI/CD                 | Intermediate |
| Cloud (Azure/AWS/GCP) | Intermediate |

### Concepts
| Concept         | Level        |
|-----------------|--------------|
| REST API design | Intermediate |
| Database design | Intermediate |
| Security (OWASP)| Intermediate |
| Testing         | Intermediate |
| System design   | Intermediate |

---

## Communication Preferences

Response language:    English
Code comments:        English
Explanation style:    Show full example
Error messages:       Keep in English
When I am stuck:      Walk me through step by step

---

## Agent Calibration Rules

When agents read this file, they MUST apply these rules:

| Level        | Agent behavior                                                         |
|--------------|------------------------------------------------------------------------|
| Beginner     | Explain the why. Full working examples. Warnings. Define all jargon.   |
| Intermediate | Brief explanation + code. Skip basics. Highlight non-obvious parts.    |
| Advanced     | Code + trade-offs. No hand-holding. Flag edge cases only.              |
| Expert       | Dense output. Assume full context. Focus on non-trivial only.          |

If USER.md is missing → agent asks once: "What is your experience level with [topic]?"
Then calibrates — never asks again in the same session.
