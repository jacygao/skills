# Working in this repository

Squiz is a review harness: it runs an AI reviewer on a coding agent's pull
request, posts the findings as review threads, and hands them back to the agent.

## Specs

`docs/specs/review-harness-spec.md` is the specification, and
`docs/specs/milestones.md` the milestones that build it. `charter.md` is the
charter the harness hands the reviewer every round. This checkout holds only
the sections of each spec the current work touches, and none of the code; the
omitted sections and the code exist, and cross-references to them are correct.

**A spec's version number tracks commits.** A committed change bumps it; edits
sitting in the working tree do not.

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
