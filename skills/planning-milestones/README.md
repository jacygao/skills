# planning-milestones
| | With the skill | No skill |
|---|---|---|
| Mean grade | 100% | 50% |
| Cases passed | 1 of 1 | 0 of 1 |

Graded on 2026-11-23 against the skill at `40c1822`, from 3 and 3 graded trials. The cases are in [`evals/planning-milestones/`](../../evals/planning-milestones/).
For a project built from nothing and planned in `docs/specs/milestones.md`. It
turns a named milestone there into an epic issue and one sub-issue per subtask,
each small enough to pass the project's checks on its own, and stops for review
before anything is worked.

## Load it

Its description loads it before planning a milestone or filing its issues.

## What to add to AGENTS.md

```markdown
## Skills

- Load `planning-milestones` before planning a milestone from
  `docs/specs/milestones.md`.

## Checks

- `npm run check`: the bar every subtask must pass alone.

## Specification

- `docs/specs/<project>-spec.md` is what the work has to satisfy, cited by
  section number.
- § 3 fixes the language rules and § 4 the source layout.
```

It also reads `docs/specs/milestones.md`, `docs/notes/`, and
`.github/ISSUE_TEMPLATE/task.md` where the project has one.

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 100% | 50% |
| Cases passed | 1 of 1 | 0 of 1 |

Graded on 2026-11-23 against the skill at `40c1822`, from 3 and 3 graded trials. The cases are in [`evals/planning-milestones/`](../../evals/planning-milestones/).
