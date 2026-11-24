# Working in this repository

squiz is a local review loop that lives on the pull request: a reviewing agent
reads a coding agent's change and leaves its findings on the pull request. It
is a TypeScript Claude Code plugin; CI runs its type check and tests.

This checkout holds only the files the current work touches: the CI workflow,
`.claude/rules/merging.md` and `package.json`. The rest of the repository
exists.

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
