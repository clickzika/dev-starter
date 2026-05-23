#!/usr/bin/env node
/**
 * PreToolUse Hook: Block edits on protected branches
 * Intercepts Edit and Write tool calls. If the current git branch is a
 * protected branch (develop, main, master, uat, dev), outputs a block
 * decision so Claude cannot write files until a work branch is created.
 * Passes through silently when on a work branch or outside a git repo.
 */

'use strict';

const { execFileSync } = require('child_process');

const PROTECTED_BRANCHES = new Set(['develop', 'main', 'master', 'uat', 'dev']);

const MAX_STDIN = 64 * 1024;

function getCurrentBranch() {
  try {
    execFileSync('git', ['rev-parse', '--git-dir'], { stdio: 'pipe' });
    return execFileSync('git', ['branch', '--show-current'], { stdio: 'pipe' })
      .toString()
      .trim();
  } catch {
    return null;
  }
}

let data = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => {
  if (data.length < MAX_STDIN) data += chunk.substring(0, MAX_STDIN - data.length);
});

process.stdin.on('end', () => {
  const branch = getCurrentBranch();

  if (branch && PROTECTED_BRANCHES.has(branch)) {
    const workType = branch === 'develop' ? 'feature/[slug] or fix/[slug]' : 'feature/[slug]';
    const decision = {
      decision: 'block',
      reason: [
        `⛔ Branch Guard: you are on "${branch}" (protected branch).`,
        `Create a work branch first:`,
        `  git checkout -b ${workType}`,
        `Then confirm with: git branch --show-current`,
        `Only edit files after switching to a work branch.`,
      ].join('\n'),
    };
    process.stdout.write(JSON.stringify(decision));
    process.exit(0);
  }

  process.stdout.write(data);
  process.exit(0);
});
