---
name: writing-notes
description: How a durable finding is written in a project's docs/notes/. Load BEFORE writing or editing any note.
user-invocable: true
---

# Writing notes

Write a note a person can act on at a glance and later work can build from
without re-running it.

## The template

A note holds one verdict. Name the file for it, not the subject:
`cost-arrives-during-a-run.md`, not `pi-cost-reporting.md`. Listing the
directory is then the whole index, and there is no central file to update when
a note lands. Notes are written by several subagents at once, and a shared
index would conflict every time. A verdict that needs "and" is two notes.

```markdown
---
settles: "§ 4: whether pi reports cost during a run; § 7: the cost a killed round records"
issue: [12, 21]
recorded: 2026-09-12
versions: { pi: "0.84.2, 0.85.1", node: 24.15.0 }
recheck-when: pi upgrades, or an unmeasured API path is configured
---

# <the verdict, as the title>

## Intent

<One line per question the work set out to answer. That they were open is why
the note exists, so do not say it again in each one.>

## Decisions

<What to do, then a sentence on why. Lead with the decision: if "so what do I
do?" returns a different sentence, you led with the reason. Every decision
answers a question above; one that answers none was invented, and more decisions
than questions is the sign that some were. Detail stays in Reference.>

## Needs your input

<What is still open and cannot be settled without a person, each with a
recommendation. Say "Nothing" rather than omitting the section.>

## Reference

<Only what someone needs in order to act on the decisions above: field names,
endpoints, settings, required parameters, the trap that would otherwise be
rediscovered.>

## Limits

<What was not established, so a clean result is not read as a wider one.>
```

Omit a section with nothing in it, except **Needs your input**, which says
"Nothing" rather than disappearing. Its absence would be ambiguous between
nothing being needed and the author forgetting to ask.

`settles` points forward, at what the fact now governs: each H2 by number and
what it governs in a few words. What was found goes in the body. `issue` points
back, at what commissioned it, and is the note's only link to the tracker.
`recheck-when` names the upgrade that would invalidate the finding, so `grep -L`
finds what to re-run.

## What stays out

The note is the result. The work that produced it has other homes:

| It is | It goes in |
|---|---|
| How the runs were driven, the command lines used to measure, what was tried, each run and what it cost | The pull request |
| A finding: what a run showed | The decision it is evidence for, as its "why", or Reference |
| A lesson about doing the work, such as how to drive a session or what to budget, that answers none of the note's questions | The pull request, and a project rule through the `writing-rules` skill where later work should follow it |
| The history of the note: what changed since it was recorded, and when | The pull request of the change |

A table of the settings, fields or hosts someone acts on is Reference. A table
of the runs that established them is not.

> Not this, under Decisions: "**Every failure forced exited 0.** Eight firings
> failed in seven different ways and every one of them exited 0." It is a
> finding; no one does anything with it.
>
> Not this either: "**Budget seven times the reviewer's spend for the sessions
> that drive it.**" It is true, but the note asked whether the round cap holds,
> and this answers how to measure it.

## Updating a note

A later change can make a decision wrong. Rewrite the decision as it now
stands, update `recorded` and `versions`, and mark what you did not re-observe
`(unverified)`. Never append a dated paragraph: "2026-10-05: since M7 no hook
blocks" turns the note into its own changelog. Nowhere else says what the note
used to hold either: not a decision, a reference value ("700, which once failed
a round, is now in range") or a limit. A limit names what was not re-observed,
not what it was before. Where the verdict changes,
rename the file and retitle the note to match. Where the note no longer settles
anything, delete it.

## Principles

- **Record the decision, not the case for it.** Before finishing, read each
  section and ask whether someone acting on the decisions needs it. A good
  note on how a site's accent colour survives its CSP asks three questions,
  makes three decisions, gives the values a reader would otherwise rediscover,
  and states two limits. One that carries `### How the runs were driven` in
  Reference is carrying its pull request.
- **Never summarise an exact field name, endpoint or id.** The string is the
  deliverable.
- **Mark a reference value you did not see in output** as `(unverified)`, so a
  plausible guess is never read as an observation.
- **The note stands on its own.** Never write "see #12 for the details", and
  name no pull request or issue in the body. A link out of the repository is
  the first thing to rot.
- **State a limit plainly.** It is a fact, not an apology.
- **Record a contradiction with `docs/specs/` and name the section.** Do not
  edit the spec; reconciling it is a separate decision.

## Resources

- The project's prose rules, such as `.claude/rules/prose.md`, where it has
  them. They govern the sentences, and `docs/notes/` is in their scope
- The project's main specification, which its `AGENTS.md` names, cited by H2
  number, never by title
- The `writing-pull-requests` skill, where the method and the evidence go
  instead
- The `writing-rules` skill, where a lesson about how to do the work goes
