# Round posts nothing on a loaded machine: state.lock "taken only after the deadline had passed"

Labels: bug, P0, harness

## What happened

SWE-drill's rebench of squiz 0.3.2 hit this failure in 7 of 324 trials. There were three runs, each with 20 trials going at once on a 20-vCPU Azure VM, using the local venue, a Claude Sonnet 5.5 reviewer and a Copilot fixer. Every other trial closed. In each of the 7, a round whose reviewer finished posted nothing, and `stopped.json` reads:

```
{"stopped": "round failed", "reason": "nothing the reviewer found was posted: /<repo>/.squiz/local/state.json could not be written: its lock was taken only after the deadline had passed"}
```

Tasks: `kestra-io__kestra-16450`, `ubugeeei-prod__vize-1265`, `floci-io__floci-1142`, `sipeed__picoclaw-2928`, `pydantic__pydantic-ai-5580`, `apache__pulsar-25953`, `cloudflare__vinext-1837`.

This is P0 because a user on a loaded machine gets no review. The reviewer's work is thrown away and the round fails as a `harness` failure.

It has not been reproduced outside the rebench.

## Evidence

Each trial's `.squiz/local/` and `host.log` are in SWE-drill's blob storage, container `sussae63383b/runs`, under:

- `results/rebench/squiz-gpt-6.1-sol/20261115T114014Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114339Z-1/`
- `results/rebench/squiz-gpt-6.1-sol/20261115T114642Z-1/`

Nobody has read those `host.log` files yet. **It is not yet known whether another writer held `state.lock` when these rounds tried to write.**

## Where it comes from

`keepCost` in `src/loop/round.ts` records the round's spend before anything is posted (spec § 3, "A round records what it spent before it posts anything"). It calls `updateState` with `until: deadlineIn(STATE_LOCK_WAIT_MS)`, and `STATE_LOCK_WAIT_MS` is `2_000`. If that write fails, the round ends with "nothing the reviewer found was posted" (§ 8).

The reason string comes from `holdingLock` in `src/loop/state-update.ts`:

```ts
if (taking.outcome === "taken") {
  if (!until.passed()) return { outcome: "held", value: runHolding(act, taking.lock) };
  taking.lock.release();
  return notHeld("its lock was taken only after the deadline had passed");
}
```

So in all 7 trials the lock **was taken**. The write was dropped because the 2 s deadline had passed by the time the take returned. A wait that ran out on a live holder would have given a different message: the `whyNotTaken` reason, which names the holder.

The 2 s deadline is not spent only on waiting for another holder. That budget also has to cover these, all before the check:

- `ownIdentity(...)`, which runs `ps` for this process's own start time when `options.self` isn't given
- `takeLock(...)`, which runs `ps` once for each holder named in the lock
- any `pause` between attempts

On a machine running 20 agent trials on 20 vCPUs, the `ps` calls alone could plausibly use up 2 s with no other writer involved. Spec § 3 describes the deadline as a bound on waiting for a lock "held by a live process". It doesn't say it also has to cover the cost of identifying ourselves and the holder.

The two explanations, both open until `host.log` is read:

1. **Contention:** another writer held the lock, and the take that finally succeeded landed just after the deadline.
2. **No contention:** `ps` (or process start-up under load) used up the budget and the lock was free all along.

## Next steps

- Read the 7 trials' `host.log` and `.squiz/local/` to find out whether another process held `state.lock` around the failed write, and how long the `ps` calls took.
- Whichever explanation holds, a lock taken successfully shouldn't be given back unused just because the deadline passed while taking it. The update itself is one read and one write. Decide whether the deadline should bound only the wait on a live holder (as § 3 reads), and whether a lock already in hand should be used.
- Add a test where identifying the process or the holder is slow (stub `identify` / `presence`) and the lock is otherwise free. The round should still record its spend and post.
