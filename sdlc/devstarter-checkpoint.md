# dev-checkpoint.md — Checkpoint & Auto-Resume Protocol

## Purpose

Prevents work loss when Claude Code hits rate limits during long workflows.
All SDLC workflows (dev-starter, dev-change, etc.) MUST follow this protocol.

---

## How It Works

```
Workflow Start
  │
  ├── 1. Setup: ตั้ง Cron auto-resume ทุก 10 นาที
  │
  ├── 2. ทำ Task → เสร็จ → Save Checkpoint
  ├── 3. ทำ Task → เสร็จ → Save Checkpoint
  ├── 4. ทำ Task → ติด Rate Limit → หยุด
  │
  │   ... รอ reset ...
  │   ... Cron fires ตอน idle ...
  │   ... อ่าน checkpoint → ทำต่อ ...
  │
  ├── 5. Resume Task → เสร็จ → Save Checkpoint
  └── 6. ทำ Task ต่อไป → ...
```

---

## Protocol — ทุก Workflow ต้องทำ 3 อย่างนี้

### 1. Setup Auto-Resume (ทำตอนเริ่ม workflow)

เมื่อเริ่ม workflow ใดก็ตาม (dev-starter, dev-change, etc.) ให้ตั้ง Cron ทันที:

```
ใช้ CronCreate:
  cron: "*/10 * * * *"  (ทุก 10 นาที)
  prompt: |
    Check if there is an interrupted workflow.
    Read memory/progress.json in the current project directory.
    If status is "in_progress" or "interrupted":
      1. Read the checkpoint data
      2. Announce: "🔄 Auto-resuming: [workflow] — [gate/phase] — [task]"
      3. Read the relevant workflow file from ~/.claude/sdlc/
      4. Continue from where it left off
    If status is "completed" or file doesn't exist:
      Do nothing.
```

แจ้ง user:
```
⏱️ Auto-resume ตั้งไว้แล้ว — ถ้าติด rate limit จะกลับมาทำต่อเองภายใน 10 นาที
```

### 1b. Limit Check — Before Starting Each New Task

Before beginning any new task (not the current one — the NEXT one),
run this check and update `tasks_this_session` + `files_read_this_session` in progress.json:

```
LIMIT CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tasks_this_session:      [N]   threshold: 8
files_read_this_session: [N]   threshold: 20

If EITHER threshold is reached:
  1. Finish the CURRENT task completely
  2. Save checkpoint with status: "paused_limit"
  3. Announce:
     "⏸ Approaching rate limit — finishing current task then pausing.
      Auto-resume via cron within 10 minutes."
  4. STOP — do NOT start the next task
  5. Cron will detect "paused_limit" and resume with fresh counters

If below both thresholds → continue to next task normally.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**ค่า threshold แนะนำ:**
| Workload | tasks threshold | files threshold |
|----------|----------------|-----------------|
| Light (small edits) | 12 | 30 |
| Balanced (default) | 8 | 20 |
| Heavy (doc generation) | 5 | 12 |

ปรับค่าใน progress.json ถ้าต้องการ — default คือ Balanced.

---

### 2. Save Checkpoint (ทำหลังจบทุก task)

หลังจากทำแต่ละ task เสร็จ ให้เขียน `memory/progress.json`:

```json
{
  "workflow": "dev-starter",
  "status": "in_progress",
  "gate": 4,
  "autopilot_mode": true,
  "autopilot_sprint": 2,
  "autopilot_total_sprints": 4,
  "autopilot_total_tasks": 32,
  "autopilot_tasks_done": 11,
  "current_task": "Sprint 2 — Task 3: Auth middleware",
  "completed_tasks": ["Sprint 1 — Task 1", "Sprint 1 — Task 2"],
  "next_task": "Sprint 2 — Task 4: JWT validation",
  "files_modified": ["src/middleware/auth.ts"],
  "tasks_this_session": 3,
  "files_read_this_session": 7,
  "last_checkpoint": "2026-03-21T14:30:00",
  "notes": "Autopilot active. Sprint 2/4. Resume silently."
}
```

**Valid `status` values:**

| Status | Meaning |
|--------|---------|
| `in_progress` | Actively working — resume immediately |
| `paused_limit` | Voluntarily paused at 90% limit — resume after reset |
| `interrupted` | Crashed mid-task — resume from last checkpoint |
| `completed` | Workflow finished — do nothing |
| `waiting_approval` | Stopped at a gate — wait for user "approve" |

**กฏสำคัญ:**
- เขียน checkpoint **ทุกครั้ง** ที่ task เสร็จ — อย่ารอ
- `status` ต้องเป็น `"in_progress"` ตลอดที่ยังทำไม่เสร็จ
- เมื่อ workflow เสร็จสมบูรณ์ เปลี่ยน `status` เป็น `"completed"`

### 3. Resume from Checkpoint (ทำเมื่อ Cron fires หรือ user กลับมา)

เมื่อ resume:

```
📂 Resuming from checkpoint:
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Workflow:    [dev-starter / dev-change / ...]
Gate/Phase:  [N]
Last done:   [task name]
Next:        [task name]
Checkpoint:  [timestamp]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ขั้นตอน:
1. อ่าน `memory/progress.json`
2. ตรวจสอบ `status`:
   - `paused_limit` →
     - ถ้า `autopilot_mode: true` → **silent resume**: reset counters silently, ไม่แจ้ง user, ทำต่อทันที
     - ถ้า `autopilot_mode: false` หรือไม่มี → **reset counters**: ตั้ง `tasks_this_session: 0` และ `files_read_this_session: 0` แล้ว resume พร้อมแจ้ง user
   - `in_progress` / `interrupted` →
     - ถ้า `autopilot_mode: true` → resume ทันทีโดยไม่แจ้ง user (silent)
     - ถ้า `autopilot_mode: false` หรือไม่มี → resume ทันทีพร้อมแสดง resume prompt ปกติ
   - `waiting_approval` → แสดง gate และรอ user approve (เสมอ — ไม่ข้ามแม้ autopilot)
   - `completed` → ไม่ทำอะไร
3. อ่าน workflow file จาก `~/.claude/sdlc/`
4. อ่านไฟล์ที่เกี่ยวข้องจาก disk (ไม่ใช่จาก chat history)
5. ประกาศว่ากำลัง resume อะไร
6. ทำ `next_task` ต่อ
7. **อย่าข้าม gate approval** — ถ้า task สุดท้ายของ gate เสร็จแล้ว ต้องรอ user approve ก่อน

---

## Cleanup — เมื่อ Workflow เสร็จ

เมื่อ workflow ทั้งหมดเสร็จสมบูรณ์:

1. Update `memory/progress.json`:
```json
{
  "workflow": "dev-starter",
  "status": "completed",
  "completed_at": "2026-03-21T18:00:00",
  "total_tasks": 15,
  "notes": "All 5 gates completed. Project deployed."
}
```

2. ลบ Cron job ที่ตั้งไว้ (ใช้ CronDelete)

3. แจ้ง user:
```
✅ Workflow เสร็จสมบูรณ์ — auto-resume ถูกปิดแล้ว
```

---

## Edge Cases

| สถานการณ์ | วิธีจัดการ |
|-----------|----------|
| `tasks_this_session` ถึง threshold | จบ task ปัจจุบัน → save `paused_limit` → หยุด → Cron resume + reset counters (silent ถ้า autopilot) |
| ติด rate limit กลางการเขียนไฟล์ | Cron resume จะเช็คว่าไฟล์เขียนครบมั้ย ถ้าไม่ครบให้เขียนใหม่ |
| User กลับมาก่อน Cron fires | User พิมพ์ "ทำต่อ" → อ่าน checkpoint → resume ปกติ |
| Checkpoint file ไม่มี | ไม่ทำอะไร — ไม่มีงานค้าง |
| อยู่ตรง gate approval | Resume แล้วรอ user approve — ไม่ข้ามเด็ดขาด |
| Session ใหม่ (session เก่าตาย) | User เปิด claude ใหม่ → พิมพ์ "ทำต่อ" → อ่าน checkpoint → resume |
| Cron fires แต่ยังติด rate limit | Cron จะ fire อีกรอบใน 10 นาที — ลองใหม่อัตโนมัติ |
| `paused_limit` แต่ limit ยังไม่ reset | Cron fire → ยังติด limit → Cron fire ใหม่ใน 10 นาที (auto-retry) |

---

## สำหรับ Workflow ที่ต้องใช้ Protocol นี้

ทุก workflow ใน `sdlc/` ที่มีหลาย task ต้อง:

1. **ตอนเริ่ม** — อ่าน `dev-checkpoint.md` แล้วตั้ง Cron
2. **ระหว่างทำ** — save checkpoint หลังจบทุก task
3. **ตอนจบ** — cleanup (update status + ลบ Cron)

Workflow ที่ **ต้องใช้**:
- `dev-starter.md` — ยาวมาก (5 gates, หลายสิบ tasks)
- `dev-change.md` — หลาย phases
- `dev-audit.md` — หลาย categories
- `dev-sprint.md` — หลาย tasks

Workflow ที่ **ไม่จำเป็น** (สั้น, จบเร็ว):
- `dev-env.md`
- `dev-secrets.md`
- `dev-dod.md`
