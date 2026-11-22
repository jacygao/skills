# Rounds on a loaded machine post nothing: the state lock is taken after its 2 s wait has passed, then given back unused

Labels: bug, P0, harness

## What happened

SWE-drill's rebench of squiz 0.3.2 ran 324 trials in three runs. Each run had 20 trials going at once on a 20-vCPU Azure VM, with the local venue, a Claude Sonnet 5.5 reviewer and a Copilot fixer. Seven trials failed and every other trial closed. In each of the seven, a round's reviewer finished but the round posted nothing, and `stopped.json` reads:

```
{"stopped": "round failed", "reason": "nothing the reviewer found was posted: /<repo>/.squiz/local/state.json could not be written: its lock was taken only after the deadline had passed"}
```

The failing tasks:

- kestra-io__kestra-16450
- ubugeeei-prod__vize-1265
- floci-io__floci-1142
- sipeed__picoclaw-2928
- pydantic__pydantic-ai-5580
- apache__pulsar-25953
- cloudflare__vinext-1837

We have not reproduced it outside SWE-drill.

This is P0 because a user on a loaded machine gets no review. The reviewer's work for that round is thrown away, and the episode stops.

## Evidence

Each trial's `.squiz/local/` and `host.log` are in SWE-drill's blob storage, in storage account `sussae63383b`, container `runs`, under:

- `results/rebench/squiz-gpt-6.1-sol/20261115T114014Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114339Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114642Z-1/`

No one has read these `host.log` files yet, so we don't know whether another writer held the lock while the write waited.

## What the code says

`keepCost` (`src/loop/round.ts`) records the round's spend through `updateState` before it posts anything (spec § 3, "A round records what it spent before it posts anything"). It gives that write a deadline of its own, `deadlineIn(STATE_LOCK_WAIT_MS)`, which is 2 000 ms. If the write fails, the round ends with `failure: "harness"` and posts nothing (§ 8).

In `holdingLock` (`src/loop/state-update.ts`), this message is returned only on one path: `takeLock` returned `"taken"`, but `until.passed()` was already true, so the lock is released unused:

```ts
if (taking.outcome === "taken") {
  if (!until.passed()) return { outcome: "held", value: runHolding(act, taking.lock) };
  taking.lock.release();
  return notHeld("its lock was taken only after the deadline had passed");
}
```

So in all seven trials, the attempt that got the lock started before the deadline and finished after it. A live holder still holding the lock when the deadline came would have produced the other reason, `whyNotTaken(taking)`, which names the holder. That reason did not appear.

The 2 s budget covers more than waiting on another writer:

- `ownIdentity` runs `ps` once for this process's own start time.
- Each `takeLock` attempt runs `ps` once for each holder named in the lock.
- Each attempt also does its filesystem work on the lock.

With 20 trials, each running a reviewer and a fixer, on 20 vCPUs, process spawns can be slow. These steps may use up most of the 2 s by themselves. The comment on `STATE_LOCK_WAIT_MS` reasons only about how long a holder keeps the lock ("A wait longer than this is a holder that has stopped"), not about this overhead.

## Open questions

The `host.log` files should settle these:

1. Did another writer hold `state.lock` while the write waited, and for how long? If none did, all 2 s went to `ps` and lock overhead.
2. How long did each `ps` run take in the failing rounds?
3. How many `takeLock` attempts were made before the one that succeeded?

## What a fix needs to keep

- The spend is recorded before anything is posted, and a round whose spend is not recorded posts nothing (§ 3).
- The lock is never broken while its holder is live, or while the holder cannot be told running or gone (§ 3).
- The wait does not spend the posting reserve (the comment on `STATE_LOCK_WAIT_MS`).

Within those limits, two options to weigh:

- Keep a lock that was taken in time to use it, rather than giving it back because the clock ran out while it was being taken.
- Leave `ps` and lock overhead out of the time budgeted for another writer.

Which option fits depends on what the logs show for question 1.
