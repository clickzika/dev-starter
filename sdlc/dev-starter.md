# dev-starter.md — Project Spec Intake Template

## How to Use This File

Place this file at `~/.claude/dev-starter.md` (global — works across all projects).
When starting a new project in an empty folder, run:

```
claude
> Read ~/.claude/dev-starter.md and start a new project
```

---

## ⚠️ CRITICAL RULES — Read Before Doing Anything

### Rule 0 — Checkpoint & Auto-Resume (ALWAYS active)

This is a long workflow. You MUST follow the Checkpoint & Auto-Resume Protocol.
Read `~/.claude/sdlc/dev-checkpoint.md` and:
1. **At start** — Setup Cron auto-resume (every 10 minutes)
2. **After every task** — Save checkpoint to `memory/progress.json`
3. **At end** — Cleanup (update status to completed, delete Cron)

This ensures work is never lost if rate limits are hit.

---

### Rule 1 — Hard Approval Gates (NEVER skip)

This project has 5 gates. Each gate has a HARD STOP.
You MUST stop, show output, and wait for explicit user approval before proceeding.

```
GATE APPROVAL REQUIRED
Gate: [N] — [Gate Name]
Output: [what was produced]
Location: [file path]

Type "approve" to continue to next gate.
Type "revise [feedback]" to make changes first.
```

Do NOT continue until the user types "approve".
Do NOT interpret silence or any other word as approval.

---

### Rule 2 — Always Read From Files, Never From Context

When resuming any session or starting a new task:

1. NEVER rely on what you remember from earlier in the conversation
2. ALWAYS read the actual file from disk before doing any work
3. The source of truth is always the file — not the chat history

Before every task, announce:
```
📂 Reading source of truth from disk:
- CLAUDE.md ✓
- memory/progress.json ✓
- docs/[relevant-doc].html ✓
```

If a required file does not exist, STOP and tell the user:
```
⛔ Cannot proceed — [filename] not found on disk.
Please confirm the file was saved before continuing.
```

---

### Rule 3 — Read Agent File Before Doing Any Work

Before any agent produces output, you MUST read that agent's file first.
The agent file defines the format, template, standards, and quality gate for every deliverable.

```
Agent          File to read first
──────         ─────────────────────────────
BA          → ~/.claude/agents/ba.md
Tech Lead   → ~/.claude/agents/techlead.md
DBA         → ~/.claude/agents/dba.md
Backend     → ~/.claude/agents/backend.md
Security    → ~/.claude/agents/security.md
DevOps      → ~/.claude/agents/devops.md
QA          → ~/.claude/agents/qa.md
UX/UI       → ~/.claude/agents/uxui.md
PM          → ~/.claude/agents/pm.md
Frontend    → ~/.claude/agents/frontend.md
Mobile      → ~/.claude/agents/mobile.md
Docs        → ~/.claude/agents/docs.md
```

Before every agent task, announce:
```
🤖 Acting as [agent name]
📖 Reading agent spec: ~/.claude/agents/[agent].md ✓
📄 Output format: [format from agent file]
📋 Producing: [deliverable name]
```

**If you skip reading the agent file, the output will be rejected.**

---

### Rule 4 — Save Before Handing Off

Before announcing any handoff to the next agent:
1. Confirm file is written to disk
2. Confirm git commit is made
3. Update memory/progress.json
4. Only then announce handoff

```
💾 Saved: [filename]
🔀 Committed: [commit message]
📋 Progress updated: memory/progress.json
✅ Ready to hand off to: [next agent]
```

---

### Rule 5 — Ask ONE Question at a Time

**NEVER ask multiple questions in one message.**
- Ask Q1 → wait for answer → ask Q2 → wait for answer → ...
- Show the question number, the question, and the options (if any)
- After the user answers, confirm what you understood, then ask the next question
- If a question is conditional (e.g. "ask only if Q4 includes 1"), skip it silently

Format for each question:
```
📋 Q[N]/26 — [Question title]

[Question text]

[Options if any]
```

---

## INTAKE MODE SELECTION

Before asking questions, present the 3 intake modes:

```
📋 How would you like to set up this project?

  1. ⚡ Quick Start (8 questions — pick a ready-made stack)
  2. 🔧 Custom (15 questions — choose each piece yourself)
  3. 💬 Describe (1 question — tell me everything, I'll figure it out)

Type 1, 2, or 3:
```

---

## MODE 1 — Quick Start (8 Questions)

Ask ONE question at a time. Every question has option `0. Let Claude decide`.
User can type a single answer, comma-separated numbers, or free text.

**For questions that need multiple lines** (e.g. features, description):
Tell the user to separate items with commas or semicolons on one line.
Example: `login, product catalog, cart, checkout, payment`

---

**Q1. What is the project name?**
(e.g. MyShop, HRSystem, TaskManager)

---

**Q2. What does this project do?**
(1-2 sentences — what problem it solves and who uses it)

---

**Q3. What are you building?**
1. 🌐 Web Application
2. 📱 Mobile App (iOS + Android)
3. 🌐📱 Web + Mobile (shared backend)
4. 🖥️ Desktop App (Windows / macOS / Linux)
5. ⚡ API only (no UI)
6. 💻 Console / CLI Tool
7. ⚙️ Background Service / Worker

---

**Q3.1 Backend?** (skip if Q3 = 5, 6, 7 — those always include their own backend/service)
1. 🆕 Build new backend (full stack)
2. 🔗 Connect to existing backend/API

If user picks **2 (Connect to existing API)**, ask these follow-up questions:

**Q-API-1. What is the existing API base URL?**
(e.g. https://api.company.com/v1, http://localhost:3000/api)

---

**Q-API-2. How does the API authenticate?**
1. JWT (Bearer token)
2. API Key (header or query param)
3. OAuth2 / SSO
4. Session / Cookie
5. No auth required
6. Not sure — I'll provide docs

---

**Q-API-3. Do you have API documentation?**
1. Yes — Swagger/OpenAPI URL (provide URL)
2. Yes — Postman collection (provide file)
3. Yes — other format (describe)
4. No — I'll describe the endpoints manually

---

Then in Q4, show **frontend/client-only stacks** (no backend/database).

---

**Q4. Choose a Solution Stack:**

Show ONLY the stacks that match Q3 + Q3.1. If Q3.1 = 1 (new backend), show full stack bundles. If Q3.1 = 2 (existing API), show client-only stacks.

### ── Q3.1 = 1 (Build new backend) — Full Stack Bundles ──

### If Q3 = 🌐 Web Application + new backend:
```
🟢 Starter (เริ่มต้น — เรียนรู้ง่าย, เหมาะกับ prototype)
  1. React + Express + SQLite
  2. Vue + Express + SQLite
  3. Svelte + Express + SQLite

🟡 Standard (กลาง — production ready)
  4. React + Express + PostgreSQL
  5. Angular + NestJS + PostgreSQL
  6. Next.js + Prisma + PostgreSQL
  7. Vue + FastAPI + PostgreSQL

🔵 Professional (สูง — enterprise scale)
  8. Angular + ASP.NET Core + SQL Server
  9. React + NestJS + PostgreSQL + Redis
  10. Next.js + Go + PostgreSQL

🎯 0. Let Claude recommend based on Q2
```

### If Q3 = 📱 Mobile App + new backend:
```
🟢 Starter
  1. Flutter + Firebase (serverless)
  2. React Native + Express + SQLite

🟡 Standard
  3. Flutter + Express + PostgreSQL
  4. React Native + NestJS + PostgreSQL

🔵 Professional
  5. Flutter + NestJS + PostgreSQL + Redis
  6. Swift (iOS) + Kotlin (Android) + Express + PostgreSQL

🎯 0. Let Claude recommend
```

### If Q3 = 🌐📱 Web + Mobile + new backend:
```
🟡 Standard
  1. React + Flutter + Express + PostgreSQL
  2. Next.js + React Native + Express + PostgreSQL

🔵 Professional
  3. Next.js + Flutter + NestJS + PostgreSQL
  4. Angular + Flutter + ASP.NET Core + SQL Server

🎯 0. Let Claude recommend
```

### If Q3 = 🖥️ Desktop App + new backend:
```
🟢 Starter
  1. Electron + SQLite
  2. Tauri (Rust) + SQLite

🟡 Standard
  3. Electron + React + SQLite
  4. .NET WPF + SQL Server

🔵 Professional
  5. .NET MAUI (cross-platform) + SQL Server
  6. Tauri + React + PostgreSQL

🎯 0. Let Claude recommend
```

### If Q3 = ⚡ API only (always new backend):
```
🟢 Starter
  1. Express (Node.js) + SQLite
  2. FastAPI (Python) + SQLite

🟡 Standard
  3. Express (Node.js) + PostgreSQL
  4. FastAPI (Python) + PostgreSQL
  5. NestJS (Node.js) + PostgreSQL

🔵 Professional
  6. ASP.NET Core + SQL Server
  7. Go (Gin) + PostgreSQL
  8. NestJS + PostgreSQL + Redis

🎯 0. Let Claude recommend
```

### If Q3 = 💻 Console / CLI:
```
  1. Node.js CLI (commander.js)
  2. Python CLI (click/typer)
  3. Go CLI (cobra)
  4. .NET CLI (System.CommandLine)

🎯 0. Let Claude recommend
```

### If Q3 = ⚙️ Background Service:
```
  1. Node.js + BullMQ + Redis
  2. Python + Celery + Redis
  3. .NET Worker Service
  4. Go worker

🎯 0. Let Claude recommend
```

### ── Q3.1 = 2 (Connect to existing API) — Client-Only Stacks ──

When Q3.1 = 2, show client-only stacks (no backend, no database).
Auto-decide: HTTP client (axios/fetch/HttpClient), no ORM, no database.
Folder structure: Template H with `src/services/api/`.

### If Q3 = 🌐 Web + existing API:
```
🟢 Starter
  1. React + Tailwind CSS
  2. Vue + Tailwind CSS
  3. Svelte + Tailwind CSS

🟡 Standard
  4. Next.js + Tailwind CSS
  5. Angular + Angular Material
  6. Nuxt.js + Tailwind CSS

🔵 Professional
  7. Next.js + Zustand + React Query
  8. Angular + PrimeNG + NgRx

🎯 0. Let Claude recommend
```

### If Q3 = 📱 Mobile + existing API:
```
🟢 Starter
  1. Flutter
  2. React Native

🟡 Standard
  3. Flutter + Riverpod
  4. React Native + Zustand

🔵 Professional
  5. Flutter + Riverpod + Dio
  6. React Native + Redux Toolkit + React Query

🎯 0. Let Claude recommend
```

### If Q3 = 🌐📱 Web + Mobile + existing API:
```
🟡 Standard
  1. React + Flutter
  2. Next.js + React Native

🔵 Professional
  3. Next.js + React Query + Flutter + Riverpod
  4. Angular + NgRx + Flutter + Riverpod

🎯 0. Let Claude recommend
```

### If Q3 = 🖥️ Desktop + existing API:
```
🟢 Starter
  1. Electron
  2. Tauri (Rust)

🟡 Standard
  3. Electron + React
  4. .NET WPF

🔵 Professional
  5. .NET MAUI (cross-platform)
  6. Tauri + React + React Query

🎯 0. Let Claude recommend
```

---

**Q5. Want to customize the stack?**

After user picks a stack, ask:
```
Your stack: [Frontend] + [Backend] + [Database]

  1. ✅ Use as-is
  2. 🔄 Customize (change some parts)

```

If user picks 2 (Customize):

If Q3.1 = 1 (new backend):
```
Change which part? (Enter to keep)
  Frontend:  [current] → ?
  Backend:   [current] → ?
  Database:  [current] → ?
```

If Q3.1 = 2 (existing API):
```
Change which part? (Enter to keep)
  Frontend:  [current] → ?
  (Backend and Database are from existing API — not changeable)
```

Show only compatible options for each change. After customizing, confirm:
```
Final stack: [Frontend] + [Backend] + [Database]
ORM: [auto-selected based on backend + database]
OK? (yes / change again)
```

If Q3.1 = 2, show instead:
```
Final stack: [Frontend only]
API:  [Q-API-1 base URL]
Auth: [Q-API-2 method]
HTTP client: [auto — axios/fetch/Dio/HttpClient]
OK? (yes / change again)
```

---

**Q6. What are the main features?**
(comma-separated, e.g. login, product catalog, cart, checkout, payment, admin dashboard)
Type 0 for Claude to suggest based on Q2.

---

**Q7. What user roles are needed?**
(comma-separated, e.g. admin, user, manager)
Type 0 for Claude to suggest based on Q6.

---

**Q8. Design preferences** (skip if Q3 = API only / CLI / Background Service)
```
  1. 🎨 Modern & Clean (Tailwind-style, minimal)
  2. 🏢 Corporate & Professional (structured, formal)
  3. 🎮 Playful & Colorful (bold colors, rounded)
  4. 🖤 Dark Mode First (dark background, neon accents)
  5. 📱 Mobile-First (thumb-friendly, large touch targets)
  6. 🪶 Minimal & Content-focused (whitespace, typography)
  7. 🎯 Dashboard & Data-heavy (charts, tables, filters)
  8. 🎯 0. Let Claude decide based on project type
```

---

**After Q8 — Auto-Decide the Rest**

Claude automatically selects (based on stack + features + best practices):
- Auth method (JWT recommended for API, session for SSO)
- Security level (OWASP Top 10 always applied)
- ORM (auto from backend + database) — skip if Q3.1 = 2
- CI/CD (GitHub Actions default)
- Deploy target (suggest based on stack level)
- Rate limiting (yes)
- HTTP client (auto from framework) — only if Q3.1 = 2

Show summary for approval:

**If Q3.1 = 1 (new backend):**
```
📋 PROJECT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:    [Q1]
Purpose:    [Q2]
Platform:   [Q3]
Backend:    🆕 New backend
Stack:      [Q4/Q5 — Frontend + Backend + Database]
ORM:        [auto]
Auth:       [auto — JWT / Session / OAuth]
Security:   OWASP Top 10 applied
Features:   [Q6]
Roles:      [Q7]
Design:     [Q8]
CI/CD:      GitHub Actions
Deploy:     [suggested based on stack]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  "approve"           → proceed to Gate 1 documents
  "change [item]"     → modify specific item
```

**If Q3.1 = 2 (existing API):**
```
📋 PROJECT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:    [Q1]
Purpose:    [Q2]
Platform:   [Q3]
Backend:    🔗 Existing API → [Q-API-1 base URL]
API Auth:   [Q-API-2]
API Docs:   [Q-API-3]
Stack:      [Q4/Q5 — client only]
HTTP Client:[auto — axios/fetch/Dio/HttpClient]
Security:   OWASP Top 10 applied (frontend)
Features:   [Q6]
Roles:      [Q7]
Design:     [Q8]
CI/CD:      GitHub Actions
Deploy:     [suggested based on stack]
Folder:     Template H
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  "approve"           → proceed to Gate 1 documents
  "change [item]"     → modify specific item
```

---

## MODE 2 — Custom (15 Questions)

Same as Quick Start Q1-Q5, then ask individually for each remaining choice.
Every question has `0. Let Claude decide`.

**Smart Narrowing Rules:**
- If Q3 = Web → skip mobile/desktop/CLI questions
- If Q3 = API only → skip frontend + design preferences
- If Q3 = CLI → skip frontend + database + design + deploy
- ORM auto-selected from backend + database (don't ask)
- If backend chosen → only show compatible databases
- If database chosen → only show compatible ORMs

Additional questions (after Q1-Q5):
```
Q6.  Auth method? (1. JWT  2. Session  3. OAuth  4. None  0. Auto)
Q7.  Security level? (1. Basic  2. OWASP Top 10  0. Auto=OWASP)
Q8.  Main features? (comma-separated)
Q9.  User roles? (comma-separated)
Q10. Design style? (1-8 or 0)
Q11. Primary color? (hex or name or 0)
Q12. Font style? (1. Sans  2. Serif  3. Mono  0. Auto)
Q13. Dark/Light mode? (1. Light  2. Dark  3. Both  4. System  0. Auto)
Q14. Deploy target? (list or 0)
Q15. Third-party integrations? (comma-separated or "none")
```

Then show same summary for approval.

---

## MODE 3 — Describe (1 Question)

```
📋 Describe your project in as much detail as you want.
Include anything: features, tech stack, design, users — everything helps.
I'll figure out the rest.

Example:
"เว็บขายของ ใช้ React กับ Python มี login สินค้า ตะกร้า จ่ายเงิน deploy Railway"

>
```

After user describes:
1. Claude extracts: project name, purpose, platform, stack, features, roles
2. Claude fills gaps with best-practice defaults
3. Show same PROJECT SUMMARY for approval
4. User can "change [item]" or "approve"

---

## PHASE 1 — Project Identity

**Q1. What is the project name?**
(free text — e.g. HRSystem, MyShop, LINEBUDGETMANAGEMENT)

---

**Q2. What does this project do?**
(free text — describe the purpose, problem it solves, and who will use it)

---

## LEGACY PHASES (below) — Superseded by MODE 1/2/3 above
## These are kept ONLY as reference for Custom mode (MODE 2) smart narrowing.
## When using MODE 1 (Quick Start) or MODE 3 (Describe), SKIP all phases below.

---

## PHASE 2 — Project Type (reference only)

**Q4. What type of project is this?**
(you may select multiple — reply with numbers separated by commas)
1. Web Application (browser-based)
2. iOS App (iPhone / iPad)
3. Android App
4. Cross-platform Mobile (iOS + Android)
5. Windows Desktop App
6. macOS App
7. Cross-platform Desktop (Windows + macOS + Linux)
8. Console / CLI Tool
9. Background Service / Worker
10. API only (no UI)

---

## PHASE 3 — Web / API Stack (ask only if Q4 includes 1 or 10)

**Q5. What frontend framework?**
1. Angular (standalone components, signals, SCSS)
2. React (Vite + TypeScript + Tailwind)
3. Vue 3 (Composition API + TypeScript)
4. Next.js (App Router + TypeScript + SSR)
5. Nuxt 3 (Vue-based SSR)
6. SvelteKit
7. Astro (static/hybrid)
8. Blazor WebAssembly (.NET)
9. No frontend (API only)
10. Other (specify)

---

**Q6. What backend framework?**
1. ASP.NET Core Minimal API (C# .NET 8)
2. ASP.NET Core Web API with Controllers (C# .NET 8)
3. Node.js + Express (TypeScript)
4. Node.js + Fastify (TypeScript)
5. Node.js + NestJS (TypeScript)
6. FastAPI (Python)
7. Django REST Framework (Python)
8. Go + Gin
9. Go + Echo
10. Go + Fiber
11. Other (specify)

---

## PHASE 4 — Mobile Stack (ask only if Q4 includes 2, 3, or 4)

**Q7. What mobile framework?**
1. Flutter (Dart — iOS + Android)
2. React Native (TypeScript)
3. .NET MAUI (C# — iOS + Android + Windows + macOS)
4. Expo (React Native managed)
5. Kotlin Multiplatform Mobile
6. Swift (iOS native only)
7. Kotlin (Android native only)
8. Ionic + Capacitor
9. Other (specify)

---

**Q8. What mobile-specific features are needed?**
(select all that apply)
1. Push notifications (FCM / APNs)
2. Biometric auth (Face ID / Fingerprint)
3. Offline mode + local data sync
4. Camera / photo library access
5. GPS / location services
6. QR code / barcode scanner
7. File upload / download
8. Deep linking / universal links
9. In-app purchases
10. Certificate pinning (SSL)
11. Jailbreak / root detection
12. None of the above

---

**Q9. Where will the mobile app be distributed?**
(select all that apply)
1. Apple App Store
2. TestFlight (iOS beta)
3. Google Play Store
4. Google Play Internal Testing
5. Enterprise / in-house distribution
6. Other (specify)

---

## PHASE 5 — Desktop Stack (ask only if Q4 includes 5, 6, or 7)

**Q10. What desktop framework?**
1. WPF (Windows only)
2. WinForms (Windows only)
3. .NET MAUI (cross-platform)
4. Avalonia UI (cross-platform)
5. Electron (JavaScript — cross-platform)
6. Tauri (Rust + web — cross-platform, lightweight)
7. Flutter Desktop
8. WinUI 3
9. Other (specify)

---

**Q11. What desktop-specific features are needed?**
(select all that apply)
1. System tray icon
2. Auto-start on login
3. Auto-update mechanism
4. Windows installer (MSIX / Inno Setup)
5. Local database (SQLite embedded)
6. File system read/write
7. Windows Hello / biometric auth
8. Active Directory / Windows auth
9. Print support
10. Serial port / hardware communication
11. Background Windows service
12. None of the above

---

## PHASE 6 — Console / CLI (ask only if Q4 includes 8 or 9)

**Q12. What runtime for the console/CLI?**
1. .NET Console App (C#)
2. .NET Worker Service (C# — background daemon)
3. Node.js CLI (TypeScript)
4. Python CLI (Click / Typer)
5. Go CLI (Cobra)
6. Rust CLI (Clap)
7. Bash script
8. Other (specify)

---

**Q13. What console features are needed?**
(select all that apply)
1. Argument / flag parsing
2. Interactive prompts (wizard-style)
3. Colored output / progress bars
4. Scheduled task (cron / Windows Task Scheduler)
5. Background daemon / Windows service
6. Stdin / pipe support
7. Output as JSON / CSV / table
8. Config file support
9. Logging to file (daily rotation)
10. None of the above

---

## PHASE 7 — Data Layer (ask everyone)

**Q14. What database?**
1. SQLite (file-based — good for small/embedded apps)
2. PostgreSQL
3. MySQL / MariaDB
4. Microsoft SQL Server
5. MongoDB
6. Redis (cache + session)
7. Firebase Firestore
8. Supabase (PostgreSQL BaaS)
9. Realm / Realm Sync (mobile-first)
10. No database needed
11. Other (specify)

---

**Q15. What ORM or data access library?**
1. Entity Framework Core (C#)
2. Dapper (C# — lightweight)
3. Prisma (Node.js)
4. TypeORM (Node.js)
5. Drizzle ORM (Node.js — lightweight)
6. SQLAlchemy (Python)
7. GORM (Go)
8. Drift (Flutter/Dart)
9. Raw SQL only
10. Other (specify)

---

## PHASE 8 — Auth & Security (ask everyone)

**Q16. What authentication method?**
1. JWT Bearer Token (stateless)
2. JWT + Refresh Token (HttpOnly cookie)
3. Session-based (cookie + server-side store)
4. OAuth2 / OpenID Connect (Google, GitHub, Microsoft)
5. Auth0 (managed auth)
6. Firebase Authentication
7. Keycloak (self-hosted SSO)
8. Apple Sign In
9. Biometric + local PIN (mobile/desktop)
10. API Key only
11. Windows Authentication (Active Directory / LDAP)
12. No authentication
13. Other (specify)

---

**Q17. What authorization model?**
1. Role-Based Access Control (RBAC)
2. Permission-Based (granular per user)
3. Attribute-Based Access Control (ABAC)
4. Owner-only (users access their own data only)
5. No authorization needed
6. Other (specify)

---

**Q18. Do you want OWASP Top 10 security controls?**
1. Yes — apply all OWASP Top 10 (recommended for production)
2. Yes — apply selected controls only
3. No — basic security only (HTTPS, CORS, input validation)

---

**Q19. What additional security measures are needed?**
(select all that apply)
1. Rate limiting on all endpoints
2. Rate limiting on auth endpoints only
3. IP allowlist / blocklist
4. Request size limiting
5. Content Security Policy (CSP) headers
6. HSTS (HTTP Strict Transport Security)
7. Certificate pinning (mobile)
8. Jailbreak / root detection (mobile)
9. File upload validation / scanning
10. Audit trail logging
11. Data encryption at rest
12. PII masking in logs
13. None of the above

---

## PHASE 9 — Features & Roles (ask everyone)

**Q20. What are the main features of this project?**
(free text — list features, e.g. "user management, budget CRUD, monthly reports, export Excel")

---

**Q21. What user roles does this project need?**
(free text — e.g. "Admin, Manager, Staff" or "none")

---

## PHASE 10 — Design Preferences (ask if Q4 includes UI — options 1-7)

**Q22. What visual style do you want?**
1. Modern & Clean (minimal, lots of whitespace, flat design)
2. Corporate & Professional (structured, formal, data-dense)
3. Bold & Colorful (vibrant colors, gradients, playful)
4. Dark Mode First (dark backgrounds, neon accents)
5. Material Design (Google's design system)
6. Apple/iOS Style (clean, rounded, subtle shadows)
7. Dashboard / Admin Panel (data-heavy, charts, tables)
8. Other (describe your preferred style)

---

**Q23. What is the primary brand color?**
(free text — e.g. "#3B82F6 blue", "red", "company brand color: #E94560", or "no preference")

---

**Q24. What font style do you prefer?**
1. System default (Inter / -apple-system / Segoe UI)
2. Modern sans-serif (Inter, Plus Jakarta Sans, Outfit)
3. Classic sans-serif (Roboto, Open Sans, Lato)
4. Rounded friendly (Nunito, Quicksand, Comfortaa)
5. Monospace / Developer feel (JetBrains Mono, Fira Code)
6. Thai-optimized (Noto Sans Thai, IBM Plex Sans Thai, Sarabun)
7. Other (specify font name)

---

**Q25. Do you need dark mode?**
1. Yes — dark mode only
2. Yes — light + dark mode with toggle
3. No — light mode only
4. Follow system preference (auto)

---

**Q26. Any design references or inspiration?**
(free text — e.g. "like Notion's clean style", "like Stripe dashboard", URL to reference site, or "no preference")

---

## PHASE 11 — Quality & DevOps (ask everyone)

**Q27. What testing strategy?**
(select all that apply)
1. Unit tests (business logic)
2. Integration tests (API / database)
3. End-to-end tests — Playwright (web)
4. End-to-end tests — Cypress (web)
5. Mobile UI tests (Detox / Flutter integration tests)
6. Load / performance tests (k6)
7. Security scan in CI (SAST)
8. No tests needed

---

**Q28. What code quality tools?**
(select all that apply)
1. ESLint + Prettier (JavaScript/TypeScript)
2. Angular ESLint
3. Husky + lint-staged (pre-commit hooks)
4. SonarQube / SonarCloud
5. .NET Roslyn Analyzers
6. Ruff (Python)
7. golangci-lint (Go)
8. Flutter analyzer
9. None

---

**Q29. Where will this be deployed?**
1. Docker self-hosted (docker-compose)
2. Docker + Nginx reverse proxy
3. Kubernetes (K8s)
4. Azure App Service
5. Azure Container Apps
6. AWS EC2
7. AWS ECS / Fargate
8. Google Cloud Run
9. Railway
10. Vercel (frontend) + separate backend
11. Netlify
12. Cloudflare Pages
13. GitHub Pages (static sites only)
14. Apple App Store (mobile)
15. Google Play Store (mobile)
16. Windows installer / enterprise
17. Other (specify)

---

**Q30. What CI/CD pipeline?**
1. GitHub Actions
2. GitLab CI/CD
3. Azure DevOps
4. Bitbucket Pipelines
5. Fastlane (mobile)
6. Xcode Cloud (iOS)
7. No CI/CD needed
8. Other (specify)

---

**Q31. Any additional requirements?**
(select all that apply)
1. LINE Notify / LINE Messaging API
2. Email sending (SMTP / SendGrid)
3. SMS notifications (Twilio)
4. Push notifications (FCM / APNs)
5. Export to Excel
6. Export to PDF
7. File upload / cloud storage (S3 / Azure Blob)
8. Real-time updates (WebSocket / SignalR)
9. Background jobs / scheduled tasks
10. Multi-language support (i18n)
11. Dark mode
12. Offline support / PWA
13. Maps / GPS integration
14. Payment gateway (Stripe / Omise / PromptPay)
15. Barcode / QR code generation
16. None of the above

---

## Agent Pipeline & Gate Structure

```
GATE 0 — Project Setup                ← runs automatically before Gate 1
  DevOps → read ~/.claude/sdlc/dev-github.md
         → PROC-GH-01: create GitHub repo + branch strategy
         → PROC-GH-10: set branch protection rules on main
         → PROC-GH-14: create PR + Issue templates (.github/)
  PM     → read ~/.claude/sdlc/dev-notion.md
         → PROC-NT-01: find or create Notion parent page
         → PROC-NT-02: create project database (Task Board)
         → PROC-NT-07: create views (Board, By Epic, Sprint, All Tasks)
  DevOps → save .project.env (NOTION_DATABASE_ID, GITHUB_REPO)
  ──────────────────────────────────────────────────
  Show:
    ✅ GitHub: github.com/[user]/[PROJECT_NAME]
    ✅ Notion: [NOTION_BOARD_URL]
    ✅ Branch protection: main protected
    ✅ Templates: PR + Issue templates created
    ✅ Notion views: Board, By Epic, Sprint, All Tasks
  No approval needed — proceed to Gate 1 automatically

GATE 1 — Discovery                    ← HARD STOP: user must approve before Gate 2
  BA → ask Q1–Q31, write CLAUDE.md
  BA → write docs/brd.html (BRD + User Stories + Acceptance Criteria)
  BA + Tech Lead → write docs/srs.html (Software Requirements Specification)
  ──────────────────────────────────────────────────
  ⛔ STOP: Show BRD + SRS → wait for "approve" or "revise [notes]"

GATE 2 — Architecture & Design        ← HARD STOP: user must approve before Gate 3
  All agents read docs/brd.html + docs/srs.html first, then produce:

  **If Q3.1 = 1 (new backend) — Full Stack docs:**
  Tech Lead → architecture + task breakdown (no separate doc — feeds into all below)
  DBA       → docs/database-design.html (schema, ERD, migrations, indexes)
  Backend   → docs/api-reference.html (endpoints, request/response, auth, errors)
  Security  → docs/security-design.html (threat model, OWASP, auth architecture)
  DevOps    → docs/infrastructure-guide.html (cloud arch, CI/CD, deploy, monitoring)
  QA        → docs/test-strategy.html (test plan, coverage, environments)
  UX/UI     → docs/prototype/index.html + docs/prototype/components.html
              (read CLAUDE.md Q22-Q26 design prefs → design tokens → wireframes → component library)
  PM        → docs/project-plan.html (epics, milestones, timeline, risks, RACI)

  **If Q3.1 = 2 (existing API) — Client-Only docs + API Request Spec:**
  Tech Lead → architecture + task breakdown
  Backend   → docs/api-request.html ← NEW: spec ที่ต้องส่งให้ backend project เดิม
  Security  → docs/security-design.html (frontend security: XSS, CSRF, token storage)
  DevOps    → docs/infrastructure-guide.html (frontend deploy only)
  QA        → docs/test-strategy.html (frontend tests + API integration tests)
  UX/UI     → docs/prototype/index.html + docs/prototype/components.html
  PM        → docs/project-plan.html

  Skip: DBA (no database), docs/database-design.html (no schema)
  Skip: docs/api-reference.html (API is in the existing backend project)

  ┌─────────────────────────────────────────────────────────────┐
  │ docs/api-request.html — API REQUEST SPECIFICATION           │
  │                                                             │
  │ This document lists ALL endpoints this project needs        │
  │ from the existing backend API. It serves as:                │
  │  1. Contract between frontend project and backend project   │
  │  2. Input for `/change` on the backend project              │
  │  3. Integration test reference                              │
  │                                                             │
  │ Format per endpoint:                                        │
  │  ─────────────────────────────────────────                  │
  │  Endpoint:     [METHOD] [path]                              │
  │  Purpose:      [what it does — 1 sentence]                  │
  │  Request:                                                   │
  │    Headers:    [auth, content-type]                         │
  │    Params:     [path params, query params]                  │
  │    Body:       [JSON schema with types + required fields]   │
  │    Example:    [sample request body]                        │
  │  Response:                                                  │
  │    Success:    [status code + JSON schema]                  │
  │    Example:    [sample response body]                       │
  │    Errors:     [possible error codes + messages]            │
  │  Auth:         [required role/scope or "public"]            │
  │  Notes:        [pagination, rate limit, etc.]               │
  │  ─────────────────────────────────────────                  │
  │                                                             │
  │ Also includes:                                              │
  │  • Summary table (all endpoints at a glance)                │
  │  • Data models used in request/response                     │
  │  • Auth flow (how this project obtains tokens)              │
  │  • Error handling strategy                                  │
  │                                                             │
  │ HOW TO USE THIS DOCUMENT:                                   │
  │  At the existing backend project, run:                      │
  │  > /change เพิ่ม API ตาม [path]/docs/api-request.html      │
  │  Claude will read the spec and create all endpoints.        │
  └─────────────────────────────────────────────────────────────┘

  COMPLETION CHECK:
  If Q3.1 = 1: All 9 documents must exist:
    docs/brd.html, docs/srs.html, docs/database-design.html,
    docs/api-reference.html, docs/security-design.html,
    docs/infrastructure-guide.html, docs/test-strategy.html,
    docs/prototype/index.html, docs/project-plan.html

  If Q3.1 = 2: All 8 documents must exist:
    docs/brd.html, docs/srs.html, docs/api-request.html,
    docs/security-design.html, docs/infrastructure-guide.html,
    docs/test-strategy.html, docs/prototype/index.html,
    docs/project-plan.html

  PAIR REVIEW — cross-check between agents:
  ┌─────────────────────────────────────────────┐
  │ After all agents produce their output:      │
  │                                             │
  │ 1. Each agent reviews the other outputs     │
  │    for conflicts with their own:            │
  │    • TechLead vs DBA: schema fits arch?     │
  │    • TechLead vs Security: secure design?   │
  │    • Backend vs DBA: API matches schema?    │
  │    • UX/UI vs Backend: UI matches API?      │
  │    • DBA vs Security: data protection?      │
  │    • DevOps vs Backend: infra supports API? │
  │                                             │
  │ 2. If CONFLICTS found:                      │
  │    Show: AGREEMENTS ✅ + CONFLICTS ⚠️       │
  │    Each side proposes resolution             │
  │    Pick the better option with trade-off     │
  │    Update affected docs before showing gate  │
  │                                             │
  │ 3. If NO conflicts: proceed to gate         │
  └─────────────────────────────────────────────┘
  ──────────────────────────────────────────────────
  ⛔ STOP: Show all 9 docs + conflict resolutions (if any)
          → wait for "approve" or "revise [doc]"

GATE 3 — Foundation + Task Setup      ← HARD STOP: user must approve before Gate 4
  PM     → read ~/.claude/sdlc/dev-github.md → PROC-GH-04: create labels
  PM     → read ~/.claude/sdlc/dev-github.md → PROC-GH-11: create milestones (1 per epic)
  PM     → break tasks into Epic → Feature → Task list → show for approval
  ⛔ STOP: Show task list → wait for "task list approved"

  After approval:
  PM     → read ~/.claude/sdlc/dev-github.md → PROC-GH-05: create GitHub Issues (1 per task, assigned to milestone)
  PM     → read ~/.claude/sdlc/dev-notion.md → PROC-NT-03: create Notion tasks (link GitHub #, Epic, Role)
  PM     → PROC-NT-10: show project dashboard (progress summary)
  DevOps → scaffold Docker Compose, branch strategy
  Backend → scaffold project, DB connection, /health endpoint
  Frontend → scaffold project, API service, auth interceptor
  ──────────────────────────────────────────────────
  Show:
    ✅ [N] GitHub issues created (assigned to milestones)
    ✅ [N] Notion tasks created (Status: To Do)
    ✅ Scaffold complete
  ⛔ STOP → wait for "approve" or "revise [component]"

GATE 4 — Feature Development          ← HARD STOP per feature
  For EACH feature in Progress Tracker:
    1. PM     → PROC-NT-04: update Notion task → "In Progress"
    2. DevOps → PROC-GH-06: create feature branch (feature/[issue#]-[slug])
    3. Backend  → read docs/api-reference.html + docs/database-design.html → implement API
    4. Frontend → read docs/prototype/index.html + docs/srs.html           → implement UI
    5. DevOps → PROC-GH-07: create PR
    6. PR REVIEW — multi-dimensional review before approval:
       ┌─────────────────────────────────────────────┐
       │ Architecture (@techlead): fits existing design? over-engineered? │
       │ Code Quality (@backend/@frontend): error handling, all states?   │
       │ Security (@security): input validation, auth, OWASP?            │
       │ Performance: N+1 queries? re-renders? bundle size?              │
       │ Testing (@qa): unit + integration + E2E coverage?               │
       │ Docs (@docs): new endpoints documented? changelog?              │
       └─────────────────────────────────────────────┘
       Severity: 🔴 BLOCKER (must fix) | 🟡 MAJOR (should fix) | 🟢 MINOR (suggestion)
       → If 🔴 BLOCKER found → agent fixes before showing approval gate
       → If 🟡 MAJOR found → list in approval summary, recommend fix
       → If only 🟢 MINOR → proceed to approval gate
    7. PM     → PROC-NT-05: update Notion task → "In Review", add PR #
    ⛔ STOP: show output + review findings → wait for "approve" or "revise [notes]"

    After approval:
    8. DevOps → PROC-GH-08: merge PR, close issue
       ⚠️ If merge conflict → follow PROC-GH-13 (conflict resolution)
    9. PM     → PROC-NT-06: update Notion task → "Done"
    → proceed to next feature

GATE 5 — Quality & Delivery           ← HARD STOP: user must approve before deploy
  QA       → read docs/brd.html → write + run tests → coverage report
  Security → read docs/security-design.html → OWASP checklist
  DevOps   → configure CI/CD pipeline → run pipeline
  Docs     → write README, API docs, deployment guide
  PM       → verify all Notion tasks → Done
  ──────────────────────────────────────────────────
  ⛔ STOP: Show test + security report → wait for "approve" to deploy

  After approval:
  DevOps → PROC-GH-15: determine semver (patch/minor/major)
  DevOps → PROC-GH-09: merge develop → main, tag with semver
  Show:
    ✅ All [N] GitHub issues closed
    ✅ All [N] Notion tasks → Done
    ✅ Merged to main, tagged [semver]
    🚀 Ready for production deployment
```

---

## CLAUDE.md Output Template

After BA collects all answers, save as CLAUDE.md in project root.

---

# [PROJECT_NAME] — Claude Code Spec

## Project Overview
| Field | Value |
|-------|-------|
| Name | [PROJECT_NAME] |
| Description | [PROJECT_DESC] |
| Stakeholders | [STAKEHOLDERS] |
| Project Type | [PROJECT_TYPE] |
| Frontend / UI | [FRONTEND] |
| Backend | [BACKEND] |
| Database | [DATABASE] |
| ORM | [ORM] |
| Auth | [AUTH] |
| Authorization | [AUTHZ] |
| Deploy | [DEPLOY] |
| CI/CD | [CICD] |
| Extra | [EXTRA] |

## Folder Structure

Generate based on Q4 (project type) + Q5-Q11 (tech stack).
Use the matching template below, then adjust for the specific frameworks chosen.

### Template A — Web Full-Stack (Q4=1, Q5≠9)
```
[PROJECT_NAME]/
├── frontend/                  ← Q5 framework
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/         ← API client
│   │   ├── stores/           ← state management
│   │   ├── assets/
│   │   └── utils/
│   ├── public/
│   ├── package.json
│   └── tsconfig.json
│
├── backend/                   ← Q6 framework
│   ├── src/
│   │   ├── controllers/      ← route handlers
│   │   ├── services/         ← business logic
│   │   ├── repositories/     ← data access
│   │   ├── models/           ← domain entities
│   │   ├── middleware/       ← auth, validation, logging
│   │   ├── config/           ← app config
│   │   └── utils/
│   ├── tests/
│   └── package.json (or .csproj, go.mod, etc.)
│
├── database/                  ← Q10 database
│   ├── migrations/
│   ├── seeds/
│   └── schema.sql (or prisma/schema.prisma, etc.)
│
├── docs/                      ← generated by Gate 2
│   ├── index.html
│   ├── brd.html
│   ├── srs.html
│   ├── prototype/
│   └── ...
│
├── .github/                   ← PROC-GH-14 templates
│   ├── pull_request_template.md
│   └── ISSUE_TEMPLATE/
│
├── docker-compose.yml
├── CLAUDE.md
├── .project.env
├── .gitignore
└── README.md
```

### Template B — API Only (Q4=10, or Q5=9)
```
[PROJECT_NAME]/
├── src/
│   ├── controllers/
│   ├── services/
│   ├── repositories/
│   ├── models/
│   ├── middleware/
│   ├── config/
│   └── utils/
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── tests/
│   ├── unit/
│   └── integration/
│
├── docs/
├── .github/
├── docker-compose.yml
├── CLAUDE.md
└── README.md
```

### Template C — Mobile App (Q4=2,3,4)
```
[PROJECT_NAME]/
├── mobile/                    ← Q7 framework
│   ├── lib/ (Flutter) or src/ (RN)
│   │   ├── screens/
│   │   ├── components/
│   │   ├── services/         ← API client
│   │   ├── stores/           ← state management
│   │   ├── models/
│   │   └── utils/
│   ├── assets/
│   └── pubspec.yaml (or package.json)
│
├── backend/                   ← Q6 framework (if needed)
│   ├── src/
│   └── ...
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── docs/
├── .github/
├── CLAUDE.md
└── README.md
```

### Template D — Mobile + Web (Q4=1+2/3/4)
```
[PROJECT_NAME]/
├── frontend/                  ← Q5 web framework
│   └── ...
│
├── mobile/                    ← Q7 mobile framework
│   └── ...
│
├── backend/                   ← Q6 shared API
│   └── ...
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── shared/                    ← shared types, constants
│   ├── types/
│   └── constants/
│
├── docs/
├── .github/
├── docker-compose.yml
├── CLAUDE.md
└── README.md
```

### Template E — Desktop App (Q4=5,6,7)
```
[PROJECT_NAME]/
├── app/                       ← Q8 framework (Electron, Tauri, etc.)
│   ├── src/
│   │   ├── main/             ← main process
│   │   ├── renderer/         ← UI
│   │   ├── services/
│   │   └── utils/
│   └── package.json
│
├── database/                  ← local DB (SQLite, etc.)
│   └── migrations/
│
├── docs/
├── .github/
├── CLAUDE.md
└── README.md
```

### Template F — CLI Tool (Q4=8)
```
[PROJECT_NAME]/
├── src/
│   ├── commands/
│   ├── utils/
│   └── config/
│
├── tests/
├── docs/
├── .github/
├── CLAUDE.md
└── README.md
```

### Template G — Background Service / Worker (Q4=9)
```
[PROJECT_NAME]/
├── src/
│   ├── workers/
│   ├── jobs/
│   ├── services/
│   ├── config/
│   └── utils/
│
├── database/
│   └── migrations/
│
├── tests/
├── docs/
├── .github/
├── docker-compose.yml
├── CLAUDE.md
└── README.md
```

### Template H — Client Only (Q3.1 = 2, connect to existing API)

Use when Q3.1 = 2 for any platform. No backend/ or database/ folders.

**H1 — Web client only:**
```
[PROJECT_NAME]/
├── src/
│   ├── components/          ← UI components
│   ├── pages/               ← route pages
│   ├── services/
│   │   └── api/             ← API client + endpoints
│   │       ├── client.ts    ← axios/fetch instance + base URL + auth
│   │       ├── endpoints/   ← one file per API domain (auth, orders, products...)
│   │       └── types/       ← request/response types from API
│   ├── stores/              ← state management
│   ├── hooks/               ← custom hooks (React) or composables (Vue)
│   ├── assets/
│   └── utils/
│
├── public/
├── docs/
├── .github/
├── .env                     ← API_BASE_URL, API_KEY (gitignored)
├── .env.example             ← template without secrets
├── CLAUDE.md
├── package.json
└── README.md
```

**H2 — Mobile client only:**
```
[PROJECT_NAME]/
├── lib/ (Flutter) or src/ (React Native)
│   ├── screens/
│   ├── components/
│   ├── services/
│   │   └── api/             ← API client + endpoints
│   │       ├── client.dart/.ts  ← HTTP instance + base URL + auth
│   │       ├── endpoints/
│   │       └── models/      ← request/response models from API
│   ├── stores/              ← state management (Riverpod/Redux/Zustand)
│   └── utils/
│
├── assets/
├── docs/
├── .github/
├── .env
├── .env.example
├── CLAUDE.md
├── pubspec.yaml (or package.json)
└── README.md
```

**H3 — Web + Mobile client only:**
```
[PROJECT_NAME]/
├── frontend/                ← web client (same as H1)
│   └── src/...
│
├── mobile/                  ← mobile client (same as H2)
│   └── lib/ or src/...
│
├── shared/                  ← shared types, API models
│   ├── types/
│   └── constants/
│
├── docs/
├── .github/
├── CLAUDE.md
└── README.md
```

**H4 — Desktop client only:**
```
[PROJECT_NAME]/
├── app/                     ← Electron, Tauri, .NET, etc.
│   ├── src/
│   │   ├── main/            ← main process
│   │   ├── renderer/        ← UI
│   │   ├── services/
│   │   │   └── api/         ← API client + endpoints
│   │   └── utils/
│   └── package.json
│
├── docs/
├── .github/
├── .env
├── .env.example
├── CLAUDE.md
└── README.md
```

### Selection Rules for Agents:
1. If Q3.1 = 1 (new backend) → pick Template A-G based on Q3
2. If Q3.1 = 2 (existing API) → pick Template H (H1/H2/H3/H4 based on Q3)
3. If Q3 has multiple types → use Template D or H3 (multi-platform)
3. Adjust folder names for framework conventions:
   - Flutter: `lib/` not `src/`
   - .NET: project folders match `.csproj` names
   - Go: `cmd/`, `internal/`, `pkg/`
   - Python: package name folder
4. Always include: `docs/`, `.github/`, `CLAUDE.md`, `README.md`

## Architecture
[Generate based on project type and backend pattern]

## Security
[Generate based on Q18–Q19, Q22–Q26]

### Basic Security (always applied)
- HTTPS enforced in production
- CORS: allow only known origins
- Input validation on all user input
- Secrets via environment variables — never hardcoded
- DTOs only — never expose internal models
- Swagger disabled in production

### OWASP Top 10 (if selected in Q18)
- A01 Broken Access Control: RequireAuthorization() on all protected endpoints
- A02 Cryptographic Failures: BCrypt, JWT in env, TLS 1.2+
- A03 Injection: ORM parameterized queries, FluentValidation on all inputs
- A04 Insecure Design: rate limiting on auth, business logic in service layer
- A05 Misconfiguration: CORS whitelist, Swagger dev-only, non-root Docker
- A06 Vulnerable Components: pin versions, audit before every release
- A07 Auth Failures: JWT 15min, refresh token HttpOnly cookie, lockout after 5 attempts
- A08 Data Integrity: lock files, no untrusted deserialization
- A09 Logging: structured logs, log auth events, never log PII or tokens
- A10 SSRF: whitelist outbound URLs, block internal IP ranges

### Mobile Security (if applicable)
- Certificate pinning: [yes/no]
- Jailbreak / root detection: [yes/no]
- Encrypted local storage: [yes/no]

## User Roles
[ROLES]

## Features
- [ ] [FEATURE_1]
- [ ] [FEATURE_2]
- [ ] [FEATURE_N]

## Coding Standards
[Generate based on selected tech stack]

## Testing Strategy
[Generate from Q22]

## Code Quality
[Generate from Q23]

## ⚠️ Gate Approval Rules (enforce in every session)

### What agents MUST do at each gate
1. Complete all tasks for the current gate
2. Save all output files to disk
3. Commit to git
4. Update memory/progress.json
5. Show the GATE APPROVAL REQUIRED message
6. STOP and wait — do not proceed

### What agents MUST do when resuming any session
1. Read memory/progress.json — find current gate and last step
2. Read the actual docs file for the current gate (NOT chat history)
3. Announce what was read and from where
4. Continue from "Next action" in progress.json

### Gate approval message format
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ GATE [N] APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate: [N] — [Gate Name]
Completed by: [Agent Name]

Output produced:
  📄 [file 1] — [what it contains]
  📄 [file 2] — [what it contains]

Please review the output above.

  "approve"        → proceed to Gate [N+1]
  "revise [notes]" → make changes and re-show
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ⚠️ Revision Protocol — How to Handle Change Requests

When the user types "revise [notes]" at any gate, the active agent MUST:

### Step 1 — Impact Analysis (always first)

Before making any change, run impact analysis and show it to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CHANGE IMPACT ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requested change: [what the user asked to change]

Documents that MUST be updated:
  📄 [doc 1] — [why it needs updating]
  📄 [doc 2] — [why it needs updating]
  📄 [doc 3] — [why it needs updating]

Code that MUST be updated (if already written):
  📁 [file/folder] — [what needs to change]

Estimated impact: [Low / Medium / High]

Proceed with all updates? (yes / cancel)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Wait for user to confirm before making any changes.

---

### Step 2 — Apply Changes in Dependency Order

Always update documents in this order (upstream → downstream):

```
1. CLAUDE.md           (spec source of truth — always first)
2. docs/brd.html       (requirements — drives everything else)
3. docs/database-design.html    (data model — drives API + code)
4. docs/api-reference.html       (API spec — drives frontend + mobile)
5. docs/prototype/index.html      (UI spec — drives frontend)
6. docs/security-design.html  (security — update if new data or endpoints added)
7. Code                (backend → frontend → mobile — always last)
```

Never update code before documents are updated and saved.

---

### Step 3 — Show Cascade Summary After Each Document Update

After updating each document, announce:

```
✅ Updated: [filename]
   Changed: [what was added / modified / removed]
   Next:    [next document to update]
```

---

### Step 4 — Re-approve After All Updates Complete

After all documents and code are updated, show the gate approval message again:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ REVISION COMPLETE — RE-APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Change applied: [summary of what changed]

Documents updated:
  📄 [doc 1] ✓
  📄 [doc 2] ✓
  📄 [doc 3] ✓

Code updated:
  📁 [file] ✓  (or "No code changes needed at this gate")

  "approve"        → proceed to Gate [N+1]
  "revise [notes]" → make further changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 📋 Change Impact Reference Map

Use this map to determine which documents cascade from each change type.
Agents MUST consult this map before showing the impact analysis.

### Adding a new feature
```
CLAUDE.md            ← add to Features list + Progress Tracker
docs/brd.html        ← add user stories + acceptance criteria
docs/database-design.html     ← add tables / fields if feature needs new data
docs/api-reference.html        ← add new endpoints
docs/prototype/index.html       ← add new screens / components
docs/security-design.html   ← update if feature has auth / data sensitivity
Code (backend)       ← new handler + endpoint + repository
Code (frontend)      ← new component + service call + route
```

### Adding or modifying a database table
```
CLAUDE.md            ← update if affects architecture overview
docs/database-design.html     ← update ERD + table definition
docs/api-reference.html        ← update affected endpoints (request/response DTOs)
docs/brd.html        ← update data requirements section
Code (migration)     ← new EF Core / Prisma migration
Code (entity)        ← new or updated entity class
Code (repository)    ← update repository if query changes
Code (DTO)           ← update request/response DTOs
Code (handler)       ← update handler logic
Code (frontend)      ← update models + service calls
```

### Adding or modifying an API endpoint
```
docs/api-reference.html        ← update endpoint definition
docs/brd.html        ← update acceptance criteria if behavior changes
docs/security-design.html   ← update if endpoint has new auth requirements
Code (endpoint)      ← update route mapping
Code (handler)       ← update business logic
Code (DTO)           ← update request/response models
Code (frontend)      ← update API service + component
```

### Changing authentication or authorization
```
CLAUDE.md            ← update Auth / Authorization fields
docs/security-design.html   ← update auth design + OWASP checklist
docs/brd.html        ← update affected user stories
docs/api-reference.html        ← update which endpoints require auth
Code (auth)          ← update auth middleware / JWT config
Code (endpoints)     ← update RequireAuthorization() calls
Code (frontend)      ← update auth interceptor + route guards
```

### Changing user roles
```
CLAUDE.md            ← update User Roles section
docs/brd.html        ← update user stories and actor list
docs/security-design.html   ← update RBAC / permission matrix
docs/api-reference.html        ← update which roles can access which endpoints
Code (auth)          ← update role definitions + claims
Code (endpoints)     ← update role-based authorization attributes
Code (frontend)      ← update role-based UI visibility
```

### Adding a new screen or UI component
```
docs/prototype/index.html       ← add wireframe + component spec
docs/brd.html        ← check if new user stories are needed
docs/api-reference.html        ← check if new endpoints are needed
Code (frontend)      ← new component + route
Code (backend)       ← new endpoint if required
```

---

## Progress Tracker

### Gate 1 — Discovery ⛔ requires approval
- [ ] BA: collect spec answers (Q1–Q31)
- [ ] BA: write CLAUDE.md
- [ ] BA: write docs/brd.html (BRD + User Stories + Acceptance Criteria)
- [ ] **GATE 1 APPROVAL** — waiting for user

### Gate 2 — Architecture & Design ⛔ requires approval
- [ ] Tech Lead: read docs/brd.html + docs/srs.html → architecture decision
- [ ] DBA: → docs/database-design.html (skip if Q3.1=2)
- [ ] Backend: → docs/api-reference.html (if Q3.1=1) OR docs/api-request.html (if Q3.1=2)
- [ ] Security: → docs/security-design.html
- [ ] DevOps: → docs/infrastructure-guide.html
- [ ] QA: → docs/test-strategy.html
- [ ] UX/UI: → docs/prototype/index.html + docs/prototype/components.html
- [ ] PM: → docs/project-plan.html
- [ ] **GATE 2 APPROVAL** — all docs ready, waiting for user

### Gate 3 — Foundation ⛔ requires approval
- [ ] DevOps: git init, branch strategy, Docker Compose
- [ ] Backend: scaffold, DB connected, /health endpoint live
- [ ] Frontend: scaffold, API service, auth interceptor, route guard
- [ ] **GATE 3 APPROVAL** — waiting for user

### Gate 4 — Feature Development ⛔ requires approval per feature
- [ ] Auth: backend + frontend implemented and tested
- [ ] **FEATURE APPROVAL: Auth**
- [ ] Feature [FEATURE_1]: backend + frontend
- [ ] **FEATURE APPROVAL: [FEATURE_1]**
- [ ] Feature [FEATURE_2]: backend + frontend
- [ ] **FEATURE APPROVAL: [FEATURE_2]**

### Gate 5 — Quality & Delivery ⛔ requires approval before deploy
- [ ] QA: all tests passing, coverage report generated
- [ ] Security: OWASP checklist verified, audit clean
- [ ] DevOps: CI/CD pipeline configured and passing
- [ ] Docs: README + API docs + deployment guide complete
- [ ] PM: Notion updated, tasks closed, retrospective written
- [ ] **GATE 5 APPROVAL** — waiting for user before deploy

## Last Checkpoint
**Status:** NOT STARTED
**Gate:** 1
**Last completed:** BA intake questions answered
**Next action:** BA — write CLAUDE.md, then write docs/brd.html
**Files modified:** CLAUDE.md

## Resume Instructions
1. Read memory/progress.json first
2. Read the source file for the current gate from disk (NOT from chat history)
3. Announce: "📂 Resuming Gate [N] — read from [filename]"
4. Continue from "Next action" in progress.json
5. Do NOT skip gate approvals even when resuming
6. Run /compact when context gets long
