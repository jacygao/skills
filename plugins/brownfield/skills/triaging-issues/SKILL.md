---
name: triaging-issues
description: How open GitHub issues get a priority and a release milestone, and how a release's issues are made small enough for one pull request each. Load BEFORE triaging issues or planning a release.
user-invocable: true
---

# Triaging issues

Give every open issue a priority and a place, so that what to work on next is a
listing rather than a judgement made again each session.

A release is a GitHub milestone named by its version, such as `0.1.0`. `Backlog`
is a milestone too, for issues no release has taken yet. **Which issues a release
holds is the owner's call.** This skill proposes, applies what the owner agrees
to, and stops.

## 1. Know what the labels mean

Read the project's `AGENTS.md` for its definitions. Where it gives none, these
hold:

- **`P0`** blocks the release it is in: a user on the default setup gets no
  result, or a wrong one, in ordinary use.
- **`P1`** is wanted in the next release or the one after: real users, or the
  project's own CI, will hit it.
- **`P2`** waits in `Backlog` until a release's theme pulls it in.

Make sure the labels and the `Backlog` milestone exist. Both are safe to repeat:

```bash
gh label create P0 --color B60205 --description "Blocks the release it is in" --force
gh label create P1 --color D93F0B --description "Wanted in the next release or the one after" --force
gh label create P2 --color FBCA04 --description "Backlog, worked when a release's theme pulls it in" --force
gh api "repos/{owner}/{repo}/milestones?state=all" --jq '.[].title' | grep -qx Backlog \
  || gh api "repos/{owner}/{repo}/milestones" -f title=Backlog \
       -f description="Triaged and not planned into a release yet."
```

## 2. Read every issue being triaged

List what has no milestone or no priority:

```bash
gh issue list --state open --limit 500 --json number,title,labels,milestone \
  --jq '.[] | select(.milestone == null
                     or ([.labels[].name] | any(test("^P[012]$")) | not))
        | "#\(.number)\t\(.milestone.title // "-")\t\(.title)"'
```

Read each body and its last comments, not just the title. A title says what was
seen; the body and comments say what it costs and what has changed since.

Read issues with `--json` throughout, never the rendered text output. That
output is laid out for a person reading a terminal, and its shape is not a
contract.

## 3. Propose

Group the proposal by priority. For each issue give one line: its number, what
it costs a user in plain words, and why that priority. Then:

- **Duplicates**, each with the issue it duplicates
- **Issues already answered** by another issue's evidence or by merged work
- **Issues to fold into another**, where two describe one fault

Recommend which issues the next release holds, with a one-line theme for it. A
release is small: one theme, about five to ten issues, done in a week or two.

For a bulk triage, present the proposal and wait for the owner. For a single
issue filed in the course of other work, apply it directly and say why in the
issue.

## 4. Apply

```bash
gh issue edit <n> --add-label P1 --milestone 0.1.0
gh issue edit <n> --add-label P2 --milestone Backlog
```

Close a duplicate or an answered issue with a comment saying why, and never
delete one. The comment is the record of the judgement:

```bash
gh issue close <n> --reason "not planned" --comment "Closed as a duplicate of #<m>, which <why it is the one to keep>."
```

Verify that nothing open is left without both:

```bash
gh issue list --state open --limit 500 --json number,labels,milestone \
  --jq '[.[] | select(.milestone == null
                      or ([.labels[].name] | any(test("^P[012]$")) | not))] | length'
```

It must print `0`.

## 5. Split what is too large for one pull request

Most issues are already one pull request. Split only an issue in the release
that is not.

One subtask is **one isolated, complete purpose**:

- **Independently green.** Its checks pass, and merging it alone cannot break
  `main`. A part that only passes once its sibling lands is not a part
- **`main` stays releasable** after it merges
- **Describable in one sentence with no "and".** If the sentence needs an "and",
  it is two subtasks

Split at a seam, not at a line count: a directory with its own reason to change,
a pure transform under an I/O wrapper, a decision one part makes and the next
consumes. Put the dangerous code in its own subtask, away from the large
mechanical thing sitting next to it.

**Load the `writing-issues` skill** before the first `gh issue create`. The issue
being split becomes the parent. Add a `## Decomposition` section to its body
saying why these seams, and do not list the children in it; GitHub renders them.
Each sub-issue takes the parent's priority and milestone:

```bash
gh issue create --title "<one line, imperative>" --label task --label P1 \
  --milestone 0.1.0 --parent 42 --body "<body>"
```

Then set **every** sequential dependency in the release, between whole issues as
well as subtasks. Which are genuinely sequential, and which only look it because
of the order you thought of them? Where two touch the same line of a shared
file, say so in both issues, because the second to merge needs a rebase.

```bash
gh issue edit 45 --add-blocked-by 43 --add-blocked-by 44
```

Verify: a sub-issue that failed to attach, or a blocker that failed to post,
looks exactly like one that was never set.

```bash
gh issue view 42 --json subIssuesSummary --jq '.subIssuesSummary.total'
gh issue list --milestone 0.1.0 --state open --limit 200 \
  --json number,title,blockedBy \
  --jq '.[] | "#\(.number) \(.title) — blocked by \(.blockedBy.totalCount)"'
```

## 6. Present and stop

Print each release's issues with their priority, sub-issues and blockers, and
the frontier: the issues with no open blocker and no sub-issues.

```bash
gh issue list --milestone 0.1.0 --state open --limit 200 \
  --json number,title,blockedBy,subIssuesSummary \
  --jq '.[] | select(.subIssuesSummary.total == 0)
        | select([.blockedBy.nodes[] | select(.state == "OPEN")] | length == 0)
        | "#\(.number) \(.title)"'
```

Do not store the frontier in an issue. Readiness is true at the moment it is
computed and wrong after the next merge.

Then stop. Do not begin implementation; that is the `working-issues` skill, and
the caller starts it.

## Resources

- `AGENTS.md` — the project's own definitions of each priority, where it has them
- The `writing-issues` skill — how a sub-issue's body is written
- The `working-issues` skill — how a release's frontier is worked
- The `cutting-releases` skill — what happens once a release's milestone is empty
