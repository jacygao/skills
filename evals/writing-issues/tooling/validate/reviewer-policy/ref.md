# Decide how the reviewer reports a defect the change didn't cause
Labels: task, P2, harness

## Purpose

Choose what the reviewer does with a defect it finds in code the pull request did not change and did not cause, so the charter can say it.

## Context

The charter and § 4 say nothing about it, so the reviewer uses its own judgement. #579 left it out as a policy choice the eval could not settle.

## Options

1. **At `low`, as a thread.** On record, but like any open thread it keeps the review going, and it understates a serious defect.
2. **Not at all.** Every review stays to its change, and the defect goes unrecorded.
3. **At its real severity, as a thread.** True to the defect, and it keeps an unrelated pull request's review open.
4. **At its real severity, in the summary, marked as existing before the change.** True and visible, and it keeps no review open, but a finding has no field for it today.

## Acceptance criteria

- [ ] The owner chooses one option, or another, on this issue
- [ ] `charter.md` states the choice
- [ ] § 4 Charter states the choice

## Reference

- `docs/notes/only-the-sibling-and-stale-document-rules-change-what-the-reviewer-reports.md`
- § 4 Findings and § 4 Pull request comments
