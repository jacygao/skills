---
settles: "§ 8: what a failed round's stop exits and where it names the failure"
issue: 201
recorded: 2026-09-27
versions: { claude-code: 2.1.270, pi: 0.85.1, gh: 2.97.0, node: 24.15.0 }
recheck-when: the hook's exit-code decisions change, pi upgrades, or § 8's rows change
---

# A failed round exits 0 and names its failure on stderr

## Intent

- Whether a round that fails ever blocks the coding agent's stop
- Where a failed round says what failed

## Decisions

- **Treat a failed round as a stop that went through.** The hook exits 0 on
  every failure, so a failed round never blocks the coding agent.
- **Read what failed from the one `squiz: ` line on stderr.** A failed round
  writes exactly one, and a round that blocks writes none, so the two never
  appear together.

## Needs your input

Nothing

## Reference

- `squiz: the reviewer could not run: the reviewer pi could not be started: spawn pi ENOENT`
- `squiz: no review ran: <worktree>/.squiz.json: "timeout" is 700, but it must be a whole number of seconds from 1 to 480`

## Limits

- Print mode only, on one machine.
