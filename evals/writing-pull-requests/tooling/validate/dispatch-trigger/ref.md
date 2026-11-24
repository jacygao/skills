# Let a CI run be started by hand

## Intent

- GitHub started no CI run for #248's branch across a push, a close and reopen, and an empty commit, while other branches ran. Why is not established.
- The workflow could not be started by hand either, so that branch has no checks at all, which reads like a repository that runs none.

## What changed

- The CI workflow also accepts a manual run (`workflow_dispatch`), so a branch whose run GitHub dropped can get one. The jobs and the existing triggers are unchanged.

## Risks

- **Low: it recovers from a dropped run, it does not prevent one.** A branch whose run is dropped still shows no checks until someone starts one.

## Verification

```
npx tsc --noEmit
```

- The manual run is not shown here. GitHub offers it only for a workflow whose `workflow_dispatch` is on the default branch, so it can be tried, on #248's branch, only after this merges. This pull request's own run is a `pull_request` event and says nothing about the new trigger.
