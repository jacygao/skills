---
name: writing-notes
description: How a durable finding is written in a project's docs/notes/. Load BEFORE writing or editing any note.
user-invocable: true
---

# Writing notes

Write a note a person can act on in one screen and later work can build from
without re-running it.

## The template

Name the file for the verdict, not the subject: `cost-arrives-during-a-run.md`,
not `pi-cost-reporting.md`. Listing the directory is then the whole index, and
there is no central file to update when a note lands. Notes are written by
several subagents at once, and a shared index would conflict every time.

```markdown
---
settles: "§ 4: whether pi reports cost during a run, and how a round's cost is summed; § 7: the cost a killed round records"
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
than questions is the sign that some were. A finding is not a decision, and the
evidence for a decision is not a second decision. Detail stays in Reference.>

## Needs your input

<What is still open and cannot be settled without a person, each with a
recommendation. Say "Nothing" rather than omitting the section.>

## Reference

<Only what someone needs in order to act on the decisions above: field names,
endpoints, required parameters, the trap that would otherwise be rediscovered.>

## Limits

<What was not established, so a clean result is not read as a wider one.>
```

Omit a section with nothing in it, except **Needs your input**, which says
"Nothing" rather than disappearing. Its absence would be ambiguous between
nothing being needed and the author forgetting to ask.

`settles` points forward, at what the fact now governs, cited by H2 number.
`issue` points back, at what commissioned it. `recheck-when` names the upgrade
that would invalidate the finding, so `grep -L` finds what to re-run.

## Principles

- **Record the decision, not the case for it.** Method, evidence, tables, what
  was tried, how runs were driven and what they cost go in the pull request.
- **Fit one screen.** A note past about 80 lines is carrying the case for its
  decisions. Move that to the pull request before finishing.
- **Never summarise an exact field name, endpoint or id.** The string is the
  deliverable.
- **Mark a reference value you did not see in output** as `(unverified)`, so a
  plausible guess is never read as an observation.
- **Never write "see #12 for the details".** The note stands on its own, and a
  link out of the repository is the first thing to rot.
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
