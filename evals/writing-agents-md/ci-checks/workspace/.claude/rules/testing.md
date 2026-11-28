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

- **Load the `writing-tests` skill before writing or changing a test.**
- **Put the command and each new test's first failure in the pull request.**

## `ux/shared` (Vitest)

- **Run one file with** `npx vitest run --root ux/shared <path>`.
- **Put tests next to the code,** as `<name>.test.{ts,tsx,js}`. Start a
  component test with `// @vitest-environment jsdom`.
- **Test sync and the offline database on real RxDB in memory**
  (`databaseManager.initialize(false, true)`), with one `userId` per test, as
  `offlineDb/content/contentSync.test.ts` does.
- **Destroy every ProseMirror or TipTap editor a test creates.** ProseMirror
  flushes DOM changes on a timer, which can fire after jsdom is gone.

## `ux/webapp` and `e2e` (Vitest)

- **Pass `--run` to the web app's tests**
  (`npm test --workspace=ux/webapp -- --run`). Without it Vitest watches and
  never exits.
- **Keep web app tests off the network.** `ux/webapp/src/test/setup.js` fails
  any test that makes a request.
- **Mount e2e pages through `AppProviders`** (`e2e/framework/providers.jsx`),
  which uses the app's real `LayoutProvider`.

## Content API (xUnit v3)

- **Put tests that need no database in `api/ContentApi.UnitTests`.** It must
  pass with the emulator stopped.
- **Put tests that touch Cosmos in `api/ContentApi.IntegrationTests`,** using
  `EmulatorFixture`. Never point a test at Azure.
- **Put code the tests share in the project's `TestHelpers/` folder.**
- **Name tests as sentences with underscores:**
  `Refuses_an_endpoint_that_is_not_on_this_machine`.
- **Use `[Theory]` with `[InlineData]` for cases that vary, and plain
  `Assert`.** Add no mocking or assertion library.
- **Stop change-feed reads on 304 Not Modified, and bound the loop.**
  `HasMoreResults` never turns false in the pull model.
- **Run them** with the emulator up:

  ```bash
  docker compose up -d cosmosdb
  dotnet test api/ContentApi.UnitTests
  dotnet test api/ContentApi.IntegrationTests
  ```

  Without a local .NET 10 SDK, use the SDK image on the emulator's network:

  ```bash
  docker run --rm --network container:$(docker compose ps -q cosmosdb) \
    -v "$PWD":/src -w /src mcr.microsoft.com/dotnet/sdk:10.0 \
    dotnet test api/ContentApi.IntegrationTests
  ```
