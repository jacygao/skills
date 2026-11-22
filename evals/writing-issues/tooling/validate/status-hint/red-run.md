# `squiz status 41`, which `squiz review` suggests, ignores the 41
Labels: bug, P2, harness

## What happens

When the round host's start cannot be told, `squiz review` exits 1 and points at
a command that takes a pull request number
(`src/review/review.ts:18`):

```
squiz: `squiz status 41` shows whether one takes it later, and .squiz/41/host.log holds what the host wrote
```

`squiz status` reads no arguments (`src/cli.ts:12-22` never looks at
`argv.slice(1)`), so `squiz status 41` prints the same table as `squiz status`:
every recorded review, not just PR #41's. The reader has to find #41 among the
others.

The spec contradicts itself in the same way: § 7 `squiz review` prints
`squiz status 41`, while § 7 `squiz status` and the command table define
`squiz status` with no arguments.

## What should happen

The command that `squiz review` suggests does what the message says: it shows
whether a host has taken PR #41's review. Either `squiz status <number>` lists
only that pull request's states, or the message names a command that exists as
written. Whichever is chosen, § 7 of `docs/specs/review-harness-spec.md` says the
same thing.

## Reproduce

In a worktree with reviews recorded for more than one pull request:

```
squiz status 41
```

The output lists rows for every pull request, for example `#38` next to `#41`.

## Why P2

The suggested command still shows PR #41's review, among the others, so nobody
loses information. The extra arguments are just ignored.

## Found while

Checking the contradictions in #908 against the code.
