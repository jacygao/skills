# Decide how the reviewer reports a defect the change did not introduce
Labels: task, P2, harness

## Purpose

Decide what the reviewer does with a defect it notices in code the pull request did not change and did not cause: report it, at what severity, and where.

## Acceptance criteria

- [ ] The owner chooses one of the options below, or another.
- [ ] The charter and § 4 Charter state the choice, and the router and the summary carry it where it needs code.

## Options

1. **At `low`, as a thread.** On record, and it never blocks. It understates a serious defect, such as an existing security hole.
2. **Not at all.** Every review stays strictly to its change.
3. **At its real severity, as a thread.** True to the defect, but an old `high` blocks an unrelated pull request.
4. **At its real severity, marked as existing before the change, in the summary rather than as a thread.** True severity, and visible to whoever reads the pull request, but it blocks nothing and sends the coding agent outside its task. This needs a field on the finding and a route to the summary.

## Reference

- #579 left this out of the charter as a policy choice, not something the eval could settle. See `docs/notes/only-the-sibling-and-stale-document-rules-change-what-the-reviewer-reports.md`.
- § 4 Findings and § 4 Pull request comments.

P2: until it is decided the charter is silent, and the reviewer uses its own judgement, as it has so far.
