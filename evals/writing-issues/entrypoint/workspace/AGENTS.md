# Working in this repository

SWE-drill runs coding agents on benchmark tasks through Harbor, grades each
trial, and ranks the arms on a leaderboard.

## Specs

`docs/specs/swe-drill-spec.md` is the specification. This checkout holds only
the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

## Checks

```bash
uv run pytest
```

## Issues

Each issue carries one label, `bug` or `task`.

**Use the `writing-issues` skill before writing an issue.** Every time,
without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
issue to `issues/new.md` instead: the title on the first line as `# <title>`,
then a line `Labels: <label>, <label>, ...`, a blank line, and the body exactly
as it would be passed to `gh issue create --body`.
