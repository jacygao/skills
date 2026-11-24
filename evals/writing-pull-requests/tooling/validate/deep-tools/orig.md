# Grant depth deep typed tools instead of bash, and hold the sandbox for later

## Intent

- The owner's decision on 2026-10-06: the first version ships `deep` without an operating-system sandbox, which is held as #529 (P2). It narrows the risk instead.
- `deep` grants tools that each run one command with fixed arguments, `run_tests`, `git_log_search`, `git_blame` and `git_show`, and no shell. A prompt injection cannot steer a reviewer into a command it was not given.
- The reviewer's environment carries no GitHub credential.

## What changed

- M11's description and acceptance criteria, which its plan copies.
- § 4 Depth's `deep` row and its rule, and § 8 What ships: `deep` at P1 as typed tools, and the sandbox at P2.

## What did not change

- § 4 Confinement's refusals and shell-group record still describe a `deep` shell. M11 rewrites Confinement when it builds the tools, and states the remaining risk there.

## Notes

- Dropped from `deep`: running arbitrary code to test a hypothesis. Running the tests and reading history cover most of what a review needs.
