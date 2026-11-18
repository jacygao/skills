---
name: writing-rules
description: How an instruction file for agents is written - a rule in .claude/rules/, AGENTS.md or CLAUDE.md. Load BEFORE writing or editing one.
user-invocable: true
---

# Writing rules

A rule file is read by an agent about to act. Every line is an instruction it
acts on, and the file holds nothing else.

## The rule

```markdown
- **<What to do, as an imperative.>** <One example, or the one-line reason a
  capable agent would otherwise reverse it.>
```

That's it. Most rules are one line.

## Principles

- **Write the instruction that was asked for.** The request sets the scope.
  What else you noticed goes in your reply, where the person can choose to
  add it.
- **Instruct, and leave describing to the source.** How a tool, a format or
  the code works is in the tool's docs, the file itself or the code. Write what
  to do with it.
- **Cache only what looking cannot find.** An agent reads the code, the config
  and every file you point it at. Write the unwritten choice, the trap and the
  convention, and point at the rest.
- **Leave the request's explanation in the request.** What the person
  explained to you, the reader sees in the files themselves. Write what the
  reader does with them.
- **Give a reason only to stop a reversal.** One clause, kept where a capable
  agent would otherwise undo the rule. The case for the rule lives in the pull
  request that added it.
- **Each rule once, in its one home.** Cite it from elsewhere.
- **State the target behaviour.** "Write one-line comments" steers better than
  a list of what to avoid.

## Before you finish

Read each sentence and ask what the agent does differently for having read it.
Delete every sentence with no answer, whole. Then compare the length with the
request: a one-line ask gets a few lines.
