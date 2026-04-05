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

