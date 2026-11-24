# Skills

Claude Code skills for building software with coding agents, shipped as one
plugin. Each skill is named `skills:<name>`, such as `skills:working-issues`.

| Skill | What it does | For | Eval, with skill vs without | |
|---|---|---|---|---|
| `writing-issues` | Writes a GitHub issue | Every project | 92% vs 64% | [README](skills/writing-issues/README.md) |
| `writing-pull-requests` | Writes a pull request body and keeps it true | Every project | 87% vs 74% | [README](skills/writing-pull-requests/README.md) |
| `writing-specs` | Writes and edits a specification | Every project | 99% vs 61% | [README](skills/writing-specs/README.md) |
| `writing-notes` | Records a finding in `docs/notes/` | Every project | 100% vs 35% | [README](skills/writing-notes/README.md) |
| `writing-rules` | Writes `AGENTS.md`, `CLAUDE.md` and rule files | Every project | 85% vs 77% | [README](skills/writing-rules/README.md) |
| `writing-tests` | Writes a test, test first | Every project | 99% vs 63% | [README](skills/writing-tests/README.md) |
| `working-issues` | Works issues through subagents into verified pull requests | Every project | 75% vs 60% | [README](skills/working-issues/README.md) |
| `planning-milestones` | Turns a planned milestone into an issue tree | Built from `docs/specs/milestones.md` | 100% vs 50% | [README](skills/planning-milestones/README.md) |
| `executing-milestones` | Finds a milestone's ready issues and works them | Built from `docs/specs/milestones.md` | No eval yet | [README](skills/executing-milestones/README.md) |
| `triaging-issues` | Prioritises issues and plans a release | Shipped, with GitHub milestones | 94% vs 86% | [README](skills/triaging-issues/README.md) |
| `cutting-releases` | Bumps, tags and publishes a release | Shipped, with GitHub milestones | No eval yet | [README](skills/cutting-releases/README.md) |

## Use it in a project

Check this into the project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "jacygao": {
      "source": { "source": "github", "repo": "jacygao/skills" }
    }
  },
  "enabledPlugins": {
    "skills@jacygao": true
  }
}
```

## What to add to the project's AGENTS.md

The skills hold the method; `AGENTS.md` holds what is specific to the project.
Each skill's README gives the lines it needs, under these headings:

| Heading | What goes in it | Read by |
|---|---|---|
| Skills | When to load each skill | Every skill |
| Checks | The command that runs the checks | `working-issues`, `planning-milestones` |
| Specification | The main spec, and the sections fixing language rules and source layout | `working-issues`, `planning-milestones`, `writing-specs`, `writing-notes` |
| Silent failures | Where a broken thing and a correct thing look the same | `working-issues` |
| Reviewer | The automated reviewer on pull requests, and the command that reads its review | `working-issues` |
| Running agents | Standing rules for agents in this project | `working-issues` |
| Issues | What every issue carries, and what each priority means | `writing-issues`, `triaging-issues` |
| Releases | The files that carry the version | `cutting-releases` |

Rules files and `CLAUDE.md` content cannot ship in a plugin, so a project keeps
its `.claude/rules/` itself. Load `writing-rules` before editing any of them.

## Evals

Each skill with an eval has its cases in `evals/<skill>/`. The score is the
mean grade across every case and trial, with the skill and with no skill:

```bash
cd evals/<skill> && vally experiment run skill.experiment.yaml
```
