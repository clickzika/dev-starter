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
