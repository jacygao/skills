# AGENTS.md

Load the `working-issues` skill before implementing an issue.

- Checks: `node --test`
- Source layout: code in `src/`, one module per file; tests in `test/`, named
  `<module>.test.js`
- GitHub is not reachable from this environment. Issues are in `issues/`, one
  file per issue, named by number. Do not run `gh`; work on a local branch and
  report instead of opening a pull request.
