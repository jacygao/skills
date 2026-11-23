# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 4. The reviewer

### Charter

`charter.md` is the standing instruction every reviewer is handed: what to
report, how to verify it, and how to scope it. The charter and this section
state the same rules.

### Findings

- `scope`: `line`, `file` or `change`, which decides inline, file-level or
  general.
- `severity`: `high`, `medium`, or `low`.
- `headline`, `reasoning`, `suggestedFix`, and an optional `reference`.

| Severity | |
|---|---|
| `high` | Wrong now, or a security problem, or it breaks a written convention. |
| `medium` | Wrong under conditions this change makes reachable, or a test that would pass with the code under it deleted. |
| `low` | Real, narrow, and survivable. |

Severity orders the findings and does not decide whether they count.

### Pull request comments

A finding scoped to a line or a file is posted as a review thread. A finding
scoped to the change goes into the summary comment as a line of text.

A round that leaves any thread open keeps the review going: `squiz review` exits
2, and the coding agent works the threads.
