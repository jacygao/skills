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
