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
