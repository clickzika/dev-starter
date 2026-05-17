#!/usr/bin/env node
/**
 * Stop Hook: Batch format and typecheck all edited files this response
 * Cross-platform (Windows, macOS, Linux)
 *
 * Reads accumulator from post-edit-accumulator.js, groups files by project root,
 * detects formatter (prettier/biome/black/ruff/gofmt), runs one pass per root.
 * Clears accumulator after reading so repeated Stop calls don't double-process.
 *
 * Supported stacks:
 *   JS/TS  → prettier or biome, then tsc --noEmit if tsconfig present
 *   Python → ruff format, then black (whichever found)
 *   Go     → gofmt -w
 *   Rust   → rustfmt
 */

'use strict';

const crypto = require('crypto');
const { execFileSync, spawnSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const TIMEOUT_MS = 30_000;
const MAX_STDIN = 1024 * 1024;

function getAccumFile() {
  const raw = process.env.CLAUDE_SESSION_ID ||
    crypto.createHash('sha1').update(process.cwd()).digest('hex').slice(0, 12);
  const sessionId = raw.replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 64);
  return path.join(os.tmpdir(), `devstarter-edited-${sessionId}.txt`);
}

function readAccum() {
  const f = getAccumFile();
  try {
    const raw = fs.readFileSync(f, 'utf8');
    fs.unlinkSync(f);
    return [...new Set(raw.split('\n').map(l => l.trim()).filter(Boolean))];
  } catch { return []; }
}

function fileExists(p) { try { return fs.statSync(p).isFile(); } catch { return false; } }
function dirExists(p) { try { return fs.statSync(p).isDirectory(); } catch { return false; } }

function findProjectRoot(filePath) {
  let dir = path.dirname(filePath);
  for (let i = 0; i < 10; i++) {
    if (fileExists(path.join(dir, 'package.json')) ||
        fileExists(path.join(dir, 'go.mod')) ||
        fileExists(path.join(dir, 'Cargo.toml')) ||
        fileExists(path.join(dir, 'pyproject.toml')) ||
        fileExists(path.join(dir, '.git'))) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return path.dirname(filePath);
}

function runSafe(bin, args, cwd) {
  try {
    const result = spawnSync(bin, args, { cwd, stdio: 'pipe', timeout: TIMEOUT_MS, shell: process.platform === 'win32' });
    return result.status === 0;
  } catch { return false; }
}

function formatJsTs(root, files) {
  const existingFiles = files.filter(f => fileExists(f));
  if (existingFiles.length === 0) return;

  // Biome takes priority if biome.json present
  if (fileExists(path.join(root, 'biome.json'))) {
    runSafe('biome', ['check', '--write', ...existingFiles], root) ||
    runSafe('npx', ['biome', 'check', '--write', ...existingFiles], root);
    return;
  }

  // Prettier
  if (fileExists(path.join(root, '.prettierrc')) ||
      fileExists(path.join(root, '.prettierrc.js')) ||
      fileExists(path.join(root, '.prettierrc.json')) ||
      fileExists(path.join(root, 'prettier.config.js'))) {
    runSafe('prettier', ['--write', ...existingFiles], root) ||
    runSafe('npx', ['prettier', '--write', ...existingFiles], root);
  }

  // TypeScript check
  if (fileExists(path.join(root, 'tsconfig.json'))) {
    const tsFiles = existingFiles.filter(f => /\.(ts|tsx)$/.test(f));
    if (tsFiles.length > 0) {
      runSafe('tsc', ['--noEmit', '--skipLibCheck'], root) ||
      runSafe('npx', ['tsc', '--noEmit', '--skipLibCheck'], root);
    }
  }
}

function formatPython(root, files) {
  const existingFiles = files.filter(f => fileExists(f));
  if (existingFiles.length === 0) return;
  // ruff preferred
  if (!runSafe('ruff', ['format', ...existingFiles], root)) {
    runSafe('black', existingFiles, root);
  }
}

function formatGo(root, files) {
  const existingFiles = files.filter(f => fileExists(f));
  if (existingFiles.length === 0) return;
  runSafe('gofmt', ['-w', ...existingFiles], root);
}

function formatRust(root, files) {
  const existingFiles = files.filter(f => fileExists(f));
  if (existingFiles.length === 0) return;
  runSafe('rustfmt', existingFiles, root);
}

function main() {
  const files = readAccum();
  if (files.length === 0) { process.exit(0); }

  // Group by project root + language
  const byRoot = new Map();
  for (const f of files) {
    const root = findProjectRoot(f);
    if (!byRoot.has(root)) byRoot.set(root, { jsTs: [], py: [], go: [], rs: [] });
    const group = byRoot.get(root);
    if (/\.(ts|tsx|js|jsx)$/.test(f)) group.jsTs.push(f);
    else if (/\.py$/.test(f)) group.py.push(f);
    else if (/\.go$/.test(f)) group.go.push(f);
    else if (/\.rs$/.test(f)) group.rs.push(f);
  }

  for (const [root, groups] of byRoot) {
    if (groups.jsTs.length) formatJsTs(root, groups.jsTs);
    if (groups.py.length) formatPython(root, groups.py);
    if (groups.go.length) formatGo(root, groups.go);
    if (groups.rs.length) formatRust(root, groups.rs);
  }

  process.exit(0);
}

main();
