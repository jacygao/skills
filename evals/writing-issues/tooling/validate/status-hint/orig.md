# squiz review tells the user to run `squiz status <number>`, but squiz status ignores the number
Labels: bug, P2, harness

## What happens

When the round host's start cannot be told, `squiz review` prints ``squiz: `squiz status 41` shows whether one takes it later``. `squiz status` ignores every argument and lists every review in the worktree.

## What should happen

The message names a command that does what it says: either `squiz status`, with no number, or a `squiz status <number>` that lists that pull request alone.

## Reproduce

```
squiz status 41    # prints the same as `squiz status`
```

The message is at `src/review/review.ts:284`, and `src/cli.ts:61-71` reads no argument for `status`. Found while checking the contradictions in #908 against the code. It is P2 because the command still shows the review, among the others. Which fix to make is the owner's call, and #908 lists it under Decision needed.

## Reference

`docs/specs/review-harness-spec.md` § 7 `squiz review` (L3374–3384) and § 7 `squiz status`.
