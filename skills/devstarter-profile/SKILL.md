# /devstarter-profile — Proactive Performance Investigation

Investigate a performance issue *before* it becomes an incident. Captures a baseline, profiles to find bottlenecks, ranks them by impact, produces an optimization roadmap, and (optionally) hands off the top fix to `/devstarter-change`.

## ⚠️ Model Gate — Run Before Anything Else

This workflow requires **Opus** (`claude-opus-4-7`).

Use `AskUserQuestion` immediately:
- question: "Are you on Opus? If not, run `/model opus` first then re-run `/devstarter-profile`."
- options: ["Yes, I'm on Opus — proceed", "I need to switch — stopping here"]

If "I need to switch": stop immediately, do not load the SDLC runbook.
If "Yes, proceed": continue.

---

## When to use vs alternatives

- **Use this** when: investigating a *performance* issue proactively (APM trend, slow-query alert, Lighthouse drop, or quarterly review)
- **Use /devstarter-incident** instead when: there's an active production crisis (SEV-1/2 from perf degradation)
- **Use /devstarter-debug** instead when: investigating a *correctness* bug (wrong output, crash) — not slowness
- **Use /devstarter-monitor** instead when: you don't have measurement in place yet (cannot profile what is not measured)
- **Use /devstarter-audit** instead when: broad project review (perf is one slice)

## Inline Args

```
/devstarter-profile                                  → interactive intake
/devstarter-profile checkout-page-slow              → use as area slug (skip Q1)
/devstarter-profile memory/apm-trace-2026-05-09.md  → read profile data as context
```

Read `~/.claude/sdlc/devstarter-profile.md` and run all phases (intake → baseline → profile → bottleneck inventory → optimization roadmap → approval gate → save + handoff → verification).

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-profile` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Run a proactive performance investigation

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-profile.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
