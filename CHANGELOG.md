# Changelog

## v3.7.0 — Top-1% Completeness (2026-05-09)

> Additive top-up release. v3.6.0 made gates enforce quality. v3.7.0
> adds the four workflows that top-1% teams have but DevStarter was
> missing — post-mortem, ADR capture, compliance audit, perf profiling —
> plus polish (lifecycle headers, TL;DR blocks, quick-start mode) and
> a hardened upgrade path with version-jump migration messaging.

### /devstarter-postmortem — Blameless Incident Post-Mortem

After a SEV-1/SEV-2 incident is resolved, run a structured blameless
post-mortem. Top-1% engineering practice; previously absent.

**New:**
- **`skills/devstarter-postmortem/SKILL.md`** — Opus-gated entry, decision
  tree (vs incident / retro / debug), inline args (no-arg / slug / file)
- **`sdlc/devstarter-postmortem.md`** — full 9-phase runbook:
  - Phase 0 — incident intake (slug, severity, timing, impact, repeat?)
  - Phase 1 — timeline reconstruction from raw evidence (chat, alerts,
    deploy logs, APM); actor-based rows (engineer / system / alert /
    customer), never names
  - Phase 2 — 5 Whys causal analysis pushed past the first plausible
    "why" to a root cause that targets systems, not humans
  - Phase 3 — contributing factors across Technical / Process /
    Observability / Organizational categories
  - Phase 4 — customer & communications review (what did customers see,
    when did we tell them, was the comms strategy adequate)
  - Phase 5 — action items table with mandatory owner + size + priority
    + target date (vague items are parked in "Open Questions" instead)
  - Phase 6 — publish at `docs/postmortems/[date]-[slug].html` using
    standard template; index.html updated
  - Phase 7 — Blameless Review Gate (7-item checklist enforced before
    publish — no person named as cause, actions target systems not
    "be more careful," every Yes contributing factor has a corresponding
    action item)
  - Phase 8 — auto-create action item tickets in PM tool
    (github-issues / notion / jira) with `post-mortem-action` label
  - Phase 9 — handoff: implement P0 actions via `/devstarter-change`,
    share with team, or schedule 30-day follow-up
- **`devstarter-menu.md`** — entry #25 under PRODUCTION

**Why:** v3.6.0 added incident response (`/devstarter-incident`) and sprint
retro (`/devstarter-retro`) but no post-mortem workflow. Top teams treat
these as different lenses: incident = response under pressure; retro =
sprint reflection; post-mortem = causal analysis with prevention actions.

### /devstarter-adr — Architecture Decision Record (Standalone)

Capture an architecture decision *outside* of a feature change. Complements
the v3.6.0 Gate A2 ADR mandate (which fires inside `/devstarter-change` for
non-trivial features); this command handles tech-stack picks, library
evaluations, infra moves, process changes, and superseding prior ADRs.

**New:**
- **`skills/devstarter-adr/SKILL.md`** — Opus-gated, decision tree (vs
  change / consult / audit), inline args (no-arg / title / consult file)
- **`sdlc/devstarter-adr.md`** — full 9-phase runbook:
  - Phase 0 — intake (decision question, scope, driver, related ADRs)
  - Phase 1 — Context & Forces table (functional / non-functional /
    operational / skill / regulatory / strategic / existing)
  - Phase 2 — ≥ 3 options (status quo always included; pros / cons / cost
    / operational fit / risk / references each)
  - Phase 3 — Recommendation referencing the Forces; confidence rating
    (Low confidence → status = Proposed, not Accepted; revisit scheduled)
  - Phase 4 — Consequences (positive AND negative AND revisit-triggers;
    empty negatives list rejected as incomplete analysis)
  - Phase 5 — Supersedes / Related (auto-search docs/adr/ for conflicts;
    explicit supersede chain enforced both directions)
  - Phase 6 — Generate sequential ADR ID (NNNN) + slug
  - Phase 7 — Save using TechLead ADR template, update docs/adr/index.html
  - Phase 8 — Approval Gate (Accepted / Proposed / revise)
  - Phase 9 — Handoff (implement now via /devstarter-change / share /
    schedule revisit / done)
- **`devstarter-menu.md`** — entry #26

**Why both ADR paths exist:**
- `/devstarter-change` Gate A2 (v3.6.0) — *forces* an ADR for non-trivial
  features so decisions inside features get captured
- `/devstarter-adr` (this) — *enables* an ADR outside a feature for
  decisions that don't fit the feature flow (stack picks, infra moves)

### /devstarter-profile — Proactive Performance Investigation

Investigate a performance issue *before* it becomes an incident. Captures
baseline → profiles to find bottlenecks → ranks by impact → optimization
roadmap → optional handoff to `/devstarter-change`.

**New:**
- **`skills/devstarter-profile/SKILL.md`** — Opus-gated, decision tree
  (vs incident / debug / monitor / audit), inline args
- **`sdlc/devstarter-profile.md`** — full 7-phase runbook:
  - Phase 0 — perf intake (area, SLO target, current measurement, trigger)
  - Pre-Phase 1 guard — STOPS if no measurement is in place; routes to
    `/devstarter-monitor` first (you can't profile what you don't measure)
  - Phase 1 — baseline (P50/P95/P99 latency, throughput, error rate, or
    LCP/FID/CLS for frontend, EXPLAIN ANALYZE for DB, etc.)
  - Phase 2 — profile data capture (clinic.js / py-spy / pprof / async-
    profiler / DevTools Performance) saved to `docs/perf/[date]-[slug]/`
  - Phase 3 — bottleneck inventory ranked by total impact (cost ×
    frequency); top 1–2 must account for ≥ 70% of cost or profile is too
    coarse and Phase 2 must redo
  - Phase 4 — optimization roadmap with impact / effort / risk per fix;
    classified Quick wins / Worth it / Maybe later
  - Phase 5 — approval gate (implement now / save roadmap / revise)
  - Phase 6 — save report at `docs/perf/[date]-[slug]/report.html`;
    handoff to `/devstarter-change` if "implement now"
  - Phase 7 — verification (post-implementation re-measurement; if
    not materially better, revert + loop back to Phase 3)
- **`devstarter-menu.md`** — entry #27

**Why:** `/devstarter-debug` covers reactive root-cause hunting for bugs;
`/devstarter-incident` is for active prod crises. Performance work that
isn't a crisis but matters before it becomes one had no home — perf
issues silently ate SLO budget. This closes that gap.

### /devstarter-compliance — Framework-specific Compliance Audit

Last of the four new v3.7.0 commands. `/devstarter-audit` covers code/security
quality and `/devstarter-security` covers OWASP — neither addresses the
specific frameworks customers and regulators actually ask about. This
command does, with a checklist + gap report + remediation roadmap +
(for Type II frameworks) an evidence pack.

**New:**
- **`skills/devstarter-compliance/SKILL.md`** — Sonnet-tier (template-driven),
  decision tree (vs audit / security / adr), inline args per framework
- **`sdlc/devstarter-compliance.md`** — full 6-phase runbook covering
  six frameworks each with a concrete checklist:
  - **WCAG 2.1 Level AA** — 38 success criteria across Perceivable /
    Operable / Understandable / Robust; axe-core preflight recommended
  - **GDPR** — Lawfulness, Data Subject Rights, Data Handling, Accountability
    (RoPA, DPIA, breach notification, cross-border transfers)
  - **HIPAA** — Privacy + Security Rule (Administrative / Physical /
    Technical) + Breach Notification (60-day/HHS rules)
  - **SOC 2 Type II** — CC1–CC9 + A/C/PI/P trust services criteria with
    evidence-pack requirements (artifacts auditors will request)
  - **PCI-DSS** — 12 core requirements, scope reduction via tokenization
  - **ISO 27001** — Annex A 93 controls (organizational / people /
    physical / technological)
  - Phase 0 — scope (framework, surface, trigger, prior audit, owner)
  - Phase 1 — run checklist (Pass / Partial / Fail / N/A / Unknown with
    evidence link per item)
  - Phase 2 — gap inventory with severity (🔴 Critical / 🟠 High /
    🟡 Medium / 🟢 Low)
  - Phase 3 — remediation roadmap (every gap has owner + size + priority
    + target date; vague items parked in Open Questions)
  - Phase 4 — evidence pack (SOC 2 / HIPAA / ISO 27001 only) — control
    → artifact → location → period covered
  - Phase 5 — publish at `docs/compliance/[framework]-[date].html`;
    `docs/compliance/index.html` updated; approval gate
  - Phase 6 — auto-create remediation tickets (per `pm.type`); handoff
    to `/devstarter-change` for P0 items
  - Appendix — recommended audit cadence per framework
- **`devstarter-menu.md`** — entry #28

**Why:** Customers ask "are you SOC 2 compliant?" — the answer needs to
be backed by a real audit + evidence, not aspirational. This workflow
produces that.

**v3.7.0 status:** all four new commands shipped (postmortem / adr /
profile / compliance). Last items pending: Lifecycle Stage / Gates count /
TL;DR headers across SDLC files + `--quick` flag on `/devstarter-change`.

### TL;DR + Lifecycle Stage + Gates count headers across all SDLC files

Mass-edit applied to all 48 `sdlc/devstarter-*.md` runbooks. Each file now
opens with a one-line scannable header:

```
> **TL;DR** — [purpose] · **Lifecycle** [Discovery|Design|Build|Ship|Operate|Reference] · **Gates** [N]
```

This lets a newcomer pick the right runbook without committing to reading
the full file. Lifecycle stage classification:

- **Discovery** — audit, consult, existing, gitsetup, sprint, starter,
  starter-gates, starter-intake
- **Design** — adr, document, starter-template
- **Build** — change, change-add, change-bug, change-remove, change-resume,
  debug, migrate, ml-workflow, review
- **Ship** — hotfix, release, release-deploy, release-prep, release-verify,
  rollback
- **Operate** — autopr, compliance, dependency, doctor, env, handover,
  incident, monitor, onboarding, postmortem, profile, retrospective,
  secrets
- **Reference** — ai-providers, checkpoint, config-sync, github, gitlab,
  jira, notion, svn, vcs-sync (procedure files loaded by other workflows)

For files that previously lacked a top-level H1 (sub-files of starter +
release), an H1 was added so the structure is uniform.

### `--quick` flag on `/devstarter-change` — scope-based reading reduction

Cuts newcomer reading load from ~3000 lines to ~1000 for a typical scoped
change by skipping agents + docs not relevant to the detected scope.

- **`skills/devstarter-change/SKILL.md`** — new "Quick Mode" section
  explaining usage, scope detection, what gets skipped per scope, and
  the auto-promotion guards
- **`sdlc/devstarter-change.md`** — auto-scope detection table + auto-
  promotion rules (touches auth / multi-tenancy / schema / billing /
  external integrations → full mode regardless of `--quick`)

**Auto-scope detection:**
| Detected scope | Skip these agents | Skip these doc updates |
|---|---|---|
| Backend-only | @uxui, @frontend, @mobile | frontend-spec, ux-spec, prototype/ |
| Frontend-only | @backend, @dba, @mobile | api-reference, openapi.yaml, database-design |
| Mobile-only | @uxui (web), @frontend (web) | frontend-spec (web parts) |
| Full-stack | (none) | (none) |
| Bug fix (localized) | @ba (no BRD update for tiny bugs) | brd.html (tiny bugs only) |

**Auto-promotion guards** — these always force full mode even with `--quick`:
auth, multi-tenancy, schema migrations, billing, payments, external
integrations, cross-cutting refactors, new bounded contexts. Quality
bar (Doc Quality Preflight) still runs in quick mode, just on the
smaller surface.

---

### update.sh enhanced — version-jump migration messaging

`update.sh` now detects when a user is jumping a minor or major version
boundary (e.g. v3.4 → v3.7) and prints explicit migration notes for each
crossed boundary:

- **From v3.4 or earlier** — warns that 13 thin agent slash-commands
  were removed in v3.5; points to `@<alias>` and `/devstarter-agents`
- **From v3.5 or earlier** — warns that v3.6 Gate A2 + Gate A4 are now
  enforcement gates (Doc Quality Preflight + Fitness Functions + PR
  Review Checklist); flags the new `templates/github/fitness-functions.yml`
- **From v3.6 or earlier** — calls out the 4 new v3.7 commands and the
  `--quick` flag

Confirms that the `rm -rf + cp -r` pattern in update.sh cleanly removes
deleted skills / runbooks / templates from prior versions — no stale
files linger after update. `agents/custom/` is preserved from backup as
before.

## Upgrade notes (any version → v3.7.0)

### Clean upgrade — what update.sh handles automatically

When `bash ~/.claude/update.sh` runs:

1. **Backs up** user files (CLAUDE.md, USER.md, settings.json,
   settings.local.json, .env) and the entire `memory/` folder to
   `~/.claude/.backup/<timestamp>/`
2. **Wipes + replaces** `agents/`, `skills/`, `sdlc/`, `templates/`
   entirely (`rm -rf` then `cp -r`) — guaranteeing no stale files
   from prior versions linger
3. **Removes** the legacy `commands/` folder if it exists (v2.x → v3.x
   migration; was already in update.sh)
4. **Restores** `agents/custom/` from the backup so user-authored
   custom agents are preserved across the wipe
5. **Updates** root toolkit files: `update.sh`, `install.sh`, `setup.sh`,
   `devstarter-menu.md`, `VERSION`, `CHANGELOG.md`
6. **Restores** user files from the backup so personal config is never
   touched
7. **Prints** version-jump migration notes (new in this release) so
   users see the breaking-change summary without reading the full
   CHANGELOG

### Manual checks after upgrade from v3.4 or earlier

- If you scripted `/devstarter-pm`, `/devstarter-techlead`, etc. into
  any tooling, switch to `@pm`, `@techlead` (the agent files are
  unchanged; only the slash-command wrappers were removed)
- If you have an existing GitHub project, copy
  `templates/github/fitness-functions.yml` to `.github/workflows/` and
  add `Fitness Functions / All checks` as a required status check on
  protected branches
- Existing in-progress features may need a docs catch-up before the
  next `/devstarter-change` Gate A2 — backfill SLO + Threat Model
  for backend, bundle budget for frontend, WCAG conformance for UX

---

## v3.7.0 status: **COMPLETE — ready to release**

All planned sub-PRs merged to develop:
1. ✅ `/devstarter-postmortem` — blameless incident post-mortem (PR #32)
2. ✅ `/devstarter-adr` — standalone ADR capture (PR #33)
3. ✅ `/devstarter-profile` — proactive performance investigation (PR #34)
4. ✅ `/devstarter-compliance` — WCAG / GDPR / HIPAA / SOC 2 / PCI-DSS / ISO 27001 audits (PR #35)
5. ✅ TL;DR + Lifecycle + Gates headers across 48 SDLC files (PR #36)
6. ✅ `--quick` flag on `/devstarter-change` (this PR)

Next: bump VERSION to 3.7.0, finalize CHANGELOG date, run `bash scripts/publish.sh`.

---

## v3.6.0 — Real Quality Gates (2026-05-09)

> The biggest single release in the v3.5.0 → v3.7.0 audit roadmap. Turns
> documented quality bars into **enforced** quality gates that auto-block
> PRs when architectural quality slips. Top-1% engineering teams catch
> ~80% of architectural regressions automatically — DevStarter now ships
> the toolkit and wires it into the change workflow.
>
> **Bundles in v3.5.1** (router standardization) — see "Router
> Standardization" section below.

### Architectural Fitness Functions — automated CI quality gates

**New:**
- `templates/github/fitness-functions.yml` — GitHub Actions workflow with
  4 fitness checks, stack-aware (Node / Python / Go), tunable via repo
  variables. Roll-up status check (`Fitness Functions / All checks`) is
  the single status to require for branch protection.
  - **Bundle budget** (Node) — `dist/` must stay under threshold (default 500 KB)
  - **Dependency rules** — depcruise (Node) / import-linter (Python) module-boundary enforcement
  - **Coverage gate** — line coverage ≥ threshold (default 80%) on Node / Python / Go
  - **Complexity ceiling** — max cyclomatic complexity per function (default 10)
- `templates/github/fitness-functions-setup.md` — install + tuning + per-stack config guide

**Wired in:**
- **`agents/devstarter-techlead.md`** — Architecture Fitness Functions
  section now references the shipped reference implementation (it was
  previously aspirational table only)
- **`sdlc/devstarter-change-add.md`** — pre-Gate A4 verification step:
  fetches `gh pr checks` for "Fitness Functions / All checks" on each PR;
  fails the gate if any check failed; offers `/devstarter-debug` or
  `/devstarter-change fix-bug` route to address blockers
- **`sdlc/devstarter-github.md`** — new procedure **PROC-GH-17** (Install
  Fitness Functions CI) parallel to PROC-GH-16 (AutoPR)
- **`sdlc/devstarter-starter-gates.md`** — Gate 0 now installs fitness
  functions during new-project bootstrap (after PROC-GH-14 templates)
- **`sdlc/devstarter-existing.md`** — installs fitness functions when
  setting up DevStarter on an existing GitHub repo (after PROC-GH-18
  branch protection)

**Why:** Per the v3.6.0 plan in `~/.claude/plans/synthetic-gliding-clock.md`
and `memory/consult-2026-05-09-top1-rigor-audit.md`. Previously the
TechLead spec defined fitness functions in a table but no CI ever ran
them. With this change the bar is enforced, not documented.

### Backend mandatory deliverable + Gate A2 Doc Quality Preflight

The Backend agent's API Reference Document was already a Gate 1 deliverable
but lacked enforceable specifics. v3.6.0 adds three required additions:

- **`agents/devstarter-backend.md`** — API Reference Document now requires:
  - **SLO/SLI table** (section 6) — concrete P50/P95/P99 latency, availability,
    and error-budget numbers per endpoint group serving > 1 RPS. No `TBD`.
  - **Threat Model** (section 7) — STRIDE checklist with concrete mitigation
    + test for each row. Mandatory if endpoint touches auth / money / PII /
    multi-tenant data / external integrations.
  - **`docs/api/openapi.yaml`** companion spec (machine-readable) — OpenAPI
    3.1+ with `x-slo` extensions matching section 6. Validates with
    `openapi-spec-validator` or `redocly lint`. Used by contract tests, SDK
    generation, gateway routing.
  - Quality gate updated: SLO table populated, Threat Model present, spec
    validates, HTML and OpenAPI don't drift.

- **`sdlc/devstarter-change-add.md`** — Gate A2 promoted from rubber stamp to
  real quality gate via a **Doc Quality Preflight** that runs before the
  approve picker appears:
  - BRD has ≥ 2× Given-When-Then criteria per user story
  - Schema migration has reversible rollback (DROP / ALTER ... DROP)
  - OpenAPI spec validates; SLO table populated; Threat Model present
  - security_design.html updated for auth/data/multi-tenant/external scope
  - **ADR mandatory** for auth, multi-tenancy, schema, caching, payments,
    billing, external integrations (the "non-trivial decision" set);
    `docs/adr/NNNN-<slug>.html` must exist with status=Accepted
  - Failing rows block the Gate A2 picker — loop back to the agent that
    owns the failing doc

**Why both ship together:** the Backend agent calls out "Gate A2 will reject
backend features that lack SLO/Threat Model" so the spec change and the
gate enforcement are coupled — shipping one without the other would either
be unenforced docs or unattainable enforcement.

### Frontend mandatory deliverable + Gate A2 enforcement

Same enforcement pattern as Backend, applied to Frontend. Gate A2 will now
reject frontend features that lack a per-route Bundle Budget row or
Accessibility Conformance Plan.

- **`agents/devstarter-frontend.md`** — new **Frontend Specification
  Document** Gate 1 deliverable at `docs/frontend-spec.html`, 13 required
  sections covering: tech stack, information architecture, component
  inventory, state architecture, **per-route bundle budget table** (concrete
  KB numbers per route, no TBD), **WCAG 2.1 AA conformance plan** (axe-core
  in CI mandatory), testing strategy, browser/device support matrix, build
  & deploy strategy, design system integration. Quality gate enforces no
  placeholder text and consistency with `browserslist` + build config.

- **`sdlc/devstarter-change-add.md`** — Doc Quality Preflight check 5b
  added for any frontend feature touching routes, components, or pages.
  Gate A2 doc-list now includes `docs/frontend-spec.html`.

**Why:** Frontend was the second of the three "expert agents with no
enforced deliverable" gap (Backend / Frontend / UX). Now matched to BA's
BRD and QA's Test Strategy enforcement pattern.

### UX Design Specification + Accessibility Conformance + Gate A2 enforcement

Last of the three "expert agents with no enforced deliverable" gap. The UX
agent had an Interactive Prototype as Gate 1 deliverable but no *written*
Design Spec with auditable accessibility commitment.

- **`agents/devstarter-uxui.md`** — new **Design Specification Document**
  Gate 1 deliverable at `docs/ux-spec.html` with 11 required sections:
  - Project-specific design principles (no generic platitudes)
  - Concrete design tokens (color/typography/spacing/radius/motion)
  - Information architecture + user flow diagrams
  - Component specifications (states, variants, ARIA pattern, motion)
  - **WCAG 2.1 AA Conformance** table covering all Level AA success
    criteria with Pass / Partial / Fail status — every Partial/Fail row
    has linked issue, owner, target date (no "TBD")
  - Manual checks list (tab-key only, focus rings, prefers-reduced-motion)
  - Microcopy guidelines (voice/tone, error rules, button-label pattern)
  - Research summary, heuristic evaluation (Nielsen 10), changelog, open issues

- **`sdlc/devstarter-change-add.md`** — Doc Quality Preflight check 5c
  added for any UX-touching feature. Gate A2 doc-list now includes
  `docs/ux-spec.html`. Drift between design tokens in spec and
  `docs/prototype/components.html` blocks the gate.

**v3.6.0 status:** All three weak agents (Backend / Frontend / UX) now have
enforceable Gate 1 deliverables matching BA's BRD and QA's Test Strategy
pattern. Gate A2 is now a real quality gate, not a rubber stamp.

### TechLead PR Review Checklist wired to Gate A4

The TechLead spec defined a 26-item PR Review Checklist (correctness,
security, tests, code quality, observability, operations) but it was
never wired to a merge gate — PRs merged on user "approve" alone.

- **`sdlc/devstarter-change-add.md`** — second pre-Gate A4 step added,
  runs after fitness functions pass:
  - TechLead loads each PR diff and evaluates all 26 items
  - Each item marked ✅ / ❌ / ⚠️ (waiver with rationale + owner +
    revisit-date in PR description) / `n/a`
  - Severity classes:
    - **🔴 BLOCKER (any ❌):** correctness / security / operations →
      Gate A4 cannot pass; route ❌ items to `/devstarter-change fix-bug`
      with each finding pre-filled
    - **🟡 MAJOR (any ❌):** tests / code quality / observability →
      surfaces in summary; owner can ship-with-debt by adding waiver
  - Checklist posted as PR comment via `gh pr review --comment`
- Gate A4 picker now shows the rolled-up checklist counts per category
  alongside the fitness-function row.

**Why:** Closes the last "documented but unenforced" gap. Combined with
the fitness functions and the Gate A2 Doc Quality Preflight, every gate
now has programmatic enforcement, not just human approval.

---

### Sub-PR summary

All five planned sub-PRs landed in develop and ship together as v3.6.0:
1. ✅ Fitness Functions CI template + workflow wiring (PR #26)
2. ✅ Backend SLO/Threat-Model/OpenAPI + Gate A2 Doc Quality Preflight + ADR mandate (PR #27)
3. ✅ Frontend Specification Document + Gate A2 enforcement (PR #28)
4. ✅ UX Design Specification + WCAG conformance + Gate A2 enforcement (PR #29)
5. ✅ TechLead PR Review Checklist wired to Gate A4 (PR #30)

Plus **Router Standardization (v3.5.1)** — bundled into this release rather than shipped separately.

---

## Router Standardization (was v3.5.1, now bundled into v3.6.0)

### 17 SKILL.md routers now have decision trees + inline args

All 17 thin SDLC routers were missing a "When to use vs alternatives" section,
forcing users to read the SDLC runbook to figure out which command applies.
Sub-PR 4 of the v3.5.0 audit fixes this.

**Updated (17 files, consistent template):**

Tier A — bare 2-liners now have purpose + decision tree + 3 inline args:
- `/devstarter-sprint`, `/devstarter-release`, `/devstarter-rollback`,
  `/devstarter-dependency`, `/devstarter-env`, `/devstarter-secrets`,
  `/devstarter-monitor`, `/devstarter-onboard`, `/devstarter-handover`,
  `/devstarter-retro`, `/devstarter-menu`

Tier B — preserved existing model gate / inline args, added decision tree:
- `/devstarter-hotfix`, `/devstarter-incident`, `/devstarter-consult`,
  `/devstarter-migrate`, `/devstarter-gitsetup`, `/devstarter-review`

**Decision trees disambiguate the common confusions:**
- hotfix vs rollback vs incident vs change fix-bug
- env vs secrets vs existing
- onboard vs handover vs existing
- consult vs debug vs review vs audit
- release vs hotfix vs rollback
- migrate vs change vs consult vs audit
- review vs audit vs debug

No SDLC runbook content changed; this is pure SKILL.md "shop window" polish
so users pick the right command without reading the full runbook first.

---

## v3.5.0 — Cut the Clutter (2026-05-09)

> **Partial release.** First two of four planned v3.5.0 sub-tasks shipped.
> Remaining (deferred to v3.5.1 or v3.6.0 prep): VCS triplication refactor
> (github/gitlab/svn → common base) and standardize 17 thin SDLC routers.
> See `memory/consult-2026-05-09-top1-rigor-audit.md` for full roadmap.

### Skills consolidation — 13 thin agent direct-invokes → 1 meta-skill

**⚠️ Breaking change** for users who invoked agents via slash commands. Agents
themselves are unchanged; only the redundant slash-command wrappers were removed.
Use `@<alias>` (e.g., `@pm`, `@techlead`, `@qa`) directly in chat — same behavior,
shorter to type, no skill-picker clutter.

**What changed:**

- **chore: removed 13 thin agent direct-invoke skills** — each was a 6-line
  passthrough to its agent file:
  `skills/devstarter-{ba,pm,techlead,backend,frontend,dba,qa,security,devops,uxui,docs,mobile,mlops}/SKILL.md`
- **feat: `skills/devstarter-agents/SKILL.md`** — single meta-skill that lists
  the full agent roster (alias, character, role) and supports inline args:
  `/devstarter-agents`, `/devstarter-agents qa`, `/devstarter-agents pick`
- **chore: `devstarter-menu.md`** — replaced 13-line AGENTS block with a single
  pointer to `/devstarter-agents`

**Migration for existing users:**

After running `update.sh`, the slash commands `/devstarter-pm`,
`/devstarter-techlead`, etc. will not exist. Either:
- Type `@pm`, `@techlead`, etc. directly in chat (recommended — short alias)
- Or run `/devstarter-agents` to see the full roster

The agent files at `agents/devstarter-*.md` are unchanged.

**Why:** Per the v3.5.0 audit (`memory/consult-2026-05-09-top1-rigor-audit.md`),
these 13 wrappers added no logic — they just routed to the agent file. They
cluttered the skill picker and added no discoverability beyond what `@pm` already
provides. One meta-skill `/devstarter-agents` lists every agent with aliases and
example prompts, replacing 13 entries with 1.

### Code review polish — severity bar + post-review actions

- **`sdlc/devstarter-review.md`** — added concrete Severity Definitions
  (🔴 BLOCKER / 🟡 MAJOR / 🟢 MINOR with specific criteria each), wired
  the post-review action loop to:
  - `gh pr review --approve` for Mode A approvals
  - `gh pr review --comment` to push findings as PR comments
  - `/devstarter-change fix-bug` for "fix blockers" path with each finding
    pre-filled as a separate bug intake
  - "explain finding" path with impact, failure mode, fix pattern, test
- Added "When to use vs alternatives" comparison to clarify boundaries with
  `/devstarter-audit` (full project) and `/devstarter-debug` (root-cause hunt)

### Handover access revocation — concrete per-VCS / per-PM commands

- **`sdlc/devstarter-handover.md`** — Gate 4 access revocation expanded from
  "Revoke (GitHub, Notion, .env)" to a concrete checklist:
  - VCS revoke commands per `vcs.type` (github / gitlab / svn)
  - PM revoke steps per `pm.type` (notion / jira / linear)
  - Mandatory secret rotation rule (cached creds persist after access removal)
  - CI/CD secret stores, monitoring/on-call, chat, cloud IAM, DNS
- Added "When to use vs alternatives" header (vs `/devstarter-onboard` and
  `/devstarter-existing`) so users pick the right command upfront

### Onboarding clarity

- **`sdlc/devstarter-onboarding.md`** — added "When to use vs alternatives"
  header to disambiguate from `/devstarter-handover` (transfer of ownership)
  and `/devstarter-existing` (first-time DevStarter setup, no team change)

---

## v3.4.0 (2026-05-09)

### /devstarter-debug — Senior Dev Problem Analysis Workflow

New skill that runs a hypothesis-driven investigation before any code is touched.
Designed around the top-1% senior engineer mental model: evidence before hypothesis,
5 Whys root cause confirmation gate, surgical fix plan with exact file:line targeting,
then handoff to `/devstarter-change fix-bug` — no re-entering requirements.

**What changed:**

- **feat: `skills/devstarter-debug/SKILL.md`** — Opus-gated entry point; supports inline args (no-arg / plain-text description / file path); routes to SDLC runbook
- **feat: `sdlc/devstarter-debug.md`** — Full 5-phase investigation runbook:
  - Phase 0: Problem intake (symptom, expected behavior, when it started, environment, reproducibility)
  - Phase 1: Evidence gathering (error messages, `git log`, `git diff`, log output → Evidence Summary)
  - Phase 2: Code archaeology (entry point → call chain tracing → data flow mapping → Execution Path Map with suspect locations)
  - Phase 3: Root Cause Analysis — 5 Whys applied to each hypothesis; scored ✅ Confirmed / ❓ Possible / ❌ Ruled out; **Gate enforced: cannot proceed to Phase 4 without ≥1 Confirmed hypothesis** — loops back to request more evidence if not found
  - Phase 4: Surgical Fix Plan — exact file:line, before/after code, blast radius analysis (callers, tests, data impact), alternative fix considered and rejected
  - Phase 5: Save diagnosis to `memory/debug-[YYYY-MM-DD]-[slug].md`; `AskUserQuestion` gate offers "implement now" → jumps to `/devstarter-change fix-bug` with pre-filled context
- **chore: `devstarter-menu.md`** — entry #24 🐛 Debug added under UTILITIES section; routing table row added
- **chore: `CLAUDE.md`** — v3.4.0 row added to Recently Shipped table

**Usage:**
```
/devstarter-debug                          → intake questions
/devstarter-debug cart total is wrong      → symptom as inline arg (skip Q1)
/devstarter-debug memory/bug-report.md    → read file as problem context
```

---

## v3.3.0 (2026-05-07)

### Opus Model Gate + Commands Migration Cleanup + Model ID Update

Three related improvements that complete the model-tier system introduced in v1.8.0 and clean up lingering debt from the v3.0.0 SKILL.md migration.

**What changed:**

- **feat: Opus model gate** — `skills/devstarter-audit/SKILL.md`, `devstarter-consult/SKILL.md`, `devstarter-hotfix/SKILL.md`, `devstarter-incident/SKILL.md`, `devstarter-migrate/SKILL.md`, `devstarter-review/SKILL.md` — added `## ⚠️ Model Gate` section at the top of each; uses `AskUserQuestion` to confirm user is on Opus before loading the SDLC runbook; if "I need to switch" is selected, workflow stops immediately
- **fix: commands/ migration cleanup** — deleted orphaned `commands/` folder (41 stale .md files left from v3.0.0 migration; content already in `skills/`); fixed 4 stale `commands/` path references in `scripts/dev-setup.sh`, `sdlc/devstarter-doctor.md`, `skills/devstarter-export/SKILL.md`, `skills/devstarter-import/SKILL.md`
- **chore: Opus model ID updated** — `claude-opus-4-6` → `claude-opus-4-7` in `devstarter-config.yml` + 6 SDLC runbooks (`devstarter-audit.md`, `devstarter-consult.md`, `devstarter-hotfix.md`, `devstarter-incident.md`, `devstarter-migrate.md`, `devstarter-review.md`)
- **docs: bugfix log** — `docs/bugfix-log.html` created with BUG-2026-05-07-001 entry documenting the commands/ cleanup

---

## v3.2.0 (2026-05-07)

### Consult→Change Handoff — Option C

`/devstarter-consult` now saves the consultation context and offers a direct handoff to `/devstarter-change`, eliminating double-entry of requirements.

**What changed:**
- **`sdlc/devstarter-consult.md`** — Step 4 replaced with "Save Consultation" step:
  - After delivering advice, saves `memory/consult-[YYYY-MM-DD]-[slug].md` using the new intake template
  - `AskUserQuestion` gate: `["save advice only", "implement now", "ask follow-up"]`
  - If "implement now": reads `devstarter-change.md`, skips all intake questions, jumps straight to Impact Analysis
  - If "save advice only": shows file path so user can run `/devstarter-change memory/consult-...md` later (Option B path)
  - If "ask follow-up": re-enters plan mode, loops back after answering
- **`sdlc/devstarter-consult.md`** — Rule 1 updated: one write exception for `memory/consult-*.md` handoff file
- **`templates/intake/devstarter-intake-consult.md`** — new intake template for consultation output; sections: Problem/Request, Analysis Summary, Recommended Approach, Acceptance Criteria

---

## v3.1.0 (2026-05-07)

### AskUserQuestion at All Gates — Full UX Consistency

All 52 remaining approval gates and mode-picker prompts across every SDLC runbook now use `AskUserQuestion` (arrow-key picker UI) instead of requiring typed input. Users can now select any gate response with arrow keys + Enter throughout the entire DevStarter workflow.

**Files updated:**
- **`agents/shared/devstarter-agent-base.md`** — Gate UX Rule added: `AskUserQuestion` required at every gate in every workflow; standard and release gate patterns documented
- **`sdlc/devstarter-change.md`** — FIRST ACTION picker now uses `AskUserQuestion` (Add / Remove / Fix)
- **`sdlc/devstarter-change-add.md`** — autopilot/manual choice uses `AskUserQuestion`
- **`sdlc/devstarter-change-bug.md`** — Gate C1 uses `AskUserQuestion`
- **`sdlc/devstarter-change-remove.md`** — Gates B1, B2, B3 use `AskUserQuestion`
- **`sdlc/devstarter-audit.md`** — FIRST ACTION picker + Gates 1, 2, per-fix approval use `AskUserQuestion`
- **`sdlc/devstarter-review.md`** — Mode picker + review outcome use `AskUserQuestion`
- **`sdlc/devstarter-retrospective.md`** — Retrospective approval gate uses `AskUserQuestion`
- **`sdlc/devstarter-dependency.md`** — Update approval gate uses `AskUserQuestion`
- **`sdlc/devstarter-document.md`** — FIRST ACTION picker + both document review gates use `AskUserQuestion`
- **`sdlc/devstarter-hotfix.md`** — Gates H1, H2 use `AskUserQuestion`
- **`sdlc/devstarter-rollback.md`** — Gates R0, R1, R2 use `AskUserQuestion`
- **`sdlc/devstarter-gitsetup.md`** — Gate 1 + develop branch protection prompt use `AskUserQuestion`
- **`sdlc/devstarter-migrate.md`** — Gates 1, 2, component approval, Gate 7 cutover use `AskUserQuestion`
- **`sdlc/devstarter-release-prep.md`** — Gate 1 DEV approval uses `AskUserQuestion`
- **`sdlc/devstarter-release-verify.md`** — Gates 2 (SIT), 3 (UAT), 4 (Production deploy) use `AskUserQuestion`
- **`sdlc/devstarter-starter.md`** — FIRST ACTION mode picker uses `AskUserQuestion`
- **`sdlc/devstarter-starter-gates.md`** — Gates 1, 2, 3 (×2), autopilot/manual, Gate 5 use `AskUserQuestion`
- **`sdlc/devstarter-starter-intake.md`** — Both PROJECT SUMMARY approval gates use `AskUserQuestion`
- **`sdlc/devstarter-starter-template.md`** — Revision confirmation + re-approval gate use `AskUserQuestion`
- **`sdlc/devstarter-existing.md`** — FIRST ACTION picker + autopilot/manual choice use `AskUserQuestion`

---

## v3.0.1 (2026-05-07)

### Patch — publish.sh + update.sh migration fix

- **`scripts/publish.sh`** — after overlaying new content onto `_release_clean`, now scans for top-level items present in the release branch but absent from current `main` and removes them; fixes `commands/` persisting in the release repo after v3.0.0 migration
- **`update.sh`** — added v2→v3 migration step: removes `~/.claude/commands/` when `skills/` is present, so existing users get a clean state on next `/devstarter-update`

---

## v3.0.0 (2026-05-07)

### SKILL.md Migration — Native Claude Code Skills Format

**Breaking change** — all 41 commands migrated from flat `commands/devstarter-*.md` to the official Claude Code skills directory format `skills/devstarter-[name]/SKILL.md`. The `commands/` directory is removed. Users upgrading from v2.x must re-run `install.sh` to get the new `~/.claude/skills/` layout.

- **`skills/`** (NEW directory, 41 entries) — each former `commands/devstarter-*.md` is now `skills/devstarter-[name]/SKILL.md`; content unchanged, structure follows Claude Code's official skill discovery pattern
- **`commands/`** (REMOVED) — replaced entirely by `skills/`
- **`install.sh`** — Step 3 updated: `mkdir -p ~/.claude/skills`, copies `skills/` recursively; backup check and item list updated from `commands` → `skills`
- **`update.sh`** — folder loop updated: `commands` → `skills`
- **`CLAUDE.md`** — project structure, naming convention, and one-command rule updated to reflect `skills/devstarter-X/SKILL.md` format

---

## v2.6.0 (2026-05-06)

### Branch Guard — Universal Base Rule

- **`agents/shared/devstarter-agent-base.md`** — Branch Guard section added after Config Guard: all 13 agents now check `git branch --show-current` before touching any file; hard STOP if on `develop`, `main`, `master`, or `uat`; creates `feature/`, `fix/`, or `hotfix/` branch via PROC-GH-06 before proceeding; cannot be skipped in autopilot, resume, or any other context
- **`sdlc/devstarter-hotfix.md`** — Branch Guard warning added at start of PHASE 4 before any code edits
- **`sdlc/devstarter-release.md`** — Branch Guard added before phase sub-file routing to enforce `release/vX.Y.Z` branch for VERSION/CHANGELOG edits
- **`sdlc/devstarter-incident.md`** — Branch Guard added at PHASE 3 Mitigation to block direct file edits on protected branches; routes to `dev-hotfix.md` or `dev-rollback.md` instead
- **`sdlc/devstarter-existing.md`** — Branch Guard added as Rule 10 in Critical Rules section

---

## v2.5.0 (2026-04-24)

### New Command + Branch Guard + Template Sync

- **`commands/devstarter-gitsetup.md`** (NEW) — thin command with inline arg routing: `full` (run all phases), `branches` (create/verify gitflow branches only), `protect` (apply protection only), `labels` (create GitHub labels only); no-arg shows interactive setup plan at Gate 1
- **`sdlc/devstarter-gitsetup.md`** (NEW) — 6-phase idempotent runbook for standalone git + gitflow setup on any existing project; Phase 1: read config, Phase 2: connect/verify remote (PROC-GH-02), Phase 3: create missing `main`/`uat`/`develop` branches + set default branch, Phase 4: apply branch protection (PROC-GH-18 + PROC-GH-10 Step 2), Phase 5: create standard GitHub labels (PROC-GH-04), Phase 6: summary + next steps; safe to re-run on partially configured repos
- **`devstarter-menu.md`** — item 19 "🌿 Git & Gitflow Setup" added under SETUP & INFRA; ML/Utilities section renumbered 20–23
- **`commands/devstarter-registry.md`** — count updated 24 → 25; gitsetup entry added
- **`sdlc/devstarter-change.md`** — Rule 9 (Branch Guard) added to critical rules: `git branch --show-current` check before any file edit; hard STOP if on `develop`, `main`, `master`, or `uat`; applies in autopilot, resume flows, and all other contexts
- **`sdlc/devstarter-change-add.md`** — BRANCH GUARD block added before A-PHASE 5; duplicate step 3 numbering fixed (steps renumbered 1–12)
- **`sdlc/devstarter-change-bug.md`** — BRANCH GUARD added as step 2 in C-PHASE 4; `EnterWorktree`, PROC-GH-07, and `ExitWorktree` steps added (were missing from bug fix flow)
- **`templates/devstarter-config.template.yml`** — synced with v2.4.0+ defaults: added `vcs.uat_branch`, `release_remote`, `upstream_remote`, `branch_protection` block; updated `sync_branches` to `"main uat develop"`; changed `pm.type` default from `notion` → `github-issues`; added full `model_management` section with tier routing for all 25 commands

---

## v2.4.0 (2026-04-23)

### Multi-Remote Release Configuration

- **`devstarter-config.yml`** — added three new fields to the `vcs:` section: `release_remote` (remote name for final main+tag push, e.g. `release` or `origin`), `release_repo` (repo slug on the release remote for Scenario A dual-remote), `upstream_remote` (empty by default, for Scenario C2 fork-based projects)
- **`sdlc/devstarter-release-deploy.md` — Strategy I Step 1** — updated "Auto-detect remote" to "Resolve push remote"; priority order: `devstarter-config.yml release_remote` → git remote auto-detect → `origin` fallback; full copy-paste script updated with same logic
- **`sdlc/devstarter-github.md` — PROC-GH-10** — added Scenario A block at end of protection script: reads `release_remote` + `release_repo` from config; when `release_remote != origin`, applies identical branch protection to `release/main` on the release repo; no-op for Scenario B/C (prints info message instead)

---

## v2.3.1 (2026-04-23)

### Publish Fix — Exclude docs/ and memory/ from Public Release

- **`scripts/publish.sh`** — added `EXCLUDE_FROM_RELEASE=("docs" "memory")` variable; release step now creates a `_release_clean` temp branch from `main`, strips excluded folders, and pushes that to the `release` remote — keeping local `main` intact with dev files while `dev-starter.git` stays clean
- **`scripts/publish.sh`** — removed `git pull release main` (release remote is write-only); local `main` is now merged from `develop` then pushed to `origin/main` independently
- **`docs/management-report.html`** — removed (dev-only document, not needed in repo)
- **`docs/release-v2.3.0.html`** — release notes for v2.3.0

---

## v2.3.0 (2026-04-23)

### Git Branch Strategy — 3-Branch Setup + Protection Rules

- **`sdlc/devstarter-github.md` — PROC-GH-01** — auto-creates 3 branches (`main`, `uat`, `develop`) on new project init; sets `develop` as the GitHub default branch via `gh repo edit --default-branch develop`
- **`sdlc/devstarter-github.md` — PROC-GH-10 Step 1** — standard branch protection for `main` + `uat`: `allow_force_pushes: false`, `allow_deletions: false`, `required_status_checks`, `required_pull_request_reviews` (1 approving review, dismiss stale reviews)
- **`sdlc/devstarter-github.md` — PROC-GH-10 Step 2** (NEW) — optional `develop` branch protection prompted after scaffold at Gate 3; recommended for teams ≥ 3; applies same protection payload as Step 1
- **`sdlc/devstarter-github.md` — PROC-GH-18** (NEW) — idempotent procedure to apply branch protection to existing repos; reads `main_branch` + `uat_branch` from `devstarter-config.yml`; checks branch exists before applying; wired into `/devstarter-existing` Phase 3.5 after PROC-GH-02
- **`sdlc/devstarter-starter-gates.md`** — Gate 0 output updated to show `✅ Branches: main → uat → develop (default ★)` and `✅ Default branch: develop`; Gate 3 completion wired to PROC-GH-10 Step 2 with status line `✅ develop branch: [protected | unprotected]`
- **`sdlc/devstarter-existing.md`** — Phase 3.5 Step 3 (GitHub path): runs PROC-GH-18 after PROC-GH-02; confirms `✅ Branch protection: main + uat — PR required, no force push, no deletion`
- **`templates/CLAUDE.md.template`** — Gate 0 section updated with 3-branch strategy table (main/uat/develop with protection status and flow)
- **`devstarter-config.yml`** — added `uat_branch: uat` field; `sync_branches` updated to `"main uat develop"`
- **`docs/git-workflow.md`** (NEW) — team handoff reference: Branch Overview table, Daily Dev Workflow (feature/* → PR), Head Dev PR review/merge commands, Release Flow (develop→uat→main), Hotfix Flow, Branch Protection Rules table, 7 Key Rules, Quick Reference block

---

## v2.2.0 (2026-04-23)

### Requirement Intake Templates + File-Arg Pattern

- **`templates/intake/devstarter-intake-new-project.md`** (NEW) — 8-section structured PRD template for new projects; covers Project Identity, Target Users, Core Features (MoSCoW), Technical Constraints, NFRs, Success Criteria, Constraints, and Out of Scope; includes INTAKE SUMMARY block for Claude to fill and present for approval before proceeding to Q0-VCS
- **`templates/intake/devstarter-intake-add-feature.md`** (NEW) — 5-section intake for new features; Feature Identity, User Story + Given/When/Then acceptance criteria, Technical Scope (UI/API/DB), Constraints & Boundaries, Priority & Effort; use with `/devstarter-change newfeature.md`
- **`templates/intake/devstarter-intake-modify-feature.md`** (NEW) — 5-section intake for modifying existing features; captures AS-IS vs TO-BE behavior, regression criteria, impact assessment (breaking change flag, UI/API/DB scope), Priority & Effort; use with `/devstarter-change change-login.md`
- **`templates/intake/devstarter-intake-fix-bug.md`** (NEW) — 5-section bug report template; Bug Identity (severity, environment), Reproduction steps, Expected vs Actual + error logs (with sanitize warning for secrets/PII), Context, Fix Acceptance Criteria; use with `/devstarter-change bug-login.md`
- **`sdlc/devstarter-starter-intake.md`** — `## SECTION 0` prepended: (1) file-arg check — if `.md`/`.txt` file passed, read it, extract requirements, show pre-filled INTAKE SUMMARY, wait for approval, go directly to Q0-VCS; (2) inline MODE 3 pre-fill path; (3) interactive section-by-section fallback; answer carry-forward skips Q1, Q2, Q6, Q7 after intake approval
- **`sdlc/devstarter-change-add.md`** — `## A-SECTION 0` prepended: file-arg check with type auto-detection from file content ("AS-IS"/"TO-BE"/"modify" → Modify Feature; "bug"/"error"/"fix"/"broken" → Bug Fix; else → Add Feature); interactive fallback reads matching template; A-PHASE 1 skipped after intake approval; answer carry-forward covers A-Q1 through A-Q8
- **`sdlc/devstarter-change-bug.md`** — `## C-SECTION 0` prepended: file-arg check reads bug report template; C-PHASE 1 skipped after intake approval; answer carry-forward covers C-Q1 through C-Q6
- **`commands/devstarter-new.md`** — File Arg Handling section added before Inline Args: detects `.md`/`.txt` path or file-on-disk arg, reads file, extracts requirements, skips mode-picker + SECTION 0, shows INTAKE SUMMARY for approval; fallback to inline text (MODE 3) if file not found
- **`commands/devstarter-change.md`** — File Arg Handling section added before Inline Args: reads file, auto-detects change type from content keywords, extracts requirements, skips A-SECTION 0 / C-SECTION 0, shows typed INTAKE SUMMARY for approval; fallback to inline text if file not found

---

## v2.1.0 (2026-04-22)

### Multi-VCS + Multi-PM Selection at Project Creation

- **`sdlc/devstarter-starter-intake.md`** — new Q0-VCS + Q0-PM questions added before Q1; user selects VCS (GitHub / GitLab / SVN / None) and PM tool (GitHub Issues / GitLab Issues / Notion / Jira / None) at the very start of every new project; PM auto-suggested based on VCS choice (GitHub → GitHub Issues, GitLab → GitLab Issues, SVN/None → None); answers written immediately to `devstarter-config.yml`
- **`templates/CLAUDE.md.template`** — removed hardcoded `github.com` repository URL and `Notion Board` fields; replaced with `{{REPOSITORY_URL}}`, `{{PM_BOARD_URL}}`, `{{VCS_TYPE}}`, `{{PM_TYPE}}` placeholders; Gate 0 now branches on `vcs.type` and `pm.type` (GitHub → `gh repo create`, GitLab → `glab project create`, SVN → SVN init, None → `git init`; PM setup routes to matching CLI/API per tool); `Notion ↔ GitHub Sync Rules` section renamed to `PM ↔ VCS Sync Rules` covering all PM/VCS combinations
- **`sdlc/devstarter-existing.md`** — Phase 3.5 Step 1 now asks Q0-VCS + Q0-PM when `devstarter-config.yml` does not exist or has placeholder values; Step 3 conditional on `vcs.type` and `pm.type` — routes to `devstarter-github.md`, `devstarter-gitlab.md`, or `devstarter-svn.md` for VCS, and to Notion / `gh` / `glab` / Jira for PM setup

---

## v2.0.1 (2026-04-20)

### Agent Slash Commands — Invoke Any Agent Directly

- **`commands/devstarter-ba.md`** through **`commands/devstarter-mlops.md`** — 13 new slash commands, one per agent; type `/devstarter-ba [task]` to invoke the BA agent directly without going through a workflow
- **`devstarter-menu.md`** — new AGENTS section listing all 13 agent commands for discoverability

---

## v2.0.0 (2026-04-20)

### Native Platform Integration — TaskCreate, AskUserQuestion, agents/custom/, Doctor + Review Commands

- **`sdlc/devstarter-checkpoint.md`** — new Section 1b: `TaskCreate`/`TaskUpdate` protocol alongside `progress.json`; creates one UI task per SDLC task for session visibility; `TaskUpdate(in_progress)` on start, `TaskUpdate(completed)` on finish; complements cross-session `progress.json` (not a replacement)
- **`sdlc/devstarter-change-add.md`** — Step A4.4: `TaskCreate` for each task after GitHub/Notion creation, stored task IDs used for `TaskUpdate` calls in A5.2; Step A5.2 steps 2 + 8: `TaskUpdate(in_progress)` / `TaskUpdate(completed)` per task
- **`sdlc/devstarter-existing.md`** — Phase 5: `TaskCreate` + `TaskUpdate(in_progress/completed)` alongside Notion/GitHub steps
- **`sdlc/devstarter-sprint.md`** — Phase 4: `TaskCreate` for each sprint item alongside GitHub/Notion creation
- **`sdlc/devstarter-change-add.md`** — `AskUserQuestion` at gates A1, A2, A3, A4 with approve/revise options; interactive gate prompts replace passive text blocks
- **`sdlc/devstarter-existing.md`** — `AskUserQuestion` at analysis confirm, Gate 1 (discovery), and work plan approval
- **`sdlc/devstarter-sprint.md`** — `AskUserQuestion` at Gate S1 sprint scope approval
- **`agents/custom/`** — new folder for user custom agents; preserved by `update.sh` (backup before overwrite, restore after); `install.sh` creates folder on fresh install; `README.md` documents naming convention and usage
- **`commands/devstarter-doctor.md` + `sdlc/devstarter-doctor.md`** — new `/devstarter-doctor` command (#21 in menu); health check for core files, 13+13 agents, 25 commands, key SDLC runbooks, config; outputs ✅/⚠️/❌ per category; Model: Haiku
- **`commands/devstarter-review.md` + `sdlc/devstarter-review.md`** — new `/devstarter-review` command (#22 in menu); 3 modes: PR `#N`, branch name, or current changes; parallel review by @techlead (architecture), @qa (testing), @security (OWASP); outputs 🔴 BLOCKER / 🟡 MAJOR / 🟢 MINOR + verdict; Model: Opus
- **Cleanup:** `agents/teams/` removed (5 files); `sdlc/devstarter-dod.md` merged into `devstarter-checkpoint.md`; `sdlc/devstarter-vcs-common.md` merged into `devstarter-github.md`
- **`setup.sh`** — Q0 name prompt → `devName` in USER.md Identity section; Q2b weak skills field; alias map normalisation (`js→javascript`, `node→node.js`, `azure→cloud`, etc.); `WEAK_LEVEL` auto-calculated one tier below default
- **`sdlc/` 15 runbooks** — Config Guard (`**Config:** Read devstarter-config.yml...`) prepended after `## Model:` header in: audit, autopr, consult, dependency, document, env, handover, incident, ml-workflow, monitor, onboarding, release, retrospective, rollback, sprint

---

## v1.9.0 (2026-04-20)

### Platform Features — Claude Code Native Tool Integration

- **`sdlc/devstarter-change-add.md`** — Step A5.2 now wraps each task's feature branch in `EnterWorktree`/`ExitWorktree` for isolated working copies; prevents dirty state between parallel tasks
- **`sdlc/devstarter-change-add.md`** — Gate A4 autopilot path now calls `PushNotification` before showing the approval prompt; users get a system notification when unattended development completes instead of having to watch the terminal
- **`sdlc/devstarter-consult.md`** — added Step 0: `EnterPlanMode` at consultation start, `ExitPlanMode` after advice delivered; signals to Claude Code that this session is analysis-only
- **`sdlc/devstarter-dependency.md`** — new Phase 1b WebSearch Enrichment step; after local audit, runs `WebSearch` for latest stable version, active CVE IDs (CVSS severity), and breaking changes for every 🔴 Vulnerable and 🟡 Outdated package found

---

## v1.8.1 (2026-04-20)

### Short Agent Aliases — Type @pm Instead of @devstarter-pm

- **`agents/pm.md`, `agents/techlead.md`, `agents/ba.md`, `agents/backend.md`, `agents/frontend.md`, `agents/dba.md`, `agents/qa.md`, `agents/security.md`, `agents/devops.md`, `agents/uxui.md`, `agents/docs.md`, `agents/mobile.md`, `agents/mlops.md`** — 13 thin alias files; each delegates immediately to the full `devstarter-*.md` spec so aliases stay maintenance-free; `install.sh` copies them automatically via existing `agents/*.md` glob
- **`CLAUDE.md`** — agent table updated with Short Alias column; alias file convention documented

---

## v1.8.0 (2026-04-10)

### Model Tier Mapping — Per-Command Model Selection

- **`devstarter-config.yml`** — new `model_management:` section; declares `haiku`, `sonnet`, and `opus` model IDs as the single source of truth; `command_tiers` map lists which commands belong to each tier (5 opus, 12 sonnet, 6 haiku); update model IDs here when Anthropic releases new versions
- **29 SDLC runbooks** — each workflow runbook now opens with a `## Model: [tier] (model-id)` header so users know which Claude model to switch to before running the command
  - **Opus** (5): `audit`, `hotfix`, `incident`, `migrate`, `consult` — deep reasoning, critical production decisions
  - **Sonnet** (19): `change`, `change-add/bug/remove/resume`, `existing`, `release`, `sprint`, `document`, `onboard`, `handover`, `retro`, `dependency`, `rollback`, `monitor`, `autopr`, `ml-workflow`, `ai-providers`, `starter`
  - **Haiku** (5): `env`, `secrets`, `checkpoint`, `config-sync`, `dod` — mechanical, lightweight tasks

---

## v1.7.0 (2026-04-08)

### Autopilot Mode — Extended to Existing + Change Flows

- **`sdlc/devstarter-existing.md`** — new Phase 4.5 autopilot prompt shown immediately after plan approval; `"autopilot"` sets `autopilot_mode=true` + task count in `progress.json`; Phase 5 executes all tasks unattended with silent cron resume; `"manual"` preserves original per-task flow
- **`sdlc/devstarter-change-add.md`** — autopilot prompt added after Gate A3 (GitHub issues + Notion tasks created); `"autopilot"` runs all A-PHASE 5 development tasks unattended; `autopilot_tasks_done` incremented per task; next human interaction is Gate A4 only
- **`sdlc/devstarter-checkpoint.md`** — expanded workflow list to all 7 SDLC runbooks with correct `devstarter-` prefixes; added explicit rule: autopilot resume logic (`paused_limit` → silent, `in_progress` → silent, `waiting_approval` → always wait) applies to **all** workflows, not only `devstarter-starter-gates`

---

## v1.6.1 (2026-04-08)

### Config Auto-Sync — devstarter-config.yml → .project.env

- **`scripts/config-sync.sh`** — new bash script; reads `devstarter-config.yml` and regenerates `.project.env` with all sections; run manually with `bash scripts/config-sync.sh`
- **`scripts/devstarter-config-hook.sh`** — Claude Code `PostToolUse` hook wrapper; detects edits to `devstarter-config.yml` and triggers `config-sync.sh` automatically
- **`.claude/settings.json`** — new project-level Claude Code settings; registers the config-sync hook on `Edit`/`Write` tool use
- **`devstarter-config.yml`** — updated: `pm.type` → `github-issues`, `skill_level` → `expert`, `version` → `1.6.1`
- **`.project.env`** — now fully regenerated by `config-sync.sh`; Notion fields omitted when PM is not `notion`

---

## v1.6.0 (2026-04-08)

### Mandatory devstarter-config.yml — Every Project Must Have One

- **`sdlc/devstarter-starter-gates.md`** — Gate 0 now generates `devstarter-config.yml` from template + syncs `.project.env`; config file is created before any Gate 1 work begins
- **`sdlc/devstarter-existing.md`** — Phase 3.5 promoted to a hard stop: `devstarter-config.yml` must exist on disk before proceeding to work plan; handles both create and update cases
- **`agents/shared/devstarter-agent-base.md`** — new `Config Guard` rule: every agent checks for `devstarter-config.yml` on session start and blocks until it exists
- **`sdlc/devstarter-starter.md`** — Rule 2 "read from disk" now includes `devstarter-config.yml` in the required file list
- **`update.sh`** — post-update check: warns user if current project is missing `devstarter-config.yml` and directs them to `/devstarter-existing`

---

## v1.5.0 (2026-04-08)

### Token Optimization — Leaner Commands, Agents & VCS Runbooks

- **Command routing registry** (`commands/devstarter-registry.md`) — single lookup table for all 24 commands; 16 thin routing files collapsed from 4 lines → 2 lines each
- **Agent boilerplate extracted** — `Progress Reporting` + `Shared Protocols` sections stripped from all 13 agent files into `agents/shared/devstarter-agent-base.md`; net −351 lines across agents
- **VCS common conventions** (`sdlc/devstarter-vcs-common.md`) — branch naming, commit format, .gitignore, labels, semver, and conflict resolution shared across github/gitlab/svn runbooks

### Centralized Config — devstarter-config.yml

- **`devstarter-config.yml`** — new primary config file at project root; replaces `.project.env` as the source of truth
- **`templates/devstarter-config.template.yml`** — full template with all options documented (GitHub/GitLab/SVN, all PM tools, CI, secrets, AI provider)
- **`sdlc/devstarter-config-sync.md`** — Python sync script to auto-generate `.project.env` from `devstarter-config.yml` for bash compatibility
- All 15 SDLC runbooks updated to read `devstarter-config.yml` for project settings

### Proactive Rate-Limit Pause

- **`devstarter-checkpoint.md`** — new `1b. Limit Check` protocol: before each new task, check `tasks_this_session` (≥8) and `files_read_this_session` (≥20) counters
- **`devstarter-agent-base.md`** — `Proactive Rate-Limit Check` section: finish current task → save `paused_limit` → stop → cron auto-resumes with reset counters
- New `paused_limit` status in progress.json: voluntary clean pause, safer than mid-task crash

### Autopilot Mode — Unattended Gate 4 Development

- **`devstarter-starter-gates.md`** — after Gate 3 approval, shows sprint/task summary and offers `"autopilot"` / `"manual"` choice
- `"autopilot"` → runs ALL Gate 4 tasks end-to-end with no user interaction; rate-limit pauses auto-resume via cron; next human interaction is Gate 5 only
- **`devstarter-checkpoint.md`** — `paused_limit` + `autopilot_mode: true` resumes silently; `in_progress` + autopilot also skips resume prompt
- **`devstarter-agent-base.md`** — new `## Autopilot Mode` section: no per-task announcements, silent blocker handling, counter updates, Gate 5 callout on completion

---

## v1.4.1 (2026-04-05)

### New Command: /devstarter-document

Add a standalone document generator command — the 24th slash command.

- **`/devstarter-document`** — generate or regenerate any project document independently,
  without re-running a full gate workflow. Supports 10 doc types:
  `brd`, `srs`, `api`, `schema`, `test`, `security`, `infra`, `prototype`, `plan`, `all`
- Each doc type routes to the correct specialist agent (@devstarter-ba, @devstarter-backend,
  @devstarter-dba, @devstarter-qa, @devstarter-security, @devstarter-devops, @devstarter-uxui, @devstarter-pm)
- Inline args supported: `/devstarter-document api` skips the picker, generates immediately
- Auto-generation during `/devstarter-new` Gate 2 is **unchanged** — this command is additive
- Registered in `devstarter-menu.md` as item 6 under Daily Work (menu renumbered 7–20)

---

## v1.4.0 (2026-04-05)

### Release: Git Auto-Detection (Strategy I)

- **`/devstarter-release`** — added Strategy I for git-based toolkit/library projects.
  Auto-detects release model at runtime:
  - **Model A** (dual-remote): `release` remote exists → pushes `main` + tag to `release` remote
  - **Model B** (single-repo): no `release` remote → pushes `main` + tag to `origin`
  Includes copy-paste ready `release.sh <version>` script.

---

## v1.3.0 (2026-04-05)

### UX: Quick-Picker First Prompt + Inline Args

Dramatically reduced friction for all intake commands — users no longer
need to answer questions they didn't ask for.

- **`/devstarter-new`** — 3-mode picker shown before any questions:
  Quick (8Q) / Custom (15Q) / Describe (1Q).
  Inline args bypass all questions: `/devstarter-new React todo app` → direct to summary.

- **`/devstarter-change`** — Quick-picker: Add / Remove / Fix.
  Inline args extract type from first word: `/devstarter-change add dark mode` → skip Q1+Q2.

- **`/devstarter-existing`** — Quick-picker: Onboard / Add+Fix / Refactor / Security / Full setup.
  Q3–Q5 (CLAUDE.md, docs/, tech stack) now auto-detected from disk — never asked.
  Inline args set intent directly: `/devstarter-existing onboard me` → scan runs immediately.

- **`/devstarter-audit`** — Quick-picker: 7 audit types + report/plan/fix outcome in one prompt.
  Q1 (project name) and Q5 (environment) auto-detected — never asked.
  Inline args: `/devstarter-audit security` or `/devstarter-audit full audit fix`.

### New VCS Runbooks

- **`sdlc/devstarter-gitlab.md`** — Full GitLab procedure runbook (PROC-GL-01 to GL-17),
  matching `devstarter-github.md` depth. Covers: create repo, MR workflow, branch
  protection, labels, milestones, hotfix, CI/CD pipeline, autonomous MR review via Claude AI.
  Uses `glab` CLI throughout.

- **`sdlc/devstarter-svn.md`** — Full SVN procedure runbook (PROC-SV-01 to SV-13).
  Mode A (SVN as primary): create repo, checkout, branch, commit, merge, tag, revert.
  Mode B (git-svn bridge/secondary): first-time setup, push commits to SVN, pull SVN changes,
  tag releases, mirror hotfixes.

- **`agents/shared/devstarter-vcs-pm-guide.md`** — Added GitLab and SVN routing sections
  with references to the new runbooks.

## v1.2.0 (2026-04-05)

### VCS_SECONDARY — Multi-VCS Project Support

- **New SDLC runbook:** `sdlc/devstarter-vcs-sync.md` — Mirror/sync runbook for pushing to secondary VCS after every primary merge. Covers GitLab, GitHub, Bitbucket, SVN (git-svn bridge), and Azure DevOps. Includes CI auto-sync via GitHub Actions and conflict resolution guide
- **Updated template:** `templates/project.env.template` — Added `VCS_SECONDARY_1`, `VCS_SECONDARY_2`, `VCS_SYNC_BRANCHES` fields with full connection options for all VCS types
- **Updated shared guide:** `agents/shared/devstarter-vcs-pm-guide.md` — Added Step 5 (Secondary VCS mirror function) and Multi-VCS special case documentation with "primary = source of truth" rule
- **Updated SDLC:** `sdlc/devstarter-change.md` — Rule 3b: mirror after every primary merge
- **Updated SDLC:** `sdlc/devstarter-release-verify.md` — Phase 10: mirror on release
- **Updated SDLC:** `sdlc/devstarter-hotfix.md` — Mirror step after hotfix merge

### Jira Full Sprint Management

- **New SDLC runbook:** `sdlc/devstarter-jira.md` — Full Jira procedures (equivalent depth to `devstarter-notion.md`):
  - `PROC-JR-01` — Create Jira project + board (Scrum template)
  - `PROC-JR-02` — Create sprint with start/end date and goal
  - `PROC-JR-03` — Create issue (Story/Task/Bug/Epic) with story points, epic link, sprint assignment
  - `PROC-JR-04` — Update issue status via transition auto-discovery (To Do → In Progress → In Review → Done)
  - `PROC-JR-05` — Start sprint (set state = active)
  - `PROC-JR-06` — Close sprint + velocity report (SP completed, carry-over list)
  - `PROC-JR-07` — Link PR/commit to issue + add comment
  - `PROC-JR-08` — Create Epic with epic name field
  - `PROC-JR-09` — Bulk create issues from task list with sprint assignment
- **Updated agent:** `agents/devstarter-pm.md` — Added PM Tool Selection routing table and Jira Sprint Management section (planning, status rules, retro, field discovery)
- **Updated shared guide:** `agents/shared/devstarter-vcs-pm-guide.md` — Expanded PM operations table (create task, create sprint, update status, close sprint) for all PM_TYPE values
- **Updated template:** `templates/project.env.template` — Added full Jira fields: `JIRA_BOARD_ID`, `JIRA_SPRINT_ID`, `JIRA_DEFAULT_ISSUE_TYPE`, `JIRA_STORY_POINTS_FIELD`, `JIRA_EMAIL`

## v1.1.0 (2026-04-05)

### MLOps Agent + AI/ML Project Templates

- **New agent:** `agents/devstarter-mlops.md` — MLOps Engineer specializing in ML pipelines, model serving, experiment tracking, drift monitoring, and LLM/RAG systems
- **New stack template:** `templates/stacks/ml-starter.md` — Lightweight ML project (scikit-learn + MLflow local + FastAPI)
- **New stack template:** `templates/stacks/ml-standard.md` — Production ML system (PyTorch + BentoML + Evidently + CI/CD auto-training)
- **New SDLC runbook:** `sdlc/devstarter-ml-workflow.md` — ML intake questions (Q1–Q6), stack selection, Gate 2 ML docs, deployment strategies, LLM/RAG setup
- **Updated menu:** `devstarter-menu.md` — Added options 18 (New AI/ML Project) and 19 (ML Workflow)
- **Updated team:** `agents/teams/devstarter-platform.md` — MLOps agent added to Platform team
- **Updated template:** `sdlc/devstarter-starter-template.md` — Template I added for AI/ML projects

### GitHub Actions Autonomous PR Review

- **New workflow template:** `templates/github/claude-pr-review.yml` — GitHub Actions workflow that triggers on every PR, calls Claude API, posts structured review comment with security/performance/quality findings, adds labels
- **New setup guide:** `templates/github/claude-pr-review-setup.md` — 5-minute setup, model selection, path filtering, LiteLLM proxy integration, label automation
- **New SDLC runbook:** `sdlc/devstarter-autopr.md` — Autonomous PR review architecture, cost estimates (~$0.003/review with Haiku), extension patterns (auto-issue creation, auto-test generation)
- **Updated SDLC:** `sdlc/devstarter-github.md` — Added PROC-GH-16 (setup autonomous review) and PROC-GH-17 (AI provider rotation)

### Multi-Provider AI Support via LiteLLM

- **New config template:** `templates/litellm/litellm-config.yaml` — LiteLLM proxy config with Claude, OpenAI, Gemini, Azure, Bedrock, and Ollama. Includes cost-based routing, fallbacks, and context window failover
- **New setup guide:** `templates/litellm/provider-setup.md` — Provider comparison, Node.js/Python integration, Docker Compose, cost optimization, usage logging to PostgreSQL
- **New SDLC runbook:** `sdlc/devstarter-ai-providers.md` — Provider selection guide, LiteLLM proxy setup, provider-agnostic AIService patterns, cost controls, rotation checklist
- **Updated agent:** `agents/devstarter-techlead.md` — Added AI/LLM Architecture section with provider selection ADR template
- **Updated:** `.env.example` — Added AI provider keys (Anthropic, OpenAI, Google) and LiteLLM proxy vars

### Enterprise Secrets Management

- **New template:** `templates/secrets/vault-setup.md` — HashiCorp Vault setup guide (Docker dev, production init, dynamic DB creds, K8s auth, OIDC, audit logs, GitHub Actions integration)
- **New template:** `templates/secrets/vault-config.hcl` — Production Vault config (Raft storage, TLS, AWS/Azure/GCP KMS auto-unseal, Prometheus telemetry)
- **New template:** `templates/secrets/aws-secrets-setup.md` — AWS Secrets Manager (IAM policies, rotation Lambda, ECS/EKS injection, Terraform, OIDC for GitHub Actions)
- **New template:** `templates/secrets/azure-keyvault-setup.md` — Azure Key Vault (Managed Identity, federated OIDC, Container Apps, AKS CSI driver, Terraform)
- **New template:** `templates/secrets/gcp-secretmanager.md` — GCP Secret Manager (Workload Identity, Cloud Run, GKE External Secrets, rotation Pub/Sub, audit logging, Terraform)
- **Updated SDLC:** `sdlc/devstarter-secrets.md` — Added Phases 6–9: enterprise backend selection, migration checklist, secrets registry, rotation runbook
- **Updated agent:** `agents/devstarter-security.md` — Added Enterprise Secrets Management section with backend selection guide, mandatory checklist, and SOC2/ISO27001/PCI DSS compliance mapping
- **Updated agent:** `agents/devstarter-devops.md` — Added enterprise secrets procedures, rotation schedule, and OIDC authentication patterns for AWS/GCP/Azure
- **Updated template:** `templates/CLAUDE.md.template` — Added `SECRETS_BACKEND` config section
- **Updated template:** `templates/project.env.template` — Added `SECRETS_BACKEND` and `AI_PROVIDER` fields with all options documented

## v1.0.3 (2026-04-05)

### Namespace Prefixing — `devstarter-` Identity
- All 12 agent files prefixed: `techlead.md` → `devstarter-techlead.md`, etc.
- All 23 command files prefixed: `menu.md` → `devstarter-menu.md`, etc.
- All 22 SDLC workflow files prefixed: `dev-starter.md` → `devstarter-starter.md`, etc.
- Team agent files prefixed: `engineering.md` → `devstarter-engineering.md`, etc.
- Shared agent files prefixed: `vcs-pm-guide.md` → `devstarter-vcs-pm-guide.md`
- Root file renamed: `dev-menu.md` → `devstarter-menu.md`
- All internal `@agent` references updated: `@techlead` → `@devstarter-techlead`, etc.
- All slash command references updated: `/menu` → `/devstarter-menu`, etc.
- All file path cross-references updated across agents, commands, sdlc, scripts, templates
- **Why:** Establishes clear identity/ownership — makes it immediately obvious which agents, commands, and workflows belong to Dev Starter vs. other Claude Code extensions

## v1.0.2 (2026-03-23)

### Light Mode Default + Dark Mode Toggle
- **Document Portal** (`templates/docs/index.html`): Redesigned with light mode as default
- **Document Template** (`templates/docs/document-template.html`): Redesigned with light mode as default
- Both templates now include a dark mode toggle (sun/moon icon) in the topbar
- Theme preference persisted via `localStorage` and shared between portal and documents
- Mermaid diagrams auto-select light/dark theme based on saved preference

### Change Request Log
- New document: `docs/changerequest-log.html` — tracks all feature additions and removals
- `/devstarter-change` Operation A (Add Feature): now creates a CR entry with ID `CR-[YYYY-MM-DD]-[NNN]`
- `/devstarter-change` Operation B (Remove Feature): now creates a CR entry with removal reason and impact
- **Revision History rule**: every Gate 1 document modified by Operation A or B MUST append a Revision History table row linking back to the CR ID

### Document Portal Registry
- Added Audit & Review section: Audit Report (`audit-report.html`), Fix Plan (`fix-plan.html`)
- Added Change Log section: Change Request Log (`changerequest-log.html`), Bugfix Log (`bugfix-log.html`)
- Total documents: 10 required (Gate 1) + 4 optional (on-demand) = 14 documents

### Removed
- Removed Help button and dropdown from Document Portal (no longer needed)
- Deleted `_readme.html` and `_project-readme.html` template files (unused)

## v1.0.1 (2026-03-22)

### Agent Identity — Sanrio Theme
- All 12 agents now have unique Sanrio character names and emoji
- Progress reporting shows character name + role (e.g. "🐧 Badtz-Maru (Backend) starting: ...")
- Characters: Hello Kitty (PM), Tuxedo Sam (Tech Lead), My Melody (BA), Badtz-Maru (Backend), Cinnamoroll (Frontend), Pochacco (DBA), Keroppi (QA), Kuromi (Security), Pompompurin (DevOps), Kiki (UX/UI), Gudetama (Docs), Aggretsuko (Mobile)

### Workflow Improvements
- **Notion task status**: Added Rule 5 — tasks MUST update through To Do → In Progress → In Review → Done (all 3 workflows)
- **Continuous development**: Added Rule 6 — after doc approval, develop ALL tasks without per-task stops (all 3 workflows)
- **Parallel execution**: Added Rule 7 — backend + frontend + infra run in parallel when independent (all 3 workflows)
- **Gate 4 rewritten** in dev-starter.md — removed per-feature HARD STOP, added parallel track diagram

### Document Standards
- **Document Portal**: Added Rule 8 — docs/index.html MUST be copied from template, never created from scratch
- **Component Library**: docs/prototype/components.html now mandatory in completion check (11 files full-stack / 10 files client-only)
- **UX/UI agent**: Added mandatory HTML skeleton, concrete Tailwind code examples for Typography, Colors, Buttons, Forms, Data Display, Feedback sections
- **Critical reminders**: Agent explicitly told "NEVER output text descriptions" + "NEVER use ASCII art"

### Bug Fixes
- Fixed: docs/index.html was being generated from scratch instead of using template
- Fixed: UX/UI prototype produced text descriptions instead of rendered HTML components
- Fixed: Component Library (components.html) was not being created
- Fixed: Notion tasks not updated during development phase
- Fixed: Development stopped after each task for approval instead of continuous flow

## v1.0.0 (2026-03-22)

### Initial Release

**Agents (12):**
- BA, Backend, DBA, DevOps, Docs, Frontend, Mobile, PM, QA, Security, Tech Lead, UX/UI
- All agents upgraded with Anti-patterns, Standards Reference, Quality Gate Checklist

**Commands (22):**
- `/devstarter-new` — Start new project (3 intake modes: Quick Start, Custom, Describe)
- `/devstarter-change` — Add feature / Remove feature / Fix bug
- `/devstarter-consult` — Consultation & solution advice (no code changes)
- `/devstarter-existing` — Setup existing project with codebase scan
- `/devstarter-release` — Release + deploy (8 deploy strategies)
- `/devstarter-hotfix` — Critical production bug fix
- `/devstarter-rollback` — Rollback production
- `/devstarter-incident` — Incident response
- `/devstarter-sprint` — Sprint planning
- `/devstarter-audit` — Audit & review project
- `/devstarter-migrate` — Migration to new tech stack
- `/devstarter-onboard` — Onboard new team member
- `/devstarter-handover` — Handover project
- `/devstarter-retro` — Sprint retrospective
- `/devstarter-env` — Setup local environment
- `/devstarter-secrets` — Secrets management
- `/devstarter-monitor` — Setup monitoring
- `/devstarter-dependency` — Update dependencies
- `/devstarter-menu` — Show project launcher menu
- `/devstarter-context` — Keep project context fresh
- `/devstarter-export` / `/devstarter-import` — Backup and restore Dev Starter
- `/devstarter-update` — Update to latest version

**SDLC Workflows:**
- 5-gate workflow with hard approval gates
- Cross-project API handoff (api-request.html)
- Checkpoint & auto-resume for rate limit recovery
- GitHub procedures (15): repo, branches, PRs, issues, milestones, hotfix, semver
- Notion procedures (10): database, tasks, views, sprint, dashboard
- 8 deploy strategies (Docker, K8s, Azure, AWS, Cloud Run, Vercel/Netlify/Cloudflare, Railway, GitHub Pages)
- Local staging with Docker Compose

**Project Types:**
- Q3: Web, Mobile, Web+Mobile, Desktop, API only, CLI, Background Service
- Q3.1: Build new backend OR connect to existing API
- 8 folder structure templates (A-H)
- Solution stack bundles per platform (Starter/Standard/Professional)

**Setup:**
- One-command install: `bash install.sh`
- Setup wizard: GitHub + Notion config, permissions merge, USER.md
- Cross-platform: Windows (Git Bash), macOS, Linux
