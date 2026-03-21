# USER.md — Developer Skill Profile

## Purpose

This file tells all agents how to calibrate their output depth.
Place at project root or `~/.claude/USER.md` for global use.
All agents read this file at session start.

---

## Identity

Name:         [Your name]
Role:         [e.g. Solo developer / Tech Lead / Product Owner]
Team size:    [e.g. 1 / 3 / 10+]
Time zone:    [e.g. Asia/Bangkok]
Language:     [e.g. Thai + English]

---

## Skill Levels

Rate yourself honestly. Agents adjust explanation depth based on this.

### Programming Languages
| Language   | Level              | Notes                        |
|------------|--------------------|------------------------------|
| C#         | [Beginner/Intermediate/Advanced/Expert] | |
| TypeScript | [Beginner/Intermediate/Advanced/Expert] | |
| Python     | [Beginner/Intermediate/Advanced/Expert] | |
| Go         | [Beginner/Intermediate/Advanced/Expert] | |
| SQL        | [Beginner/Intermediate/Advanced/Expert] | |
| Other:     | [Beginner/Intermediate/Advanced/Expert] | |

### Frameworks & Tools
| Tool            | Level              | Notes                        |
|-----------------|--------------------|------------------------------|
| Angular         | [Beginner/Intermediate/Advanced/Expert] | |
| React           | [Beginner/Intermediate/Advanced/Expert] | |
| ASP.NET Core    | [Beginner/Intermediate/Advanced/Expert] | |
| Docker          | [Beginner/Intermediate/Advanced/Expert] | |
| Git / GitHub    | [Beginner/Intermediate/Advanced/Expert] | |
| CI/CD           | [Beginner/Intermediate/Advanced/Expert] | |
| Cloud (Azure/AWS/GCP) | [Beginner/Intermediate/Advanced/Expert] | |

### Concepts
| Concept         | Level              | Notes                        |
|-----------------|--------------------|------------------------------|
| REST API design | [Beginner/Intermediate/Advanced/Expert] | |
| Database design | [Beginner/Intermediate/Advanced/Expert] | |
| Security (OWASP)| [Beginner/Intermediate/Advanced/Expert] | |
| Testing         | [Beginner/Intermediate/Advanced/Expert] | |
| System design   | [Beginner/Intermediate/Advanced/Expert] | |

---

## What I Struggle With

List topics where you want extra explanation, more examples, step-by-step guidance:

- [e.g. Docker networking]
- [e.g. JWT refresh token flow]
- [e.g. EF Core migrations]

---

## What I Am Good At

List topics where agents should skip basics and go straight to the answer:

- [e.g. SQL queries]
- [e.g. Angular component structure]
- [e.g. Git branching]

---

## Communication Preferences

Response language:    [Thai / English / Both]
Code comments:        [Thai / English]
Explanation style:    [Show full example / Explain concept only / Just the code]
Error messages:       [Translate to Thai / Keep in English]
When I am stuck:      [Walk me through step by step / Give me a hint only / Just fix it]

---

## Working Style

Daily hours:          [e.g. 09:00–18:00 BKK]
Session length:       [e.g. 1–2 hours typical]
Interruption style:   [Ask me questions as you go / Do your best and show me at the end]
Preferred commit size: [Small + frequent / Larger batches]

---

## Agent Calibration Rules

When agents read this file, they MUST apply these rules:

| My Level    | Agent behavior                                                         |
|-------------|------------------------------------------------------------------------|
| Beginner    | Explain the why. Full working examples. Warnings. Define all jargon.   |
| Intermediate| Brief explanation + code. Skip basics. Highlight non-obvious parts.    |
| Advanced    | Code + trade-offs. No hand-holding. Flag edge cases only.              |
| Expert      | Dense output. Assume full context. Focus on non-trivial only.          |

For topics in "What I Struggle With" → always give extra detail regardless of level.
For topics in "What I Am Good At" → skip fundamentals entirely.

If USER.md is missing → agent asks once: "What is your experience level with [topic]?"
Then calibrates — never asks again in the same session.
