---
name: working-issues
description: How GitHub issues become worktrees, subagent briefs, and verified pull requests — one issue, or every ready issue in a milestone. Load BEFORE dispatching implementation work to subagents.
user-invocable: true
---

# Working issues

You are running the work, not writing it. Subagents write the code. You decide
what gets built next, brief them so the parts that fail silently get attention,
and **check what comes back**.

Everything here reads the project's `AGENTS.md` for what is specific to it:

- the checks that must pass, by the command that runs them
- the specification, and the part of it that fixes the language rules and the
  source layout
- the silent failures that project is prone to
- any automated reviewer that runs on a pull request, and the command that reads
  its review
- standing rules for running agents in it

Where `AGENTS.md` does not say, ask rather than guess.

## 1. Take the work from the argument, never from inference

**The caller names the work: one issue, or a GitHub milestone.** Which to execute
next is a fact about what the caller intends to build, and the repository does
not hold it. Do not infer it from which milestone is open or from what was
worked last.

A fresh session does not know what merged since the last one, so bring the tree
and the open pull requests current before answering:

```bash
git fetch -q origin && git checkout -q main && git pull -q
gh pr list --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

**Given no argument**, report and stop. Reporting is not executing. Name the open
milestones, so the caller has something to choose from:

```bash
gh api "repos/{owner}/{repo}/milestones?state=open" \
  --jq '.[] | "\(.title)\t\(.open_issues) open"'
```

**Given an issue**, read it and every specification section it cites, then go to
section 2.

**Given a milestone**, first close any split issue whose sub-issues are all
closed. A split issue is done through its sub-issues, so it is never dispatched
itself. Check its own acceptance criteria against `main`, tick the ones that
hold, and close it. Where one does not hold, file what is missing as a new
sub-issue instead.

Then read the frontier: the issues with no open blocker and no sub-issues.
**Readiness is true at the moment it is computed and wrong after the next
merge**, so compute it here and never carry it forward:

```bash
milestone=0.1.0
gh issue list --milestone "$milestone" --state open --limit 200 \
  --json number,title,blockedBy,subIssuesSummary \
  --jq '[.[] | select(.subIssuesSummary.total == 0)] | sort_by(.number) | .[]
        | "\(if ([.blockedBy.nodes[] | select(.state == "OPEN")] | length) == 0
             then "READY  " else "blocked" end)  #\(.number)  \(.title)"'
```

**Check the listing against the milestone before believing it.** The listing is
served from a search index that lags behind the issues themselves, and can omit
issues GitHub knows about. The milestone's own count is not served from that
index. Compare it with the listing before the frontier filter, so that split
issues count on both sides:

```bash
gh issue list --milestone "$milestone" --state open --limit 200 --json number --jq length
gh api "repos/{owner}/{repo}/milestones" \
  --jq ".[] | select(.title == \"$milestone\") | .open_issues"
```

A milestone count above the listing's means issues the listing cannot yet see.
Find them with `gh api "repos/{owner}/{repo}/issues?milestone=<number>&state=open"`
rather than waiting for the index.

**Given a list of ready issues** from another skill, such as a milestone tree's
frontier, go to section 2 with that list.

## 2. Give each piece of work its own worktree

One worktree, one branch, one pull request, one issue.

**Dispatch with `isolation: "worktree"` on the Agent call, never by path.** Hooks
run in the directory the subagent was dispatched in, not the one its brief
names. A subagent told to work in `.claude/worktrees/<name>` has its hooks run
against wherever this session stood, which is usually `main`. Isolation puts the
subagent, and its hooks, in a worktree of its own at
`.claude/worktrees/agent-<agent_id>`, created from `origin/main`.

The brief's first instruction is the branch switch, before anything else:

```bash
git fetch -q origin && git switch -c <area>/<short-name> origin/main
```

- **The primary tree stays on `main` and never switches branches.** Every
  worktree and every dispatched agent reads it.
- **Branches are named `<area>/<short-name>`**, matching those already in the
  repository.
- **The worktree's path is the Agent result's `worktreePath`.** Nothing else
  names it before the subagent reports, so take it from there for verification
  and removal.
- `.claude/worktrees/` belongs in `.gitignore`. Add it if it is missing.
- **Remove the worktree once its pull request merges**, and the branch isolation
  left behind with it:

  ```bash
  git worktree remove <worktreePath>
  git branch -D worktree-agent-<agent_id>
  ```

  A stale worktree holds a branch checked out, and the next agent that wants
  that branch fails for a reason that reads like something else. The
  `worktree-agent-<agent_id>` branch is the one isolation created, and nothing
  else removes it.

**Take the baseline before dispatching, not before answering.** Run the checks
`AGENTS.md` names on `main` and keep the result. Its one job is attribution: if
`main` is already red and you fan out four agents, all four report a failing
suite, none of them caused it, and nothing in their reports says so. Where the
project has no checks yet, the baseline is empty, and that is a fact to state
rather than a gap to fill with an invented check.

**Dispatch the whole frontier at once**, as one agent call per issue in a single
message, so they run concurrently. Issues with no open blocker are independent
by construction. A blocked issue is not dispatched, because its blocker's result
is an input to it and not merely an ordering.

Where two issues on the frontier touch the same file, say so in both briefs. The
second to merge rebases, and an agent told to expect that handles it without
asking.

## 3. Brief a subagent with the failures, not the task

A brief that says what to build gets code that compiles. A brief that names what
will go wrong silently gets code that works.

Every brief carries:

- The issue number, and the specification sections that govern it, cited by
  number, to be read in full
- `AGENTS.md`, which says which skills to load before writing a note, an issue
  or a pull request
- `docs/notes/` for what earlier work already settled. A fact established there
  is read, not re-derived
- The part of the specification that fixes the language rules and the source
  layout. A change that invents a directory the layout does not have is in the
  wrong shape
- **The specific silent failures.** Mostly these are places where a broken
  thing and a correct thing produce the same output. `AGENTS.md` lists the
  project's; name what tells the two apart
- **Red, then green.** Write each test first and watch it fail for the reason it
  names, then write the code that makes it pass. A test that was never seen
  failing has not shown it can, and is deleted rather than kept
- What to prove rather than assume, and to file a `needs-human` issue instead of
  shipping something it could not verify
- **The pull request body ends at its last real section.** No generated-with
  footer, no session link, no co-author trailer, in the body or in the commits
- The branch switch above as its first step. It is started in its worktree, so
  the brief names no path, and it works there and never leaves
- **Where `AGENTS.md` names an automated reviewer, work its review to the end**
  once the pull request is open, by the command `AGENTS.md` gives
- Report back: the pull request number, the checks it ran with their output,
  each new test's failure as it first ran, what it filed, and **what it could
  not determine**

**An agent that reports what it could not determine has done its job.** That
answer is yours to resolve, not theirs to guess:

- It could not reach something you can. Fetch it and hand it over.
- It could not verify a claim the code rests on. File `needs-human` and say what
  would settle it.
- It stopped rather than inventing. Say so when you relay the result, because it
  is the outcome you asked for.

**A result that contradicts the specification is reconciled in the
specification, not worked around.** Reconciling means loading `writing-specs`
and, because a specification change is a decision about the product, bringing
it to the caller.

## 4. Verify what comes back. Do not take the report

An agent's report is a claim. Check it in a worktree of its own, detached, and
never in the subagent's `worktreePath`, where its hooks may still be running:

```bash
git worktree add -q .claude/worktrees/verify-<n> origin/<branch> --detach
```

Run the project's checks there and compare them against the baseline you took
before dispatching. A failure present in both is inherited, and chasing it in
this branch is wasted work.

Run the test files the change touches, not the whole suite, while agents are
running theirs. A machine running several suites at once fails the
timing-sensitive tests, and a red result that load caused says nothing about the
branch.

Then **read each new test against the failure it was reported to have**. A
report that shows no red for a test, or shows one that failed for another reason
(an import, a typo, a missing fixture), has not shown the test can catch
anything. Send it back rather than proving it yourself. A test with no red is
deleted.

Remove the verification worktree when done.

**Where an automated reviewer runs on its own when a subagent finishes**, this
session may be woken with its result. Where threads are open, send the same
subagent back to work them rather than working them here.

## 5. Report in plain words

Subagents write for other agents. You are writing for somebody deciding what to
merge, and making them decode a mechanism to reach that decision is the slowest
step in the loop.

- **Lead with the verdict**, one sentence, before any detail.
- **Name a problem by what it costs**, not by the mechanism behind it.
- **Earn each technical term.** Reach for one only after the plain sentence it
  rests on, and only where no ordinary word does the job.
- **Give a number something to sit against.** `$0.04` is trivia; `$0.04 of the
  $0.10 a run may cost` is a decision.

The test: could somebody who has not read the diff act on your first paragraph?
If not, the first paragraph is the thing to rewrite. The pull request body
itself is governed by `writing-pull-requests`, not by this section.

## 6. Decide, or ask

**Test the question before passing it on.** A subagent's open question arrives
with its assumptions attached, and the first of them to check is whether it
needs answering at all: whether the thing is needed, whether it earns its
place, and whether it is already solved another way. A question a command
settles in a minute is not a question for the caller. Answer it, and report the
answer rather than the question.

**Decide anything recoverable from the specification, the code, or a
measurement.** Which frontier issues go out together, how the briefs are
written, which tests to run, whether a finding is fixed here or filed as its
own issue.

**Ask anything that trades cost against product.** A new runtime dependency. A
default users see. What a user-facing string says. Whether a milestone's scope
moves. Deciding these builds the wrong product confidently.

When asking, bring a recommendation and the reason, not a menu. When you have
already argued a position and it is overruled, implement the decision.

## 7. What needs a person

File it as `needs-human` rather than mentioning it in a reply that scrolls away.
The label does not exist until it is made, and creating it is safe to repeat:

```bash
gh label create needs-human --color fbca04 \
  --description "Blocked on something only a person can do" --force
```

Anything that needs a credential, changes a repository setting, installs or
publishes something, spends money beyond what the work was given, or needs an
artefact downloaded by hand.

## 8. Standing rules

- **Follow the standing rules in `AGENTS.md`** for running agents in this
  project, such as where a plugin under development is loaded from.
- **A number comes with the command that reproduces it.** Label a prediction as
  a prediction. When a measurement disagrees with one, say so plainly.
- **Read the specification before judging.** It governs reviews as well as
  authorship, and it is cited by section number.
- **Prefer cutting.** State the decision and its one-clause reason; the argument
  that produced it belongs in the commit or the issue.
- **Push back once, with reasons, then implement the decision.** Disagreement is
  a conversation, not a veto in either direction.

## 9. Stop and hand back

At the end of a stretch of work, report what merged, what is open, what each
open pull request is waiting on, and what needs the caller specifically.

Do not start the next milestone without being asked.

## Resources

- `AGENTS.md` — the project's checks, specification, silent failures, reviewer
  and standing rules
- `docs/notes/` — facts already settled by earlier work
- The `writing-notes`, `writing-issues` and `writing-pull-requests` skills — how
  the finding, the issue and the pull request from this work are each written
