# Try a dropped download again in the Copilot CLI installs, which curl's own --retry skips

## Intent

- In the senior check, turborepo's reference fix got no grade: the verifier's Copilot CLI download from npm failed with `curl: (92) HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2)`. curl's `--retry` does not retry a dropped stream, so the install failed at the first one.
- Part of #282, the check that found it.

## What changed

- Each download these installs make is now tried up to 5 times on any failure, pausing 5, 10, 15 and 20 seconds between tries, with curl's own `--retry 5` still on each try. After the 5th, the install fails with curl's exit code, as it did before.
- The downloads: Copilot CLI from npm, for the Copilot agents and for the judge, whose Copilot CLI the senior validation agent also runs; hve-core's archive, which had no retry before; and squiz's Node and squiz archives.

## What did not change

- Claude Code's install is Harbor's own bootstrap script, and still does not retry.

## Risks

- Low: a download that keeps failing now takes longer to fail. A failure curl does not retry, such as a 404 or a dropped stream, ends after 5 attempts and 50 seconds of pauses. One curl retries itself, a timeout or a 408, 429 or 5xx, is tried 6 times by each curl, so up to 30 attempts and about three and a half minutes of waiting, where it was 6 attempts and about 30 seconds before.

## Verification

```
uv run pytest
```

- New tests give the Copilot CLI install a stand-in curl that exits 92, as the real one did. The install succeeds after 2 such failures, and fails with exit 92 after the 5th try. Both tests failed before the change.
