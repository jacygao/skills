# writing-issues
| | With the skill | No skill |
|---|---|---|
| Mean grade | 92% | 64% |
| Cases passed | 5 of 6 | 0 of 6 |

Graded on 2026-11-24 against the skill at `40c1822`, from 17 and 17 graded trials. The cases are in [`evals/writing-issues/`](../../evals/writing-issues/).
How a GitHub issue is written: a bug or a task, each from its template, with
every claim checked against the code and docs and a blocker set as a GitHub
relationship rather than a line of text.

## Load it

Its description loads it before `gh issue create`.

## What to add to AGENTS.md

```markdown
## Skills

- Load `writing-issues` before creating an issue.

## Issues

- Every issue carries <a kind label, a priority, an area, a milestone>.
```

It uses `.github/ISSUE_TEMPLATE/task.md` and `bug.md` where the project has
them, and its own `templates/` where it has not.

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 92% | 64% |
| Cases passed | 5 of 6 | 0 of 6 |

Graded on 2026-11-24 against the skill at `40c1822`, from 17 and 17 graded trials. The cases are in [`evals/writing-issues/`](../../evals/writing-issues/).
