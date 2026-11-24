# Write a timed-out suss.json when Harbor's agent timeout stops run

## Intent

- Harbor runs the agent phase under `asyncio.wait_for`. When that timeout fired, suss captured the patch while the harness was still running in the container, and wrote no `suss.json`, so the trial had no record.
- Now suss stops the harness inside the sandbox first, then captures the patch, writes a `timed-out` record, and passes the cancel on, so Harbor still sees the timeout.

Closes #38

## What changed

- `install` and `run` now always run under the in-sandbox wrapper, with or without `max_seconds`, so suss can kill the harness's whole process group at any time, not only at the limit.
- On a cancel, suss kills the harness's process group with one more exec, bounded at 15 seconds. The record is `timed-out`, with `run`'s exit code `null` and `run_seconds` from the start of `run` until that stop returns, since the harness goes on working until the kill lands.
- suss then captures the patch and writes `suss.json`, giving up after 60 seconds, and raises the cancel. Harbor waits on a cancelled agent with no limit, so both bounds keep a stuck exec from hanging the trial.
- Spec § 3: a trial is also `timed-out` when Harbor's agent timeout stops it, and the example's `run_seconds` is a decimal.

## Risks

- Low: a cancelled run's `run_seconds` includes the stop exec, where a finished run's leaves out suss's own commands. A slow stop adds up to 15 seconds.
- Low: if the stop fails or times out, the harness keeps running while the patch is captured, and the record still says `timed-out` with nothing to mark that the patch may not be final.
- Low: on a cancel, an error while capturing the patch or writing `suss.json`, the 60-second bound included, is replaced by the cancel. Harbor sees only its timeout, and the trial has no record.
- Low: a stop that runs before the wrapper has written the group's id kills nothing. The window is at the very start of `run`.

## Verification

```
uv run pytest
```

- New tests cancel `run` mid-run through the local environment, with and without `max_seconds`, while the fake harness has a backgrounded child due to write to the workspace. No harness process survives, the late write never lands, and `suss.json` is a `timed-out` record with the spec's keys.
- Another wraps `run` in `asyncio.wait_for`, as Harbor does, and gets `TimeoutError`.

## Notes

- `docs/notes/docker-exec-timeout-leaves-the-command-running.md` and `_limited`'s docstring still say the wrapper needs only bash and `sleep`; it now also runs `rm`, and the stop runs `cat`.

- A cancel before the harness starts, during the instruction upload or while the logs directory is made, still writes no record, as before.
