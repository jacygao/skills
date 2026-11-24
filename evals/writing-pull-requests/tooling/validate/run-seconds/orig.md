# Write a timed-out suss.json when Harbor's agent timeout stops run

## Intent

- Harbor 0.22.0 runs the agent phase in `asyncio.wait_for`. When it fires, `SussAgent.run` got a `CancelledError`, captured the patch while the harness was still running in the container, and wrote no `suss.json`.
- Now suss stops the harness inside the sandbox first, then captures the patch, writes a `timed-out` record and raises the cancel again, so Harbor still sees the timeout.

Closes #38

## What changed

- Every harness command now runs under the bash wrapper, whether or not `max_seconds` is set. The wrapper writes the run's process-group id to `<logs>/<command>-<random>.pgid` and deletes that file once the command exits.
- On a cancel, `_start` kills that group through `exec`, within `STOP_SECONDS` (10). `harness.run` then returns a `timed-out` result with `run` `null` and `run_seconds` measured to the cancel, and the `CancelledError` goes back in the result's `cancelled` field.
- `SussAgent.run` captures the patch and writes the record within `CLEANUP_SECONDS` (60), then raises `result.cancelled`. Harbor waits on a cancelled agent with no limit, so a stuck exec would otherwise hang the trial.
- Spec § 3: a trial is `timed-out` at `max_seconds` and when Harbor's agent timeout stops it, and the example's `run_seconds` is `1290.4`.

## Risks

- Low: if the cancel lands after `exec` was sent but before the wrapper has written its group file, nothing gets killed and the harness keeps running while the patch is captured. That window is one exec's latency at the start of `run`.
- Low: if the stop exec fails or times out, suss still writes the record. Nothing marks that the patch may not be final.

## Verification

```
uv run pytest
```

- `test_a_cancelled_run_stops_the_harness_before_the_patch` runs with and without `max_seconds`. It cancels while the fake harness has a backgrounded child due to write to the workspace, and checks that no harness process survives, the late write never lands, and the patch holds the earlier change.
- `test_harbors_agent_timeout_still_sees_the_cancel` wraps `run` in `asyncio.wait_for`, as Harbor does, and expects `TimeoutError`.

## Notes

- A cancel during the instruction upload, or before `run`'s logs directory is made, still writes no record. The patch is captured, as it was before this change.
