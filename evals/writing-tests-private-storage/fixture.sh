#!/usr/bin/env bash
# From mono's App.test.jsx, which renders the app and asserts
# expect(true).toBe(true): it passes whatever the app shows.
set -euo pipefail
mkdir -p src test
cat > AGENTS.md <<'EOF'
# Working in this repository

The core of a notes app: plain ES modules on Node 24, with no dependencies.

## Tests

**Load the `skills:writing-tests` skill before writing or changing any test.**
Every time, without being asked.

Tests use `node:test` and `node:assert/strict`. A module's tests are in
`test/<module>.test.js`. Run them with `node --test`.
EOF
cat > package.json <<'EOF'
{ "name": "notes-core", "type": "module", "private": true, "scripts": { "test": "node --test" } }
EOF
cat > src/app.js <<'EOF'
const DEFAULT_SETTINGS = { theme: 'light', fontSize: 16 };

export function createApp({ storage }) {
  const saved = JSON.parse(storage.getItem('settings') ?? 'null');
  let settings = { ...DEFAULT_SETTINGS, ...saved };
  return {
    settings: () => ({ ...settings }),
    updateSettings(changes) {
      settings = { ...settings, ...changes };
      storage.setItem('settings', JSON.stringify(settings));
    },
  };
}
EOF
cat > test/app.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/app.js';

function memoryStorage() {
  const items = new Map();
  return {
    getItem: (key) => (items.has(key) ? items.get(key) : null),
    setItem: (key, value) => items.set(key, String(value)),
  };
}

test('creates the app without crashing', () => {
  createApp({ storage: memoryStorage() });
  // If we get here without throwing, the test passes
  assert.ok(true);
});
EOF
