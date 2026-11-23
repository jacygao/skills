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
