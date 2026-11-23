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
