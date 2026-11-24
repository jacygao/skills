# Grant depth deep typed tools instead of bash, and hold the sandbox for later

## Intent

- The owner decided on 2026-10-06 that the first version ships `deep` without an operating-system sandbox, which is held as #529 at P2. This narrows what `deep` can do instead.
- `deep` grants tools that each run one fixed command, and no shell, so a reviewer cannot be steered into a command it was not given. Its environment carries no GitHub credential.
- `run_tests` still runs the project's code at the commit under review, with the user's access, and nothing confines it until #529.

## What changed

- M11: its description and acceptance criteria now build `run_tests`, `git_log_search`, `git_blame` and `git_show` for `pi` and Copilot, with no argument reaching a shell and no GitHub credential, and have § 4 Confinement say what risk remains.
- § 4 Depth: the `deep` row grants those tools and no shell, and the rule under the table says what each runs and that the test command is unconfined.
- § 8 What ships: `deep` at P1 as those tools, and the sandbox as a P2 row.
- `deep` no longer runs arbitrary code to test a hypothesis.

## What did not change

- These still say `deep` grants a shell. The configuration refuses `deep`, so no round reaches them, and M11 rewrites them when it builds the tools:
  - § 4 The reviewer session: "Only `deep` grants a shell".
  - § 4 Confinement: the `deep` paragraph, the refused calls and the shell-group record.
  - § 4 Adapters: Copilot's detached shells "matter at `deep` alone".
  - § 4 The `pi` adapter: "`deep` adds `bash`".
  - § 4 The Copilot adapter's grant: what granting `deep` would need.
  - § 4 Charter's verify rule, "run the test where the depth grants a shell", and the same line in `charter.md`.
  - § 9 Configuration's `depth` row: "`deep` adds the shell".
