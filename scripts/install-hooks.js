#!/usr/bin/env node
/**
 * install-hooks.js — Merge DevStarter hooks into ~/.claude/settings.json
 * Usage: node install-hooks.js <hooks_dir> <settings_file> <hooks_template>
 * Cross-platform (Windows, macOS, Linux)
 */

'use strict';

const fs = require('fs');
const path = require('path');

function main() {
  const [,, hooksDir, settingsPath, templatePath] = process.argv;

  if (!hooksDir || !settingsPath || !templatePath) {
    console.error('Usage: node install-hooks.js <hooks_dir> <settings_file> <hooks_template>');
    process.exit(1);
  }

  // Normalize hooks dir path (forward slashes for consistency in JSON)
  const normalizedHooksDir = hooksDir.replace(/\\/g, '/');

  // Read template and substitute path placeholder
  const template = fs.readFileSync(templatePath, 'utf8')
    .replace(/\$\{DEVSTARTER_HOOKS_DIR\}/g, normalizedHooksDir);

  const hooksConfig = JSON.parse(template);

  // Read existing settings or start fresh
  let settings = {};
  if (fs.existsSync(settingsPath)) {
    try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); }
    catch { settings = {}; }
  }

  // Merge hooks — append DevStarter hooks, avoid duplicates by command string
  settings.hooks = settings.hooks || {};

  for (const [event, newMatchers] of Object.entries(hooksConfig.hooks)) {
    if (!settings.hooks[event]) {
      settings.hooks[event] = newMatchers;
      continue;
    }

    // Collect existing command strings to avoid duplicates
    const existingCmds = new Set();
    for (const matcher of settings.hooks[event]) {
      for (const h of (matcher.hooks || [])) {
        if (h.command) existingCmds.add(h.command);
      }
    }

    for (const matcher of newMatchers) {
      const filteredHooks = (matcher.hooks || []).filter(h => !existingCmds.has(h.command));
      if (filteredHooks.length > 0) {
        settings.hooks[event].push({ ...matcher, hooks: filteredHooks });
      }
    }
  }

  // Write back
  fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n', 'utf8');
  console.log('✅ DevStarter hooks installed to', settingsPath);
}

main();
