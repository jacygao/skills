#!/usr/bin/env bash
# squiz's AGENTS.md, cut to what a spec edit needs, and the sections of its
# specification that squiz d820369 changed, as they stood before it.
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

**Version:** 1.33 (draft)

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
  leaves threads open with a round remaining also writes `handoff.md` there:
  each open thread with every reply on it, the description, each agent's final
  message and transcript path as its stop recorded them (The hooks), and the
  diff the reviewer read. Where the threads cannot be listed, the round writes
  none, and `host.log` says why. In a headless run, `fixer.log` beside it holds
  the output of the fixer started on it (Headless runs below).
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
  reply is newest, and that is a change like any other.

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

### Headless runs

**A run is headless where `.squiz.json` names a `fixer`, `claude` or `copilot`
(§ 10 Configuration).** Whoever starts the run declares it, and squiz never
decides it from whether a session is alive. The setting reaches the hook, the
round host and the commands alike, because each reads `.squiz.json`.

**A headless run is woken by nothing.** Its hooks return at once, as every hook
does, and its run has ended by the time its review does. The round host still
writes each note in `notes/`, and in place of the wake writes a line in
`host.log`:

```
3f9c2e0: no wake: .squiz.json names a fixer, so the run is headless
```

**A round that leaves threads open with a round remaining starts a fixer on its
handoff.** Once the round has written `rounds/<k>/handoff.md`, the round host
starts a fresh run of the CLI `fixer` names, never a resume of an earlier
session. The fixer runs in the change's worktree, detached as the round host
is, with its output in `rounds/<k>/fixer.log`. It runs on the CLI's own default
model. Its command line loads squiz from the plugin directory of the squiz
that starts it, because a new run is handed no plugin directory, settings or
MCP configuration of the run before it:

```
claude -p <prompt> --plugin-dir <squiz> --permission-mode acceptEdits --allowedTools 'Bash(squiz:*)' 'Bash(git:*)'
copilot -p <prompt> --plugin-dir <squiz> --no-ask-user --allow-tool=write '--allow-tool=shell(squiz)' '--allow-tool=shell(git)' --disable-builtin-mcps --no-auto-update --disable-client-telemetry
```

A Copilot fixer carries the three flags the Copilot reviewer does (The Copilot
adapter), which turn off the built-in GitHub MCP server, auto-update and client
telemetry. Without them, on Copilot 1.0.110, a fixer also reached
`cafe.github.com` and `telemetry.enterprise.githubcopilot.com`. The hosts a
fixer reaches with them have not been measured.

**The fixer edits files and runs `squiz` and `git`, and each command
`fixerCommands` names (§ 10 Configuration).** The CLI refuses any other
command, since nobody is there to approve it, except the file and read-only
commands, such as `touch` and `ls`, that Claude Code's `acceptEdits` allows on
its own. Each named command is granted by its name alone, with any arguments,
after `git`. A repository whose tests run as `node --test` names `node`:

```
claude -p <prompt> … --allowedTools 'Bash(squiz:*)' 'Bash(git:*)' 'Bash(node:*)'
copilot -p <prompt> … '--allow-tool=shell(squiz)' '--allow-tool=shell(git)' '--allow-tool=shell(node)' --disable-builtin-mcps …
```

A granted command runs whatever it is given, and the fixer writes the files it
runs, so naming `node` lets the fixer run any program `node` can. Without
`fixerCommands` the fixer cannot run the project's tests.

Its environment is the round host's, less `CLAUDE_CODE_MESSAGING_SOCKET`, which
names the session whose hook started the host, and with `SQUIZ_FIXER=1`, which
keeps the fixer's prompt from being recorded as the run's (The hooks). The
prompt names the handoff:

```
Squiz reviewed this change and left threads open. /work/squiz-a/.squiz/local/rounds/1/handoff.md holds them, each with every reply on it, with the change's description, the agents' final reports and the diff the reviewer read.

Work the threads as it says: fix what applies, and reply on each one to say what you changed or why you disagree. Do not run `squiz review`: squiz reviews your work again when you finish.
```

**The fixer's own stop starts the next round**, as any stop does (The hooks).
Its edits, its commit or its replies are a new state, which the hook queues.

**The round cap bounds the fixers.** Only a round that leaves threads open with
a round remaining hands anything back, so the closing round starts no fixer,
whether it closes with threads open or with none. A cap of R starts at most
R−1 fixers in an episode.

**No fixer starts beside one still running.** Where a fixer an earlier round of
the episode started is running, or cannot be told running or gone, by its pid
and start time, the round starts none, and its record says why. A round no
handoff was written for starts none either.

**The reviewed record says how the fixer's start went**, in its `fixer` field,
and `host.log` says the same in one line:

| `outcome` | What it holds | `host.log` |
|---|---|---|
| `started` | The CLI, and the fixer's pid and start time | `round 1: started the fixer, claude, as process 4200, writing to …/rounds/1/fixer.log` |
| `exited` | The CLI and the pid, for a fixer that ended before its start time could be read | `round 1: started the fixer, claude, as process 4200, writing to …/rounds/1/fixer.log; it had exited before it could be checked` |
| `failed` | The CLI, and why it did not start | `round 1: the fixer, copilot, did not start: spawn copilot ENOENT` |
| `unknown` | The CLI, and why nothing could say whether it started. No later round of the episode starts a fixer. | `round 1: whether the fixer, claude, started could not be told: the intermediate process did not answer within 5000ms` |
| `not started` | Why no start was tried | `round 2: no fixer started: the fixer round 1 started, process 4200, is still running` |

A round that needed no fixer has no `fixer` field and no such line.

**The round records the fixer as `unknown` before it starts it**, with the
reason `its start was never recorded`, and replaces that with how the start
went. A state file that refuses the reservation starts no fixer. One that takes
the reservation and refuses the result keeps the reservation, which holds back
every later fixer of the episode, as any `unknown` does.

**The round that closes a headless episode writes `closed.json`** in the
episode's directory, once the close is recorded and its summary posted. It
holds the close's head, its exit status, the threads it left open and, where a
bound closed it with threads open, which bound:

```json
{
  "head": "3f9c2e07b1d4a8c6e5f0923b7a1d6c4e8b2f5a90",
  "exitStatus": 3,
  "openThreads": ["T1"],
  "closedAt": "round cap"
}
```

The file appears whole: it is written beside its path and renamed into place. A
caller that sees it reads the outcome from the episode's directory. It moves into `episodes/<n>/` with the rest of its episode (The state file).

**A round host in a headless run outlives every fixer of its open episode.**
Once nothing is queued, it looks every second at the queue and at each fixer
the records name as started, by its pid and start time. A state queued meanwhile
is taken as any other. A close ends the wait: whatever a fixer still running
then queues starts a host of its own. `host.log` names the fixer it waits on:

```
waiting for the fixer round 1 started, process 4200, to exit, for at most 2700 seconds
```

**The wait on one fixer is bounded by the reviewer's time bound for each round
the cap allows**, `timeout` × `rounds` seconds, 2,700 by default, counted from
when the host first waits on it. A round that runs while the host waits does
not start the count again. A fixer that cannot be told running or gone
is waited on as one running is, and the time counts toward the bound. A host
that waited without one would hold `host.lock` for good, and every later
trigger would read the episode as in hand. Once the bound passes, the host
writes `stopped.json` naming it and exits. A fixer that then stops and queues a
state starts a host of its own, and its trigger removes the file.

**An episode that stops short of its close writes `stopped.json`** in the
episode's directory, beside where `closed.json` would be. The host writes it as
it exits, once no fixer is running or the bound on its wait has passed, and only
where the episode has not closed and no state is queued or under review. It holds the head of the last state
recorded, which case stopped the episode, and why:

```json
{
  "head": "3f9c2e07b1d4a8c6e5f0923b7a1d6c4e8b2f5a90",
  "stopped": "fixer queued nothing",
  "reason": "the fixer round 1 started, process 4200, exited, and its run queued nothing"
}
```

| `stopped` | The last state recorded | `reason` |
|---|---|---|
| `round failed` | Failed | Why it failed |
| `fixer did not start` | Handed its threads back, and its fixer failed to start, got no handoff, or had no start recorded | Why, from its `fixer` field |
| `fixer queued nothing` | Handed its threads back, and its fixer started and exited | Which fixer, and that its run queued nothing |
| `earlier fixer queued nothing` | Handed its threads back, and started no fixer because an earlier one was running, which then exited | Which earlier fixer, and that its last stop queued nothing |
| `fixer outlived its bound` | Any, with a fixer not seen to exit within the bound above | Which fixer, and the bound |

The host decides and writes it under `state.lock`, beside its path and renamed
into place, as `closed.json` is. `host.log` says what it wrote:

```
wrote the stop to /work/squiz-a/.squiz/local/stopped.json: fixer queued nothing
```

A file that cannot be written is a line in `host.log` saying why, and the
caller's wait runs to its own bound.

**A caller waits for `closed.json` or `stopped.json`, whichever appears.** The
two are never there together. The trigger that next queues a state removes
`stopped.json` in the same update, under `state.lock`, so a retry by
`squiz review`, or a new commit, never runs beside it. A trigger that cannot
remove it queues nothing, and fails naming the file. A hook on a failed state
queues nothing, and leaves it. A stopped episode is still live, so
`stopped.json` never moves into `episodes/<n>/`.

**Three things leave a headless episode open with neither file:**

- A fixer whose start could not be told. It may still be running, so while one
  is on the episode's records nothing is written.
- A round host that dies, or cannot write the state file. Nothing is left to
  notice the episode stopped.
- A last state that names no stop, such as one not reviewed because a head no
  trigger queued superseded it. `host.log` says `marked no stop:` and why.

A caller bounds its wait, and reads `host.log` and `squiz status` to tell which
it was.

**A headless run's handoff gives the run's prompt where nobody wrote a
description.** Under the local venue the description is `description.md`, else
the first prompt the worktree's sessions were given (§ 4 The record). Where it
is the prompt, a line under `## The description` says so before it:

```
## The description

Nobody wrote a description of this change, so this is the prompt the run was started with:

Add backoff. Requirement: the first retry is immediate.
```

Where there is neither, the section reads `The change has no description.`

**A headless run's handoff holds the reports its stops carried** (The hooks).
A run with no subagent hands the fixer its session's transcript path, and under
Claude Code its final message too. Copilot's `Stop` carries no final message,
so under Copilot the fixer reads the session's report from its `events.jsonl`.
A Copilot subagent's report names its parent's `events.jsonl`:

```
### Subagent dcc0b994-3d65-4ad3-92f3-ccf70b8232d5, dispatched by session af7a1b25-6bdc-459f-99e1-5c3ab2513f83

Transcript: none of its own. Its events are in its parent's transcript, /Users/someone/.copilot/session-state/af7a1b25-6bdc-459f-99e1-5c3ab2513f83/events.jsonl

PONG
```

**Where a subagent and its parent end on one state, the handoff shows the
subagent's report.** The subagent's `SubagentStop` fires before the parent's
`Stop`, and the first stop to queue a state is its owner. The parent's `Stop`
finds the state queued and records nothing.
EOF_FIXTURE
