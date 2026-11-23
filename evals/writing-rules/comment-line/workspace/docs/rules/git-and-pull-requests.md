---
description: "Creating a branch, committing, opening a pull request, or deploying."
---

# Git and pull requests

## Branches

- **Name:** `<area>/<issue>-<short-name>`, for example `sync/15-token-checkpoint`,
  `ci/7-deploy-test-and-production` or `docs/4-sowie-privacy-policy`.
- **Use `tests/`, not `test/`,** for test-only branches. A branch named `test`
  exists, so git can't create anything under `test/`.
- **One issue, one branch, one worktree.** Agents work in `.claude/worktrees/`,
  and the primary checkout stays on `main`.
- **Remove a worktree and its branch** once its pull request merges.

## Commits

- **Prefix with the kind of change,** as the history does: `feat`, `fix`,
  `test`, `ci`, `docs`, `chore`, and a scope where it helps
  (`fix(api): …`, `feat(sync): …`).
- **No `Co-Authored-By` trailer, no "generated with" line and no session link,**
  in commits or in pull request bodies.

## Pull requests

- **Write the body with the `writing-pull-requests` skill,** using the sections
  that have something to say: Intent (with `Closes #N`), What changed, What did
  not change, Risks graded high or low, Verification with commands, Notes.
- **Verification names the command,** not just the number it printed.
- **Every PR check must pass.** If `ux/shared` fails only with the known
  `document is not defined` flake (#20), re-run it and say so in the PR.
- **Work squiz's review to the end:** nothing left open. See `AGENTS.md`.
- **Agents never merge.** The owner reviews and merges.

## Deploying

- **Merging to `main` deploys the web app and website to the test environment**
  (`deploy-test.yml`). Test shares production's database, so treat a merge as
  touching production data (#16 removes test).
- **Production deploys are run by hand:** `deploy-production.yml` for the web
  app and website. The content API is deployed to `ml-content-api-ae` by hand,
  with no workflow.
