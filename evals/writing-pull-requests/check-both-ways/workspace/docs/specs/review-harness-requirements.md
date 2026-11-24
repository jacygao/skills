# Requirements of the review harness spec

This is the working list for rewriting `docs/specs/review-harness-spec.md` one H2 per pull request, and it is deleted when the rewrite ends. Each line cites the spec lines it comes from, and `also` names the lines that state it again, which the rewrite removes.

## 1. Purpose

### 1.0 Preamble

- **R1.0.1** When a coding agent finishes a piece of work, a reviewer agent reviews it; the reviewer may run a different model and a different harness from the coding agent. (L7–10)
- **R1.0.2** The two agents work the findings over as many rounds as it takes, and everything they say to each other is kept as review comments on the pull request. (L10–13)

## 4. The venue

### 4.0 Preamble

- **R4.0.1** Squiz has two venues. `github` reviews a pull request at its head commit and keeps the record as review threads and comments on it. `local` reviews the working tree against the commit its work started from and keeps the record in `.squiz/local/` in the worktree. (L1185–1192; also L12–15, L4224, L13–15)
- **R4.0.2** The loop is the same in both venues: the state file, the hooks, the queue, the round host, the owner's note and its wake, the round cap and the budget. (L1194–1197)
- **R4.0.3** The local venue needs `git` and does not need `gh`, a remote, a pull request or an issue. (L1404; also L20, L1665, L19–20)

## Decisions

### Features

- **PQ-A1, the local venue: kept.** A user chooses whether a review's record is kept on GitHub or in local files. Consolidating it with the GitHub venue is left for later.
