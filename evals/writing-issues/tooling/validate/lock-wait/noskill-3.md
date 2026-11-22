# A round on a loaded machine posts nothing: state.json's lock "was taken only after the deadline had passed"

Labels: bug, P0, harness

## What happened

In SWE-drill's rebench of squiz 0.3.2, 7 of 324 trials failed the same way. Every other trial closed. In each of the 7, a round's reviewer finished but nothing it found was posted. The trial's `stopped.json` reads:

```
{"stopped": "round failed", "reason": "nothing the reviewer found was posted: /<repo>/.squiz/local/state.json could not be written: its lock was taken only after the deadline had passed"}
```

A user whose machine is busy gets no review. That's why this is P0.

## Setup

- squiz 0.3.2, local venue
- Reviewer: Claude Sonnet 5.5. Fixer: GitHub Copilot CLI.
- Three runs, each with 20 trials going at once on a 20-vCPU Azure VM
- Failing tasks: `kestra-io__kestra-16450`, `ubugeeei-prod__vize-1265`, `floci-io__floci-1142`, `sipeed__picoclaw-2928`, `pydantic__pydantic-ai-5580`, `apache__pulsar-25953`, `cloudflare__vinext-1837`

It has not been reproduced outside those runs.

## Evidence

Each trial's `.squiz/local/` and `host.log` are in SWE-drill's blob storage. The account is `sussae63383b`, container `runs`, under:

- `results/rebench/squiz-gpt-6.1-sol/20261115T114014Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114339Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114642Z-1/`

**Nobody has read these `host.log` files yet.** So we don't know whether another writer held `state.lock` when the round tried to record its spend.

## Where the message comes from

`keepCost` in `src/loop/round.ts` records the round's spend through `updateState` with `until: deadlineIn(STATE_LOCK_WAIT_MS)`, which is 2 s. If that write fails, the round ends with "nothing the reviewer found was posted". That matches the spec: a round records its spend before posting anything (§ 3, *The state file*; § 8).

The exact reason string comes from `holdingLock` in `src/loop/state-update.ts`. It is returned when `takeLock` **succeeds** but `until.passed()` is already true. The lock is then released unused. So in these 7 rounds the lock was taken in the end. The 2 s ran out before or while it was being taken.

The same 2 s also covers more than waiting for another holder:

- `ownIdentity` runs `ps` for this process's own start time before the first attempt. It is skipped only when `options.self` is supplied.
- Each `takeLock` attempt runs `ps` once for each holder named in the lock.
- Between attempts there are `pause` calls.

Two explanations fit what we know, and `host.log` should tell them apart:

1. **Contention.** Another writer held the lock for most of the 2 s, and the round got it just too late.
2. **No contention.** Nobody else held the lock. On a machine running 20 trials, the `ps` calls and the lock-taking itself took up the 2 s.

If it's (2), the comment above `STATE_LOCK_WAIT_MS` doesn't hold under load. It says a wait longer than 2 s "is a holder that has stopped". A deadline meant to bound waiting on another writer would then be failing rounds that had no other writer.

## To do

- [ ] Read the 7 trials' `host.log` and `.squiz/local/` around the failing round. Did another process hold `state.lock`, and for how long? How long did the `ps` calls take?
- [ ] Reproduce it, for example with many concurrent episodes or with `ps` slowed down.
- [ ] Fix it so a round on a loaded machine records its spend and posts. The spec's lock rules (§ 3) must still hold: never break a live holder's lock, and keep a deadline of its own.
