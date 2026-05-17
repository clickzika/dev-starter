#!/usr/bin/env node
/**
 * PreCompact Hook - Save state marker before context compaction
 * Cross-platform (Windows, macOS, Linux)
 *
 * Logs compaction event to memory/compaction-log.txt so you can see
 * when context was summarized relative to the session timeline.
 */

'use strict';

const fs = require('fs');
const path = require('path');

function getProjectDir() {
  return process.env.CLAUDE_PROJECT_DIR || process.cwd();
}

function ensureDir(dir) {
  try { fs.mkdirSync(dir, { recursive: true }); } catch {}
}

function appendFile(filePath, content) {
  try { fs.appendFileSync(filePath, content, 'utf8'); } catch {}
}

function getTimestamp() {
  return new Date().toISOString().replace('T', ' ').slice(0, 19);
}

function main() {
  const projectDir = getProjectDir();
  const memDir = path.join(projectDir, 'memory');
  ensureDir(memDir);

  const logPath = path.join(memDir, 'compaction-log.txt');
  const timestamp = getTimestamp();
  appendFile(logPath, `[${timestamp}] Context compaction triggered\n`);

  process.stderr.write('[PreCompact] State saved before compaction\n');
  process.exit(0);
}

main();
