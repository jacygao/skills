# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.33 (draft)

## 5. The reviewer

The reviewer is a second agent that reads the code the coding agent has just
written and reports what is wrong with it. It has no GitHub access of its own:
it reports each finding as it confirms it, and the harness turns each one into a
comment on the pull request.

### Adapters

An adapter is the code that knows how to drive one reviewer CLI. There are two,
for `pi` and for the GitHub Copilot CLI, and `reviewer` in Configuration chooses
between them. A further reviewer means writing a further adapter and changing
nothing else. An adapter implements four things:

| | |
|---|---|
| `argv(opts)` | Build the command line from a working directory, a charter file, a prompt, a session directory, the thinking level and the model. |
| `confine(opts)` | Put in place whatever the CLI is handed outside its command line, check what the CLI cannot be trusted to refuse, and return what to add to its environment. A CLI handed nothing returns an empty environment and writes no file. |
| `read(reports)` | Report each finding and each verdict as the run makes it, from the file the reviewer reports into, and return the run's cost where the CLI reports one, with the models the CLI reported that cost against. A run the CLI reports as failed is told apart from one that reported no findings. |
| `grants` | The tools the CLI is given, as one list in the CLI's own names: the reading tools, the reporting calls and the history tools, as Tools sets out. |

**A configured model runs the round, or the round fails at setup.** The adapter
passes it as an argument of its own, never through a shell's parsing. Where no
model is configured, the command line and the environment are exactly what they
are without the setting. A CLI that falls back to another model when handed one
it does not offer is checked in `confine` first; one that refuses such a model
before its first request is left to refuse it. Either way the round fails as a
setup problem, with no review run and nothing spent, and the reason names
`model` and its value:

```
"model" in .squiz.json is "openai/gpt-5", which is not a model pi offers; it must be a provider and model as pi --list-models lists them, such as "openai/gpt-5-mini"
```

Where a run completed no message, the round adds the model it was handed to the
reason: the configured one, or else the user's default as the adapter reads it.

```
the reviewer completed no message; "model" in .squiz.json is "gpt-5-nano", which the reviewer's CLI may not offer
the reviewer completed no message; .squiz.json sets no "model", and the user's default, "gpt-6-astra", may not be one the reviewer's CLI offers
```

**An adapter may ship files its CLI runs**, where reporting a finding or running a
history tool needs one: an extension the CLI loads, or a server it starts. Each
is the adapter's own, it is named on the command line `argv` builds, and the
names it registers are in `grants`. The `pi` adapter ships an extension, and the
Copilot adapter ships a server.

**Every reporting call is checked by the harness's own report checks, whatever
serves it.** They decide what a report must carry, and refuse one the harness
could not compose a comment or a mutation from. A CLI may convert an argument
before the checks see it, as `pi` does, or validate nothing, as Copilot does. The
schema the model is shown guards nothing.

**A finding reaches the harness as `read` reads it out of the report file, and
so does the run's cost.** An adapter whose CLI cannot report before the run ends
reports everything at the end, so its rounds keep nothing when they are killed.
One whose CLI reports its cost only at the end writes the cost then, and a run
stopped before that has no cost.

**A reviewer CLI must exit on `SIGTERM`, and so must every process it starts.**
The time bound signals the reviewer's process group and waits a grace before
escalating. An adapter for a CLI that ignores `SIGTERM` is not one this harness
can hold.

**The exit status does not say how a run ended.** A CLI can exit 0 when it was
stopped, as Copilot does. A run declared its review finished where the report
file holds the finish, and the round knows when it stopped a run itself. Nothing
else is read for it.

**The history tools run inside the reviewer's own group**, in the extension `pi`
loads and in the server the Copilot adapter ships, so the signal that stops the
reviewer stops the `git` they start.

**Each adapter tells the history tools where the snapshot is:**

| Adapter | Where the history tools find the snapshot |
|---|---|
| `pi` | The directory `pi` was started in, which is the snapshot, as for the reads the extension confines. |
| Copilot | `SQUIZ_SNAPSHOT`, the snapshot's absolute path, which the adapter puts in the `env` of the reporting server's MCP configuration (The Copilot adapter). |

A history tool that finds no snapshot named answers with its error and runs
nothing.

### The Copilot adapter

The adapter for the GitHub Copilot CLI, which a project chooses with
`"reviewer": "copilot"`. It must:

- **Run Copilot non-interactively, in a pane and detached alike**, so that it
  exits by itself once the reviewer's last message is written, with nobody to
  answer it.
- **Hand Copilot the prompt byte for byte**, read from its file as Copilot
  starts, so that no newline reaches the line a pane's shell reads. The prompt
  must fit in one argument, which Linux limits to 128 KiB, and nothing here
  handles a longer one.
- **Put the charter in the system prompt**, as the instructions of a custom agent
  the adapter writes into its own `COPILOT_HOME`, where it wins over a tree's
  agent of the same name.
- **Grant exactly the tools Tools names**, which disables every other tool,
  `skill` and every shell tool among them.
- **Confine reads to the snapshot** with Copilot's own path check, with the
  temporary directory taken out of it (Confinement).
- **Keep the tree's and the user's configuration out:**
  - its own `COPILOT_HOME`, holding the agent file and no trusted folders, so
    that none of the tree's hooks or MCP servers runs, and a `config.json`
    holding only who the user is signed in as;
  - `COPILOT_ALLOW_ALL` set empty, since `true` would trust the working directory;
  - the tree's custom instruction files left out of the system prompt;
  - the built-in GitHub MCP server off;
  - no directory added with `--add-dir`, which would load its skills and agents
    as trusted.

  None of the user's own Copilot configuration reaches the reviewer except its
  default model, where the project configures none, and the `loggedInUsers` and
  `lastLoggedInUser` of its `config.json`, which are how it signs in (Tools).
  Every other field, the tokens and the trusted folders among them, is left
  out. A `config.json` that is there and cannot be read, or does not hold a
  JSON object, fails `confine`. The reviewer reads the tree's `AGENTS.md` with
  `view`, as the charter tells it to.
- **Reach no host but Copilot's own and its model's**: `--no-auto-update` and
  `--disable-client-telemetry` on every run. Measured on Copilot 1.0.107, a
  review then reached `api.github.com` and the plan's model host, which on the
  one plan measured was `api.enterprise.githubcopilot.com`, and nothing else.
  Without the two flags it also reached `cafe.github.com` and
  `telemetry.enterprise.githubcopilot.com`. Another plan's model host has not
  been measured.
- **Set the reasoning effort on every run**: `thinking` as it is, and `off` as
  `none`.
- **Start the reporting server the adapter ships**, with `SQUIZ_REPORTS` and
  `SQUIZ_SNAPSHOT` in the `env` of its MCP configuration.
- **Append the run's usage to the report file only where Copilot exits 0 by
  itself.**

**The reviewer runs on the configured model, or else the user's default, and
either one goes on `--model`.** Copilot refuses a model the user cannot use
before any request, exiting 1 and spending nothing. Handed the same model only
through `COPILOT_MODEL`, it runs on some other model and exits 0. A model Copilot
does not offer therefore fails the round at setup, whichever of the two named it.

A configured `model` is Copilot's own name for it, such as `gpt-5-mini`, and is
the script's `$1`. `confine` then hands over no `COPILOT_MODEL`.

With no `model` configured, `confine` reads `model` from the user's own
`settings.json`, under `~/.copilot/` or the `COPILOT_HOME` the user set, and
returns it as `COPILOT_MODEL`. A `COPILOT_MODEL` already in the round host's
environment is the user's default, and is returned in place of the setting. The
script puts a non-empty `COPILOT_MODEL` on `--model`, so that a pane, which runs
with the variables the round hands it, refuses the model as a detached run does.
A `settings.json` that is there and cannot be read, or does not hold a JSON
object, fails `confine`. Where the user has neither, `confine` returns
`COPILOT_MODEL` set empty, so that one a pane's server carries never reaches
`--model`. The round then runs on whatever Copilot falls back to, which may be
the coding agent's own model.

#### The reporting server

**The reporting calls and the history tools are served by an MCP server the
adapter ships**, over standard input and output. It lists the three reporting
calls with the schemas the report checks declare, and writes the same lines to
the report file as `pi`'s extension does. It lists the three history tools after
them, and runs each in the directory `SQUIZ_SNAPSHOT` names. A call to a tool the
server does not serve is a protocol error. Copilot hands the server its own
environment, so the emptied GitHub credentials reach it too.

**The server checks every call itself, because Copilot validates none.** A
reporting call must meet the report checks, and a history tool's arguments must
match its schema before it runs. Either refusal, and a history tool that failed,
is answered with `isError: true` and the reason as its text, which Copilot hands
to the model as the call's error:

```
MCP server 'squiz': git_blame was not run: line must be an integer.
```

Nothing converts an argument first, so a report records what the model sent.

**The server goes on answering while a history tool runs.** A
`notifications/cancelled` naming a running history tool stops its `git`, and
that call is not answered. The server exits when its standard input closes, and
on `SIGTERM` and `SIGHUP`.

#### How the run ends and is read back

**Copilot exits by itself whether or not the reviewer finished its review**, so
the finish in the report file is what says it did. The usage line Copilot's run
leaves reads as:

| Figure | Read as |
|---|---|
| Tokens | The sum, over every model in `modelMetrics`, of `inputTokens` and `outputTokens`. `inputTokens` already holds cache reads and cache writes. |
| AI credits | `totalNanoAiu`, at 10⁹ to a credit. |
| Messages | The sum, over every model, of `requests.count`. |
| Models | Each model in `modelMetrics` whose name is not blank and whose `requests.count` is a number above zero, in the order the file lists them. |

A Copilot round has no dollar figure. A usage line with no model in
`modelMetrics`, or with a model that lacks `inputTokens` or `outputTokens`,
reports no usable cost.

| The file holds | The run |
|---|---|
| A finish | Reviewed |
| No finish, and a usage line counting at least one request | Stopped without finishing |
| No finish, and no usage line or one counting no request | Completed no message |

A run that wrote nothing to the report file completed no message: Copilot could
not be started, its model provider refused the run, or Copilot refused the
configured model. Detached, the round adds the run's stderr to the reason.

**A Copilot round records a cost only where Copilot ended by itself and its
usage line carried token counts.** That cost is Copilot's own total, and is never
a floor. Any other round records no cost and names no model, because the usage
line is the only place a Copilot run names one. A round the time bound stopped
leaves no usage line.

**The reviewer's process group holds everything the run starts**, the reporting
server and the `git` its history tools run included, and nothing in it traps a
signal.

The round writes the command that resumes the run's session to `resume.txt`:

```
COPILOT_HOME=.squiz/41/rounds/2/session copilot --resume=99b4a257-0666-4e1f-a9a2-94d9c79b14be
```

## 8. Failure modes

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
  cannot read (§ 7).
- **`.squiz/<number>/host.log`**, where the round host writes a line for each
  thing it did, and where its own stderr goes. It is the only surface for what
  the host does outside a round.
- **`squiz review`'s stderr**, one line for each thing that failed, as The
  command's stderr below sets out.
- **The summary's Notes**, which the round that closes the episode writes (§ 6).
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
| The round host's start cannot be told | The process that starts the host failed or answered nothing readable after it may have started the host, or the host's start time could not be read. A live process holding the host lock means the host started, and `squiz review` waits on it. Where no live process holds the lock within 10 seconds of the start, or by the run's deadline where that comes first, `squiz review` exits 1, and stderr names `squiz status` and `.squiz/<number>/host.log`, as § 7 `squiz review` shows. The state stays queued, and the next trigger starts a host for it. | Hook stderr, `squiz review` stderr |
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
| The reviewer exceeds the review budget | Exit 1, unless the round holds the reviewer's declaration, as the end of this row says. The reviewer process is killed, what it reported before the kill is posted, and the failure comment and stderr say how many findings arrived. The same line then says what squiz saw during the round, and never what caused the kill. For a `pi` reviewer it gives how many messages the reviewer completed, with the bound's seconds averaged over them, and how many requests its provider failed, quoting the first line of the last one's error. A Copilot round's line adds nothing of that, because Copilot reports neither while it runs. Where the machine slept during the review, the line ends by saying for how long, as in "the machine slept for 13 minutes of the round", whichever reviewer ran. The round is recorded as a failed round rather than a clean one, whatever it posted, and the summary that closes the episode notes that the bound cut it short. A round that already holds the reviewer's declaration is the review it declared instead, because the review was finished before the bound was reached, unless one of its reports could not be read back. That round posts no failure comment, and exits 0, 2 or 3 as its outcome says. | Failure comment, `squiz review` stderr, `squiz status`, `host.log`, summary's Notes |
| A reviewer's pane cannot be closed | The reviewer is already stopped, and its pane stays open on the person's screen. | `host.log` |
| A round's snapshot cannot be removed | The snapshot stays on disk, and the round's result stands. `host.log` names its path and why it could not be deleted (§ 5 The snapshot). | `host.log` |
| GitHub is unreachable | Exit 1 and nothing is posted, the failure comment included. Nothing is stored to retry. Where the episode ends having posted nothing, stderr says so. A trigger whose calls cannot reach GitHub queues nothing. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| `gh` cannot be run at all | Exit 1, nothing posted, the failure comment included, and no review runs. stderr names the call that needed it and says `gh` could not be run. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| The calls before the review run out of time | Exit 1, and no review runs. A snapshot that the fetch, the clone and the checkout could not make within the part is this row too. The failure comment and stderr say which call had nothing left, where the posting reserve can still reach GitHub. A lookup that ran out of time is never read as a branch with no pull request. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The threads on the pull request cannot all be listed | Exit 1, and no review runs. The failure comment and stderr say so. The pages that arrived are dropped, because a reviewer handed a subset rules on a subset. A trigger whose listing fails queues nothing. | Failure comment, `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| A verdict cannot be applied | A verdict whose mutation GitHub refuses leaves its thread as it was handed over, and the round counts the thread that way. A verdict naming a thread that was not handed over, and a second verdict for one thread, are not sent. The round's outcome stands. stderr names each with its thread, what the reviewer ruled, and why it was not applied, which for a refused mutation is what GitHub answered. `squiz status` does the same for a round that reviewed. The summary that closes the episode, and the failure comment of a round that failed, name each as § 6 What the comment carries shows, without GitHub's answer. Nothing is retried. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| Some comments post and others fail | The comments that landed stay, the round exits as its outcome says, and stderr says how many could not be posted. A later round makes the rest again. A round that closes the episode lists each in its summary's Notes, and a round that fails lists each in its failure comment. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| The reviewer's reason cannot be posted | The verdict stands, and the thread stays in the state the reviewer ruled. The round's outcome stands. stderr names the thread and what GitHub answered, and so does `squiz status` for a round that reviewed. A round that closes the episode names the thread in its summary's Notes, without GitHub's answer. Nothing is retried: the next round that keeps the thread open posts a reason of its own. | `squiz review` stderr, `squiz status`, summary's Notes |
| The reply on a thread the round closes cannot be posted | The thread is resolved all the same, and the verdict stands. The round's outcome stands. stderr names the thread and what GitHub answered, and so does `squiz status` for a round that reviewed. The round records the line in its entry of the state file, and the summary that closes the episode names it in Notes, without GitHub's answer, whichever round it was. A round that fails names it in its failure comment instead. Nothing is retried, because no later round closes the thread again. | `squiz review` stderr, `squiz status`, summary's Notes, failure comment |
| A round that leaves threads open has findings no thread holds | A finding about the change as a whole, one the harness could anchor to neither a line nor a file, and one whose comment could not be posted reach no thread, and a round that leaves threads open posts no summary. The round's record keeps each. `squiz review` prints each on stderr, and the summary that closes the episode lists each that no later round settled (§ 6). | `squiz review` stderr, summary's Notes |
| No finding posts | A round that found findings and posted none of them is a failed round, whatever its verdicts did: exit 1, recorded failed with the reason "round 2 found 3 findings and could not post them to PR #41", and a failure comment where GitHub takes one. It posts no summary and does not close the episode. A new commit, a new reply or a run of `squiz review` retries it where a round remains, and closes the episode where none does, as The failure comment below says. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The posting reserve runs out before the findings are posted | Exit 1, and the findings are reported on stderr as unposted rather than as comments that landed. No failure comment is posted, because the reserve it would be posted in is spent. Nothing is attempted past the end of the reserve. | `squiz review` stderr, `squiz status`, `host.log` |
| The round's spend cannot be written | Exit 1, and nothing the reviewer found is posted. The failure comment and stderr say nothing was posted, and give the underlying error. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The round's end cannot be written to the episode's state | Exit 1, and no summary is posted, because the end, and the close where the round closes the episode, is written before the summary. The findings and verdicts the round posted stand, and the failure comment and stderr name the write that failed. The episode then reads as one still open, and the next run reviews the pull request again. A close reached before any review fails the same way, with nothing posted but the failure comment. | Failure comment, `squiz review` stderr, `squiz status`, `host.log` |
| The round's result cannot be recorded | The round host could not write what the round reached, after the round posted it. The host names the result and the reason, and exits. What the round posted stands. The reviewing record still names the host, so once the host has exited `squiz status` shows the round killed. A `squiz review` already waiting on the round sees no result and exits 4 at its deadline. A later run exits 1 saying the host stopped before its round ended, unless the round had closed the episode, which it then prints as closed. | `host.log`, `squiz status` |
| A round's posting time or resume command cannot be written | The round's result stands. A round with no resume command shows `—` under Resume in `squiz status`. | `host.log` |
| The summary comment cannot be posted | The close is a close still rather than a round the harness failed, and the command exits 0 or 3 as the close does. stderr says the episode closed without its summary, and names what GitHub answered or that the reserve was spent. Nothing is retried, because a second attempt would be a second comment. `squiz review` prints the line for the run that waited on the close, and for every later run on the closed episode, whether the close came after a review or before one. `squiz status` prints it under the line of a round that reviewed. `host.log` holds it after the close's own line, for a close before the review as well as after one. | `squiz review` stderr, `squiz status`, `host.log` |
| The episode closes before any round ran | An episode whose failed attempts spent the token bound before any round reaches this. It closes as § 6 says, and exits 3 because no round reviewed the state: with the summary and the open threads where those attempts left any of the reviewer's threads, and with a line on stderr where they left none. | Summary's Notes, `squiz review` stderr |
| The harness itself throws | A throw in a command is trapped at its top level, which writes one line on stderr. A throw inside a round fails the round: it is recorded failed with the throw as its reason, and posts no failure comment. `squiz review` exits 1. The hook exits 0, as it does on every path. A throw in the round host outside a round ends the host, and the round it held reads as killed. | `squiz review` stderr, `squiz status`, `host.log`, hook stderr |
| No wake reaches the owner of the work | The note stays in `.squiz/<number>/notes/`. The owner learns the result from `squiz review` or `squiz status`, and the pull request holds it. A note that cannot be written is reported the same way. | `host.log` |
| The round cap is reached | Exit 3, or 0 for the state the closing round reviewed where nothing is open. Findings still unresolved stay open, and the summary comment reports them. | Summary's Notes, `squiz status` |
| The token bound is reached | Exit 3, or 0 for the state the closing round reviewed where nothing is open. The episode closes without starting another round, and the summary comment reports that the bound was reached rather than reporting the round as one the reviewer failed. | Summary's Notes, `squiz status` |
