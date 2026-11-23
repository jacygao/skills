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
