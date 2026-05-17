#!/usr/bin/env node
/**
 * PostToolUse Hook: Accumulate edited file paths for batch Stop processing
 * Cross-platform (Windows, macOS, Linux)
 *
 * Records JS/TS/Go/Python file paths to a session-scoped temp file.
 * stop-format-typecheck.js reads this at Stop time for batch formatting.
 * Matcher: Edit|Write
 */

'use strict';

const crypto = require('crypto');
const fs = require('fs');
const os = require('os');
const path = require('path');

const MAX_STDIN = 1024 * 1024;

const TRACKABLE_EXT = /\.(ts|tsx|js|jsx|go|py|rb|php|rs|kt|swift|dart|cs|java)$/;

function getAccumFile() {
  const raw = process.env.CLAUDE_SESSION_ID ||
    crypto.createHash('sha1').update(process.cwd()).digest('hex').slice(0, 12);
  const sessionId = raw.replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 64);
  return path.join(os.tmpdir(), `devstarter-edited-${sessionId}.txt`);
}

function appendPath(filePath) {
  if (filePath && TRACKABLE_EXT.test(filePath)) {
    try { fs.appendFileSync(getAccumFile(), filePath + '\n', 'utf8'); } catch {}
  }
}

let data = '';
process.stdin.setEncoding('utf8');

process.stdin.on('data', chunk => {
  if (data.length < MAX_STDIN) {
    data += chunk.substring(0, MAX_STDIN - data.length);
  }
});

process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    appendPath(input.tool_input?.file_path);
    const edits = input.tool_input?.edits;
    if (Array.isArray(edits)) {
      for (const edit of edits) appendPath(edit?.file_path);
    }
  } catch {}

  process.stdout.write(data);
  process.exit(0);
});
