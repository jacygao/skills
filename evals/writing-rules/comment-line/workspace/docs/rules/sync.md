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
