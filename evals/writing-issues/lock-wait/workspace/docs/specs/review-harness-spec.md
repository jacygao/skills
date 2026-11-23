# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 3. The loop

### The state file

Each episode's directory holds:

- `state.json`, the state file.
- `host.log`, the round host's output.
- `state.lock`, held while the state file is changed.
- `stopped.json` while a headless episode has stopped short of its close.

**Every change to the state file is made under `state.lock`.** A writer takes the
lock, reads the file, changes it, writes it whole, and releases the lock. The
lock is held for one update and never across a review. It names its holder's pid
and start time, and a lock whose holder has gone is taken over. A writer that
finds the lock held by a live process, or by one that cannot be told running or
gone, waits up to a deadline of its own and never breaks the lock. A wait that
runs out is a state file that cannot be written (§ 8). Readers take no lock.

**A round records what it spent before it posts anything.** The spend is what the
round cap and the token bound count, so a round whose spend is not recorded posts
nothing: a round that posted its findings and recorded nothing is one the next
round repeats comment for comment.

## 8. Failure modes

| Failure | What happens | Where it is reported |
|---|---|---|
| The round's spend cannot be written | Exit 1, and nothing the reviewer found is posted. The failure comment and stderr say nothing was posted, and give the underlying error. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
