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
cat > charter.md <<'EOF_FIXTURE'
# Review charter

You are the reviewer. A coding agent has just finished a change, and your job is
to read it and report what is wrong with it.

## What to report

Read the pull request description first, for the intent of the change and for
the scope it declares. A finding that contradicts something the description
declares out of scope is not a finding.

Report:

- correctness bugs
- convention violations
- security problems
- tests that assert nothing

Report every finding that holds, whatever its severity. Severity orders what you
return; it does not decide whether something counts.

## How to scope a finding

Reading beyond the diff is expected: untouched files, callers, history. Where
the defect is somewhere the change did not touch, the finding is still scoped to
`line`: anchor it to the changed line that caused it, and name the other file
and line in the reasoning.
EOF_FIXTURE
cat > docs/specs/review-harness-spec.md <<'EOF_FIXTURE'
# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 4. The reviewer

### Charter

`charter.md` is the standing instruction every reviewer is handed: what to
report, how to verify it, and how to scope it. The charter and this section
state the same rules.

### Findings

- `scope`: `line`, `file` or `change`, which decides inline, file-level or
  general.
- `severity`: `high`, `medium`, or `low`.
- `headline`, `reasoning`, `suggestedFix`, and an optional `reference`.

| Severity | |
|---|---|
| `high` | Wrong now, or a security problem, or it breaks a written convention. |
| `medium` | Wrong under conditions this change makes reachable, or a test that would pass with the code under it deleted. |
| `low` | Real, narrow, and survivable. |

Severity orders the findings and does not decide whether they count.

### Pull request comments

A finding scoped to a line or a file is posted as a review thread. A finding
scoped to the change goes into the summary comment as a line of text.

A round that leaves any thread open keeps the review going: `squiz review` exits
2, and the coding agent works the threads.
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
