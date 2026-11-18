---
name: writing-specs
description: Guiding principles for writing and editing a project's specifications, under docs/specs/ unless its AGENTS.md says otherwise. Load BEFORE writing or editing any spec, and again before rewriting a section.
user-invocable: true
---

# Writing specs

Write a specification someone can build from.

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
and concretely serves both. How the code meets a requirement is not one: the
code and its tests hold that.

## Principles

- **The spec is a standalone document.** Never reference the conversation, prior
  versions, or what was "discussed" or "decided".
- **State what the system does.** Do not state what it doesn't do unless the
  exclusion is itself a requirement.
- **State what is observable, not how it is achieved.** Commands, exit statuses,
  files, formats, settings and what a user sees. Leave out how a race, lock,
  retry or tie is resolved, and a dependency's quirk and its workaround. Before
  adding a sentence, ask whether two correct implementations would differ there
  in a way a user would notice.
- **A bug fix rarely changes the spec.** A fix that makes the code do what the
  spec says changes nothing here. One that changes observable behaviour rewrites
  the sentence that states it, and adds no sentence about the case it fixed.
- **No rationale.** Not as a section, a sentence or a clause ("because…",
  "since…"), unless it belongs in a dedicated "Decisions" or "Alternatives
  considered" section.
- **When editing, rewrite the whole section rather than append.** A section
  does not grow without a new requirement. Compare its length before and after,
  and cut what you cannot name a requirement for.
- **Write for the reader.** Who is reading this, and what do they need?
- **Start with the most useful information.** Don't bury the lede.
- **Show, don't tell.** One example per format, in its fullest common form. A
  variant gets a sentence, not another example.
- **Keep it current.** Outdated docs are worse than no docs.
- **Link, don't duplicate.** Reference other sections instead of copying.

## Resources

The project's main specification, which its `AGENTS.md` names, is the worked
example of structure and voice, not of length.

Where the project has prose rules, such as `.claude/rules/prose.md`, they govern
the sentences themselves, and specs are in their scope.
