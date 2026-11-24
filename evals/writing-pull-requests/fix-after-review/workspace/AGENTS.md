# Working in this repository

Squiz is a review harness: it runs an AI reviewer on a coding agent's pull
request, posts the findings as review threads, and hands them back to the agent.

## Specs

`docs/specs/review-harness-spec.md` is the specification, and
`docs/specs/milestones.md` the milestones that build it. This checkout holds
only the sections of each spec the current work touches, and of the code only
`src/cli.ts`; the omitted sections and the code exist, and cross-references to
them are correct.

## Notes

`docs/notes/` holds durable findings: what earlier work established, recorded so
that it is read rather than re-derived.

## Checks

```bash
npm run typecheck && npm test
```

## Pull requests

**Load the `writing-pull-requests` skill before opening a pull request.** Every time, without being asked.

GitHub is not reachable from this environment, so do not run `gh`. The pull
request for this branch is #251, and `pr/251.md` holds it as it stands on
GitHub: the title on the first line as `# <title>`, a blank line, then the
body. Update `pr/251.md` in place instead of running `gh pr edit`, keeping that
format, with the body exactly as it would be passed to `gh pr edit --body`.
