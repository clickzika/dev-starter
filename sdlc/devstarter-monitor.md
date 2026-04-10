# dev-monitor.md — Monitoring + Observability Setup

## Model: Sonnet (`claude-sonnet-4-6`)

## How to Use

When setting up monitoring for a deployed project:
```
claude
> Read ~/.claude/devstarter-monitor.md and setup monitoring for this project
```

---

## PHASE 1 — What to Monitor

Agent reads CLAUDE.md to understand tech stack, then asks:

**Q1. What monitoring tools do you have / want?**
(select all that apply)
1. Prometheus + Grafana (self-hosted)
2. Datadog
3. Azure Monitor / Application Insights
4. AWS CloudWatch
5. Sentry (error tracking)
6. UptimeRobot / Pingdom (uptime)
7. Docker + container metrics only
8. Custom / none yet

**Q2. What alerts do you want?**
(select all that apply)
1. Service down (uptime)
2. High error rate (5xx responses)
3. Slow response time (P95 > threshold)
4. High CPU / memory
5. Database connection failures
6. Failed login attempts (security)
7. Disk space running low
8. CI/CD pipeline failures

---

## PHASE 2 — Health Endpoint

Every service MUST have a health endpoint.
Agent verifies or adds:

```csharp
// ASP.NET Core Minimal API
app.MapGet("/health", () => Results.Ok(new {
    status = "healthy",
    version = Assembly.GetEntryAssembly()?.GetName().Version?.ToString(),
    timestamp = DateTime.UtcNow,
    database = "ok"  // add real DB check
})).WithTags("Health").AllowAnonymous();

app.MapGet("/health/ready", async (AppDbContext db) => {
    try {
        await db.Database.CanConnectAsync();
        return Results.Ok(new { status = "ready", database = "connected" });
    } catch {
        return Results.StatusCode(503);
    }
}).WithTags("Health").AllowAnonymous();
```

---

## PHASE 3 — Structured Logging

Agent adds structured logging to backend:

```csharp
// Program.cs — add Serilog
builder.Host.UseSerilog((context, config) =>
    config
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .Enrich.WithMachineName()
        .WriteTo.Console(new JsonFormatter())
        .WriteTo.File(
            new JsonFormatter(),
            "logs/app-.log",
            rollingInterval: RollingInterval.Day,
            retainedFileCountLimit: 30
        )
);

// Never log PII — add filter:
// .Filter.ByExcluding(e => e.MessageTemplate.Text.Contains("password"))
```

Key events to log:
```
[ ] Auth events: login success/fail, logout, token refresh
[ ] 4xx/5xx responses with request path
[ ] DB connection errors
[ ] External API calls and their status
[ ] Background job start/complete/fail
[ ] Startup and shutdown
```

---

## PHASE 4 — Alert Rules

Agent generates alert configuration based on Q2 answers:

```yaml
# Example: Uptime alert
alerts:
  - name: service-down
    condition: http_status != 200
    url: https://[your-domain]/health
    interval: 60s
    notify: [team channel]

  - name: high-error-rate
    condition: error_rate_5xx > 1%
    window: 5m
    notify: [team channel]

  - name: slow-response
    condition: p95_response_time > 2000ms
    window: 10m
    notify: [team channel]

  - name: high-memory
    condition: memory_usage > 85%
    notify: [team channel]
```

---

## PHASE 5 — Runbook

Agent writes `docs/runbook.html`:

```
For each alert:
  Alert name: [name]
  Meaning: [what this means]
  First check: [what to look at first]
  Common causes: [list]
  Fix steps: [numbered steps]
  Escalate if: [condition]
  Related: [links to dev-hotfix.md or dev-rollback.md]
```

---

## Monitoring Checklist

```
[ ] /health endpoint returns 200
[ ] /health/ready checks DB connection
[ ] Structured JSON logs in production
[ ] Uptime check configured (every 60s)
[ ] Error rate alert set up
[ ] Response time alert set up
[ ] Disk space alert set up
[ ] Auth failure alert set up
[ ] Runbook written for each alert
[ ] Team notified of alert channels
```
