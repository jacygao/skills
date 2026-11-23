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
