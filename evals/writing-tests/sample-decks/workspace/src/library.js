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
