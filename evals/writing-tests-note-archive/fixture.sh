#!/usr/bin/env bash
# From mono's agent.test.ts, which asserts the arguments of mocked insert and
# patch calls although an in-memory database exists to read the note back from.
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
cat > src/db.js <<'EOF'
export function createDb() {
  const docs = new Map();
  return {
    insert(doc) {
      docs.set(doc.id, { ...doc });
      return { ...doc };
    },
    get(id) {
      const doc = docs.get(id);
      return doc ? { ...doc } : null;
    },
    patch(id, fields) {
      const doc = docs.get(id);
      if (!doc) throw new Error(`no document "${id}"`);
      docs.set(id, { ...doc, ...fields });
    },
    find(predicate = () => true) {
      return [...docs.values()].filter(predicate).map((d) => ({ ...d }));
    },
  };
}
EOF
cat > src/notes.js <<'EOF'
import { randomUUID } from 'node:crypto';

export function createNote(db, { title, body = '' }, now = new Date()) {
  return db.insert({ id: randomUUID(), title, body, createdAt: now.toISOString() });
}

export function renameNote(db, id, title) {
  db.patch(id, { title });
}

export function getNote(db, id) {
  return db.get(id);
}

export function listNotes(db) {
  return db.find().sort((a, b) => a.createdAt.localeCompare(b.createdAt));
}
EOF
cat > test/notes.test.js <<'EOF'
import { test, mock } from 'node:test';
import assert from 'node:assert/strict';
import { createNote, renameNote } from '../src/notes.js';

test('createNote inserts the note', () => {
  const db = { insert: mock.fn((doc) => doc) };
  createNote(db, { title: 'Groceries' });
  assert.equal(db.insert.mock.calls.length, 1);
  assert.equal(db.insert.mock.calls[0].arguments[0].title, 'Groceries');
});

test('renameNote patches the title', () => {
  const db = { patch: mock.fn() };
  renameNote(db, 'n1', 'Shopping');
  assert.deepEqual(db.patch.mock.calls[0].arguments, ['n1', { title: 'Shopping' }]);
});
EOF
