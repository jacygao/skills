#!/usr/bin/env bash
# squiz's AGENTS.md, cut to what filing an issue needs, and the spec and code
# the issue is about, as they stood when it was filed. squiz's own issue
# templates are left out, so the skill's are used.
set -euo pipefail
cat > AGENTS.md <<'EOF_FIXTURE'
# Working in this repository

Squiz is a review harness: it runs an AI reviewer on a coding agent's pull
request, posts the findings as review threads, and hands them back to the agent.

## Specs

`docs/specs/review-harness-spec.md` is the specification. This checkout holds
only the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

## Configuration

**A user's choice is a setting in `.squiz.json`, not an environment variable.**
Every squiz process reads `.squiz.json` from the repository's main worktree, so
the hook, the round host and the commands agree without the choice having to be
passed down to each of them. A variable is set per run, is easy to forget, and
does not reach a process its run did not start. § 10 Configuration of the
specification lists the settings and how each is checked.

## Checks

```bash
npm run typecheck && npm test
```

## Issues

Each issue carries one kind label, `bug` or `task`, one priority label and one
or more area labels:

- **`P0`** blocks the release it is in: a user on the default setup gets no
  review, or a wrong one, in ordinary use.
- **`P1`** is wanted in the next release or the one after: real users, or squiz's
  own CI, will hit it.
- **`P2`** waits in `Backlog` until a release's theme pulls it in.
- **`harness`**: squiz's own loop, round host, review, summary and commands.
- **`claude-code`**: Claude Code as the coding agent.
- **`copilot`**: the GitHub Copilot CLI, as the coding agent or the reviewer.

**Use the `writing-issues` skill before writing an issue.** Every time,
without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
issue to `issues/new.md` instead: the title on the first line as `# <title>`,
then a line `Labels: <label>, <label>, ...`, a blank line, and the body exactly
as it would be passed to `gh issue create --body`.
EOF_FIXTURE
mkdir -p docs/specs src/loop issues
cat > docs/specs/review-harness-spec.md <<'EOF_FIXTURE'
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
EOF_FIXTURE
cat > src/loop/round.ts <<'EOF_FIXTURE'
import { deadlineIn } from "../reviewers/deadline.ts";
import { updateState } from "./state-update.ts";

function keepCost(episode: Episode, state: EpisodeState, review: Review, measured: Measured): Step<EpisodeState> {
  if (withSpend(state, review, measured) === null) return { step: state };

  const written = updateState(
    episode,
    (current) => withSpend(current, review, measured) ?? current,
    // Its own wait rather than what the reserve has left. A reserve the stop has
    // nearly spent would leave too little to take the lock.
    { until: deadlineIn(STATE_LOCK_WAIT_MS) },
  );
  if (written.outcome === "failed") {
    return {
      ended: {
        outcome: "failed",
        failure: "harness",
        reason: `nothing the reviewer found was posted: ${written.reason}`,
      },
    };
  }
  return { step: written.state };
}

// Another writer holds the state lock for one read and one write. A wait longer
// than this is a holder that has stopped, and waiting on would spend the posting
// reserve.
const STATE_LOCK_WAIT_MS = 2_000;
EOF_FIXTURE
cat > src/loop/state-update.ts <<'EOF_FIXTURE'
/**
 * A lock held by a live process, or by one `ps` cannot tell running or gone, is
 * waited on until `options.until` passes, and the call then fails naming the
 * holder. A lock naming a process that has gone is taken over.
 */
export function holdingLock<T>(directory: string, name: string, act: () => T, options: UpdateOptions): Locked<T> {
  const { until } = options;
  const notHeld = (reason: string): Locked<T> => ({ outcome: "failed", reason });
  const boundMs = (): number => Math.max(1, until.remaining());

  // Runs `ps` for this process's own start time.
  const self = options.self ?? ownIdentity(boundMs(), options.identify);
  if ("reason" in self) return notHeld(self.reason);

  for (;;) {
    // Runs `ps` once for each holder it finds named in the lock.
    const taking = takeLock(directory, name, { boundMs: boundMs(), self, presence: stillRunning });
    if (taking.outcome === "taken") {
      if (!until.passed()) return { outcome: "held", value: runHolding(act, taking.lock) };
      // The caller's time for this write has gone, so the lock goes back unused.
      taking.lock.release();
      return notHeld("its lock was taken only after the deadline had passed");
    }
    if (until.passed()) return notHeld(whyNotTaken(taking));
    pause(Math.min(until.remaining(), PAUSE_MS));
  }
}
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
