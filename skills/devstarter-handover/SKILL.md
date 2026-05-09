# /devstarter-handover — Handover Project

Transfer project ownership: knowledge capture, handover doc, access revocation, secret rotation.

## When to use vs alternatives

- **Use this** when: an existing owner is leaving / changing role / transferring an area to someone else
- **Use /devstarter-onboard** instead when: a new person is joining with no predecessor (no transfer, just setup)
- **Use /devstarter-retro** instead when: closing out a sprint (no ownership change)

## Inline Args

```
/devstarter-handover                        → interactive (from / to / area / deadline)
/devstarter-handover Alice Bob full         → handover full project from Alice to Bob
/devstarter-handover Alice Bob backend      → handover backend area only
```

Read `~/.claude/sdlc/devstarter-handover.md` and follow all phases.
