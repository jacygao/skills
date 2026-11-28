# Working in this repository

## Skills

This repository holds the skills. Read the one that matches the job from
`skills/<name>/SKILL.md` before doing it:

- `writing-agents-md`: before adding a section to `AGENTS.md` or `CLAUDE.md`
- `writing-rules`: before writing a rule
- `writing-issues`: before `gh issue create`
- `writing-pull-requests`: before `gh pr create`

## Writing a skill

- **Write no em dashes.** Use a period, colon or comma. A bold lead ends with a
  period.
- **Give no fixed threshold, such as a line count.** Say what to weigh, with an
  example. A limit belongs in an eval's grader, never in the skill.
- **Keep a skill's README true when the skill changes:** its AGENTS.md lines,
  and its row in the table in `README.md`.

## Checks

Run the evals of each skill a change touches, with the skill and without:

```bash
cd evals/<skill> && vally experiment run skill.experiment.yaml
```

Then update the scores in the skill's README and in `README.md`. A new skill
gets an eval with cases from a real project, named in its `description`.

## The reviewer

Squiz reviews every pull request (`.squiz.json`). Once a pull request is open,
run `squiz review <number>` and work it to exit 0: fix what applies, answer each
thread with `squiz reply <id> <text>`, push, and run it again.

## Running agents here

- **Never merge.** The owner merges.
