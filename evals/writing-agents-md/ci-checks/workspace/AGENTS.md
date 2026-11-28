# Working in this repository

## Rules

- **Before changing code, read the rules in `.claude/rules/` that apply to your
  task.** Claude Code loads them itself. Other agents list them with
  `grep -H '^description' .claude/rules/*.md`.
- **Change behaviour red, green, refactor** (the `writing-tests` skill). Commit
  the failing tests before the fix, so the pull request shows them failing. A
  change that alters no behaviour, such as docs, a rename or a test's name,
  needs no new test.
- **Write or edit a rule with the `writing-rules` skill.** Give a new rule file
  a quoted `description` and, if it covers one area of code, `paths`. An
  unquoted colon breaks the YAML, and the rule then loads everywhere.

## Skills

Load the skill that matches the job from https://github.com/jacygao/skills:

- `writing-issues`: before `gh issue create`
- `writing-pull-requests`: before `gh pr create`
- `writing-rules`: before writing or editing `.claude/rules/`, `AGENTS.md` or
  `CLAUDE.md`
- `writing-tests`: before writing or changing a test
- `writing-notes`: before writing or editing a note in `docs/notes/`
- `working-issues`: before dispatching implementation to subagents
- `triaging-issues`: before triaging issues or planning a release
- `cutting-releases`: before cutting a release

Without the `skills` plugin, read one with
`gh api repos/jacygao/skills/contents/skills/<name>/SKILL.md -q .content | base64 -d`.

## Checks

Run what CI runs before opening a pull request:

```bash
npm ci
npm run build --workspace=ux/webapp
npm run build --workspace=ux/website
npm run build --workspace=ux/chrome-extension
npm run typecheck --workspace=ux/webapp-v2
npm test --workspace=ux/webapp-v2
npm run build --workspace=ux/webapp-v2
npm run typecheck --workspace=ux/core
npm test --workspace=ux/core
npm run typecheck --workspace=ux/storage
npm test --workspace=ux/storage
npm test --workspace=ux/shared
npm test --workspace=ux/webapp -- --run
npm test --workspace=e2e
npm run typecheck --workspace=ux/mobileapp
npm test --workspace=ux/mobileapp
npm run export --workspace=ux/mobileapp
```

- **Run only the test files your change touches while other agents run
  theirs.** Suites running in parallel fail the timing-sensitive tests.

## Traps

- **Set `CosmosDbOptions:UseEmulator=true` for a local API.** Without it the API
  uses the production client and fails on the emulator's certificate.
- **Verify changes locally against the emulator,** never on the old test sites
  (test-app.memorylab.co, test.memorylab.co). They run on production's
  database until #28 removes them.
- **Treat `api/rag` as unused,** even though the Study AI's old
  `search_vectors` tool still calls it.

## Running agents here

- **Give each issue its own worktree, branch and pull request.** Dispatch
  subagents with `isolation: "worktree"`, and keep the primary checkout on
  `main`.
- **Never merge.** The owner merges.
- **Never deploy, publish or delete cloud resources** without the owner's
  approval for that specific action.
- **Say what you couldn't verify,** in your report or the pull request.
