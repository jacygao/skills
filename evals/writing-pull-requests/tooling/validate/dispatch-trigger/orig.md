# Let a CI run be started by hand

## Intent

- GitHub started no workflow run for #248's branch across three attempts: a push, a close and reopen of the pull request, and an empty commit made for the purpose. Other branches ran normally throughout.
- `.github/workflows/ci.yml` triggered only on `pull_request` and on a push to `main`, so there was no way to start one by hand either. The Actions tab offers no button for a workflow that declares no `workflow_dispatch`.
- That leaves a branch whose head has **zero** check-runs, which reads exactly like a repository that runs no checks. `.claude/rules/merging.md` says never to read a missing check as a passing one, and without this there is no way to get a conclusion at all.

## What changed

- `workflow_dispatch:` added to the triggers, with a comment saying what it is for.

## What did not change

- **The jobs, the steps and the other two triggers.** Nothing about what CI does.
- **Nothing about why GitHub dropped the runs**, which is not established. Actions is enabled with `allowed_actions: all`, the head sha returns `total_count: 0` for its runs, and pushing a further commit changed nothing — so a single lost push event is not the whole story.

## Risks

- **Low: a manual run is a manual step.** This does not prevent a dropped event, it gives a way to recover from one. A branch whose run was dropped still shows no checks until somebody starts one.

## Verification

```
npx tsc --noEmit
```

Clean. No source file changed. The trigger itself is proved by this pull request's own run appearing, and by a dispatched run on #248's branch producing a conclusion where pushes produced none.
