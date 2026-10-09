---
name: executing-milestones
description: How a planned milestone's issue tree from docs/specs/milestones.md yields the issues ready to work, which working-issues then dispatches. Load BEFORE executing a milestone.
user-invocable: true
---

# Executing milestones

This skill starts where `planning-milestones` stops. That skill ends at a
reviewable issue tree and files nothing else. This one finds which issues in
that tree are ready, and hands them to the `working-issues` skill, which
dispatches, verifies and reports.

If the milestone has no epic, run `planning-milestones` first and stop there for
review. A single issue outside any milestone goes straight to `working-issues`.

## 1. Take the milestone from the argument, never from inference

**The caller names the milestone.** Which one to execute next is a
fact about what the caller intends to build, and the repository does not hold
it. Do not infer it from which epic is open, from the order of
`docs/specs/milestones.md`, or from what was planned last.

A fresh session does not know what merged since the last one, so bring the tree
and the open pull requests current before answering:

```bash
git fetch -q origin && git checkout -q main && git pull -q
gh pr list --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

**Given no argument**, report and stop. Reporting is not executing. Name the
open epics, so the caller has something to choose from, and the work outside
them, which no epic's frontier can see:

```bash
gh issue list --state open --limit 100 --json number,title,parent \
  --jq '.[] | select(.parent == null) | "epic     #\(.number)  \(.title)"'

gh api "repos/{owner}/{repo}/issues?state=open&per_page=100" --paginate --jq '
  .[] | select(.pull_request == null)
      | select([.labels[].name] | any(. == "bug" or . == "needs-human"))
      | "outside  #\(.number)  \(.title)"'
```

The `pull_request == null` filter is not optional. That endpoint returns pull
requests alongside issues, and a pull request carries no dependency summary, so
a query without it reads every open pull request as ready work.

**Given a milestone id**, find its epic — the issue with no parent carrying
that milestone's label, which is exact where matching a title is not:

```bash
milestone=M0
epic=$(gh issue list --label "milestone:$milestone" --state all --limit 100 \
  --json number,parent --jq '.[] | select(.parent == null) | .number')
```

Nothing back means the milestone has not been planned. Two numbers back means
two epics for one milestone, which splits the tree. Either way, say so and stop.

Then read the frontier, the sub-issues with no open blocker. **Readiness is true
at the moment it is computed and wrong after the next merge**, so compute it
here and never carry it forward:

```bash
gh issue list --label "milestone:$milestone" --state open --limit 100 \
  --json number,title,parent,blockedBy \
  --jq '[.[] | select(.parent != null)] | sort_by(.number) | .[]
        | "\(if ([.blockedBy.nodes[] | select(.state == "OPEN")] | length) == 0
             then "READY  " else "blocked" end)  #\(.number)  \(.title)"'
```

**Check that list against the epic before believing it.** It is served from a
search index that lags behind the issues themselves, and this repository has
already produced one that omitted sub-issues the epic knew about. The sub-issues
API is not served from that index:

```bash
gh api "repos/{owner}/{repo}/issues/$epic/sub_issues" --paginate \
  --jq '[.[] | select(.state == "open") | .number] | "open: \(.)"'
```

A number here that the frontier did not list is a sub-issue the listing cannot
yet see. Read those with `gh issue view <n> --json blockedBy` rather than
waiting for the index.

## 2. Hand the ready issues to working-issues

**Load the `working-issues` skill** and give it the issues marked `READY`, plus
any sub-issue the epic check found that the listing missed. It takes them from
the worktrees onward: the baseline, the briefs, the verification and the report.

Do not start the next milestone without being asked.

## Resources

- `docs/specs/milestones.md` — the milestones in build order
- The `planning-milestones` skill — how the tree this skill executes was built
- The `working-issues` skill — how the ready issues are dispatched and verified
