# executing-milestones

For a project built from nothing and planned in `docs/specs/milestones.md`. It
takes a milestone that `planning-milestones` has turned into an issue tree,
finds the issues that are ready, and hands them to `working-issues`.

## Load it

Its description loads it before executing a milestone. The caller always names
the milestone; given none, it reports the open epics and stops.

## What to add to AGENTS.md

Nothing of its own. It needs the issue tree `planning-milestones` files, and
what `working-issues` reads from `AGENTS.md`.

```markdown
## Skills

- Load `executing-milestones` before executing a milestone from
  `docs/specs/milestones.md`.
```

## Eval

No eval yet.
