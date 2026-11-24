# Working in this repository

Suss measures and compares how well coding harnesses do specific kinds of
coding work: it runs the same SWE-bench Pro tasks under each harness, through
Harbor, and grades them by their hidden tests.

`docs/specs/suss-spec.md` is the specification. This checkout holds only the
files the current work touches, and those a reviewer needs beside them: the
spec, one note, `src/suss/`, and the tests of the agent and the harness. The
rest of the repository exists.

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
