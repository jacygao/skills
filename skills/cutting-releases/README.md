# cutting-releases

For a project that has shipped and tracks releases in GitHub milestones. It
turns a finished milestone into a version bump in a pull request, a tag on the
merge commit, a GitHub Release, and a closed milestone. It runs only when the
owner asks.

## Load it

Its description loads it before cutting a release.

## What to add to AGENTS.md

```markdown
## Skills

- Load `cutting-releases` before cutting a release.

## Releases

- The version is in `package.json`, `package-lock.json` and
  `.claude-plugin/plugin.json`.
- <whether a specification's version moves with each release>
```

It still searches the repository for a version it was not told about, but a
file missing from this list is easy to miss.

## Eval

No eval yet.
