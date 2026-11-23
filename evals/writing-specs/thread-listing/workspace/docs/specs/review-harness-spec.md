# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.36 (draft)

## 7. Commands

Everything squiz ships to be run is a subcommand of one binary, `squiz`. Squiz
ships no slash command, and the setup check is `squiz doctor`.

### `squiz review`

`squiz review <number>` acts on the record of the pull request's current state
(§ 3 The state file) and waits for its review within the deadline § 8 sets.
Under the local venue it is `squiz review`, run in the worktree it reviews, and
every message names the change, its rerun and where the summary is as § 4 The
contract sets out. The exit status says what happened:

| Exit | What it means |
|---|---|
| 0 | A round reviewed this state and nothing is open. The episode is closed, and its summary is posted. Or the pull request is a draft. |
| 1 | The review could not run. |
| 2 | Threads are open, and rounds remain. |
| 3 | The round cap or the token bound closed the episode with threads open. Or it closed the episode without a round reviewing this state, whatever is open. Or a failed round closed it after this state's round left threads open. |
| 4 | The review goes on in the round host, and the run's wait ended first. |

These are the only statuses `squiz review` gives. A caller reads any other, such
as a crash or a command that could not start, as 1. Apart from a draft, exit 0
is given only for a state a round reviewed. A state answered with 3 is answered
with 3 for the run waiting on it and for every later run.

A run that exits 0, 2, 3 or 4 prints its outcome on stdout. A run that exits 1
prints nothing on stdout. stderr carries what failed (§ 8 The command's stderr),
and the line § 10 Configuration gives where no `.squiz.json` is found.

A run that exits 0, 2, 3 or 4 writes everything it prints on stdout to
`.squiz/<number>/review.txt`, replacing it on every run, and prints that path
first. Where the file cannot be written, the outcome and the exit stand, and
stderr adds:

```
squiz: the output could not be written to /work/squiz/.squiz/41/review.txt: EACCES: permission denied
```

Every number and every thread in the output is as it stands on the pull request.
Each open thread is printed as its `squiz threads` line, followed by its comments
indented two spaces, the first without its first line. Threads open, exit 2:

```
Full output, to read where this is cut short: /work/squiz/.squiz/41/review.txt
Squiz reviewed PR #41 at 3f9c2e0: round 2 of 3, 1 new finding.

2 threads are open:

PRRT_kwDOL7tYbc5abcd1 packages/sync/src/queue.ts:134 high — Retry backoff resets on every enqueue
  - `enqueue()` calls `resetBackoff()` on every call, so a busy queue never backs off.
  - Reachable whenever a retry is pending and a new item arrives.

  **Suggested fix:** reset the backoff only when the queue was empty.

PRRT_kwDOL7tYbc5abcd2 packages/sync/src/session.ts:57 medium — Clock skew is read as token expiry
  - `isExpired()` compares the server's `exp` against the local clock with no margin.

  **Suggested fix:** allow the skew the server documents before reading a token as expired.

  **Squiz coding agent**

  The server bounds skew at two seconds, and `clock.ts:12` already allows for it.

  **Squiz reviewer · still open**

  `isExpired()` still compares against the local clock with no margin: `clock.ts:12` allows for skew in `now()`, which this path does not call. Call `now()` here, or show where the margin is applied.

Fix what applies in /work/squiz, and reply on each thread with
`(cd '/work/squiz' && squiz reply <id> <text>)` to say what you changed or why
you disagree. Commit and push what you changed, then run `squiz review 41` again.
```

A run handed a result it did not produce heads it `Squiz already reviewed PR #41
at 3f9c2e0: round 1 of 3, 2 new findings.`, and prints the threads as they stand
on the pull request now.

Nothing open, exit 0: the heading is `Squiz reviewed PR #41 at 8d21a4f: round 2
of 3, no new findings.`, and the paragraph after it is `Nothing is open. The
review is closed, and its summary is on the pull request.`

A draft, exit 0: the run prints only `PR #41 is a draft. Squiz reviews it once
it is marked ready for review, so there is nothing to wait for.`, and writes no
file. The hooks write nothing for a draft. Once it is marked ready for review,
the next trigger queues its state as any other.

Closed with threads open, exit 3: after the round's heading, the paragraph is
``The round cap is reached. The review is closed with 1 thread open, and its
summary is on the pull request. A person takes it from here, so do not run
`squiz review 41` again.``, and the open threads follow. Where the token bound
closed the episode, the paragraph begins "The token bound is reached".

Closed before a round reviewed the run's state, exit 3: a line after the
round's heading says why, as `Squiz did not review PR #41 at 8d21a4f: the
episode closed at the round cap, after reviewing 3f9c2e0.`, and the paragraph
says "with nothing open" where nothing is.

Closed by a failed round, exit 3: the round reviewed nothing to head the
output, so the line saying why it failed is the heading, as `Squiz did not
review PR #41 at 3f9c2e0: the reviewer was killed at its 900-second bound, and
the round recorded no findings.`, and stderr says where its failure comment
went. Where the close has no summary on the pull request, the paragraph does not
claim one. A run whose own state a round reviewed and left threads open before
the failed round closed the episode is handed the same close, rather than its
own exit 2, because nothing reviews a push after the cap. Its stderr carries the
closing round's summary problems, where its failure comment went, and the "not
known" line below where that round's host stopped before recording them.

Still reviewing, exit 4: the run prints one of these lines after the path.

- Its state's round is running: ``Squiz is still reviewing PR #41 at 3f9c2e0. Run `squiz review 41` again to wait for it.``
- Its state is queued behind an older one's round: ``Squiz is reviewing PR #41 at 3f9c2e0 first, and 8d21a4f is next. Run `squiz review 41` again to wait for it.``
- Its state was reviewed clean and a later one is queued: ``Squiz found nothing open in PR #41 at 3f9c2e0, and is reviewing 8d21a4f before it closes the review. Run `squiz review 41` again to wait for it.``
- Its state was superseded (§ 3 The state file): ``Squiz is reviewing PR #41 at 8d21a4f instead of 3f9c2e0. Run `squiz review 41` again to wait for it.``
- A failed round closed the episode and is still posting its summary (§ 3 The round cap), which every run on the episode waits for so that what the posting came to reaches its stderr: ``Squiz has closed the review of PR #41 and is still posting its summary. Run `squiz review 41` again to wait for it.``

A run on an episode that has already closed prints the close, whatever the round
cap or the token bound would now allow. The line names the head the close was
reached on, as `Squiz's review of PR #41 closed at 3f9c2e0 after 2 rounds, with
nothing open. Only a new head commit starts another review in this worktree.` A
clean close is printed this way, with exit 0, only for its own head and for a
failed state it recorded. Where the round cap or the token bound closed it, the
line ends `No round runs again in this worktree.` instead. Where threads are
open, the line counts them, the run exits 3, and the threads follow.

The one wait on a closed episode is for a failed round's close that is still
posting its summary: the run waits until the round host records what the
posting came to, then prints the close. Where the host is known to have
stopped, because no process holds the episode's host lock or the one that held
it is gone, nothing will record the posting. The run reads the state once more,
in case the host recorded it just before stopping, and otherwise prints the
close at once at exit 3, and stderr adds `squiz: the review of PR #41 closed,
and whether its summary was posted is not known: the round host stopped before
recording it`. A run that cannot tell whether the host is running keeps
waiting.

The review could not run, exit 1. Each reason is one line on stderr, and § 8's
line to stop ends the output. Where the round host's start cannot be told, the
run waits on a live host. Where no host takes the review, the state stays
queued and the run prints:

```
squiz: no review ran: whether the round host for PR #41 started could not be told, and none has taken the review since: the intermediate process exited 1: spawn node ENOENT
squiz: `squiz status` shows whether one takes it later, and .squiz/41/host.log holds what the host wrote
squiz: put these lines in your report rather than running squiz review again
```

The other reasons take the same form:

- A failed round prints `squiz: review failed: <reason>`, with the reason its
  failure comment gives (§ 8 The failure comment), then `squiz: the failure is
  posted on PR #41`.
- A run that failed before any round, or could not reach GitHub, prints
  `squiz: no review ran: <why>`, as `squiz: no review ran: PR #41 is closed`.
- A run after this worktree pushed waits up to 60 seconds, or until its
  deadline where that comes first, for GitHub to report a head containing the
  pushed commit, and acts on that head. Where GitHub does not, the run queues
  nothing and prints `squiz: no review ran: PR #41 still has 3f9c2e0 as its head
  after 60 seconds, though this worktree pushed 8d21a4f to it`. Commits not
  pushed, a head pushed from elsewhere, and a branch with no push destination
  are taken as GitHub reports them. The hooks never wait.

A round that left threads open and has findings no thread holds keeps exit 2.
On stderr it prints the count it could not post, where any failed to post, then
each finding as § 6's Notes write it:

```
squiz: round 1 could not post 1 of its 3 findings to PR #41
squiz: round 1 raised this on no thread: `src/sync/queue.ts:90` — The queue is never drained (no thread could be opened for it)
```

## 8. Failure modes

### The review budget

A review is bounded per round by time, `timeout`, and by tokens, `tokens`
(§ 10 Configuration).

**At the time bound the reviewer is killed**, the findings it reported so far are
posted, and the round is recorded failed. The failure comment and stderr say how
many findings arrived. For a `pi` reviewer they add how many messages it
completed, the bound's seconds averaged over them, and how many requests its
provider failed. Where the machine slept during the review, they end with "the
machine slept for 13 minutes of the round". The summary that closes the episode
notes the cut. A round that already holds the reviewer's finish, with every
report read back, is the review it declared instead: it posts no failure comment,
and exits 0, 2 or 3.

**A round runs in the round host, outside any caller's timeout.** The time bound
is on the review alone. Before and after the review, each call the round makes
has 30 seconds of its own, and the round makes every call it has, however long
the ones before it took. A call that pages is one call, and its pages share its
30 seconds. No call to GitHub may take more than 30 seconds, and that is not
configurable. A call that reaches it while the round posts is one comment that
failed to post rather than GitHub being unreachable: the comments that landed
stay, and the round exits as its outcome says.

**Time the machine sleeps during the review is added back to the time bound**, at
most the bound itself in one round, so no review runs longer than twice its
bound. The calls outside the review, and `squiz review`'s wait, count sleep as
they count any other time.

**`squiz review` waits within one deadline of 540 seconds**, counted from its
start. A run whose round ends first returns the round's result, 0, 2 or 3, or 1
with the reason the round recorded, and posts no second failure comment. A run
whose deadline arrives first exits 4, and a run stopped from outside, by a person
or the coding agent's tool, ends with no status of its own. Either way the round
goes on in the round host, and the next run returns its result.

**Every attempt's tokens count against the token bound, whether or not it was a
round.** A reviewer that ran is charged what its report file says, however its
attempt ended. An attempt is charged a floor, zero where the file reports none,
where it was a start that failed after the reviewer may have run, or one the
harness threw out of. A tmux window, and a child whose identity could not be
read, may have run. A failed Herdr start spends nothing. A Copilot usage line is
kept as Copilot's total, a Copilot round with no cost counts nothing, and dollars
and AI credits bound nothing.

**The bound is read when an attempt records what it spent**, and the attempt that
reaches it closes the episode, whether it reviewed or failed. A round that
reviewed closes with a summary saying the bound was reached, rather than that the
reviewer failed. The bound never stops the running round.

