# Working in this repository

SWE-drill runs coding harnesses through the same benchmarks, grades them the
same way, and publishes the ranking as a leaderboard site under `site/`.

This checkout holds only the site and the workflow that publishes it; the rest
of the repository exists, and references to it are correct.

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
