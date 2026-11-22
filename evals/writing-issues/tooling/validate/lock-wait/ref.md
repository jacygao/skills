# A round on a loaded machine posts none of its findings
Labels: bug, P0, harness

## What happens

A round whose reviewer finished can post none of its findings on a loaded machine. Its `stopped.json` reads:

```
{"stopped": "round failed", "reason": "nothing the reviewer found was posted: /<repo>/.squiz/local/state.json could not be written: its lock was taken only after the deadline had passed"}
```

## What should happen

A round that takes the state lock late, with no other writer holding it, still records its spend and posts its findings. A lock a live writer holds past the wait still fails the write, as § 3 The state file says.

## Evidence

Not reproduced here. SWE-drill's rebench of squiz 0.3.2 hit it on 7 of 324 trials, across three runs of 20 trials at once on a 20-vCPU Azure VM, with the local venue, a Claude Sonnet 5.5 reviewer and a Copilot fixer. Every other trial closed. The trials' `.squiz/local/` and `host.log` are in SWE-drill's blob storage, `sussae63383b/runs` under `results/rebench/squiz-gpt-6.1-sol/20261115T11{4014,4339,4642}Z-1/`.

## Cause

- `keepCost` in `src/loop/round.ts` writes the round's spend with a 2-second deadline, `STATE_LOCK_WAIT_MS`.
- `holdingLock` in `src/loop/state-update.ts` spends that deadline on `ps` as well: once for its own identity, and once for each holder. A lock it takes after the deadline is released unused.
- Whether the 7 trials also had another writer is not known, because their `host.log` files have not been read.

## Reference

- § 3 The state file, on `state.lock`
- § 8, "The round's spend cannot be written"
