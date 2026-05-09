# /devstarter-compliance — Compliance Audit (WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001)

Run a structured audit against a specific compliance framework. Outputs a gap report, remediation roadmap with owners + target dates, and (for SOC 2 / HIPAA / ISO 27001) an evidence pack for external auditors.

## When to use vs alternatives

- **Use this** when: a specific compliance framework needs an audit (WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001)
- **Use /devstarter-audit** instead when: broad project audit (security + quality + drift + dependency hygiene) — different scope
- **Use /devstarter-security** instead when: OWASP-focused application security review (deeper on app-layer threats, narrower scope than compliance)
- **Use /devstarter-adr** instead when: deciding *which* framework to pursue (capture as ADR before launching the audit)

## Inline Args

```
/devstarter-compliance              → interactive (pick framework + scope)
/devstarter-compliance wcag         → WCAG 2.1 Level AA audit
/devstarter-compliance gdpr         → GDPR data-mapping + DPIA
/devstarter-compliance hipaa        → HIPAA PHI flow audit
/devstarter-compliance soc2         → SOC 2 Type II evidence pack
/devstarter-compliance pci          → PCI-DSS scope review
/devstarter-compliance iso27001     → ISO 27001 Annex A controls
```

Read `~/.claude/sdlc/devstarter-compliance.md` and run all phases (scope → checklist → gap inventory → remediation roadmap → evidence pack → publish → tickets + handoff).
