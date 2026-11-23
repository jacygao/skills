# Working in this repository

Memory Lab: a spaced-repetition notes app. One repository holds the web app, the
Chrome extension, the marketing website, the shared client code and the Azure
Functions API.

## Where things are

| Path | What |
|---|---|
| `ux/shared` | Client code shared by the web app and the Chrome extension, including the offline database and sync (`offlineDb/`) |
| `ux/webapp` | The web app, memorylab.co |
| `ux/chrome-extension` | The Chrome extension. Its `manifest.json` version is the release version |
| `ux/website` | The marketing website |
| `api/content` | The content API (C#, Azure Functions, Cosmos DB) |
| `api/rag` | The RAG functions. Deployed but not in use |
| `docs/specs`, `docs/rfcs`, `docs/implementation-plans` | Feature specs, design RFCs and plans |
| `docs/release-notes` | One file per release, named by version |
| `docs/rules` | Conventions: testing, git, issues, sync, comments |

## Skills

The method lives in the owner's skills, at https://github.com/jacygao/skills.
Load the one that matches the job before doing it:

- `writing-issues`: before `gh issue create`
- `writing-pull-requests`: before `gh pr create`
- `working-issues`: before dispatching implementation to subagents
- `triaging-issues`: before triaging issues or planning a release
- `cutting-releases`: before cutting a release
- `writing-rules`: before writing or editing `docs/rules/`, `AGENTS.md` or `CLAUDE.md`

If the `skills` plugin isn't enabled, read them with
`gh api repos/jacygao/skills/contents/skills/<name>/SKILL.md -q .content | base64 -d`.

## Checks

These are what CI runs on every pull request (`.github/workflows/ci.yml`):

```bash
npm ci
npm run build --workspace=ux/webapp
npm run build --workspace=ux/website
npm run build --workspace=ux/chrome-extension
npm test --workspace=ux/shared
```

The content API's own tests are described in `docs/rules/testing.md`.

Several suites running at once on one machine fail the timing-sensitive tests.
While other agents are running theirs, run only the test files your change
touches.

## Silent failures

- **Sync can lose edits without an error.** Read `docs/rules/sync.md`
  before touching `ux/shared/offlineDb`, `api/content/Application/Sync` or
  `ContentDb`.
- **The API uses the emulator only when `CosmosDbOptions:UseEmulator=true`.**
  It no longer guesses from the hostname. Without that setting, a local run uses
  the production client and fails on the emulator's certificate.
- **The test environment shares production's database.** Nothing deployed is a
  safe place to try a change. Verify locally against the emulator.
- **A passing `ux/shared` run can still exit 1.** An editor timer from
  `NoteLink.test.js` sometimes fires after teardown (#20). Re-run it, and say
  that you did.

## The reviewer

Squiz reviews every pull request, with the Copilot CLI on `gpt-6-astra`
(`.squiz.json`, which is local and not committed). Once a pull request is open, work
the review to the end:

- `squiz threads` lists what's open.
- Fix what applies, answer each thread with `squiz reply <id> <text>`, push.
- Run `squiz review <number>` again, until nothing is open.

## Running agents here

- **One issue, one worktree, one branch, one pull request.** Dispatch subagents
  with `isolation: "worktree"`. The primary checkout stays on `main`.
- **Never merge.** The owner merges.
- **Never deploy, publish or delete cloud resources** without the owner's
  approval for that specific action.
- **An agent that can't verify something says so** in its report or the pull
  request, rather than claiming it.
