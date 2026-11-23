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
