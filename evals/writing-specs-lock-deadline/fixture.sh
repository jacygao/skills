#!/usr/bin/env bash
# squiz's AGENTS.md, cut to what a spec edit needs, and the sections of its
# specification that squiz 0c2abc5 changed, as they stood before it.
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

**Version:** 1.35 (draft)

## 3. The loop

The loop runs the review from end to end. A coding agent finishes its work on a
pull request, or runs `squiz review <number>`, and a round starts: a reviewer
reads the change in a session of its own, and its findings go onto the pull
request as threads. The session that owns the work is told the result. It works
the threads, replies and pushes, and the next round starts, until nothing is
open or the round cap is reached.

### The state file

**An episode is keyed by the number of its pull request.** Its state lives in
`.squiz/<number>/` inside the worktree. The directory holds the state file, which
the rest of this section describes, and:

- `rounds/<k>/`, for each round: `prompt.md`, the task prompt the reviewer is
  handed, the report file the reviewer reports into, the reviewer's session,
  `resume.txt`, the command that resumes that session, and `gh/`, the empty `gh`
  configuration the reviewer runs with (§ 5 Tools). The snapshot the reviewer
  reads is in the temporary directory instead (§ 5 The snapshot). A round that
  leaves threads open with a round remaining also writes `handoff.md` there,
  what a fixer works from. In a headless run, `fixer.log` beside it holds the
  output of the fixer started on it, and a round that resumes the fixer's
  session also writes `update.md`, what changed since its last handoff, and
  `fixer.exit`, the resumed CLI's exit status (Headless runs below).
- `notes/`, the notes for the sessions that own the work, under The report.
- `host.log`, the round host's output.
- `state.lock`, held while the state file is changed.
- `closed.json`, in a headless run, once the episode has closed, and
  `stopped.json` while it has stopped short of its close (Headless runs below).
- `episodes/<n>/`, for each closed episode a later one replaced, numbered from 1
  in the order they closed: its state file, its `rounds/`, its `closed.json`,
  and the local venue's `summary.md` (§ 4 The record), moved there when a new
  head starts a new episode, as set out below.

**`.squiz/` keeps itself out of git.** Wherever squiz makes an episode's
directory and `.squiz/.gitignore` is missing, it writes one holding `*`. One that
exists is left as it is.

**Every change to the state file is made under `state.lock`.** A writer takes the
lock, reads the file, changes it, writes it whole, and releases the lock. The
lock is held for one update and never across a review. It names its holder's pid
and start time, and a lock whose holder has gone is taken over. A writer that
finds the lock held by a live process, or by one that cannot be told running or
gone, waits up to a deadline of its own and never breaks the lock. A wait that
runs out is a state file that cannot be written (§ 8). Readers take no lock.

**The state file also holds one record for each state of the pull request the
episode has reviewed.** A state is two things, read when a trigger starts:

- **The head commit**, as GitHub reports it for the pull request.
- **The latest activity on the reviewer's threads.** Activity is a reply from
  anyone other than the reviewer, on a thread the reviewer opened: a comment after
  the first in that thread, carrying no `**Squiz reviewer · ` marker. The coding
  agent's replies are activity, and so is a person's. A thread a person opened
  holds no activity, whatever is said on it. The latest activity is the GitHub
  identifier of the newest such reply on the pull request, or none. An edited
  reply keeps its identifier and changes nothing. A deleted one can change which
  reply is newest, and that is a change like any other. GitHub gives a reply's
  time to the second, and a reply on a general thread (§ 5 Pull request
  comments) has a REST id of another sequence than a reply on any other
  thread's, so nothing orders the two within one second. Where the newest of
  each was posted in the same second, the latest activity is both identifiers,
  the other thread's first, separated by a space.

Each record has one of five statuses:

| Status | What it records |
|---|---|
| Queued | A trigger asked for a review of this state, and no round has started it. |
| Reviewing | A round host is running the round. The record names the host, and once the reviewer starts, the reviewer's session and snapshot, so that a recovery can find and stop them. |
| Reviewed | The round's result: its exit status and the threads it left open. A round that left nothing open while a later state was queued behind it records *reviewed clean, episode open* instead, with no exit status. That record gets exit status 0 where it later closes the episode, when the state behind it is superseded by it. A round that left the episode open also records each finding no thread holds, as § 6's Notes would give it. In a headless run, a round that handed its threads back also records how its fixer's start went (Headless runs below). |
| Failed | Why the round failed, and whether its owner has had a note about it. |
| Not reviewed | Why no round reviewed it: the episode closed first, or a later state superseded it. |

A record of a round that started also holds what `squiz status` prints for it
(§ 7).

**A state file missing a field its writer always writes cannot be read**, and is
treated as any state file that cannot be read is (§ 8). Those fields are
`spentOutsideRounds`; each round's `reviewer`, `elapsedSeconds`, `head`, `raised`
and `ruled` (§ 6); the number of a reviewing record's round; and a reviewed
record's round and its count of new findings. The reason names the field:

```
/work/squiz/.squiz/41/state.json: round 1 has "raised" as undefined
```

**A trigger reads the record for the pull request's state before it queues
anything.** It has looked up the pull request and listed its threads by then,
because the state is read from them.

- **No record:** the trigger queues the state, and starts a round host where
  none is running.
- **Failed:** a hook queues nothing. `squiz review` queues the state again,
  because running the command is the request to retry it.
- **Reviewing**, by a round host that has gone: the trigger recovers the round, as
  The round host sets out, which records it failed. It then does what it does for
  a failed state.
- **Queued:** the trigger queues nothing, and starts a round host where none is
  running.
- **Reviewing**, by a round host that is running: the trigger queues nothing.
- **Reviewing**, by a round host no one can tell running or gone: the trigger
  recovers nothing, queues nothing and starts nothing, because recovering a round
  whose host may be alive would stop a live reviewer and remove its snapshot.
  `squiz review` exits 1 naming the host it could not check, and a hook returns.
  The next trigger checks again.
- **Reviewed, or not reviewed:** the trigger queues nothing. `squiz review`
  returns that result, with the threads read from the pull request as they stand
  now.

`squiz review` then waits, as § 8 sets out, and the hooks return at once.

**A failed state is retried only when someone runs `squiz review`.** A hook
firing on it queues nothing, so a turn spent reading a failure note does not
bring the failure back. The retry queues the state behind every state already
queued or recorded, as a state queued for the first time is, so the records
stay in the order their rounds ran. A retry that fails again posts its failure comment,
exits 1 and writes no second note, and its stderr tells the coding agent not to
run the command again (§ 7 `squiz review`). A new commit or reply is a new state, and is queued like any other.

**One state gets one review.** A trigger for a state already queued or under
review queues nothing, so two firings for one commit and the same replies post
one set of threads and at most one summary. An episode runs one round at a time,
oldest queued state first.

**A state accepted into the queue is never dropped.** It is reviewed, or it is
given a result of its own. Say state A is under review and state B, a later
commit, is queued behind it:

| A's round ends with | What happens to B |
|---|---|
| Threads open, rounds remaining | B is reviewed next, as usual. |
| Nothing open, rounds remaining | The episode does not close. A is recorded as *reviewed clean, episode open*: no exit status, no summary, and no note for its owner. B is reviewed next, and the episode closes from the last round with nothing queued behind it. Where B is superseded by A, A is that round, as below. A run of `squiz review` waiting on A goes on waiting, for the state the queue ends on, and returns that state's result: 0 or 3 with the close, or 2 where B left threads open. It exits 4 where its wait runs out first. |
| The round cap reached, or the token bound | The episode closes, as it must, and posts its summary. Its Notes name the cap or the bound and each state left not reviewed, whether A left threads open or nothing. B is recorded as not reviewed, with the reason. A run of `squiz review` waiting on B is handed the close with a line saying why B was not reviewed, and exits 3, whether A left threads open or nothing. B's owner gets a note saying the same. |

The line comes right after the heading of the close the run is handed:

```
Full output, to read where this is cut short: /work/squiz/.squiz/41/review.txt
Squiz reviewed PR #41 at 3f9c2e0: round 3 of 3, no new findings.
Squiz did not review PR #41 at 8d21a4f: the episode closed at the round cap, after reviewing 3f9c2e0.
```

Where the token bound closed the episode, its reason reads "the episode closed at
the token bound, after reviewing 3f9c2e0".

**A round reviews the pull request's newest state, and only that.** When the
round starts, the round host checks that its state still has the pull request's
head commit and latest activity. A state the pull request has moved past is
superseded: no review runs, nothing is posted, and it is recorded not reviewed,
naming the state that superseded it as § 6's Notes do:

```
superseded by 8d21a4f
superseded by 3f9c2e0 with different replies
```

The record also holds that state's head commit and latest activity, because
other states can share its short commit. The round host queues nothing. A
trigger queues the newer state, and since a hook does not wait, a state
superseded after a hook queued it is queued by the next trigger. A run of
`squiz review` waiting on a superseded state follows the state that superseded
it and returns that state's result. Where that state has no record, the run
reads the pull request afresh and acts on its record as any trigger does. It
exits 4 where its wait runs out first, as § 7 shows.

**A state reviewed clean can close the episode when the state behind it is
superseded by it.** Say A was reviewed clean with B, a reply, queued behind it,
and the reply is deleted before B's round starts. The pull request is at A again,
so B is superseded by A. A closes the episode where all of these hold:

- no round has run since A's, whether it reviewed or failed;
- none of the reviewer's threads is open on the pull request;
- nothing else is queued.

A is then the last round with nothing queued behind it. Otherwise B is recorded
superseded, and the episode stays open for the next commit or reply. No reviewer
runs for a close on A, and nothing is spent against the round cap. The close is
recorded first, as for any round. The summary is then posted
as § 6 sets out for a close that runs no reviewer. A's record then becomes a
reviewed result with exit status 0 and no threads open, carrying the summary's
problem where it was not posted, and A's owner gets the note of any close. A
run of `squiz review` waiting on A or on B returns A's close.

**A round decides its close and records it in one step.** It reads the queue
under `state.lock`, decides from it as the table above sets out, and writes the
close in that same update, before it posts the summary. A clean close also
records, in that update, the state its round reviewed. A trigger that comes
after the close reads it before it queues anything, so no state queued while
the summary is posted is stopped by a close it arrived before. A round that
finds the round cap or the token bound already spent, and closes the episode
without starting a reviewer (§ 6), also writes the close before it posts the
summary, and that close is never clean.

**A state left not reviewed is named by its short head commit, followed by "with
different replies" where an earlier state has the same commit.** The earlier
states are the one the round that closed the episode reviewed, and those
queued ahead of it:

```
Squiz did not review PR #41 at 3f9c2e0 with different replies: the episode closed at the round cap, after reviewing 3f9c2e0.
```

**The state file keeps the reviewer's last ruling on each thread**, by the
thread's node id: `fixed`, `withdrawn` or `open`. A close that runs no reviewer
counts the thread by it (§ 6). A round writes its rulings in the update that
records its cost, before it posts anything, so no verdict reaches a thread unless
its ruling is on record. A state file that will not take that update fails the
round with nothing posted. A thread a finished review gave no verdict is kept as
`open`. A failed round writes the rulings it salvaged, and leaves every other
thread's alone. A ruling is kept whether or not GitHub then takes it.

**A close at the round cap or the token bound stays closed in its worktree.** A
new commit or reply queues nothing, and `squiz review` prints the close (§ 7).
A second episode on the same pull request starts in another worktree on the same
branch, which holds no state for it.

**A clean close stays closed for the head it reviewed, and for every state it
recorded.** The clean close records how many of the state file's records are the
closed episode's. A trigger acts on any other state as follows:

- **No record, on a head other than the one the close reviewed:** the trigger
  queues the state after the closed episode's records, for a new episode, and
  starts a round host where none is running. A run of `squiz review` waits on it,
  as on any other state.
- **A record the closed episode wrote, on another head**, as a force-push back to
  a head it reviewed leaves the pull request: the trigger queues nothing, and
  `squiz review` returns that record's result, which names its own head.
- **A record queued after the close:** the trigger acts on it as on any record. A
  hook leaves a failed one failed, and `squiz review` queues it again.
- **New replies on the head the close reviewed**, and a failed record the closed
  episode wrote: the trigger queues nothing, and `squiz review` prints the close.

No trigger queues a state the closed episode recorded, so its records keep their
places, and every record after them is the next episode's.

**The round host starts the new episode in the update that takes its first
state.** Under `state.lock`, it finds the close clean and a state queued after
the closed episode's records. In that one update it:

1. Writes the closed episode's state file, holding the closed episode's records
   in their order, to the next `episodes/<n>/state.json`.
2. Moves `rounds/` to `episodes/<n>/rounds/`, and rewrites each round's
   `resume.txt` to name the session where it now is. It moves the local venue's
   `summary.md` to `episodes/<n>/summary.md`.
3. Writes a fresh state file in its place: no rounds, nothing spent outside them,
   the reviewer's rulings carried over, and every record after the closed
   episode's, in their order. It takes the oldest queued one as round 1.

A round host that finds a round of the closed episode still recorded under
review starts no new episode, because that round's reviewer may still run and
its snapshot stands at the path the new round of that number takes. It records
each state queued after the close failed, and `squiz review` retries it as any
failed state:

```
no review ran: round 1 of the closed episode is still recorded under review by round host 4242
```

The new episode has its own round cap and token bound, and posts its own summary
when it closes. It reads the reviewer's threads from the change as any episode
does, so the closed episode's threads, and the rulings on them, are part of it.
Everything else in the directory belongs to the worktree and stays where it is:
`notes/`, `host.log`, the locks, and the local venue's files other than
`summary.md`. Where the archive cannot be written, the closed episode is left as
it was, and the round host records the state it took failed with the reason.

`host.log` says where the closed episode went:

```
2026-11-08T09:14:02.511Z a new episode starts on a state the clean close never recorded: the closed one is in /work/squiz/.squiz/41/episodes/1
```

A run of `squiz review` whose state's record, or whose close, moved into an
archive before it read it reads it there.
EOF_FIXTURE
