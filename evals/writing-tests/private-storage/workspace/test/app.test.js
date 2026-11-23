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
