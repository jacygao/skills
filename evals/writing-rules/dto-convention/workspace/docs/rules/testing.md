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
