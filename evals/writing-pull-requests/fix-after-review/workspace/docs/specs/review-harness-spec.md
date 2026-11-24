# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 0.47 (draft)
**Status:** For review
**Owner:** TBD

---

## 6. Commands

Everything the harness ships to be run. One binary and one slash command.

### The `squiz` binary

A plugin's `bin/` is added to the Bash tool's `PATH` while the plugin is
enabled, so the coding agent runs the binary by name. The hook's shell is given
no such `PATH`, so the `hooks.json` registration reaches the same file through
`${CLAUDE_PLUGIN_ROOT}`.

| Command | Run by | What it does |
|---|---|---|
| `squiz hook` | Claude Code | The `SubagentStop` entry point, named in `hooks.json`. Runs one round. |
| `squiz threads` | The coding agent | Lists the open threads on the pull request for the current branch. Each line carries the thread's identifier, where the thread is, and the severity and headline of the finding on it. |
| `squiz reply <id> <text>` | The coding agent | Replies in a thread. |

```
2 open threads on #185
PRRT_kwDOUEd2qM6mPuUP scratch/paging/pages.ts:26 high — pageCount drops the partial last page
PRRT_kwDOUEd2qM6mPuVO scratch/paging/pages.ts:34 high — pageAt starts every page one page too far
```

A thread whose first comment carries none of § 2 Identity's markers was opened by
a person rather than by the reviewer. It is no finding, and its line is the
identifier and the location alone.

`<id>` is whatever `squiz threads` printed for that thread. It round-trips
between the two commands, and is short enough for an agent to copy. It leads the
line and is printed undecorated, so a line splits into the identifier and the
rest of it at the first space.

### The setup check

`/squiz doctor` is a slash command, run by a person. It reports which of the
dependencies is missing or unauthenticated.

## 9. Adoption

### Installing

Squiz is a Claude Code plugin and installs from a marketplace, which is a
`.claude-plugin/marketplace.json` in a git repository. A private repository
works.

```
/plugin marketplace add <owner>/<repo>
/plugin install squiz@<marketplace>
```

`/plugin uninstall squiz` removes it.

### Getting started

Four things in the host project, the last two optional.

1. Add `.squiz/` to `.gitignore`. It holds each episode's state file and the
   reviewer's session storage.
2. Allow `squiz` in the project's Claude Code permissions, so the coding agent
   is not prompted every time it works a thread.
3. **Optional.** `.squiz.json`, to change any of the settings below. Every one
   has a working default, so a project that writes none still runs. The `test`
   setting is read only at depth `deep`, where it names the non-mutating command
   the reviewer runs instead of one it infers for itself.
4. **Optional.** `AGENTS.md`, to have the reviewer enforce rules of the
   project's own. It carries the conventions a reviewer cannot derive from
   reading code, and it can point at whatever else the project treats as
   authoritative. Without it the review still finds correctness bugs, security
   problems and tests that assert nothing, and reports no convention violations.

Then run `/squiz doctor`.

A project that dispatches subagents in parallel gives each one its own worktree
on its own branch. Squiz does not create them.

### Configuration

`.squiz.json`, at the root of the repository.

| Setting | Default | |
|---|---|---|
| `rounds` | 3 | The round cap, settable 1 to 8 |
| `depth` | `read` | `deep` adds the shell, and requires the tracked-file comparison |
| `test` | none | The non-mutating command that runs the tests |
| `timeout` | 480 | Seconds one round's reviewer may run, settable 1 to 480 |
| `tokens` | 1,500,000 | Tokens one round may spend, settable 100,000 to 10,000,000 |
| `thinking` | `medium` | How hard the reviewer thinks, one of `off`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` |

`timeout` defaults to the most it may be, so a project can lower the time bound
and cannot raise it. The ceiling is the runtime's rather than a preference: the
rest of the hook's 600 seconds belongs to the calls the round makes before and
after the review, and a reviewer is given what is left of the window rather than
the whole of what is configured. The review budget names the shares.

`tokens` is the review budget's other bound. The review budget says what it
counts, when it is read, and what an episode's ceiling comes to under a given
round cap.

A setting outside its range, or of a type the table does not give it, is
rejected with an error naming the setting, the value given and what was
expected. A key the table does not name is rejected the same way, with an error
saying it is not a setting and listing the settings there are. A `.squiz.json`
that cannot be read or parsed is a failure the harness controls, so the round
exits 0 and the hook's stderr names it.
