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
mkdir -p docs/specs issues
cat > docs/specs/review-harness-spec.md <<'EOF_FIXTURE'
# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 4. The venue

**The venue is where a review happens.** Squiz has two:

| Venue | The change | The record | Used for |
|---|---|---|---|
| **GitHub** | A pull request, at its head commit | Review threads and comments on the pull request | Every review, unless `SQUIZ_VENUE` is `local` |
| **Local** | The working tree, against the commit its work started from | Files in `.squiz/local/` in the worktree | A change with no remote and no pull request |

### Choosing the venue

**Every squiz process chooses its venue from `SQUIZ_VENUE`, the same way.**

| `SQUIZ_VENUE` | The venue |
|---|---|
| Unset, the empty string, or `github` | GitHub |
| `local` | Local |
| Anything else | None. Nothing is reviewed. |

The hook, the round host, `squiz review`, `squiz threads`, `squiz reply` and
`squiz status` each read the variable for themselves. A coding agent's hooks and
shell inherit it from the run, and the round host inherits it from the trigger
that started it, so all of them agree.

A value that names no venue reviews nothing. `squiz review` exits 1 and the hook
says why on stderr:

```
squiz: no review ran: SQUIZ_VENUE is "lcoal", and squiz has the venues github and local
```

The local venue's start hook writes `.squiz/local/base.json`, the commit the
work started from, when a session starts.

## 10. Adoption

### Configuration

`.squiz.json`, at the root of the repository's main worktree, is read from there
whichever worktree is under review. Where the main worktree holds no
`.squiz.json`, every setting takes its default.

| Setting | Default | |
|---|---|---|
| `reviewer` | `pi` | The reviewer CLI, `pi` or `copilot` |
| `rounds` | 3 | The round cap, settable 1 to 8 |
| `timeout` | 900 | Seconds one round's reviewer may run, settable 60 to 3,600 |

A setting outside its range, or of a type the table does not give it, is
rejected with an error naming the setting, the value given and what was
expected. A key the table does not name is rejected the same way.

### The setup check

`squiz doctor` prints a line per dependency and setting it checks, saying it is
present or naming what is missing.
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
