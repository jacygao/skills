---
name: writing-issues
description: How a GitHub issue is written. Load BEFORE running gh issue create.
user-invocable: true
---

# Writing issues

Write an issue an agent can act on and a person can read: the part at fault
named, one decided outcome, each thing in its place, nothing unneeded. One body
serves both readers.

## The templates

`gh issue create --body` bypasses the repository templates: GitHub applies
`.github/ISSUE_TEMPLATE/` to the web UI only. Read `task.md` or `bug.md` there.
Where the project has no templates, use the ones in `templates/` beside this
file. Skip the YAML frontmatter, which is for GitHub rather than for the body.

Two kinds, each with the matching label:

- **`bug`**: something behaves differently from how the spec or docs say it
  should
- **`task`**: a unit of work, or a decision, with the criteria that say when it
  is done

## Decide what is wrong before writing

Check the project's spec or docs, not only what the code does today.

- **The spec decides the behaviour.** Name the part that breaks it. That part
  is the subject of the title and of the first sentence, even where another
  part shows the symptom. State the one outcome the spec gives; offer no other.
- **The spec itself states the wrong behaviour.** The spec is a part at fault.
  Name it in the title, and ask for it to change along with the code. What
  happens still says only what a user sees; why the spec is at fault goes in
  Cause.
- **The spec does not decide.** The issue is a `task` whose job is the
  decision: Purpose asks for the choice, Options sets out each way it could go,
  and the acceptance criteria are the choice made and written down. It is
  never a bug offering "either X or Y", and never a task presenting one option
  as settled.

## Sections

These, in this order, and no other headings. Leave out an optional section
when it has nothing to say.

| Bug | Task |
|---|---|
| What happens | Purpose |
| What should happen | Context, optional |
| Reproduce, or Evidence when there is no command | Options, only for a decision |
| Cause, optional | Acceptance criteria |
| Reference, optional | Reference, optional |

- **What happens** is what a user sees, as observed. No file, function or line,
  no issue number, no diagnosis, no fix, and not how it was found.

  > Not this: `notes sync --server work` uploads to work, but the next
  > `notes sync` uploads to the default server. The server is kept only for
  > the run that was given the flag, so later runs never see it.
  >
  > This: `notes sync --server work` uploads to work, but the next
  > `notes sync` uploads to the default server.

  The second sentence of the first says how the product works inside, not
  what the user saw. It goes in Cause.
- **What should happen** is testable: a command, input or action and what it
  produces, or a document and what it says. It names anything that must stay
  as it is. Never "works correctly" or "does what it says".
- **Reproduce** holds commands and their output, in a code block, and nothing
  else. With no command, the section is **Evidence**: where and when it was
  seen and what that showed, and that it was not reproduced.
- **Cause** holds the code locations, the diagnosis, and what is not yet known.
- **Purpose** is one sentence. If it needs two, it is probably two issues.
- **Context** is the finding or the gap behind the work.
- **Options** states each option as concretely as an outcome: what it would
  do, and what it costs. Choices appear here and nowhere else.
- **Acceptance criteria** are checkboxes, each one check that passes or fails
  on its own. The project's checks passing is one.
- **Reference** lists what governs the issue: spec sections, docs, linked
  issues. "Found while ..." is its last bullet, every time.

## The title and the first sentence

Both name the part as a user knows it: a command, a setting, or what the
product does for them. The internal function or file that causes it belongs
in Cause.

- **The title is one plain clause**: the part at fault and what it does wrong
  (bug), or the work (task). Commands in backticks. Nothing joined with
  "which", "where", "but", "so", "and", "while" or a comma clause. Its length
  is not a rule; what it says is.
- **The first sentence of the body, the first under What happens or Purpose,
  says what a user sees or gets**, in their words: no internal component, state, file or function they would not know.
  It begins with what goes wrong, never with a condition ("When ...",
  "If ...", "On ..."). State a condition only when the problem needs it to
  happen, after saying what goes wrong. Quote output only when its exact text
  is the bug or what someone would search for.

From the title and the first sentence alone, a reader can say what is wrong
and which part is wrong.

## Principles

- **Every sentence is needed.** Say each fact once. Analysis that belongs in a
  linked issue stays there. There is no length limit: a complex issue may be
  long, but no longer than its facts.
- **Every claim is checked.** A command, output, path, line, section or number
  in the issue matches the code and docs as they are.
- **No priority in the body.** The label carries it, and a reason in the body
  is one more thing that can disagree with it.
- **Label and place it the way the project's `AGENTS.md` says**: kind,
  priority, area, milestone, or whatever else it requires of every issue.
- **A blocker is a relationship, not a line of text.** Set it with
  `gh issue create --blocked-by` or `gh issue edit --add-blocked-by`, so GitHub
  renders it and `--json blockedBy` reads it back.

## Resources

````bash
gh issue create --title "<the part at fault and what it does wrong>" --label bug --body "$(cat <<'EOF'
<the bug template's sections, comments removed>
EOF
)"
````

````bash
gh issue create --title "<the work, imperative>" --label task --body "$(cat <<'EOF'
<the task template's sections, comments removed>
EOF
)"
````

````bash
gh issue create --title "<the work, imperative>" --label task --blocked-by 12,13 --body "..."
gh issue edit 14 --add-blocked-by 12
````
