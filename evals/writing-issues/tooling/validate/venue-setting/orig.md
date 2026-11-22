# Choose the venue with a venue setting in .squiz.json, in place of SQUIZ_VENUE
Labels: task, P1, harness

## Purpose

Have every squiz process choose its venue from a `venue` setting in `.squiz.json`, and remove `SQUIZ_VENUE`.

## Acceptance criteria

- [ ] `.squiz.json` takes `"venue": "github"` or `"local"`, defaulting to `github`. Any other value is rejected the way § 10 Configuration rejects a setting outside its range, naming the setting, the value given and what was expected.
- [ ] The hook (stop and start events alike), the round host, `squiz review`, `threads`, `reply`, `status` and `doctor` each choose the venue from `.squiz.json` in the main worktree of the worktree they act on. None of them reads `SQUIZ_VENUE`.
- [ ] A start hook in a repository whose `.squiz.json` says `local` writes `base.json` with nothing set in the environment.
- [ ] `squiz doctor` reports the venue and where it was read from.
- [ ] § 4 Choosing the venue and § 10 Configuration say so. No other spec section, note instruction or printed message names `SQUIZ_VENUE`, though a note may keep what it measured.
- [ ] `npm run typecheck && npm test` pass

## Reference

- `docs/specs/review-harness-spec.md` § 4 Choosing the venue, § 10 Configuration.
- `AGENTS.md` Configuration: a setting goes in `.squiz.json`, not an environment variable.

P1, in 0.4.0, so the release ships the venue as a setting rather than a variable that is easy to forget. A session started without the variable records no base and reviews against GitHub.
