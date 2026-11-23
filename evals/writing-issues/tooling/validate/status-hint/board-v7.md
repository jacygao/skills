# `squiz status <number>` ignores the number
Labels: bug, P2, harness

## What happens

`squiz review` can tell the user to run `squiz status 41`, but `squiz status` ignores the number and lists every review in the worktree.

## What should happen

`squiz status 41` lists only the review of pull request 41. `squiz status` with no number still lists every review.

## Reproduce

```
squiz status 41    # prints the same as `squiz status`
```

## Cause

- `src/review/review.ts:18` puts the number in the message.
- `src/cli.ts:12-22` reads no argument for `status`.

## Reference

- `docs/specs/review-harness-spec.md` § 7 `squiz review` and § 7 `squiz status`
- Found while checking the contradictions in #908 against the code
