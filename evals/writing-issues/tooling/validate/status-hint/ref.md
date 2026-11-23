# `squiz review` suggests a nonexistent `squiz status 41`
Labels: bug, P2, harness

## What happens

`squiz review` can tell the user to run `squiz status 41`, but `squiz status` takes no number. It ignores the 41 and lists every review.

## What should happen

The hint, and the example of it under § 7 `squiz review`, name `squiz status` with no number, as § 7 `squiz status` defines the command.

## Reproduce

```
$ squiz status 41    # lists the same reviews as `squiz status`
```

## Cause

`src/review/review.ts:18` puts the review's number into the hint, as the example under § 7 `squiz review` does.

## Reference

- `docs/specs/review-harness-spec.md` § 7 `squiz review` and § 7 `squiz status`
- Found while checking the contradictions in #908 against the code
