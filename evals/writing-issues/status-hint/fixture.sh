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
mkdir -p docs/specs src/review issues
cat > docs/specs/review-harness-spec.md <<'EOF_FIXTURE'
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
EOF_FIXTURE
cat > src/review/review.ts <<'EOF_FIXTURE'
import { join, relative } from "node:path";

export async function awaitReview(context: ReviewContext, key: string, episode: Episode): Promise<number> {
  for (;;) {
    const state = readState(episode.directory);
    if (closedFor(state, key)) return print(closed(context, state));
    // A host that may not have started is waited on once a live one holds the
    // lock, and reported once its time to take the lock has passed.
    const window = Math.min(startBy.remaining(), until.remaining());
    if (startUnknown !== undefined && hostRunning(episode.directory, stillRunning, window)) {
      startUnknown = undefined;
    }
    if (startUnknown !== undefined && (startBy.passed() || until.passed())) {
      return print({
        outcome: "not run",
        key,
        reason: `whether the round host for ${context.name} started could not be told, and none has taken the review since: ${startUnknown}`,
        problems: [`\`squiz status ${key}\` shows whether one takes it later, and ${relative(episode.worktree, join(episode.directory, "host.log"))} holds what the host wrote`],
      });
    }
    if (until.passed()) return print(stillReviewing(context, state.records ?? []));
    await sleep(Math.max(1, Math.min(pollMs, until.remaining())));
  }
}
EOF_FIXTURE
cat > src/cli.ts <<'EOF_FIXTURE'
export async function main(argv: string[]): Promise<number> {
  const command = argv[0];
  if (command === "review") {
    return review(argv.slice(1));
  }
  if (command === "threads") {
    return listThreads();
  }
  if (command === "reply") {
    return postReply(argv.slice(1));
  }
  if (command === "status") {
    const chosen = venueAt(process.cwd());
    if (chosen.outcome === "failed") {
      reportFailure(`no reviews listed: ${chosen.reason}`);
      return 0;
    }
    const printed = squizStatus(process.cwd(), chosen.venue);
    process.stdout.write(printed.stdout);
    process.stderr.write(printed.stderr);
    return 0;
  }
  return usage();
}
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
