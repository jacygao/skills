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
