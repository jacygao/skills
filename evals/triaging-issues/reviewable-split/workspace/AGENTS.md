# Working in this repository

Squiz runs an AI reviewer on a coding agent's pull request, posts the findings,
and hands them to a fixer agent that works them.

## Issues

**Load the `triaging-issues` skill before triaging issues or planning a
release.** **Load the `writing-issues` skill before writing an issue.**

GitHub is not reachable from this environment. Do not run `gh`. Issues are in
`issues/`, one file per issue, named by number, with their labels and milestone
under the title. File a sub-issue as `issues/<parent>-<n>.md` in the same form,
with a `Parent: #<parent>` line under the milestone.

## Checks

```bash
npm run typecheck && npm test
```
