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
| Mean grade | 96% | 50% |
| Cases passed | 2 of 3 | 0 of 3 |

Graded on 2026-11-28 against the skill on the `writing-agents-md` branch, from 9 and 8 graded trials. The cases are in [`evals/writing-agents-md/`](../../evals/writing-agents-md/).
