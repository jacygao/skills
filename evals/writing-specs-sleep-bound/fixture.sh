#!/usr/bin/env bash
# squiz's AGENTS.md, cut to what a spec edit needs, and the sections of its
# specification that squiz ddd5e22 changed, as they stood before it.
set -euo pipefail
mkdir -p docs/specs docs/notes
cat > AGENTS.md <<'EOF_FIXTURE'
# Working in this repository

Squiz is a review harness: it runs an AI reviewer on a coding agent's pull
request, posts the findings as review threads, and hands them back to the agent.

## Specs

**Load the `skills:writing-specs` skill before writing or editing anything under
`docs/specs/`.** Every time, without being asked.

`docs/specs/review-harness-spec.md` is the specification. This checkout holds
only the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

**A spec's version number changes once a release.** Leave the version line
alone.

## Notes

**Load the `skills:writing-notes` skill before writing or editing anything under
`docs/notes/`.**

`docs/notes/` holds durable findings: what earlier work established, recorded so
that it is read rather than re-derived.

## Checks

```bash
npm run typecheck && npm test
```
EOF_FIXTURE
cat > docs/specs/review-harness-spec.md <<'EOF_FIXTURE'
# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.30 (draft)

## 7. Failure modes

**Every failure the harness controls ends the command with a status the coding
agent can read.** A run that could not review exits 1. A failure that leaves the
round's outcome standing keeps the outcome's status, 0, 2 or 3, and adds a line on
stderr.

**No failure path is silent.** Every path reaches at least one of six surfaces a
person reads:

- **The failure comment**, which a round that fails posts on the pull request, as
  The failure comment below sets out.
- **`squiz status`**, which shows a failed state's reason, a killed round, and a
  reviewed state's problems, and prints a line on its stderr for a state file it
  cannot read (§ 6).
- **`.squiz/<number>/host.log`**, where the round host writes a line for each
  thing it did, and where its own stderr goes. It is the only surface for what
  the host does outside a round.
- **`squiz review`'s stderr**, one line for each thing that failed, as The
  command's stderr below sets out.
- **The summary's Notes**, which the round that closes the episode writes (§ 5).
- **The hook's stderr**, one line for what a `Stop` or `SubagentStop` firing
  could not do.

**A failure reaches the pull request once the round has found its pull request
and can read the episode's state.** A round that fails after that posts a failure
comment where GitHub can be reached, and the problems of a round that closes the
episode go into the summary's Notes. A failure before that posts nothing, and is read on the local
surfaces alone.

**A round that fails in the round host is recorded failed, with its reason**,
which `squiz status`, `squiz review`'s stderr and `host.log` all carry.

**What ran and answered is reported by its answer.** Where `gh` ran and said what
was wrong, the round reports the status it exited with and the first line it
wrote. A `gh` that could not be run at all is a failure of its own.

**A call whose body `gh` did not read to its end is a failure**, never a call
that did what was asked. Where `gh` exited non-zero, the failure reported is what
`gh` said, and where it exited 0, GitHub not having been reached.

The last column names the surfaces each path reaches.

| Failure | Behaviour | Read on |
|---|---|---|
| The hook's payload cannot be read | Nothing is queued, and the hook exits 0, as it does on every path. | Hook stderr |
| git cannot name the worktree or its branch | Exit 1, and no review runs. A trigger queues nothing. A round that meets it records the state failed and posts no failure comment, because it has found no pull request to post one on. | Hook stderr, `squiz review` stderr, `squiz status`, `host.log` |
| The configuration cannot be read | `squiz review` exits 1 naming the setting it refused, and no review runs. A round host started for the state stops before taking it, and says why. The state stays queued. | `squiz review` stderr, `host.log` |
| The state cannot be queued | The trigger's write of the queued record fails. Nothing is queued and no round host is started, and `squiz review` exits 1. | Hook stderr, `squiz review` stderr |
| The round host cannot be started | The state stays queued with no host to take it, and the next trigger starts one. `squiz review` exits 1. | Hook stderr, `squiz review` stderr |
| The round host's start cannot be told | The process that starts the host failed or answered nothing readable after it may have started the host, or the host's start time could not be read. A live process holding the host lock means the host started, and `squiz review` waits on it. Where no live process holds the lock within 10 seconds of the start, or by the run's deadline where that comes first, `squiz review` exits 1, and stderr names `squiz status` and `.squiz/<number>/host.log`, as § 6 `squiz review` shows. The state stays queued, and the next trigger starts a host for it. | Hook stderr, `squiz review` stderr |
| Whether a round host is running cannot be told | Where a reviewing record names a host that cannot be told running or gone, nothing is recovered, queued or started, and `squiz review` exits 1. `squiz status` shows the state reviewing, with "the round host could not be checked:" and why. A round host that cannot tell whether another holds the lock exits, and the next trigger starts one. | `squiz review` stderr, `squiz status`, `host.log` |
| The command is stopped from outside | The coding agent's tool or a person ends `squiz review` while it waits. The round runs in the round host, outside the command's process tree and group, and goes on. The next run returns its result. | `squiz status` |
| The round host dies | The reviewing record names a host that has gone, so the round reads as killed. The next trigger or round host to find it stops the orphaned reviewer, confirms it is gone, removes the snapshot, and records the round failed, as The round host under § 3 sets out. What the reviewer reported is not posted, and no failure comment is posted. `squiz review` exits 1, saying the host stopped before its round ended. The state is retried by a new commit or reply, or by `squiz review`. | `squiz status`, `squiz review` stderr |
| The state file cannot be read | Exit 1, and no review runs. Every reader of the file reports it with the underlying error rather than the word "failed": the hook queues nothing, `squiz review` exits 1, `squiz status` prints a line for the episode and lists the rest, and the round host exits, leaving the state queued. No failure comment is posted, because whether the episode is closed is in the file, and so is the record that would stop each firing posting another. | Hook stderr, `squiz review` stderr, `squiz status`, `host.log` |
| The round cannot write its reviewing record | Exit 1, and no review runs. The round host records the state failed, since a round nothing records would run twice. Where that write fails too, the host exits, and the state stays queued for the next host. | `squiz review` stderr, `squiz status`, `host.log` |
| The reviewer's session cannot be recorded | The review goes on. Until a later write names it, the record names no reviewer for `squiz status` or a recovery to find. | `host.log` |
| No pane can be opened | Where tmux or Herdr refuses to open a pane, the round host starts the reviewer detached, and the round goes on. `squiz status` shows the session as `detached`. Why the pane was refused is not kept. | `squiz status` |
| The reviewer is not installed | Exit 1, and the failure comment and stderr name the reviewer that could not be started. It is reported as a setup problem rather than as a bad round. A missing Copilot arrives instead as a Copilot adapter run that completed no message, because the line the round starts is `sh`, and is reported as a setup problem by the row below. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The reviewer runs, exits cleanly, and completes no message | Exit 1, and what the reviewer reported before its provider gave out is posted. A credential the provider refuses arrives here rather than above, because the reviewer starts and answers. The failure comment and stderr carry the reason the reviewer gave. Not retried, because the reviewer already retried the request itself. Reported as a setup problem rather than as a bad round. An errored message in a round that completed others is a retry rather than a failure. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The reviewer's output cannot be read, and no retry recovers it | Exit 1, and what the reviewer reported before its output stopped being readable is posted. The failure comment and stderr say the review did not run. A retry whose output cannot be read either and a first attempt that left no time for a retry both arrive here. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The reviewer stops without finishing its review | Retried once, where the round has time left for one. Both attempts post what the reviewer reported before it stopped. A review that was never finished and an honest finding of nothing are distinguished before anything is posted. Exit 1 where the retry does not finish either, with a failure comment saying the review was never finished. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The reviewer exceeds the review budget | Exit 1, unless the round holds the reviewer's declaration, as the end of this row says. The reviewer process is killed, what it reported before the kill is posted, and the failure comment and stderr say how many findings arrived. The same line then says what squiz saw during the round, and never what caused the kill. For a `pi` reviewer it gives how many messages the reviewer completed, with the bound's seconds averaged over them, and how many requests its provider failed, quoting the first line of the last one's error. A Copilot round's line adds nothing, because Copilot reports neither while it runs. The round is recorded as a failed round rather than a clean one, whatever it posted, and the summary that closes the episode notes that the bound cut it short. A round that already holds the reviewer's declaration is the review it declared instead, because the review was finished before the bound was reached, unless one of its reports could not be read back. That round posts no failure comment, and exits 0, 2 or 3 as its outcome says. | Failure comment, `squiz review` stderr, `squiz status`, `host.log`, summary's Notes |
| A reviewer's pane cannot be closed | The reviewer is already stopped, and its pane stays open on the person's screen. | `host.log` |
| A round's snapshot cannot be removed | The snapshot stays on disk, and the round's result stands. `host.log` names its path and why it could not be deleted (§ 4 The snapshot). | `host.log` |
| GitHub is unreachable | Exit 1 and nothing is posted, the failure comment included. Nothing is stored to retry. Where the episode ends having posted nothing, stderr says so. A trigger whose calls cannot reach GitHub queues nothing. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| `gh` cannot be run at all | Exit 1, nothing posted, the failure comment included, and no review runs. stderr names the call that needed it and says `gh` could not be run. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| The calls before the review run out of time | Exit 1, and no review runs. A snapshot that the fetch, the clone and the checkout could not make within the part is this row too. The failure comment and stderr say which call had nothing left, where the posting reserve can still reach GitHub. A lookup that ran out of time is never read as a branch with no pull request. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The threads on the pull request cannot all be listed | Exit 1, and no review runs. The failure comment and stderr say so. The pages that arrived are dropped, because a reviewer handed a subset rules on a subset. A trigger whose listing fails queues nothing. | Failure comment, `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| A verdict cannot be applied | A verdict whose mutation GitHub refuses leaves its thread as it was handed over, and the round counts the thread that way. A verdict naming a thread that was not handed over, and a second verdict for one thread, are not sent. The round's outcome stands. stderr names each with its thread, what the reviewer ruled, and why it was not applied, which for a refused mutation is what GitHub answered. `squiz status` does the same for a round that reviewed. The summary that closes the episode, and the failure comment of a round that failed, name each as § 5 What the comment carries shows, without GitHub's answer. Nothing is retried. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| Some comments post and others fail | The comments that landed stay, the round exits as its outcome says, and stderr says how many could not be posted. A later round makes the rest again. A round that closes the episode lists each in its summary's Notes, and a round that fails lists each in its failure comment. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| The reviewer's reason cannot be posted | The verdict stands, and the thread stays in the state the reviewer ruled. The round's outcome stands. stderr names the thread and what GitHub answered, and so does `squiz status` for a round that reviewed. A round that closes the episode names the thread in its summary's Notes, without GitHub's answer. Nothing is retried: the next round that keeps the thread open posts a reason of its own. | `squiz review` stderr, `squiz status`, summary's Notes |
| The reply on a thread the round closes cannot be posted | The thread is resolved all the same, and the verdict stands. The round's outcome stands. stderr names the thread and what GitHub answered, and so does `squiz status` for a round that reviewed. The round records the line in its entry of the state file, and the summary that closes the episode names it in Notes, without GitHub's answer, whichever round it was. A round that fails names it in its failure comment instead. Nothing is retried, because no later round closes the thread again. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| A round that leaves threads open has findings no thread holds | A finding about the change as a whole, one the harness could anchor to neither a line nor a file, and one whose comment could not be posted reach no thread, and a round that leaves threads open posts no summary. The round's record keeps each. `squiz review` prints each on stderr, and the summary that closes the episode lists each that no later round settled (§ 5). | `squiz review` stderr, summary's Notes |
| No finding posts | A round that found findings and posted none of them is a failed round, whatever its verdicts did: exit 1, recorded failed with the reason "round 2 found 3 findings and could not post them to PR #41", and a failure comment where GitHub takes one. It posts no summary and does not close the episode. A new commit, a new reply or a run of `squiz review` retries it where a round remains, and closes the episode where none does, as The failure comment below says. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The posting reserve runs out before the findings are posted | Exit 1, and the findings are reported on stderr as unposted rather than as comments that landed. No failure comment is posted, because the reserve it would be posted in is spent. Nothing is attempted past the end of the reserve. | `squiz review` stderr, `squiz status`, `host.log` |
| The round's spend cannot be written | Exit 1, and nothing the reviewer found is posted. The failure comment and stderr say nothing was posted, and give the underlying error. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The round's end cannot be written to the episode's state | Exit 1, and no summary is posted, because the end, and the close where the round closes the episode, is written before the summary. The findings and verdicts the round posted stand, and the failure comment and stderr name the write that failed. The episode then reads as one still open, and the next run reviews the pull request again. A close reached before any review fails the same way, with nothing posted but the failure comment. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The round's result cannot be recorded | The round host could not write what the round reached, after the round posted it. The host names the result and the reason, and exits. What the round posted stands. The reviewing record still names the host, so once the host has exited `squiz status` shows the round killed. A `squiz review` already waiting on the round sees no result and exits 4 at its deadline. A later run exits 1 saying the host stopped before its round ended, unless the round had closed the episode, which it then prints as closed. | `host.log`, `squiz status` |
| A round's posting time or resume command cannot be written | The round's result stands. A round with no resume command shows `—` under Resume in `squiz status`. | `host.log` |
| The summary comment cannot be posted | The close is a close still rather than a round the harness failed, and the command exits 0 or 3 as the close does. stderr says the episode closed without its summary, and names what GitHub answered or that the reserve was spent. Nothing is retried, because a second attempt would be a second comment. `squiz review` prints the line for the run that waited on the close, and for every later run on the closed episode, whether the close came after a review or before one. `squiz status` prints it under the line of a round that reviewed. `host.log` holds it after the close's own line, for a close before the review as well as after one. | `squiz review` stderr, `squiz status`, `host.log` |
| The episode closes before any round ran | An episode whose failed attempts spent the token bound before any round reaches this. It closes as § 5 says: with the summary, the open threads and exit 3 or 0 where those attempts left any of the reviewer's threads, and with exit 0 and a line on stderr where they left none. | Summary's Notes, `squiz review` stderr |
| The harness itself throws | A throw in a command is trapped at its top level, which writes one line on stderr. A throw inside a round fails the round: it is recorded failed with the throw as its reason, and posts no failure comment. `squiz review` exits 1. The hook exits 0, as it does on every path. A throw in the round host outside a round ends the host, and the round it held reads as killed. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| No wake reaches the owner of the work | The note stays in `.squiz/<number>/notes/`. The owner learns the result from `squiz review` or `squiz status`, and the pull request holds it. A note that cannot be written is reported the same way. | `host.log` |
| The round cap is reached | Exit 3, or 0 where nothing is open. Findings still unresolved stay open, and the summary comment reports them. | Summary's Notes, `squiz status` |
| The token bound is reached | Exit 3, or 0 where nothing is open. The episode closes without starting another round, and the summary comment reports that the bound was reached rather than reporting the round as one the reviewer failed. | Summary's Notes, `squiz status` |

### The review budget

The review budget bounds a review two ways. Both are configurable.

| Bound | Default | When it is reached |
|---|---|---|
| **Time**, per round | 900 seconds | The reviewer is stopped, the round records that the bound cut it short, and it posts the findings reported before the stop. |
| **Tokens**, per round | 10,000,000 | The episode closes without starting another round. |

A `pi` reviewer killed at the time bound yields the cost of its completed
messages as well as its findings, both read from the same moment of the run.

**What a failed round salvaged goes on the pull request, and the round is a
failed round still.** The findings the reviewer confirmed are posted and the
verdicts it reported are applied, in the posting reserve and under the same
deadline a finished review's posting runs under. A finding no thread can hold is
listed in the failure comment. None of that decides what the
round became. The outcome is the reviewer's own, the cost is the floor the
failure left, and the round neither hands threads back to the coding agent nor
closes the episode over what it managed to put up.

A failed round that confirmed nothing has no findings to post and no verdicts to
apply. It still posts its failure comment under § 7.

**A round runs in the round host, so no caller's timeout bounds it.** It has
three parts, each bounded on its own:

| Part | How long | What runs in it |
|---|---|---|
| Before the review | At most 30 seconds | The pull request lookup, the threads listing, the diff, and the fetch, clone and checkout that make the snapshot |
| The review | The time bound | The reviewer |
| Posting | A reserve of 60 seconds | The findings, the verdicts, the summary comment and the failure comment |

Stopping the reviewer runs after the moment the review had to be over by, and a
reviewer that ignores the signal spends the grace and the kill there. That overrun comes out of the
posting reserve: a round whose reserve is spent by the time it has findings
posts nothing and says so.

**`squiz review` waits within one deadline of 540 seconds**, counted from the
moment it starts, which keeps it under the 600 seconds Claude Code gives a shell
command. Everything the run does counts against it.

- **A run whose state's round ends before its deadline returns that round's
  result**, 0, 2 or 3, or exits 1 with the reason the round recorded where it
  failed. It posts no second failure comment.
- **A run whose deadline arrives first exits 4.** Its state is queued or under
  review, so the round goes on, and the next run returns it.

**A part is one deadline every call inside it runs under, and a call with
nothing left on it is not made at all.**

**No single call to GitHub may take more than 30 seconds**, and this bound is not
configurable. A call that reaches either bound is treated as GitHub being
unreachable, so the round exits 1 and the comments that landed stay.

**The token bound is on one round rather than on the episode.** A round whose
tokens reached it closes the episode. The episode's own ceiling follows from the
round cap: a cap of R rounds with a bound of B tokens is an episode of R × B,
which is 30,000,000 tokens at the default cap of 3 and 80,000,000 at the largest
cap the configuration accepts.

The tokens an attempt spent count whether or not the attempt was a round, as a
ledger of its own.

**A reviewer that ran is charged what its report file says, however its attempt
ended.** Two attempts end with no read of the file to its end:

- **A start that failed after the reviewer may have run.** A tmux window runs its
  command as it opens, and a child whose identity could not be read ran until it
  was stopped. A Herdr pane runs nothing until its start succeeds, so its failed
  start spends nothing.
- **An attempt the harness threw out of** after the reviewer started. The
  reviewer's process group is stopped and its pane closed before the attempt
  returns.

The file is read once the reviewer is stopped, and what it says is a floor. A
Copilot usage line is Copilot's own total and is kept as it is. A reviewer that
ran and whose file reports no spend is charged a floor of zero.

The bound is read before a round starts, and again when a round records what it
spent. **It stops the next round, never the running one**, so the round that
reaches it may spend more than the bound, and the time bound is the only thing
that caps a single round.

**The token bound holds a Copilot round that has a cost as it holds a `pi`
one**, with tokens counted the same way for both. A Copilot round with no cost
counts nothing against it. Dollars and AI credits bound nothing.
EOF_FIXTURE
