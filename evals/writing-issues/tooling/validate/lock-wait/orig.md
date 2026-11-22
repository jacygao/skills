# A round's findings go unposted where the state lock is taken just past its 2-second wait on a loaded machine
Labels: bug, P0, harness

## What happens

On a loaded machine, a round the reviewer finished fails without posting anything. Its `stopped.json` reads:

```
{"stopped": "round failed", "reason": "nothing the reviewer found was posted: /<repo>/.squiz/local/state.json could not be written: its lock was taken only after the deadline had passed"}
```

SWE-drill's rebench of squiz 0.3.2 hit it on 7 of 324 trials, across three runs. Each run had 20 trials going at once on a 20-vCPU Azure VM, with the local venue, a Claude Sonnet 5.5 reviewer and a Copilot fixer. The tasks were kestra-io__kestra-16450, ubugeeei-prod__vize-1265, floci-io__floci-1142, sipeed__picoclaw-2928, pydantic__pydantic-ai-5580, apache__pulsar-25953 and cloudflare__vinext-1837. Every other trial closed.

## What should happen

A slow machine takes the state lock late, and the round still records its spend and posts its findings. A lock held by a process that has stopped still fails the write.

## Where it comes from

- `keepCost` in `src/loop/round.ts` writes the round's spend under `deadlineIn(STATE_LOCK_WAIT_MS)`, which is 2,000 ms.
- `holdingLock` in `src/loop/state-update.ts` runs `ownIdentity`, which is a `ps`, inside that same wait. It runs another `ps` for each holder it finds. A lock it takes once the wait has run out is released unused, and the round fails with the message above.
- So on a machine where `ps` is slow, 2 s can run out with no other writer holding the lock at all. Whether the 7 trials also had a competing writer is not yet known: their `host.log` files have not been read.

## Reproduce

Not reproduced here. The trials' `.squiz/local/` and `host.log` are in SWE-drill's blob storage, `sussae63383b/runs` under `results/rebench/squiz-gpt-6.1-sol/20261115T11{4014,4339,4642}Z-1/`.

## Reference

§ 3 The state file, on the state lock.
