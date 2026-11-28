# Skills

Agent skills for building software with coding agents. Each one is a folder
holding a `SKILL.md`, so any agent that reads that format can load it, such as
Claude Code or GitHub Copilot.

| Skill | Purpose | Project | Eval with skill | Eval without | Details |
|---|---|---|---|---|---|
| `writing-issues` | Writes a GitHub issue | Every project | 92% | 64% | [README](skills/writing-issues/README.md) |
| `writing-pull-requests` | Writes a pull request body and keeps it true | Every project | 87% | 74% | [README](skills/writing-pull-requests/README.md) |
| `writing-specs` | Writes and edits a specification | Every project | 99% | 61% | [README](skills/writing-specs/README.md) |
| `writing-notes` | Records a finding in `docs/notes/` | Every project | 100% | 35% | [README](skills/writing-notes/README.md) |
| `writing-agents-md` | Decides what goes in `AGENTS.md` and what goes elsewhere | Every project | 96% | 50% | [README](skills/writing-agents-md/README.md) |
| `writing-rules` | Words a rule in `AGENTS.md`, `CLAUDE.md` or a rule file | Every project | 85% | 77% | [README](skills/writing-rules/README.md) |
| `writing-tests` | Writes a test, test first | Every project | 99% | 63% | [README](skills/writing-tests/README.md) |
| `working-issues` | Works issues through subagents into verified pull requests | Every project | 75% | 60% | [README](skills/working-issues/README.md) |
| `planning-milestones` | Turns a planned milestone into an issue tree | Built from `docs/specs/milestones.md` | 100% | 50% | [README](skills/planning-milestones/README.md) |
| `executing-milestones` | Finds a milestone's ready issues and works them | Built from `docs/specs/milestones.md` | – | – | [README](skills/executing-milestones/README.md) |
| `triaging-issues` | Prioritises issues and plans a release | Shipped, with GitHub milestones | 94% | 86% | [README](skills/triaging-issues/README.md) |
| `cutting-releases` | Bumps, tags and publishes a release | Shipped, with GitHub milestones | – | – | [README](skills/cutting-releases/README.md) |

## Use it in a project

### Claude Code

The skills ship as one plugin, and each is named `skills:<name>`, such as
`skills:working-issues`. Check this into the project's `.claude/settings.json`:

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

### GitHub Copilot and other agents

Copy each skill's folder from `skills/` into the folder the agent reads skills
from: `.github/skills/` in the project for GitHub Copilot, or `~/.copilot/skills/`
for every project.

### AGENTS.md

Each skill's README gives the lines to add to the project's `AGENTS.md`.
Rules files and `CLAUDE.md` content cannot ship in a plugin, so a project keeps
its `.claude/rules/` itself. Load `writing-agents-md` before adding a section
to `AGENTS.md`, and `writing-rules` before writing any rule.

## Evals

Each skill with an eval has its cases in `evals/<skill>/`. The score is the
mean grade across every case and trial, with the skill and with no skill. A
dash means the skill has no eval yet. The agent under test runs through the
GitHub Copilot SDK, on Claude Opus 5.5. To rerun one:

```bash
cd evals/<skill> && vally experiment run skill.experiment.yaml
```
