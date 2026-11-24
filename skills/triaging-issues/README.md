# triaging-issues
| | With the skill | No skill |
|---|---|---|
| Mean grade | 94% | 86% |
| Cases passed | 1 of 3 | 0 of 3 |

Graded on 2026-11-24 against the skill at `ad7c416`, from 9 and 9 graded trials. The cases are in [`evals/triaging-issues/`](../../evals/triaging-issues/).
For a project that has shipped and tracks releases in GitHub milestones. It
gives open issues a priority and a release milestone, and splits a release's
issues until each fits one pull request.

## Load it

Its description loads it before triaging issues or planning a release.

## What to add to AGENTS.md

Where `AGENTS.md` defines no priorities, the skill uses its own: `P0` blocks the
release it is in, `P1` is wanted in the next release or the one after, and `P2`
waits in `Backlog`. Add a section only to change them.

```markdown
## Skills

- Load `triaging-issues` before triaging issues or planning a release.

## Issues

- `P0`: <what blocks a release in this project>
- `P1`: <what is wanted soon>
- `P2`: <what waits in Backlog>
```

## Eval

| | With the skill | No skill |
|---|---|---|
| Mean grade | 94% | 86% |
| Cases passed | 1 of 3 | 0 of 3 |

Graded on 2026-11-24 against the skill at `ad7c416`, from 9 and 9 graded trials. The cases are in [`evals/triaging-issues/`](../../evals/triaging-issues/).
