const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const CCUSAGE = 'C:\\Users\\natthaphatw\\AppData\\Roaming\\npm\\ccusage.cmd';

let raw = '';
try { raw = fs.readFileSync(0, 'utf8'); } catch {}

let data = {};
try { data = JSON.parse(raw); } catch {}

const model = (data.model && data.model.display_name) || 'Claude';
const cwd = (data.workspace && data.workspace.current_dir) || data.cwd || process.cwd();

let branch = '';
try {
  branch = execSync('git rev-parse --abbrev-ref HEAD', {
    cwd,
    stdio: ['ignore', 'pipe', 'ignore'],
  }).toString().trim();
} catch {}

const cyan = '\x1b[36m';
const yellow = '\x1b[33m';
const green = '\x1b[32m';
const magenta = '\x1b[35m';
const red = '\x1b[31m';
const dim = '\x1b[2m';
const reset = '\x1b[0m';

const sep = `${dim} | ${reset}`;
const parts = [`${cyan}${model}${reset}`, `${yellow}${cwd}${reset}`];
if (branch) parts.push(`${green}${branch}${reset}`);
let ctxPct = null;
const cw = data.context_window;
if (cw && typeof cw.used_percentage === 'number') {
  ctxPct = cw.used_percentage;
} else {
  const t = readContextTokens(data.transcript_path);
  if (t !== null) ctxPct = (t / 1000000) * 100;
}
if (ctxPct !== null) {
  const color = ctxPct >= 90 ? red : ctxPct >= 70 ? yellow : magenta;
  parts.push(`${color}ctx ${makeBar(ctxPct)} ${ctxPct.toFixed(1)}%${reset}`);
}

// Current session = 5-hour rate-limit window (native payload; Claude.ai Pro/Max only).
const fiveHour = (data.rate_limits && data.rate_limits.five_hour) || null;
const sessionPct =
  fiveHour && typeof fiveHour.used_percentage === 'number'
    ? fiveHour.used_percentage
    : null;
if (sessionPct !== null) {
  const color = sessionPct >= 90 ? red : sessionPct >= 70 ? yellow : green;
  parts.push(`${color}ses ${makeBar(sessionPct)} ${sessionPct.toFixed(0)}%${reset}`);
}

const blue = '\x1b[34m';
const block = getBlockInfo();
if (block && typeof block.totalTokens === 'number') {
  parts.push(`${blue}${formatTokens(block.totalTokens)} used${reset}`);
}

// Reset countdown: prefer the native rate-limit reset, else the ccusage block end.
let resetMs = null;
if (fiveHour && typeof fiveHour.resets_at === 'number') resetMs = fiveHour.resets_at * 1000;
else if (block && block.endTime) resetMs = new Date(block.endTime).getTime();
if (resetMs) {
  const left = formatRemaining(resetMs);
  if (left) parts.push(`${dim}reset ${left}${reset}`);
}

process.stdout.write(parts.join(sep));

function readContextTokens(transcriptPath) {
  if (!transcriptPath) return null;
  let lines;
  try {
    lines = fs.readFileSync(transcriptPath, 'utf8').split('\n');
  } catch {
    return null;
  }
  for (let i = lines.length - 1; i >= 0; i--) {
    const line = lines[i].trim();
    if (!line) continue;
    let entry;
    try { entry = JSON.parse(line); } catch { continue; }
    if (entry.type !== 'assistant' || entry.isSidechain) continue;
    const u = entry.message && entry.message.usage;
    if (!u) continue;
    return (u.input_tokens || 0) +
           (u.cache_creation_input_tokens || 0) +
           (u.cache_read_input_tokens || 0);
  }
  return null;
}

// Active 5-hour usage block via ccusage. Cached 45s so we don't pay
// ~0.85s per render; the reset countdown is recomputed live from endTime.
function getBlockInfo() {
  const cacheFile = path.join(os.tmpdir(), 'cc-statusline-block.json');
  try {
    const st = fs.statSync(cacheFile);
    if (Date.now() - st.mtimeMs < 45000) {
      return JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
    }
  } catch {}
  try {
    const out = execSync(`"${CCUSAGE}" blocks --active --json --offline`, {
      timeout: 5000,
      stdio: ['ignore', 'pipe', 'ignore'],
    }).toString();
    const blocks = (JSON.parse(out).blocks) || [];
    const b = blocks.find((x) => x.isActive) || blocks[0];
    if (!b) return null;
    const info = { totalTokens: b.totalTokens, endTime: b.endTime };
    try { fs.writeFileSync(cacheFile, JSON.stringify(info)); } catch {}
    return info;
  } catch {
    return null;
  }
}

function makeBar(pct) {
  const width = 20;
  const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)));
  return '█'.repeat(filled) + '░'.repeat(width - filled);
}

function formatRemaining(when) {
  const ms = new Date(when).getTime() - Date.now();
  if (isNaN(ms)) return null;
  if (ms <= 0) return '0m';
  const totalMin = Math.floor(ms / 60000);
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  return h > 0 ? `${h}h${m}m` : `${m}m`;
}

function formatTokens(n) {
  if (n >= 1e6) return (n / 1e6).toFixed(1) + 'M';
  if (n >= 1e3) return (n / 1e3).toFixed(0) + 'k';
  return String(n);
}
