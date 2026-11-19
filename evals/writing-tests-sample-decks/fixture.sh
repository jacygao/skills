#!/usr/bin/env bash
# From mono's SampleDecksModal.data.test.js, which pins the sample decks'
# count ("has exactly 3 decks, each with at least 6 notes").
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
cat > src/library.js <<'EOF'
export function createLibrary() {
  const decks = new Map();
  const notes = new Map();
  let next = 1;
  return {
    addDeck(fields) {
      const deck = { id: `d${next++}`, ...fields };
      decks.set(deck.id, deck);
      return deck;
    },
    addNote(deckId, fields) {
      if (!decks.has(deckId)) throw new Error(`no deck "${deckId}"`);
      const note = { id: `n${next++}`, deckId, ...fields };
      notes.set(note.id, note);
      return note;
    },
    decks: () => [...decks.values()],
    notesIn: (deckId) => [...notes.values()].filter((n) => n.deckId === deckId),
  };
}
EOF
cat > src/samples.js <<'EOF'
export const SAMPLE_DECKS = [
  {
    id: 'french-basics',
    title: 'French basics',
    notes: [
      { front: 'Hello', back: 'Bonjour' },
      { front: 'Thank you', back: 'Merci' },
      { front: 'Please', back: "S'il vous plaît" },
      { front: 'Goodbye', back: 'Au revoir' },
      { front: 'Yes', back: 'Oui' },
      { front: 'No', back: 'Non' },
    ],
  },
  {
    id: 'world-capitals',
    title: 'World capitals',
    notes: [
      { front: 'Capital of Kenya?', back: 'Nairobi' },
      { front: 'Capital of Peru?', back: 'Lima' },
      { front: 'Capital of Norway?', back: 'Oslo' },
      { front: 'Capital of Vietnam?', back: 'Hanoi' },
      { front: 'Capital of Ghana?', back: 'Accra' },
      { front: 'Capital of Chile?', back: 'Santiago' },
    ],
  },
  {
    id: 'cell-biology',
    title: 'Cell biology',
    notes: [
      { front: 'Powerhouse of the cell?', back: 'Mitochondrion' },
      { front: 'Where is DNA kept?', back: 'The nucleus' },
      { front: 'What makes proteins?', back: 'Ribosomes' },
      { front: 'What surrounds the cell?', back: 'The cell membrane' },
      { front: 'Where does photosynthesis happen?', back: 'Chloroplasts' },
      { front: 'What packages proteins?', back: 'The Golgi apparatus' },
    ],
  },
];

export function startSample(library, deckId) {
  const sample = SAMPLE_DECKS.find((d) => d.id === deckId);
  if (!sample) throw new Error(`no sample deck "${deckId}"`);
  const deck = library.addDeck({ title: sample.title, sample: true });
  for (const note of sample.notes) library.addNote(deck.id, { ...note });
  return deck;
}
EOF
cat > test/samples.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createLibrary } from '../src/library.js';
import { SAMPLE_DECKS, startSample } from '../src/samples.js';

test('has exactly 3 decks, each with at least 6 notes', () => {
  assert.equal(SAMPLE_DECKS.length, 3);
  for (const deck of SAMPLE_DECKS) assert.ok(deck.notes.length >= 6);
});

test('starting a sample puts its deck and its notes in the library', () => {
  const library = createLibrary();
  const deck = startSample(library, 'world-capitals');
  assert.deepEqual(library.decks().map((d) => d.title), ['World capitals']);
  const kenya = library.notesIn(deck.id).find((n) => n.front === 'Capital of Kenya?');
  assert.equal(kenya.back, 'Nairobi');
});

test('starting an unknown sample is an error', () => {
  assert.throws(() => startSample(createLibrary(), 'no-such-deck'), /no sample deck/);
});
EOF
