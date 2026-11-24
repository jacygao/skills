# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.36 (draft)

## 1. Purpose

**Squiz automates code review between agents.** Whenever a coding agent
finishes a piece of work, a reviewer agent reviews it. The reviewer can run a
different model from the coding agent, and a different harness. The
two agents work through the findings over as many rounds as it takes to settle
them. Everything they say to each other is kept as review comments on the pull
request, where a person, or an agent trusted to merge, can see how each finding
was settled. A change with no pull request, such as a working tree in a
repository with no remote, keeps the same record in a directory instead (§ 4
The local venue).

## 2. Dependencies

Squiz runs on the developer's machine, and needs all three of these. The local
venue needs `git` in place of the GitHub repository, and no `gh` (§ 4).

| Dependency | Supported | Needed for |
|---|---|---|
| GitHub repository | `git`, and `gh` signed in | The pull request is where the review happens and is recorded. |
| Runtime | Claude Code / GitHub Copilot CLI | Runs the coding agent, and starts a review when the agent finishes its work. Copilot support is experimental (§ 3 The report). |
| Reviewer | `pi` / GitHub Copilot CLI | Reviews the change. It should run a different model from the coding agent, so that no model reviews its own work, but that is the user's choice, and squiz does not check it. Only the one `reviewer` names has to be installed. |

A terminal multiplexer is optional. Where tmux or Herdr is running, each
reviewer runs in a pane of it, where a person can watch it. Where neither is,
the reviewer runs detached, and a log holds its progress.

### GitHub access

The harness must be able to:

- Read a pull request: its description, its base and head refs, and the
  commit each names
- List the existing review threads and whether each one is resolved
- Create a review comment anchored to a file and a line
- Create a review comment on a file as a whole, carrying no line
- Reply inside an existing review comment thread
- Resolve a review thread, and re-open one
- Post an issue-level comment on the pull request, for the summary and for a
  round that failed

`gh pr comment` and `gh pr review` take a body only, so every anchored comment
goes through `gh api`. Resolving and re-opening a thread go through GraphQL,
since REST has neither.

### Identity

Every comment is posted with the credentials `gh` holds, so all of them appear
under the account that authenticated it. The reviewer, the coding agent and the
harness share one GitHub identity.

Each comment names its own author at the start of its first line, inside that
line's bold span. What follows the marker differs from comment to comment, so
the marker is the opening of the span rather than the whole of it.

| Written by | Begins |
|---|---|
| The reviewer | `**Squiz reviewer · ` |
| The coding agent | `**Squiz coding agent` |
| The harness, at close | `**Squiz review — ` |
| The harness, when a round fails | `**Squiz review failed — ` |

A comment without one of those markers was written by a person.

`**Squiz review` is a prefix of `**Squiz reviewer`, so a marker is matched up to
and including the character after the name.

## 4. The venue

**The venue is where a review happens.** It supplies the change under review,
holds the threads the reviewer opens and the coding agent replies on, and takes
the summary and the failure comment. Squiz has two:

| Venue | The change | The record | Used for |
|---|---|---|---|
| **GitHub** | A pull request, at its head commit | Review threads and comments on the pull request | Every review, unless `.squiz.json` sets `venue` to `local` |
| **Local** | The working tree, against the commit its work started from | Files in `.squiz/local/` in the worktree | Every review where `.squiz.json` sets `venue` to `local`: a change with no remote and no pull request |

§ 3 describes the loop in the GitHub venue's terms. The loop is the same in
both venues: the state file, the hooks, the queue, the round host, the owner's
note and its wake, the round cap and the budget. The local venue, below, says
what each of § 3's terms means there.

