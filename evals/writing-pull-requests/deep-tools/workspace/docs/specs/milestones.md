# Milestones

**Version:** 0.29 (draft)
**Status:** For review
**Owner:** TBD

---

Fourteen milestones for building squiz, in the order they are done. Each ends in
something that can be run or seen, never in a module written.

| Order | Milestone | State |
|---|---|---|
| 1 | M0 — Prerequisites spike | Done |
| 2 | M1 — Plugin skeleton, configuration, and the gate | Done |
| 3 | M2 — The finding contract and the comment format | Done |
| 4 | M3 — The GitHub client and the coding agent's commands | Done |
| 5 | M4 — The reviewer | Done |
| 6 | M5 — The round | Done |
| 7 | M6 — The summary comment | Done |
| 8 | M7 — The reviewer as a detached session | Done |
| 9 | M10 — The subagent-era workarounds removed | Done |
| 10 | M12 — Copilot as the reviewer | Done |
| 11 | M13 — Copilot as a coding agent | |
| 12 | M11 — Depth `deep` | |
| 13 | M8 — Episode boundaries | |
| 14 | M9 — Install and dogfood | |

**A milestone's number names it, and the table places it.** M10, M12, M13 and
M11 come before M8 and M9 in the order.

**From M7, squiz runs its reviewer as a session of its own, instead of inside a
subagent's hook or shell call.** The review itself stays as it is: findings as
threads on the pull request, verdicts on replies, rounds, a cap, and a summary.
So do the commands the coding agent runs to read and answer it.

**`docs/specs/review-harness-spec.md` specifies the design.** The session,
trigger and wake code lives in `src/sessions/`, which knows nothing about
reviews and imports nothing from the rest of `src/`, so it can be lifted out if
a second tool needs it.

**The first version leaves three things out:** delivering a note when a session
starts, rules for acknowledging a note and retrying one, and messages in both
directions. GitHub Copilot is the one coding agent besides Claude Code that the
first version supports, in M13.

M9 is the last of them. The P1 and P2 entries of the specification's What ships
that no milestone here delivers are a second version, and its milestones are
planned once M9 closes. M12 was the exception: it brought forward "a second
reviewer adapter", for GitHub Copilot, because the owner reviews with Copilot
already.

## M12 — Copilot as the reviewer

**Done.** Its criteria are in #457.

Added a second reviewer adapter, for the GitHub Copilot CLI, chosen with
`"reviewer": "copilot"` in `.squiz.json`; `pi` stays the default. Copilot runs
from one shell line with its own `COPILOT_HOME`, on the user's default model,
with the charter as a custom agent and the three reporting calls served by an
MCP server that applies the shared report checks. A round records a cost only
where it is exact, in tokens and AI credits. A long pane line runs from a file,
so Copilot starts in a Herdr pane. A live run worked a planted defect to exit 0.

It left these for M9: choosing the reviewer's model in `.squiz.json` (#483),
and the setup check following `reviewer` (#512). Its open questions about
Copilot are held with `milestone:M9`, and granting `deep` to Copilot is #526,
with M11.

## M11 — Depth `deep`

The `bash` grant, on the snapshot M7 gives every reviewer.

The snapshot holds no installed dependencies, so the configured test command
installs or builds what it needs before the tests run. What that adds to a round
is measured before M11 is planned.

### Acceptance criteria

- [ ] Depth `deep` produces a command line with `bash`, and the configured test
      command reaches the reviewer.
- [ ] A write the reviewer makes through the shell is detected on its snapshot
      and named in the summary.
- [ ] A configured test command that works in a fresh checkout runs to
      completion in the snapshot.
