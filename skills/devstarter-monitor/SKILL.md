# /devstarter-monitor — Setup Monitoring

Set up logs / metrics / alerts / dashboards for a service.

## When to use vs alternatives

- **Use this** when: standing up observability for a new service or backfilling for an existing one
- **Use /devstarter-incident** instead when: responding to an active production incident (different concern — incident IS the response)
- **Use /devstarter-audit** instead when: reviewing what monitoring already exists (audit covers gaps; this command sets new things up)

## Inline Args

```
/devstarter-monitor                         → interactive (pick stack + scope)
/devstarter-monitor logs                    → logs-only setup (loki/cloudwatch/datadog)
/devstarter-monitor metrics                 → metrics + dashboards (prometheus/grafana)
/devstarter-monitor alerts                  → alert rules + on-call routing
```

Read `~/.claude/sdlc/devstarter-monitor.md` and follow all phases.

---

## 🌐 Universal Prompt — Works with Any AI

> **Claude Code users:** Use `/devstarter-monitor` above.
> **Codex / Gemini / Copilot / ChatGPT:** Copy the prompt below into your AI.

```
DevStarter — Set up monitoring, alerting, and observability

DevStarter install path: ~/.claude/ (Mac/Linux) or %USERPROFILE%\.claude (Windows)
Full workflow / agent spec: read `sdlc/devstarter-monitor.md` from your DevStarter install.

Stop at every ⛔ GATE marker and wait for my approval before continuing.
Start: type 'start' or describe your request
```

> Not set up for your AI? See `docs/multi-ai-guide.md` for non-Claude setup.
