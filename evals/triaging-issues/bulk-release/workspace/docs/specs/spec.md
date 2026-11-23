# Squiz specification

## 4. Agents squiz starts

Every Copilot run squiz starts, reviewer or fixer, carries the isolation flags
`reviewerArgs` returns: `--disable-builtin-mcps`, `--no-auto-update` and
`--disable-client-telemetry`.

A fixer may run the project's checks, as `AGENTS.md` names them, and no other
shell command. A grant such as `Bash(git:*)` is too wide: `git -c alias.x='!cmd'
x` runs any command.

## 5. The handoff

The handoff is what the next agent reads. Its last line asks the fixer to run
`squiz review` once it has pushed, and nothing the fixer is told may contradict
it.

## 6. Headless runs

A headless run writes each round's handoff to `.squiz/handoff.md` and exits.
