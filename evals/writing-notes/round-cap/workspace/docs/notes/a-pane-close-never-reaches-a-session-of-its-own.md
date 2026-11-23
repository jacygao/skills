---
settles: "§ 3: whether closing the reviewer's pane stops the coding agent's session"
issue: 188
recorded: 2026-09-20
versions: { herdr: 0.9.4, claude-code: 2.1.268 }
recheck-when: herdr upgrades
---

# A pane close never reaches a session of its own

## Intent

- Whether closing the pane a round's reviewer runs in stops the coding agent's session

## Decisions

- **Let a round close its reviewer's pane when it ends.** The coding agent's
  session runs in a pane of its own, and herdr delivers a close only to the
  processes of the pane it closes.

## Needs your input

Nothing

## Reference

- `herdr pane close <id>` sends `SIGHUP` to the pane's process group only.

## Limits

- Seen on macOS only.
