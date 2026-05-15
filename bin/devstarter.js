#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync, spawnSync } = require('child_process');

const PKG_DIR = path.join(__dirname, '..');
const CLAUDE_DIR = path.join(os.homedir(), '.claude');

const BOLD = '\x1b[1m';
const CYAN = '\x1b[36m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const RESET = '\x1b[0m';

const DIRS_TO_COPY = ['agents', 'skills', 'sdlc', 'templates'];
const FILES_TO_COPY = ['devstarter-menu.md', 'USER.md', 'setup.sh', 'install.sh'];

function log(msg) { process.stdout.write(msg + '\n'); }
function ok(msg) { log(`${GREEN}✅ ${msg}${RESET}`); }
function warn(msg) { log(`${YELLOW}⚠️  ${msg}${RESET}`); }

function copyDir(src, dest) {
  if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(s, d);
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

function main() {
  const cmd = process.argv[2];

  if (cmd !== 'init') {
    log(`${BOLD}DevStarter${RESET} — Claude Code workflow system`);
    log('');
    log('Usage:');
    log('  npx devstarter init   Install to ~/.claude/');
    log('');
    log('More info: https://github.com/clickzika/dev-starter');
    process.exit(0);
  }

  log('');
  log(`${BOLD}╔══════════════════════════════════════════════╗${RESET}`);
  log(`${BOLD}║   DevStarter — npm Installer                 ║${RESET}`);
  log(`${BOLD}╚══════════════════════════════════════════════╝${RESET}`);
  log('');

  if (!fs.existsSync(CLAUDE_DIR)) {
    fs.mkdirSync(CLAUDE_DIR, { recursive: true });
    ok(`Created ${CLAUDE_DIR}`);
  }

  for (const dir of DIRS_TO_COPY) {
    const src = path.join(PKG_DIR, dir);
    const dest = path.join(CLAUDE_DIR, dir);
    if (!fs.existsSync(src)) { warn(`Skipping ${dir}/ (not found in package)`); continue; }
    copyDir(src, dest);
    ok(`Installed ${dir}/`);
  }

  for (const file of FILES_TO_COPY) {
    const src = path.join(PKG_DIR, file);
    const dest = path.join(CLAUDE_DIR, file);
    if (!fs.existsSync(src)) { warn(`Skipping ${file} (not found in package)`); continue; }
    fs.copyFileSync(src, dest);
    ok(`Installed ${file}`);
  }

  log('');
  log(`${CYAN}All files installed to ${CLAUDE_DIR}${RESET}`);
  log('');

  // Attempt to run setup.sh
  const setupSh = path.join(CLAUDE_DIR, 'setup.sh');
  if (fs.existsSync(setupSh)) {
    const isWin = process.platform === 'win32';
    const shell = isWin ? 'bash' : 'bash';
    log('Running setup wizard...');
    log('');
    const result = spawnSync(shell, [setupSh], { stdio: 'inherit' });
    if (result.status !== 0) {
      warn('Setup wizard exited with errors. Run manually:');
      warn(`  bash ~/.claude/setup.sh`);
    }
  } else {
    log('Start Claude Code and run:');
    log(`  ${CYAN}/devstarter-menu${RESET}`);
  }

  log('');
}

main();
