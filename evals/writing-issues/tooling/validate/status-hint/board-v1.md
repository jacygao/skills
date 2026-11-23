# `squiz review` suggests `squiz status <number>`, which ignores the number
Labels: bug, P2, harness

## What happens

`squiz review` tells the user to run `squiz status 41` to see whether a review starts, but `squiz status` ignores the number and lists every review in the worktree.

The message is printed when `squiz review` stops waiting and cannot tell whether a round host started:

```
squiz: `squiz status 41` shows whether one takes it later
```

## What should happen

The command the message names does what the message says.

## Reproduce

```
squiz status 41    # prints the same as `squiz status`
```

## Cause

- `src/review/review.ts:18` builds the message with the review's number.
- `src/cli.ts:12-22` runs `status` without reading any argument.

## Options

1. **Drop the number from the message.** The smallest change. The user picks their review out of the full list.
2. **Make `squiz status <number>` list that pull request alone.** The message stays as it is. `squiz status` takes an argument, and § 7 `squiz status` has to say so.

The owner chooses, under Decision needed in #908.

## Reference

- `docs/specs/review-harness-spec.md` § 7 `squiz review` and § 7 `squiz status`
- Found while checking the contradictions in #908 against the code

## Priority

P2: `squiz status` still shows the review, among the others.
