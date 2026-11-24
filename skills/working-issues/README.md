# working-issues
| | With the skill | No skill |
|---|---|---|
| Mean grade | 75% | 60% |
| Cases passed | 1 of 3 | 1 of 3 |

Graded on 2026-11-24 against the skill at `40c1822`, from 6 and 7 graded trials. The cases are in [`evals/working-issues/`](../../evals/working-issues/).
Turns GitHub issues into worktrees, subagent briefs and verified pull requests:
one issue, or every ready issue in a milestone. It briefs each subagent on the
parts that fail silently, checks what comes back against the project's own
checks, and works an automated review to the end where the project has one.

## Load it

Its description loads it before dispatching implementation work to subagents.
Say so in `AGENTS.md` too, so a session that never matches the description still
loads it.

## What to add to AGENTS.md

This skill reads more of `AGENTS.md` than any other. Where a section is missing
it asks rather than guesses, so each one you leave out costs a question.

```markdown
## Skills

- Load `working-issues` before dispatching an issue to a subagent.

## Checks

- `npm run check`: type-check, lint and tests. Must pass on every pull request.

## Specification

- `docs/specs/<project>-spec.md` is what the work has to satisfy, cited by
  section number.
- § 3 fixes the language rules and § 4 the source layout.

## Silent failures

- <a place where a broken thing and a correct thing produce the same output,
  and what tells them apart>

## Reviewer

- <the automated reviewer on pull requests, and the command that reads its
  review, such as `squiz review <n>`>. Leave this out if there is none.

## Running agents

- <standing rules, such as where a plugin under development is loaded from>
```

It also reads `docs/notes/` for what earlier work settled, and files a
`needs-human` issue for a claim it could not verify.

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 75% | 60% |
| Cases passed | 1 of 3 | 1 of 3 |

Graded on 2026-11-24 against the skill at `40c1822`, from 6 and 7 graded trials. The cases are in [`evals/working-issues/`](../../evals/working-issues/).
