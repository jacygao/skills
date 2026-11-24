# Remove from spec § 1 and § 2 what the specification does not need

## Intent

- § 1 and § 2 carried evidence and two duplicated facts alongside what the code must do. This removes them and changes no requirement.
- Scope is § 1 and § 2 only; other cleanups are editing the other sections.
- **Four notes still point at § 2 Verified against**, a heading this renames; see What did not change.

Closes #485

## What changed

- **How something came to be known**, moved out of § 2:
  - The Verified against version table and its re-check commands → a new note, `docs/notes/no-dependency-version-is-a-minimum.md`. The H3 is now "Behaviour the design rests on" and holds only the behaviour list.
  - The `gh pr review --help` re-check, the Bash tool's documentation source, and the process forms that do not outlive a stop (plain `&`, `setsid` alone, `nohup … & disown`, `( nohup … & )`) → the new note; the process forms are marked unverified there. The plain `&` is also recorded in `a-pane-outlives-the-call-that-made-it-and-both-wakes-reach-an-idle-session.md`.
  - "Measured against …" on each behaviour, the foreground subagents that ended their turn, and how most subagents ran the exit-0 form → already in `a-review-the-shell-moves-to-the-background-is-often-killed-by-its-own-subagent.md`, `the-runtime-kills-the-reviewer-too-but-only-sigterm-is-certain.md`, `a-subagent-reads-the-file-whenever-its-output-is-cut.md` and `a-pane-outlives-…`.
- **A fact stated twice**:
  - § 1's sentences on how a review starts and where the reviewer runs → § 3's opening paragraph says it.
  - § 2's `SubagentStop` `session_id` / `agent_id` bullet → § 3 The Claude Code hooks owner table says it; the evidence is in `an-episode-keys-on-agent-id.md`.
- The specification's version is bumped.

## What did not change

- **Four notes still cite § 2 Verified against** and now land on nothing: `a-subagent-reads-the-file-whenever-its-output-is-cut.md`, `the-deep-grant-does-not-confine.md`, `cost-arrives-during-a-run.md` and `githubs-diff-is-git-diff-byte-for-byte.md`. Each should point at the new note.
- **No version is a requirement.** § 2 states none and the setup check does not check versions; Node 24 is the only minimum, and § 8 owns it. The new note records the decision.
- **Kept, borderline:** "ten minutes after its turn ended as well as one" (a wake has no expiry), the timeout variable names (needed to test the bounds), the optional-multiplexer paragraph, and the `**Squiz review` prefix trap under Identity.
- **Left, because fixing it changes content:** "makes the call exit 0, so its output is never cut" conflicts with the bullet above it, which saves a long exit-0 output to a file and shows a preview. It should read "never cut to an excerpt".
- **Stated in § 2 and elsewhere, kept in § 2:** the Bash ceiling and stall rule (also § 7), and the wakes (also § 3 The report), because § 3 and § 6 point at § 2 for them.

## Verification

- Searched, as the brief reports: `grep -rn 'Verified against\|established rather than\|§ 2' src docs/specs skills commands charter.md hooks`. It left out `docs/notes/`, where the four notes above still cite the old heading.
- Suggested before merge: `git grep -n 'Verified against'` and `git grep -n '§ 2'` over the whole repository, reading each `§ 2` hit against what § 2 now holds.
