# Working in this repository

Squiz runs an AI reviewer on a coding agent's pull request, posts the findings,
and hands them to a fixer agent that works them.

## Working an issue

**Load the `working-issues` skill before implementing an issue.**

- Checks: `npm test`
- Source layout: code in `src/`, one module per file; tests in `test/`, named
  `<module>.test.js`
- GitHub is not reachable from this environment. Do not run `gh`. Issues are in
  `issues/`, one file per issue, named by number. Work on a local branch, and
  report where you would open a pull request.
- File a sub-issue as `issues/<parent>-<n>.md`, in the form of its parent, with
  a `Parent: #<parent>` line under the milestone.
