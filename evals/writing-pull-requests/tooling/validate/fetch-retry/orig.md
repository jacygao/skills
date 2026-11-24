# Try a dropped download again in every install, which curl's own --retry skips

## Intent

- In the senior check, turborepo's reference fix got no grade: the verifier's Copilot CLI download from npm failed with `curl: (92) HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2)`. curl's `--retry 5` retries timeouts and some HTTP errors, not a dropped stream, so it never tried again.
- Part of #282

## What changed

- `swe_drill.copilot.fetch()` is a shell function, `fetch <file> <url>`. It runs curl as before and tries again on any failure, 5 tries in all, waiting 5, 10, 15 and 20 seconds between them. After the last try it fails with curl's own exit code.
- Every download an install makes goes through it: Copilot CLI from npm, used by the agents and by the verifier's validation and judge; hve-core's archive; and squiz's Node and squiz archives.

## Risks

- Low: a download that is truly gone now takes about 50 seconds longer to fail.

## Verification

```
uv run pytest
```

The new tests use a stand-in curl that fails with exit 92, as the real one did. The install succeeds after 2 such failures, and fails after the 5th. Before the change, both failed with the same `NetworkConnectionError … exit 92` the senior check showed.
