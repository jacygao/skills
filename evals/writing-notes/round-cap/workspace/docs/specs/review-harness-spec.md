# Squiz review harness

Version 0.3.0

## 3. The loop

A round runs when the coding agent's session stops. It reviews the pull request,
posts each finding as a review thread, and hands the open threads back to the
coding agent.

The round cap, `rounds` in `.squiz.json`, is the number of rounds an episode may
run. A round that leaves threads open blocks the stop, so the coding agent works
them, unless it is the episode's last round under the cap. A cap of R therefore
blocks at most R−1 times. A blocked stop exits 2; every other stop exits 0.

## 5. Verdicts

Each round rules on every thread already on the pull request: `fixed`,
`withdrawn` or `open`. A thread ruled `fixed` or `withdrawn` is resolved. A
thread ruled `open` is unresolved, including one an earlier round had resolved.

## 8. Failures

A round that fails exits 0 and writes one line on stderr, beginning `squiz: `,
naming what failed. It never blocks the stop.

| Failure | stderr |
|---|---|
| The reviewer is not installed | `squiz: the reviewer could not run: <reason>` |
| GitHub is unreachable | `squiz: no review ran: <reason>` |
| `.squiz.json` cannot be read or a setting is out of range (§ 10) | `squiz: no review ran: <path>: <reason>` |
| The reviewer exceeds the review budget | `squiz: the reviewer was killed at its <n>-second bound, and the round recorded <what it kept>` |
