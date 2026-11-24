# Record that a marketplace install reaches the Bash tool's PATH and the hook

## Intent

Closes #54

- The note's first limit said it was untested whether a marketplace install puts the plugin's `bin/` on `PATH`. § 6 has the coding agent run `squiz threads` and `squiz reply` by name from the Bash tool, so an install that did not extend that `PATH` would leave the agent unable to work the threads.
- Now measured: under an install the Bash tool finds `squiz` by name, and the `SubagentStop` hook runs through `${CLAUDE_PLUGIN_ROOT}`, as under `--plugin-dir`.

## What changed

- **A Reference section for the install**: the two commands and the `marketplace.json` they want, `command -v squiz` resolving to the plugin's `bin/squiz`, and the `hook_response` showing `SubagentStop` at `"exit_code": 0, "outcome": "success"`.
- **A Decisions entry**: the name the coding agent runs resolves under an install as it does under `--plugin-dir`, so `squiz threads` and `squiz reply` find the binary either way. It covers finding the binary, not which commands it dispatches.
- **The first two limits are replaced** by what was measured, and two narrower ones take their place: the install was from a local directory rather than a git host, and at `local` scope.
- The note records that print mode does fire `SubagentStop`; an earlier attempt that saw nothing used `--debug` rather than `--include-hook-events`.
- `settles` adds § 9, `issue` adds 54, and `versions` adds the Claude Code version the install ran on.

## What did not change

- An install from a remote marketplace, and one at `user` scope, were not tried. The note lists both as limits.
- #54's body still names `squiz resolve`, which squiz does not have. It is left as the record of what was asked.

## Verification

- Installed at `local` scope with the repository as its own marketplace, ran one subagent in a new session with no `--plugin-dir`, and read the stream with `--include-hook-events --output-format stream-json --verbose` plus `--debug-file`. The install, the marketplace and the `.claude/settings.local.json` it created were removed afterwards.
- No source file changed; `npx tsc --noEmit` is clean.
