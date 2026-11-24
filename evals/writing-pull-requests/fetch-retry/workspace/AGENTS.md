# Working in this repository

SWE-drill runs coding agents on benchmark tasks through Harbor, grades each
trial, and ranks the arms on a leaderboard.

`docs/specs/swe-drill-spec.md` is the specification. This checkout holds only
the files the current work touches, and those a reviewer needs beside them:
the spec, the agents under `src/swe_drill/agents/`, `src/swe_drill/copilot.py`,
the judge that installs Copilot CLI, and the Copilot agents' tests. The rest of
the repository exists.

## Checks

```bash
uv run pytest
```

## Pull requests

**Load the `writing-pull-requests` skill before opening a pull request.** Every time, without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
pull request to `pr/new.md` instead: the title on the first line as
`# <title>`, a blank line, then the body exactly as it would be passed to
`gh pr create --body`.
