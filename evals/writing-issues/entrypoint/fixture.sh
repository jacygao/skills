#!/usr/bin/env bash
# swe-drill's AGENTS.md, cut to what filing an issue needs, and the spec
# the issue is about, as it stood when it was filed.
set -euo pipefail
cat > AGENTS.md <<'EOF_FIXTURE'
# Working in this repository

SWE-drill runs coding agents on benchmark tasks through Harbor, grades each
trial, and ranks the arms on a leaderboard.

## Specs

`docs/specs/swe-drill-spec.md` is the specification. This checkout holds only
the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

## Checks

```bash
uv run pytest
```

## Issues

Each issue carries one label, `bug` or `task`.

**Use the `writing-issues` skill before writing an issue.** Every time,
without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
issue to `issues/new.md` instead: the title on the first line as `# <title>`,
then a line `Labels: <label>, <label>, ...`, a blank line, and the body exactly
as it would be passed to `gh issue create --body`.
EOF_FIXTURE
mkdir -p docs/specs issues
cat > docs/specs/swe-drill-spec.md <<'EOF_FIXTURE'
# SWE-drill Specification

## 5. Lanes

SWE-drill has two lanes, `rebench` and `atlas-rf`. Every task gives the agent
phase a network that allows only the hosts its agent class names. A lane's
tasks are copies of the dataset's, made by `swe-drill lanes build`, and a copy
changes only what this section lists.

### `atlas-rf`

All 70 tasks of SWE Atlas's Refactoring set, `scale-ai/swe-atlas-rf`. Each
instruction asks for a refactoring of a real repository, names the interfaces it
must leave behind, and says the test files are already changed. Every task names
16 CPUs and 16384 MiB, an agent timeout of 3600 seconds and a verifier timeout
of 7200. Each task runs a prebuilt image from Scale's registry.

The verifier's `test.sh` captures the change in the workspace with `git add -A`
and `git diff --cached HEAD`, runs the regression tests the refactoring must
keep passing, then runs `tests/evaluate_rubrics.py`, which asks an LLM judge
whether the change meets each of the task's rubric items.

Each copy's `task.toml` adds `[verifier] environment_mode = "separate"`, and
changes three lines of its `[verifier.env]` so the judge calls Copilot's API.
Each copy's `tests/test.sh` changes two lines of the task's, so the tests,
which run code the agent wrote, start with no `EVAL_API_KEY`.

### Sandboxes

A trial runs on Docker on this machine, or on Modal. Harbor merges a task's
`environment/docker-compose.yaml`, where it has one, over its own compose file.
On Modal, a task with that file runs under Docker in Docker.
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
