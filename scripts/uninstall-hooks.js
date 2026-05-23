#!/usr/bin/env node
/**
 * uninstall-hooks.js — Remove DevStarter hooks from ~/.claude/settings.json
 * Usage: node uninstall-hooks.js <settings_file>
 * Cross-platform (Windows, macOS, Linux)
 *
 * Identifies DevStarter hooks by command path containing "devstarter-"
 * and removes them. Leaves all other hooks untouched.
 */

'use strict';

const fs = require('fs');

function main() {
  const [,, settingsPath] = process.argv;

  if (!settingsPath) {
    console.error('Usage: node uninstall-hooks.js <settings_file>');
    process.exit(1);
  }

  if (!fs.existsSync(settingsPath)) {
    console.log('No settings.json found — nothing to remove.');
    process.exit(0);
  }

  let settings;
  try {
    settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  } catch {
    console.error('Could not parse settings.json — skipping hook removal.');
    process.exit(0);
  }

  if (!settings.hooks || typeof settings.hooks !== 'object') {
    console.log('No hooks found in settings.json — nothing to remove.');
    process.exit(0);
  }

  let removed = 0;

  for (const [event, matchers] of Object.entries(settings.hooks)) {
    if (!Array.isArray(matchers)) continue;

    const filtered = matchers
      .map(matcher => {
        if (!matcher.hooks || !Array.isArray(matcher.hooks)) return matcher;
        const cleanHooks = matcher.hooks.filter(h => {
          const cmd = h.command || '';
          // DevStarter hooks reference scripts/hooks/ with devstarter- prefix
          const isDevStarter = cmd.includes('scripts/hooks/') &&
            (cmd.includes('session-start') ||
             cmd.includes('pre-compact') ||
             cmd.includes('post-edit-accumulator') ||
             cmd.includes('stop-format-typecheck') ||
             cmd.includes('stop-check-console-log') ||
             cmd.includes('devstarter'));
          if (isDevStarter) removed++;
          return !isDevStarter;
        });
        return cleanHooks.length > 0 ? { ...matcher, hooks: cleanHooks } : null;
      })
      .filter(Boolean);

    if (filtered.length > 0) {
      settings.hooks[event] = filtered;
    } else {
      delete settings.hooks[event];
    }
  }

  if (Object.keys(settings.hooks).length === 0) {
    delete settings.hooks;
  }

  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n', 'utf8');

  if (removed > 0) {
    console.log(`✅ Removed ${removed} DevStarter hook(s) from ${settingsPath}`);
  } else {
    console.log('No DevStarter hooks found in settings.json.');
  }
}

main();
