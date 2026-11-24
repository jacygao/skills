# writing-rules
| | With the skill | No skill |
|---|---|---|
| Mean grade | 85% | 77% |
| Cases passed | 1 of 3 | 1 of 3 |

Graded on 2026-11-24 against the skill at `40c1822`, from 9 and 9 graded trials. The cases are in [`evals/writing-rules/`](../../evals/writing-rules/).
How an instruction file for agents is written: a rule in `.claude/rules/`,
`AGENTS.md` or `CLAUDE.md`. It is the skill to load when adding the sections
the other skills' READMEs ask for.

## Load it

Its description loads it before writing or editing one of those files.

## What to add to AGENTS.md

```markdown
## Skills

- Load `writing-rules` before editing `AGENTS.md`, `CLAUDE.md` or
  `.claude/rules/`.
```

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 85% | 77% |
| Cases passed | 1 of 3 | 1 of 3 |

Graded on 2026-11-24 against the skill at `40c1822`, from 9 and 9 graded trials. The cases are in [`evals/writing-rules/`](../../evals/writing-rules/).
