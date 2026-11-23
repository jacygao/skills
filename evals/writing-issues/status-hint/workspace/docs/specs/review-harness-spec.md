# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 7. Commands

Everything the harness ships to be run is a subcommand of one binary, `squiz`,
run from a shell.

| Command | Run by | What it does |
|---|---|---|
| `squiz review <number>` | The coding agent, a coordinator, a CI job | Reviews pull request `<number>` once for each head commit and each new reply on the reviewer's threads, waits for the review, and prints what is open. |
| `squiz status` | A person, a coordinator | Lists the reviews running and finished in every worktree of the repository. |
| `squiz threads` | The coding agent | Lists the open threads on the pull request for the current branch. |
| `squiz reply <id> <text>` | The coding agent | Replies in a thread. |

### `squiz review`

`squiz review <number>` runs from the worktree pull request `<number>`'s branch is
checked out in, and waits for the review within one deadline for the whole
invocation. A run that failed before any round prints one line saying why, then
the line to stop. The lines saying why:

```
squiz: no review ran: PR #41's head is "feature-a", and "/work/squiz" has "main" checked out
squiz: no review ran: PR #41 is closed
```

A round host whose start cannot be told is waited on once a live process holds
`.squiz/<number>/host.lock`. Where none holds it within 10 seconds, or by the
run's deadline where that comes first, the run exits 1 saying where to look:

```
squiz: no review ran: whether the round host for PR #41 started could not be told, and none has taken the review since: the intermediate process exited 1: spawn node ENOENT
squiz: `squiz status 41` shows whether one takes it later, and .squiz/41/host.log holds what the host wrote
squiz: put these lines in your report rather than running squiz review again
```

### `squiz status`

`squiz status` lists every review recorded in any worktree of the repository,
one line per pull request state, newest first. It starts nothing and asks
nothing of GitHub.

```
PR    Commit   Replies  State      Started   Elapsed  Result         Session           Worktree
#41   9e01b2c  OmQx7a   queued     —         —        —              —                 .claude/worktrees/agent-a5336e10
#41   8d21a4f  OmQx7a   reviewing  07:13:05  3m 12s   —              tmux squiz-41-r3  .claude/worktrees/agent-a5336e10
#38   a1b2c3d  —        failed     06:40     8m 00s   the reviewer was stopped at the time bound  detached  .claude/worktrees/agent-a077fff7
```

## 9. Failure modes

| Failure | What happens | Where it is reported |
|---|---|---|
| The round host cannot be started | The state stays queued with no host to take it, and the next trigger starts one. `squiz review` exits 1. | Hook stderr, `squiz review` stderr |
| The round host's start cannot be told | The process that starts the host failed or answered nothing readable after it may have started the host. Where no live process holds the lock within 10 seconds of the start, or by the run's deadline where that comes first, `squiz review` exits 1, and stderr names `squiz status` and `.squiz/<number>/host.log`, as § 7 `squiz review` shows. The state stays queued, and the next trigger starts a host for it. | Hook stderr, `squiz review` stderr |
