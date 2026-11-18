# Skills

Claude Code skills for building software with coding agents, as one plugin. A
project enables it in its own settings, and every skill is named
`skills:<name>`, such as `skills:working-issues`, wherever it sits in this
repository.

| Skill | For |
|---|---|
| `writing-issues`, `writing-pull-requests`, `writing-specs`, `writing-notes`, `writing-rules` | Every project |
| `working-issues` | Every project: issues worked through subagents, worktrees and verification |
| `planning-milestones`, `executing-milestones` | A project built from nothing, milestone by milestone, from `docs/specs/milestones.md` |
| `triaging-issues`, `cutting-releases` | A project that has shipped, planned release by release in GitHub milestones |

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

The project's `AGENTS.md` names the skills it uses and when to load each one.

## What a project's AGENTS.md provides

The skills hold the method. What is specific to a project lives in its
`AGENTS.md`, and the skills read it from there:

- **When to load each skill**, such as `writing-specs` before editing
  `docs/specs/`
- **Its checks**, by the command that runs them
- **Its specification**, and the part of it that fixes the language rules and the
  source layout
- **The silent failures** it is prone to, so a brief can name them
- **An automated reviewer**, where one runs on pull requests, and the command
  that reads its review
- **Standing rules** for running agents in it
- **Issue conventions**: what every issue must carry, such as a priority and a
  milestone, and what each priority means
- **Releases**: the files that carry the version, and whether a specification's
  version moves with a release

Rules files and `CLAUDE.md` content cannot ship in a plugin, so a project keeps
its `.claude/rules/` itself.
