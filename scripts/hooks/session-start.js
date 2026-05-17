#!/usr/bin/env node
/**
 * SessionStart Hook - Load DevStarter memory context on new session
 * Cross-platform (Windows, macOS, Linux)
 *
 * Reads memory/progress.json and MEMORY.md from the current project,
 * injects a brief context block so Claude knows where work left off.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const MAX_OUTPUT_CHARS = 4000;

function readFile(filePath) {
  try { return fs.readFileSync(filePath, 'utf8'); } catch { return null; }
}

function getProjectDir() {
  return process.env.CLAUDE_PROJECT_DIR || process.cwd();
}

function getClaudeDir() {
  const home = os.homedir();
  return path.join(home, '.claude');
}

function loadProgress(projectDir) {
  const progressPath = path.join(projectDir, 'memory', 'progress.json');
  const raw = readFile(progressPath);
  if (!raw) return null;
  try { return JSON.parse(raw); } catch { return null; }
}

function loadMemoryIndex(projectDir) {
  const memPath = path.join(projectDir, 'memory', 'MEMORY.md');
  return readFile(memPath);
}

function loadGlobalMemoryIndex() {
  const claudeDir = getClaudeDir();
  // Find memory dir for this project
  const projectsDir = path.join(claudeDir, 'projects');
  if (!fs.existsSync(projectsDir)) return null;
  // Try to find MEMORY.md in any project subdirectory matching cwd
  const cwd = process.cwd();
  const cwdKey = cwd.replace(/[:\\\/]/g, '-').replace(/^-/, '');
  const candidates = [
    path.join(projectsDir, cwdKey, 'memory', 'MEMORY.md'),
  ];
  for (const c of candidates) {
    const content = readFile(c);
    if (content) return content;
  }
  return null;
}

function main() {
  const projectDir = getProjectDir();
  const parts = [];

  // Load progress.json
  const progress = loadProgress(projectDir);
  if (progress) {
    parts.push('## DevStarter Session Resume');
    if (progress.workflow) parts.push(`Workflow: ${progress.workflow}`);
    if (progress.status) parts.push(`Status: ${progress.status}`);
    if (progress.last_completed) parts.push(`Last done: ${progress.last_completed}`);
    if (progress.next_step) parts.push(`Next: ${progress.next_step}`);
    if (progress.branch) parts.push(`Branch: ${progress.branch}`);
    parts.push('');
  }

  // Load MEMORY.md index
  const memIndex = loadMemoryIndex(projectDir) || loadGlobalMemoryIndex();
  if (memIndex) {
    const truncated = memIndex.length > 2000 ? memIndex.slice(0, 2000) + '\n...(truncated)' : memIndex;
    parts.push('## Project Memory Index');
    parts.push(truncated);
    parts.push('');
  }

  if (parts.length === 0) {
    process.exit(0);
  }

  const output = parts.join('\n');
  const final = output.length > MAX_OUTPUT_CHARS ? output.slice(0, MAX_OUTPUT_CHARS) + '\n...' : output;

  process.stdout.write(final + '\n');
  process.exit(0);
}

main();
