# Remove from spec § 1 and § 2 what the specification does not need

## Intent

- § 1 and § 2 carried evidence, a duplicated overview and a duplicated payload fact alongside what the code must do. This removes those and changes no requirement.
- Scope is § 1 Purpose and § 2 Dependencies only. Seven other cleanups are editing the other sections.

Closes #485

## What changed

Lines: § 1 went from 19 to 17, and § 2 from 120 to 98 (heading to the next H2).

Removed passages, by kind, and where each went:

- **How something came to be known**
  - § 2 "Verified against" version table and its lead-in → new note `docs/notes/no-dependency-version-is-a-minimum.md`. The H3 is renamed "Behaviour the design rests on" and now holds only the behaviour list. Nothing referred to the old heading.
  - "Re-check with `gh pr review --help`" → the new note.
  - "Documented, in Claude Code's tools reference under the Bash tool" → the new note.
  - "The runtime tells the subagent not to end its turn; three of five foreground subagents ended it anyway. Background subagents waited." → already in `a-review-the-shell-moves-to-the-background-is-often-killed-by-its-own-subagent.md`.
  - "Measured against 2.1.288" (SIGTERM bullet) → the same note.
  - "Measured against 2.1.270 and 2.1.288" (stall bullet) → the same note and `the-runtime-kills-the-reviewer-too-but-only-sigterm-is-certain.md`.
  - "Measured against 2.1.289" and "Most subagents ran it that way" (output shortening) → already in `a-subagent-reads-the-file-whenever-its-output-is-cut.md`.
  - "A plain `&`, `setsid` alone, `nohup … & disown` and `( nohup … & )` do not", and "Measured against 2.1.288 on macOS" → the new note, marked unverified because no other note records a run of them. The plain `&` is also in `a-pane-outlives-the-call-that-made-it-and-both-wakes-reach-an-idle-session.md`. The rule that stays says a process outlives the stop only if it leaves both the tree and the group.
  - "Measured against 2.1.288" (asyncRewake bullet) → already in `a-pane-outlives-the-call-that-made-it-and-both-wakes-reach-an-idle-session.md`.
- **A fact stated twice**
  - § 1: "A review starts when the coding agent finishes its work, or when it runs one command. The reviewer runs as a session of its own, and the coding agent reads the findings off the pull request." → § 3's opening paragraph already says this.
  - § 2: "A `SubagentStop` payload's `session_id` is the session that dispatched the subagent, and its `agent_id` is the subagent's own. Measured against 2.1.261." → § 3 The Claude Code hooks already says this in its owner table. The evidence is in `an-episode-keys-on-agent-id.md`.
- Version 0.72 → 0.73.

## What did not change

- **Verified against: no version is a requirement.** § 2 states no version for any dependency, and the setup check reports what is missing or unauthenticated rather than what is old. Node 24 or later is the only minimum, and § 8 owns it. The note records this decision.
- **Kept, borderline:**
  - "ten minutes after its turn ended as well as one" in the asyncRewake bullet. It reads like a measurement, but it says that a wake has no expiry, and the wake design depends on that.
  - "The threshold is read from `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS`" and the `BASH_*_TIMEOUT_MS` names. They are values someone checking or testing the bounds needs.
  - The optional-multiplexer paragraph in § 2. § 4 The reviewer session owns how a pane is chosen, but this paragraph is about what has to be installed.
  - The `**Squiz review` prefix trap under Identity. It is a reason that stops a reader from writing a test that matches every finding.
- **Found and left, because it changes content rather than removing it:** "makes the call exit 0, so its output is never cut" conflicts with the bullet above it, which says a long exit-0 output is saved to a file and shown as a 2 KB preview. Its note shows that is what happens over about 30,000 characters. A correct version would read "never cut to an excerpt".
- **Owned elsewhere, left in § 2:** the 600-second Bash ceiling and the stall rule are also stated in § 7, and the socket and asyncRewake wakes in § 3 The report. § 2 keeps them because § 3 and § 6 point at § 2 for these runtime facts.

## Verification

```
grep -rn 'Verified against\|established rather than\|§ 2' src docs/specs skills commands charter.md hooks
```

The remaining `§ 2` references point at the outliving rule (§ 3 The round host), the output cut (§ 6), Identity's markers (§ 3, § 4, § 6), and the different-model rule (§ 4). All of these are still in § 2.
