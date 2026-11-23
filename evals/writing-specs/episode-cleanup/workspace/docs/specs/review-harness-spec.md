# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.36 (draft)

## 3. The loop

A trigger queues a state of the pull request, a round host reviews it in a round,
and the session that owns the work is told the result. That session works the
threads, and the next trigger queues the next state, until the episode closes.

### Terminology

| Term | What it is |
|---|---|
| **Episode** | One review of one pull request in one worktree, from its first round to its close. A worktree holds one live episode per pull request at a time, and keeps the episodes before it. |
| **Round** | One review of one state of the pull request (The state file). |

An episode closes for one of three reasons: a round leaves nothing open, the
round cap is spent, or a round reaches the token bound (§ 8 The review budget).
A close is **clean** where its
round left nothing open and no state behind it not reviewed. Every other close is
at the round cap or the token bound, and stays closed.

### The round host

**The rounds of one episode run one at a time in a round host, `squiz host
<number>`, outside every trigger's process.** Its output is in
`.squiz/<number>/host.log`. A trigger that queues a state starts one where none
runs, detached so that it outlives the shell call or hook that started it. A
person never starts one. At most one runs per episode. It exits when nothing is
left queued or its worktree is gone, and after it dies the next trigger starts a
host for any queued state.

**A round whose round host died is not recovered.** Nothing its reviewer reported
is posted, and its reviewer and its snapshot are left as they are. Its record
stays under review, `squiz status` shows it `killed`, and `squiz review` exits 1
saying the round host stopped before its round ended (#327).

### Parallel coding agents

**Each worktree is reviewed on its own.** `squiz review` resolves the worktree
with `git rev-parse --show-toplevel` from the directory it runs in, and the hook
from the payload's `cwd`, which for a subagent is fixed when it is dispatched.
One worktree, one branch, one pull request, one live episode per pull request.

**Squiz never removes a worktree.** Whatever created it removes it, and the
episode's state goes with it.

**Where a tree's `HEAD` moved to another branch while an episode was live, each
pull request's episode keeps its state under its own number**, and each reviewer
reads a snapshot of its own pull request's head.

**Two coding agents on one branch in one tree share one episode and one round
cap**, and nothing detects it (#924).

