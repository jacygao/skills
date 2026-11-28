# writing-agents-md

Decides what goes in a project's `AGENTS.md` or `CLAUDE.md`, what moves to a
rule file, a skill, a spec or a note, and how the file is laid out.
`writing-rules` then writes each line.

## Load it

Its description loads it before creating, restructuring or adding a section to
either file.

## What to add to AGENTS.md

```markdown
## Skills

- Load `writing-agents-md` before adding a section to `AGENTS.md` or
  `CLAUDE.md`.
```

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 100% | 61% |
| Cases passed | 2 of 3 | 1 of 3 |

Graded on 2026-11-28 against the skill at `ce7131b`, from 8 and 9 graded trials. The cases are in [`evals/writing-agents-md/`](../../evals/writing-agents-md/).
