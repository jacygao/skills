# Skills

Claude Code skills for building software with coding agents, as a plugin
marketplace. A project enables the plugins it needs in its own settings.

| Plugin | Skills | For |
|---|---|---|
| `core` | `writing-issues`, `writing-pull-requests`, `writing-specs`, `writing-notes`, `working-issues` | Every project |
| `greenfield` | `planning-milestones`, `executing-milestones` | A project built from nothing, milestone by milestone, from `docs/specs/milestones.md` |
| `brownfield` | `triaging-issues`, `cutting-releases` | A project that has shipped, planned release by release in GitHub milestones |

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
    "core@jacygao": true,
    "brownfield@jacygao": true
  }
}
```

Swap `brownfield` for `greenfield` while the project is still being built from
nothing. Skills are invoked by plugin, such as `core:working-issues`.

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
