---
name: writing-agents-md
description: What goes in a project's AGENTS.md or CLAUDE.md, what goes elsewhere, and how the file is laid out. Load BEFORE creating, restructuring or adding a section to one.
user-invocable: true
---

# Writing AGENTS.md

AGENTS.md is loaded into every session in the repository, whatever the task.
Each line is paid for in every session and competes with every other line for
attention. A line earns its place when most sessions need it, or when missing
it causes a failure nobody would see.

Write each line with `writing-rules`. This skill decides which lines exist and
where they live.

## What belongs

- **The checks.** The exact commands that must pass before a pull request,
  copied from CI. Read the CI workflow when you write them, and list every job,
  or point at the rule file that holds the rest.
- **Silent failures.** A place where a broken thing and a correct thing look
  the same, and what tells them apart: "the hook exits 0 on every failure path".
- **The unwritten convention** an agent would get wrong from reading the code,
  such as erasable TypeScript only, or how an arm is named.
- **Which skill to load before which job**: `writing-pull-requests` before
  `gh pr create`. A session whose task never matches a skill's description still
  loads it from here.
- **Where the rest is, and when to read it.** Specs, rule files, notes: one line
  each, saying what the agent does with them.
- **The limits of an agent's authority.** Never merge, never deploy, never
  delete cloud resources without approval for that action.

Use the section headings the skills' READMEs give, such as `## Checks` and
`## Silent failures`. The skills read the file by heading.

## What goes elsewhere

| Content | Its home |
|---|---|
| A rule for one area of the code | A rule file in `.claude/rules/` with `paths` |
| A method: how to split pull requests, cut a release, write a commit | The skill that does that job |
| A rule copied unchanged into several repositories | A skill |
| A product decision | The spec that argues for it |
| Something learned by building | A note in `docs/notes/` |
| The current state: which release, what exists so far | Issues and milestones |
| A rule a check can enforce | The check, with a one-line pointer here |
| How to edit this file | This skill |
| The argument for a rule | The pull request that added it |

Leave out what the agent finds by looking: the directory tree, what a file
holds, how a tool or a header format works, what the code already shows. An
overview of the codebase does not help an agent find files faster.

## Layout

- **One file.** `AGENTS.md` holds the content and `CLAUDE.md` holds the single
  line `@AGENTS.md`, so Claude Code and every other agent read the same rules.
- **Most important first.** Checks, silent failures and authority come before
  pointers.
- **Say a thing once, plainly.** Repeated emphasis ("every time, without being
  asked", "NEVER") dilutes the lines that carry none. A rule that must never be
  broken belongs in a hook or a check, which are enforced; this file is only
  read.
- **Point to rule files for every agent.** Claude Code loads `.claude/rules/`
  itself. Other agents need the command that lists them.

## Starting a new file

Write it by hand from what the project needs, not from `/init` or another
generator. Generated files describe the repository, which the agent can read
for itself. Start with the checks and the skills, and add a line each time an
agent gets something wrong that a line would have prevented.

## Editing an existing file

- **Check the section you touch before adding to it.** Each command against
  the CI workflow, each path against the tree, each cited issue against its
  state. A Checks section that says it is "what CI runs" and misses a job is
  false: make it true in the same edit, or point at the file that holds the
  rest.
- **Look for the line's real home first,** in the table above.
- **Add only what was asked,** and what makes the touched section true. Name
  any other gap in your reply, such as a skill the file does not load.
- **Remove a line that is no longer true,** or that no longer changes what an
  agent does.

## Before you finish

For each section, ask which sessions need it. If the answer is "only the ones
touching one area" or "only the ones doing one job", move it to that area's rule
file or that job's skill, and leave a pointer only if nothing else would load it.
