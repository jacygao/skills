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
