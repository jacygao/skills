# A round on a loaded machine posts none of its findings
Labels: bug, P0, harness

## What happens

A round whose reviewer finished can post none of its findings on a loaded machine. Its `stopped.json` says the state file's lock was taken only after the deadline had passed.

## What should happen

Either the wait for the state lock is raised to 10 seconds, or the time spent running `ps` no longer counts against it. The owner can pick whichever is simpler.

## Evidence

SWE-drill's rebench of squiz 0.3.2 hit it on 7 of 324 trials. Not reproduced here.

## Cause

`holdingLock` in `src/loop/state-update.ts` runs `ps` inside the 2-second wait that `keepCost` in `src/loop/round.ts` gives it.
