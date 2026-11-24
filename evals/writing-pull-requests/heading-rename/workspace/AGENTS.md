# Working in this repository

squiz is a local review loop that lives on the pull request: a reviewing agent
reads a coding agent's change and leaves its findings on the pull request.

This checkout holds only what the current work touches: § 1 to § 3 of the
specification and some of `docs/notes/`. The omitted sections, notes and
source exist, and references to them are correct.

## Specs

`docs/specs/review-harness-spec.md` is the specification.

**A spec's version number tracks commits.** A committed change bumps it; edits
sitting in the working tree do not.

## Notes

`docs/notes/` holds durable findings: what earlier work established, recorded so
that it is read rather than re-derived.

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
