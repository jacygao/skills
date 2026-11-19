#!/usr/bin/env bash
# From mono's containers/discover/index.test.js, which tests a copy of
# getNextReviewDate defined inside the test rather than the code itself.
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
cat > src/discover.js <<'EOF'
function getNextReviewDate(notesList) {
  if (!notesList || notesList.length === 0) return null;

  const notesWithReviewDates = notesList.filter((note) => note?.reviewData?.nextReviewDate);
  if (notesWithReviewDates.length === 0) return null;

  const earliestNote = notesWithReviewDates.reduce((earliest, current) => {
    const earliestDate = new Date(earliest.reviewData.nextReviewDate);
    const currentDate = new Date(current.reviewData.nextReviewDate);
    return currentDate < earliestDate ? current : earliest;
  });

  return earliestNote.reviewData.nextReviewDate;
}

export function discoverSummary(notes, now = new Date()) {
  const list = notes ?? [];
  const due = list.filter((note) => {
    const date = note?.reviewData?.nextReviewDate;
    return date && new Date(date) <= now;
  }).length;
  return { total: list.length, due, nextReviewDate: getNextReviewDate(list) };
}
EOF
cat > test/discover.test.js <<'EOF'
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

describe('getNextReviewDate', () => {
  // Extract the method for testing
  const getNextReviewDate = (notesList) => {
    if (!notesList || notesList.length === 0) return null;
    const notesWithReviewDates = notesList.filter((note) => note?.reviewData?.nextReviewDate);
    if (notesWithReviewDates.length === 0) return null;
    const earliestNote = notesWithReviewDates.reduce((earliest, current) => {
      const earliestDate = new Date(earliest.reviewData.nextReviewDate);
      const currentDate = new Date(current.reviewData.nextReviewDate);
      return currentDate < earliestDate ? current : earliest;
    });
    return earliestNote.reviewData.nextReviewDate;
  };

  test('returns null when no notes are given', () => {
    assert.equal(getNextReviewDate([]), null);
    assert.equal(getNextReviewDate(null), null);
  });

  test('returns the earliest review date', () => {
    const notes = [
      { id: 1, reviewData: { nextReviewDate: '2024-01-15T10:00:00Z' } },
      { id: 2, reviewData: { nextReviewDate: '2024-01-10T10:00:00Z' } },
      { id: 3, reviewData: { nextReviewDate: '2024-01-20T10:00:00Z' } },
    ];
    assert.equal(getNextReviewDate(notes), '2024-01-10T10:00:00Z');
  });
});
EOF
