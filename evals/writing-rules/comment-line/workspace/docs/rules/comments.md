---
description: "Writing or changing a code comment."
---

# Comments

Default to no comment. The code and its names say what it does.

- **Keep a comment only if removing it makes something ambiguous or
  dangerous.** No comments that restate a name, a type or the line below, and
  none on boilerplate: getters, wiring, config.
- **When one is needed, say why, not what,** in one line.
- **Update or delete the comment above code you change.** A comment that
  outlived its code still reads as true.
- **No `// TODO`.** File an issue instead.
- **Don't point outside the file:** no issue numbers, spec names or URLs. They
  move and the comment doesn't.
- **Tests:** the test name says what it checks. Comment only a fixture whose
  shape isn't obvious.

## How to write one

- State the one fact the code cannot show. Leave out what the code does and
  any consequence a reader can work out from the fact.
- One short sentence, with a subject and a verb. Not a fragment that only
  makes sense beside the line below it.

Bad:

```ts
// serverEtag too, or a pulled copy with a new ETag is ignored and the
// next push assumes a stale one.
```

Good:

```ts
// A pull can change only the ETag.
```
