---
name: cutting-releases
description: For a project that has shipped and tracks releases in GitHub milestones. How a release's GitHub milestone becomes a version bump, a tag and a GitHub Release. Load BEFORE cutting a release.
user-invocable: true
---

# Cutting releases

Turn a finished milestone into a version users can install, and leave a record
of what is in it.

**Cutting a release is the owner's call.** Do it only when asked.

Versions follow semantic versioning, and each number counts up without limit, so
`0.9.0` is followed by `0.10.0`. GitHub's latest release is the version users
have.

## 1. Check the milestone is done

```bash
release=0.1.0
gh api "repos/{owner}/{repo}/milestones?state=open" \
  --jq ".[] | select(.title == \"$release\") | \"#\(.number) \(.open_issues) open\""
```

An open issue left in it is the owner's to move or finish. Name each one and
stop. Never move one to the next release yourself.

## 2. Bump the version in a pull request

`AGENTS.md` names every file that carries the version, such as `package.json`,
its lock file and a plugin manifest. Set each to the release's version. Where
`AGENTS.md` says a specification's version moves once a release, bump it in the
same pull request.

Find any file `AGENTS.md` missed before trusting the list:

```bash
git grep -nE '"version":\s*"[0-9]+\.[0-9]+\.[0-9]+"' -- ':!**/node_modules/**'
```

**Load the `writing-pull-requests` skill** before `gh pr create`. Run the
project's checks, because a test can pin the version.

Merging follows the project's own rules for merging.

## 3. Tag and publish from the merge

Once the pull request merges, read the merge commit and confirm that `main`'s
own run for it passed. A tag on a red commit ships the failure.

```bash
sha=$(gh pr view <n> --json mergeCommit --jq .mergeCommit.oid)
gh run list --branch main --commit "$sha" --json conclusion,status --jq '.[]'
gh release create "v$release" --target "$sha" --title "$release" --generate-notes
```

Tag the merge commit, not `main`. `main` may have moved since, and the release
would then hold work its milestone never planned.

## 4. Close the milestone

```bash
number=$(gh api "repos/{owner}/{repo}/milestones" \
  --jq ".[] | select(.title == \"$release\") | .number")
gh api -X PATCH "repos/{owner}/{repo}/milestones/$number" -f state=closed
```

Then say which release is next. Where the owner has named it, create its
milestone; where not, ask.

## Resources

- `AGENTS.md` — the files that carry the version, and whether a specification's
  version moves with a release
- The `writing-pull-requests` skill — the version bump's pull request body
- The `triaging-issues` skill — how the next release's issues are chosen
