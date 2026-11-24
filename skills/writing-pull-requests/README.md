# writing-pull-requests
| | With the skill | No skill |
|---|---|---|
| Mean grade | 87% | 74% |
| Cases passed | 7 of 8 | 5 of 8 |

Graded on 2026-11-24 against the skill at `40c1822`, from 24 and 24 graded trials. The cases are in [`evals/writing-pull-requests/`](../../evals/writing-pull-requests/).
How a GitHub pull request body is written and kept true: from the diff, not
from memory of the work, with every place the change leaves inconsistent
named, only the checks that ran reported, and the body rewritten in place after
each fix commit.

## Load it

Its description loads it before every `gh pr create` and `gh pr edit`.

## What to add to AGENTS.md

```markdown
## Skills

- Load `writing-pull-requests` before every `gh pr create` or `gh pr edit`.
```

It uses `.github/PULL_REQUEST_TEMPLATE.md` where the project has one, and its
own `templates/` where it has not.

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 87% | 74% |
| Cases passed | 7 of 8 | 5 of 8 |

Graded on 2026-11-24 against the skill at `40c1822`, from 24 and 24 graded trials. The cases are in [`evals/writing-pull-requests/`](../../evals/writing-pull-requests/).
