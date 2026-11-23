# Squiz review harness

Version 0.3.0

## 3. The loop

`squiz review` runs a round in the round host. It reviews the pull request,
posts each finding as a review thread, and hands the open threads back to the
coding agent. The session-stop hook starts no round and always exits 0.

The round cap, `rounds` in `.squiz.json`, is the number of rounds an episode may
run. `squiz review` exits 2 where a round leaves threads open, unless it is the
episode's last round under the cap, and 0 otherwise. A cap of R therefore exits 2
at most R−1 times.

## 5. Verdicts

Each round rules on every thread already on the pull request: `fixed`,
`withdrawn` or `open`. A thread ruled `fixed` or `withdrawn` is resolved. A
thread ruled `open` is unresolved, including one an earlier round had resolved.

## 8. Failures

A round that fails makes `squiz review` exit 1, writes one line on stderr,
beginning `squiz: `, naming what failed, and posts a comment on the pull request
saying the round failed and why.

| Failure | stderr |
|---|---|
| The reviewer is not installed | `squiz: the reviewer could not run: <reason>` |
| GitHub is unreachable | `squiz: no review ran: <reason>` |
| `.squiz.json` cannot be read or a setting is out of range (§ 10: `timeout` is 60 to 3600 seconds, default 900) | `squiz: no review ran: <path>: <reason>` |
| The reviewer exceeds the review budget | `squiz: the reviewer was killed at its <n>-second bound, and the round recorded <what it kept>` |
