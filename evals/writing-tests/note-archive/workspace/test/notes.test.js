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
