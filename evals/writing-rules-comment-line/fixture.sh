#!/usr/bin/env bash
# Mono's rules, with the comment rule as it stood before one line was added to it.
# Eval runs cannot write under .claude/, so its rules live in docs/rules/.
set -euo pipefail

cat > 'AGENTS.md' <<'EOF_FIXTURE'
# Working in this repository

Memory Lab: a spaced-repetition notes app. One repository holds the web app, the
Chrome extension, the marketing website, the shared client code and the Azure
Functions API.

## Conventions

Conventions live in `docs/rules/`, one topic per file.

- **Claude Code loads them for you.** A rule with `paths` loads when you read or
  edit a matching file. A rule without `paths` loads at the start of every
  session.
- **Other agents:** before changing code, list the rules and read the ones that
  apply to your task:

  ```bash
  grep -H '^description' docs/rules/*.md
  ```

- **Every code change starts with a failing test.** See
  `docs/rules/testing.md`, even before you open a test file.

### Adding or changing a convention

- **One topic per file.** If a rule doesn't fit an existing file's topic, start
  a new file rather than stretching one.
- **Keep each file under about 100 lines.** Split one that grows past that.
- **Give it a header:** a quoted one-line `description`, and `paths` if it
  covers one area of code. Quote every value, because an unquoted colon breaks
  the YAML, and Claude Code then silently loads the rule everywhere.
- **State the rule, then its reason in one line.** Long arguments belong in the
  issue or pull request that settled the rule; link it.
- **Only write what's true of the repository now.** If a rule lands with an open
  issue, say which one.

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
| `docs/rules` | Conventions: testing, git, issues, sync, comments, DTOs |

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
EOF_FIXTURE

mkdir -p 'docs/rules'
cat > 'docs/rules/comments.md' <<'EOF_FIXTURE'
---
description: "Writing or changing a code comment."
---

# Comments

Default to no comment. The code and its names say what it does.

- **Keep a comment only if removing it makes something ambiguous or
  dangerous.** No comments that restate a name, a type or the line below, and
  none on boilerplate: getters, wiring, config.
- **When one is needed, say why, not what,** in one line.
- **Update or delete the comment above code you change.** A comment that
  outlived its code still reads as true.
- **No `// TODO`.** File an issue instead.
- **Don't point outside the file:** no issue numbers, spec names or URLs. They
  move and the comment doesn't.
- **Tests:** the test name says what it checks. Comment only a fixture whose
  shape isn't obvious.

## How to write one

- State the one fact the code cannot show. Leave out what the code does and
  any consequence a reader can work out from the fact.
- One short sentence, with a subject and a verb. Not a fragment that only
  makes sense beside the line below it.

Bad:

```ts
// serverEtag too, or a pulled copy with a new ETag is ignored and the
// next push assumes a stale one.
```

Good:

```ts
// A pull can change only the ETag.
```
EOF_FIXTURE

mkdir -p 'docs/rules'
cat > 'docs/rules/git-and-pull-requests.md' <<'EOF_FIXTURE'
---
description: "Creating a branch, committing, opening a pull request, or deploying."
---

# Git and pull requests

## Branches

- **Name:** `<area>/<issue>-<short-name>`, for example `sync/15-token-checkpoint`,
  `ci/7-deploy-test-and-production` or `docs/4-sowie-privacy-policy`.
- **Use `tests/`, not `test/`,** for test-only branches. A branch named `test`
  exists, so git can't create anything under `test/`.
- **One issue, one branch, one worktree.** Agents work in `.claude/worktrees/`,
  and the primary checkout stays on `main`.
- **Remove a worktree and its branch** once its pull request merges.

## Commits

- **Prefix with the kind of change,** as the history does: `feat`, `fix`,
  `test`, `ci`, `docs`, `chore`, and a scope where it helps
  (`fix(api): …`, `feat(sync): …`).
- **No `Co-Authored-By` trailer, no "generated with" line and no session link,**
  in commits or in pull request bodies.

## Pull requests

- **Write the body with the `writing-pull-requests` skill,** using the sections
  that have something to say: Intent (with `Closes #N`), What changed, What did
  not change, Risks graded high or low, Verification with commands, Notes.
- **Verification names the command,** not just the number it printed.
- **Every PR check must pass.** If `ux/shared` fails only with the known
  `document is not defined` flake (#20), re-run it and say so in the PR.
- **Work squiz's review to the end:** nothing left open. See `AGENTS.md`.
- **Agents never merge.** The owner reviews and merges.

## Deploying

- **Merging to `main` deploys the web app and website to the test environment**
  (`deploy-test.yml`). Test shares production's database, so treat a merge as
  touching production data (#16 removes test).
- **Production deploys are run by hand:** `deploy-production.yml` for the web
  app and website. The content API is deployed to `ml-content-api-ae` by hand,
  with no workflow.
EOF_FIXTURE

mkdir -p 'docs/rules'
cat > 'docs/rules/issues-and-releases.md' <<'EOF_FIXTURE'
---
description: "Filing, splitting or triaging an issue, or planning or cutting a release."
---

# Issues and releases

## The issue is the spec

- **Before code changes, write an issue that says what will change.** Refine it
  with the owner until nothing is ambiguous. Implementation starts only when the
  owner confirms.
- **Write it with the `writing-issues` skill:** Purpose in one sentence,
  Acceptance criteria as a checklist ending with the checks, and Reference.

## Labels and priority

Every open issue has a kind and a priority:

- **Kind:** `task` (a unit of work) or `bug` (what happens, what should, and a
  command that reproduces it). The issue type, Task or Bug, matches.
- **`P0`** blocks the release it's in.
- **`P1`** is wanted in the next release or the one after.
- **`P2`** waits in `Backlog` until a release's theme pulls it in.

## Releases are milestones

- **A release is a GitHub milestone named by its version.** The version follows
  the Chrome extension's: `ux/chrome-extension/manifest.json`, bumping the last
  number each release (1.2.10 → 1.2.11).
- **`Backlog`** is the milestone for triaged work that no release has taken.
  Follow-ups go there unless the owner puts them in a release.
- **Which issues a release holds is the owner's call.** Propose; don't move
  issues between releases yourself.
- **Each release gets release notes** in `docs/release-notes/<version>.md`.

## Splitting large work

- **The large issue becomes the parent (the epic).** It keeps the spec and adds
  a `## Decomposition` section saying why the work is split where it is.
- **Each sub-issue is one pull request,** describable in one sentence with no
  "and", that leaves `main` green on its own.
- **Attach children with `--parent`. Never list them by hand,** because GitHub
  renders them and a hand-written list goes stale.
- **Set every real dependency as a blocker** (`gh issue edit N --add-blocked-by M`).
  Where two sub-issues edit the same file, say so in both.
- **Work the frontier:** the issues with no open blocker. Compute it when you
  need it; never store it in an issue.

## Things only a person can do

Label them `needs-human`: credentials, repository settings, installing or
publishing something, spending money, deleting cloud resources.
EOF_FIXTURE

mkdir -p 'docs/rules'
cat > 'docs/rules/sync.md' <<'EOF_FIXTURE'
---
description: "Touching sync: the offline database, the sync endpoints or ContentDb."
paths:
  - "ux/shared/offlineDb/**"
  - "api/content/Application/Sync/**"
  - "api/content/Services/ContentDb.cs"
  - "api/content/Domain/Content*.cs"
---

# Sync

Content syncs between every client and Cosmos DB through `POST /sync/pull` and
`POST /sync/push`, using RxDB's replication protocol. The web app and the Chrome
extension share `ux/shared/offlineDb`. The mobile app will implement the same
protocol itself. #10 is the full spec. Release 1.2.11 brings the server side in
line with it (#12, #13, #14); until those merge, the server still orders pulls by
`updatedAt`.

## Rules that keep edits from being lost

- **Pull follows the server's save order, never a client's clock.** The server
  reads the Cosmos change feed for the user's partition. `updatedAt` is never
  used to decide what a device downloads.
- **The checkpoint is opaque.** It is `{ token }`, and clients store it and send
  it back unread. RxDB merges checkpoints instead of replacing them, so the
  server reads only `token` and ignores any old `updatedAt`/`id` beside it.
  A missing or null token means "start from the beginning".
- **Push conflicts are decided by ETag, atomically.**
  - No previous server copy: create the document; 409 means a conflict.
  - Otherwise: replace with `IfMatchEtag`; 412 means a conflict.
  - A previous copy without `serverEtag`: a conflict.
  - On a conflict, the server returns its copy, and the client resolves it.
- **The client resolves conflicts: last write wins by `updatedAt`.** The
  conflict handler's `isEqual` compares `updatedAt` **and** `serverEtag`, so a
  device picks up the new ETag of its own write.
- **`updatedAt` is set by the client that made the edit.** Server code that
  writes content must not change it, or a background write would beat a user's
  edit.

## What crosses the wire

- **`serverEtag` is the only Cosmos system data a client sees.** Outgoing
  documents carry no field starting with `_` except `_deleted`; that includes
  `_lsn`, which change-feed documents carry. RxDB reserves `_` fields, and
  Cosmos's `_attachments` clashes with RxDB's own.
- **Incoming documents can't set server fields.** The server takes `userId` from
  the auth token, keeps `createdAt` on replace, and strips system fields and
  `serverEtag` before writing.
- **Deletes are soft:** `_deleted: true`, kept like any other update.

## Testing sync

See `docs/rules/testing.md`. Client tests run real RxDB against a scripted server, and API
tests run `ContentDb` against the emulator. A sync change needs a test for the
silent case, not just the happy path: an edit uploaded late, two pushes racing,
an old checkpoint.
EOF_FIXTURE

mkdir -p 'docs/rules'
cat > 'docs/rules/testing.md' <<'EOF_FIXTURE'
---
description: "Writing or running tests, in ux/ or the API."
paths:
  - "**/*.test.{js,jsx,ts,tsx}"
  - "**/vitest.*"
  - "api/ContentApi.*Tests/**"
  - "ux/webapp/src/test/**"
  - "e2e/**"
  - ".github/workflows/ci.yml"
---

# Testing

## Every change

- **Red, then green.** Write the test first and watch it fail for the reason it
  names, then make it pass. A test never seen failing is deleted, not kept.
- **Where a test can't fail first** (it pins behaviour that already holds), break
  the code on purpose, watch the test fail, then revert.
- **Fake only the boundary.** Run the real code and replace only what crosses the
  network. Sync tests, for example, run real RxDB against a scripted server.
- **Put the evidence in the pull request:** the command you ran, and each new
  test's first failure.

## Client code (`ux/shared`, Vitest)

- **Run:** `npm test --workspace=ux/shared`. A single file:
  `npx vitest run --root ux/shared <path relative to ux/shared>`.
- **Tests sit next to the code,** as `<name>.test.ts`, `.tsx` or `.js`.
- **Environment:** tests run in `node` by default. A component test opts into
  jsdom with `// @vitest-environment jsdom` as its first line.
- **Offline database and sync:** use real RxDB on in-memory storage
  (`databaseManager.initialize(false, true)`) and give each test its own
  `userId`. `offlineDb/content/contentSync.test.ts` is the pattern.
- **Editors:** destroy every ProseMirror/TipTap editor a test creates before the
  test ends. A timer left running fails the whole run after teardown (#20).
- **Other suites:** `ux/webapp` and `e2e` don't pass yet and aren't in CI (#8).

## Content API (`api/`, xUnit v3)

Two test projects, each folder named after its project:

| Project | Holds | Needs |
|---|---|---|
| `api/ContentApi.UnitTests` | Logic that needs no database | Nothing. It must pass with the emulator stopped |
| `api/ContentApi.IntegrationTests` | Anything that reads or writes Cosmos | The local emulator |

- **Integration tests use `EmulatorFixture`,** shared through the xUnit
  collection fixture. It creates a uniquely named database per run and deletes it
  afterwards, even when tests fail, and it refuses any endpoint that isn't on this
  machine. Never point a test at Azure.
- **Names are sentences, with underscores:**
  `Refuses_an_endpoint_that_is_not_on_this_machine`.
- **Assertions:** use `[Theory]` with `[InlineData]` for cases that vary, and
  plain `Assert`. There's no mocking library and no assertion library.
- **Runner:** `global.json` selects Microsoft.Testing.Platform, which xUnit v3
  needs on .NET 10.
- **Change-feed reads stop on 304 Not Modified,** and always bound the loop. In
  the pull model `HasMoreResults` never turns false.

### Running the API tests

```bash
docker compose up -d cosmosdb   # the vNext emulator, HTTPS on 8081
dotnet test api/ContentApi.UnitTests
dotnet test api/ContentApi.IntegrationTests
```

Without a local .NET 10 SDK, run them in the SDK image on the emulator's
network:

```bash
docker run --rm --network container:$(docker compose ps -q cosmosdb) \
  -v "$PWD":/src -w /src mcr.microsoft.com/dotnet/sdk:10.0 \
  dotnet test api/ContentApi.IntegrationTests
```

## CI

`.github/workflows/ci.yml` runs two checks on every pull request:
- **Build and test:** the client builds, and the `ux/shared` tests.
- **Content API tests:** the unit tests, then the integration tests against the
  emulator as a service container.

A failing test in any of them fails the pull request.
EOF_FIXTURE
