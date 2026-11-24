---
name: writing-pull-requests
description: How a GitHub pull request body is written and kept true. Load BEFORE every gh pr create or gh pr edit, even when it was loaded earlier in the session.
user-invocable: true
---

# Writing pull requests

Write a pull request body a reviewer can act on. The reviewer, person or
agent, reads it as the contract for the change: what it does, what it leaves
alone, and what was shown to work. A claim the diff does not bear out costs a
round of review, or a wrong finding.

## The template

`gh pr create --body` bypasses the repository template: GitHub applies
`.github/PULL_REQUEST_TEMPLATE.md` to the web UI only. Read that file and use
the sections that have something worth saying, under its headings and no
others. Where the project has none, use `templates/PULL_REQUEST_TEMPLATE.md`
beside this file.

The template is the only copy of the structure. Change the section list there,
not here.

## Read the diff before writing

Write from `git diff <base>...HEAD`, not from memory of the work or from the
brief. The brief says what was meant; the diff says what the change does.

- **State what the code does, as the diff does it.**

  > Not this: the upload's timeout now covers the whole request.
  >
  > This: the upload's timeout now runs from the first byte sent to the last
  > byte of the response; connecting is not counted.

  The first is what the change set out to do. A reviewer checks the code
  against it, finds a mismatch, and raises a finding on the description.
  "Every", "each" and "all" are claims too: "every request now retries" is
  false while the health check still calls the client directly. Bound the
  word to what the diff touches.
- **A claim that nothing else is affected names the search behind it**, run over
  the whole repository, docs included. "Nothing else calls the old flag" is
  false while a README still shows it. Search with `git grep`, and fix what it
  finds or name it. Quote the command as it ran, with its paths and
  exclusions: the claim reaches no further than that search did.
- **Find the risk in the diff.** Ask what the changed code now does in its worst
  case. A timeout added to each of several calls in a loop bounds each call,
  not the loop; the worst case is their sum. A failure the change already
  stops on and reports, such as a build step that fails when its input
  moves, is what the change does: say it once, in What changed, not again
  as a risk.

## Principles

- **Write for the reader.** Who is reading this, and what do they need?
- **Lead with what decides how to review it.** A merge-order dependency, a spec
  that now runs ahead of the code, a fix for a path not reachable in practice:
  the reviewer needs it before the rest, so it opens Intent, or is a Risk. Not
  in Notes.
- **Behaviour, not mechanism.** Say what a user, caller or reviewer sees
  change. Function names, internal fields and constants belong in the diff,
  unless the change is a refactor whose subject they are.
- **Size it to the change, not to the work.** A small change gets a short
  body. A check a brief asked for is reported as its result, in a line, not as
  its working: "every route in the list has a test", not the table that
  shows it.
- **Every section is optional.** Keep one because it says something a reader
  needs, not because the template lists it.
- **Every line earns its place.** One honest sentence beats three obvious ones.
  "`squiz status` still takes no argument" in What did not change tells the
  reader nothing they would have doubted.
- **Bullets, not paragraphs.** A reader should not have to parse a paragraph to
  find the three facts inside it.
- **`Closes #N` sits in Intent**, and only where this change finishes the
  issue. Otherwise "Part of #N", and what is left.
- **What did not change names every place the change leaves inconsistent on
  purpose**: the passages still describing the old behaviour, the callers not
  moved yet, the follow-up issue that will. A decision by the owner that
  narrows the scope goes here too, not only in a thread reply.
- **Grade each risk high or low.** Something unverified, undecided or deferred,
  such as "no trial has run on it yet", is a note, not a risk.
- **Verification reports only what ran.** A result goes in only if you, or the
  brief, ran the check and saw it; a result you expect is not one. A command
  you suggest but did not run is labelled as a suggestion. Name the command,
  not the number it printed, and say which checks were by hand. Claim what
  the run showed, not what you infer from it: a request that succeeds on a
  warm cache says nothing about a cold start.
- **Say what could not be shown, where a reader would look for it.** A
  migration that runs only on deploy cannot be shown from the branch: say so,
  and why, rather than cite a run that could not have happened. A check that
  never applied needs no line, not even one saying it was skipped: "no Go
  changed, so `go test` was not run" tells the reader nothing.
- **Transcribe no figure that will move.** A test count, a spec version arrow,
  a count of runs: each goes stale as the branch moves, in any section. Cite
  an issue by number only once it is filed.
- **Show a visible change.** A change to what a page or terminal shows carries
  a screenshot or the output, not the word "screenshots".

## After a fix commit

Each push can make the body false. Before pushing a fix, read the body against
the new diff and rewrite the lines it changed, in place. Replace a stale claim;
do not append the history of how it changed. What a review round found goes
in the thread replies, not the body.

## Resources

````bash
gh pr create --title "<one line, imperative>" --body "$(cat <<'EOF'
<the sections worth keeping, from the template, comments removed>
EOF
)"
gh pr edit <number> --body "$(cat <<'EOF'
<the whole body, rewritten against the new diff>
EOF
)"
````
