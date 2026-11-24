# Milestones

**Version:** 0.11 (draft)
**Status:** For review
**Owner:** TBD

---

Ten milestones for building Squiz, in the order they are done. Each ends in
something that can be run or seen, never in a module written.

M9 is the last of them. The P1 and P2 entries of the specification's What ships
that no milestone here delivers are a second version, and its milestones are
planned once M9 closes.

## M3 — The GitHub client and the coding agent's commands

Everything that shells out to `gh`, and the two commands that make it
demonstrable before the loop exists: `squiz threads` and `squiz reply`.

Covers bringing the head-branch lookup M1 landed under the typed error
contract; fetching the pull request's number, base and head refs, description
and diff; listing review threads with their comments and resolved state;
creating an anchored review comment with `path`, `line`, `side` and
`commit_id`; replying in a thread; resolving and re-opening; and posting an
issue-level comment.

### Acceptance criteria

- [ ] Against a scratch pull request, `squiz threads` lists the open threads
      and `squiz reply` adds a reply that appears in the thread.
- [ ] Every capability in the specification's GitHub access list has a tested
      call behind it, re-opening included.
- [ ] A failure returns a typed error rather than throwing, and a partial
      success is never reported as success.
- [ ] The thread identifier `squiz reply` takes is decided and recorded. It
      round-trips from `squiz threads` output and survives being copied by an
      agent.

This milestone needs a scratch repository and pull request to test against.

## M9 — Install and dogfood

The marketplace manifest, a README carrying the getting-started steps,
`/squiz doctor`, and `docs/notes/` consolidated.

### Acceptance criteria

- [ ] `/plugin marketplace add` followed by `/plugin install` works into a fresh
      host project.
- [ ] `/squiz doctor` reports `git`, `gh` and its authentication, `pi`, Claude
      Code, and the Node version, naming whatever is missing.
- [ ] A subagent there produces a reviewed pull request end to end.
- [ ] Squiz reviews its own pull requests in this repository.
