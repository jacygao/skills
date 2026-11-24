# Working in this repository

Squiz is a review harness: it runs an AI reviewer on a coding agent's pull
request, posts the findings as review threads, and hands them back to the agent.

## Specs

`docs/specs/review-harness-spec.md` is the specification. This checkout holds
only the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

`docs/specs/review-harness-requirements.md` is the reviewed list of the
specification's requirements that its rewrite works from, one H2 per pull
request. It lives on #908's branch, `spec-requirements-list`, not on `main`,
and is copied here to be read; this checkout holds only its parts that the
current work touches. It cites spec lines as they were when the list was made.

**A spec's version number changes once a release.** The pull request that sets
the release's version bumps it. Every other pull request leaves it alone.

## Checks

```bash
npm run typecheck && npm test
```

## Pull requests

**Load the `writing-pull-requests` skill before opening a pull request.** Every time, without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
pull request to `pr/new.md` instead: the title on the first line as
`# <title>`, a blank line, then the body exactly as it would be passed to
`gh pr create --body`.
