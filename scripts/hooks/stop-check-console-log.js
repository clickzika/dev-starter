#!/usr/bin/env node
/**
 * Stop Hook: Warn about debug logging statements left in modified files
 * Cross-platform (Windows, macOS, Linux)
 *
 * Checks git-modified JS/TS files for console.log and py/go files
 * for common debug print patterns. Excludes test files, scripts/, config files.
 * Warning only — does not block (exits 0 always).
 */

'use strict';

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const MAX_STDIN = 1024 * 1024;

const EXCLUDED_PATTERNS = [
  /\.test\.[jt]sx?$/,
  /\.spec\.[jt]sx?$/,
  /\.config\.[jt]s$/,
  /[/\\]scripts[/\\]/,
  /[/\\]__tests__[/\\]/,
  /[/\\]__mocks__[/\\]/,
];

const DEBUG_PATTERNS = {
  js: /console\.log\s*\(/,
  py: /^\s*print\s*\(/m,
  go: /fmt\.Println\s*\(|fmt\.Printf\s*\(/,
};

function isGitRepo() {
  try { execFileSync('git', ['rev-parse', '--git-dir'], { stdio: 'pipe' }); return true; }
  catch { return false; }
}

function getGitModifiedFiles() {
  try {
    const out = execFileSync('git', ['diff', '--name-only', 'HEAD'], { stdio: 'pipe' }).toString();
    const staged = execFileSync('git', ['diff', '--name-only', '--cached'], { stdio: 'pipe' }).toString();
    const all = [...new Set([...out.split('\n'), ...staged.split('\n')])].map(f => f.trim()).filter(Boolean);
    return all.map(f => path.resolve(f));
  } catch { return []; }
}

function readFile(p) {
  try { return fs.readFileSync(p, 'utf8'); } catch { return null; }
}

function check(files) {
  const warnings = [];

  for (const file of files) {
    if (EXCLUDED_PATTERNS.some(p => p.test(file))) continue;
    if (!fs.existsSync(file)) continue;

    const content = readFile(file);
    if (!content) continue;

    let pattern;
    if (/\.[jt]sx?$/.test(file)) pattern = DEBUG_PATTERNS.js;
    else if (/\.py$/.test(file)) pattern = DEBUG_PATTERNS.py;
    else if (/\.go$/.test(file)) pattern = DEBUG_PATTERNS.go;
    else continue;

    if (pattern.test(content)) {
      warnings.push(path.relative(process.cwd(), file));
    }
  }

  return warnings;
}

let data = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => {
  if (data.length < MAX_STDIN) data += chunk.substring(0, MAX_STDIN - data.length);
});

process.stdin.on('end', () => {
  try {
    if (isGitRepo()) {
      const files = getGitModifiedFiles();
      const warnings = check(files);
      if (warnings.length > 0) {
        process.stderr.write('[Hook] WARNING: Debug statements found in:\n');
        for (const w of warnings) process.stderr.write(`  ${w}\n`);
        process.stderr.write('[Hook] Remove before committing.\n');
      }
    }
  } catch {}

  process.stdout.write(data);
  process.exit(0);
});
