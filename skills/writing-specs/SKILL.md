---
name: writing-specs
description: Guiding principles for writing and editing a project's specifications, under docs/specs/ unless its AGENTS.md says otherwise. Load BEFORE writing or editing any spec, and again before rewriting a section.
user-invocable: true
---

# Writing specs

Write a specification someone can build from, and keep it the size of the
product, not of its history.

## Structure

Fix the meaning of each heading level and hold to it:

- **H1**: document title. Exactly one per document.
- **H2**: a major topic. The primary unit of the document.
- **H3**: a sub-section within a topic, named for its content.
- **H4**: a subdivision of a sub-section, where one genuinely has parts.
- **H5 and deeper**: do not use. If you need a fifth level, the H2 is too broad
  and should be split.

Do not add, remove, rename, or reorder H2 sections unless asked. If a change
seems to need a new H2, say so in the reply and ask before adding it.

## Who reads it

An agent builds from this document. A person decides from it.

The agent needs every requirement present, or it invents one. The person needs
each requirement stated once, or they stop reading. A requirement stated once
and concretely serves both.

## What goes in

A sentence belongs in the spec only if it states a requirement: something a
user, a caller or another program can observe, where two correct
implementations could not differ. Commands, flags a person types, settings and
their defaults, exit statuses, files a person reads, formats, messages and
bounds.

Ask who would see it. If only the program's own parts would, such as another
module, an adapter's interface, a script's steps, or a file or field only the
program reads, it is how the code works. So is a threshold or interval the code
picked to detect something, which no person sets, and so is the condition the
code tests. State when a behaviour applies in terms the user knows, such as
"after a push", not as the comparison that detects it.

Everything else is true and worth keeping, and it has a home that is not the
spec:

| It is | It goes in |
|---|---|
| How the code works: functions, fields, internal files, the argv it builds, wrappers, locks, races, polling, retries | The code and its tests |
| The bug, its cause, the case a fix covers, why the change was made | The pull request |
| What a dependency does, the version it was seen on, a measurement | A note, where the project keeps them |
| What is not built, not measured, or still open | An issue |
| A prompt or template the program sends, in full or as a list of its points | The code. The spec says in a sentence what it must carry |

A dependency's behaviour enters the spec only as what the product does about
it: "gives up on the package registry after 30 seconds and exits 1", not why
the registry is slow or how the wait is timed.

## Editing

A change description, an issue or a pull request is the brief the code was
built from. The spec takes the requirements out of it and leaves the rest.
Most of a good brief does not belong in the spec.

**The existing text is not the model for what to add.** A section that already
holds argv, internal fields or a log line for every case is not permission to
add more of them. State the new requirement at the level this skill sets, and
name the section in the reply as one to trim. Where the change makes such
detail wrong, such as a command line the code no longer builds, delete it
rather than update it.

**A brief's flags and command lines are the code's.** Where the brief gives the
flags or command lines the program passes to another program, the spec says
what the call does, such as "resumes the session by its id", and names none of
them.

For every edit:

1. **Find where the behaviour is already stated, and change that sentence.**
   Add a sentence only for a requirement the spec does not yet state.
2. **A bug fix rarely changes the spec.** A fix that makes the code do what the
   spec says changes nothing here. One that changes observable behaviour
   rewrites the sentence that states it, and adds nothing about the case it
   fixed.
3. **State each requirement once.** Another section that needs it cites it by
   number, and a row in a table of failures names the outcome and cites where
   it is stated rather than restating it.
4. **Check the size before you finish.** Diff the spec and read every added
   line. For each, ask what a user would see differently if it were false. A
   line with no answer goes. A bug fix adds a clause or nothing, and a feature
   adds a few lines per requirement.
5. **Say in the reply** how many lines the spec grew by, and which requirement
   each addition states.

## Principles

- **The spec is a standalone document.** Never reference the conversation,
  prior versions, or what was "discussed" or "decided".
- **State what the system does.** Do not state what it doesn't do unless the
  exclusion is itself a requirement.
- **No rationale.** Not as a section, a sentence or a clause ("because…",
  "since…", "so that…"), unless it belongs in a dedicated "Decisions" or
  "Alternatives considered" section.
- **One example per format, in its fullest common form.** A message, log line
  or file gets one example. Its other cases get a sentence, not an example
  each.
- **Start with the most useful information.** Don't bury the lede.
- **Keep it current.** Outdated docs are worse than no docs.

## Trimming

When asked to trim a spec or a section, remove whole passages that fail "What
goes in", and keep every requirement, bound, default, exit status and format.
Move what has a home there before deleting it. The pull request lists each
removed passage by kind and where it went.

## Resources

The project's main specification, which its `AGENTS.md` names, is the worked
example of structure and voice, not of length or of detail.

Where the project has prose rules, such as `.claude/rules/prose.md`, they govern
the sentences themselves, and specs are in their scope.
