# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.36 (draft)

## 5. The reviewer

The reviewer is a second agent that reads the change and reports what is wrong
with it. It has no GitHub access of its own. Its findings, its verdicts and its
finish reach squiz through three calls, `report_finding`, `report_verdict` and
`finish_review`, and squiz posts them. Its last message is not read.

### Adapters

An adapter drives one reviewer CLI. `reviewer` in `.squiz.json` chooses `pi` or
Copilot.

**The reviewer runs at the thinking level `thinking` sets**, on every run, and
never at the CLI's own setting. `pi` runs a model that lacks the level at
another, which `squiz doctor` names (§ 7 The setup check). Copilot takes it as
its reasoning effort, with `off` as `none`.

**The reviewer runs on the configured `model`, in its CLI's spelling, or else on
the user's default.** Each adapter spells it and finds the default as its own
section says. A model the CLI does not offer fails the round at setup, with no
review run and nothing spent, and the reason names `model` and its value:

```
"model" in .squiz.json is "openai/gpt-5", which is not a model pi offers; it must be a provider and model as pi --list-models lists them, such as "openai/gpt-5-mini"
```

With no `model`, the reviewer's command line and environment are what they are
without the setting.

**A run that completed no message has a reason that adds what the reviewer said
on stderr**, in a pane as detached. Where the adapter recognises the cause, the
reason is the adapter's alone. The Copilot adapter recognises a reviewer that is
not signed in: a run whose stderr holds `Error: No authentication information
found.` gets a reason that quotes the line and names no model:

```
the reviewer is not signed in to Copilot: it said "Error: No authentication information found."
```

Where Copilot words it any other way, and under `pi`, the round gives its
ordinary reason, with what the reviewer said. That reason adds the model the run
was handed, configured or the user's default:

```
the reviewer completed no message; "model" in .squiz.json is "gpt-5-nano", which the reviewer's CLI may not offer
the reviewer completed no message; .squiz.json sets no "model", and the user's default, "gpt-6-astra", may not be one the reviewer's CLI offers
```

**Squiz checks every reporting call itself, whatever CLI serves it.** A
malformed call is refused when it is made, and the reviewer gets the reason as
the call's error, so it can call again. Every other report of the round stands.

**A round counts as reviewed only where the reviewer made the finish call**,
whatever ended the run afterwards, the time bound included. The CLI's exit
status is not read for how the run ended.

- A round that reported nothing and finished found nothing.
- A round with no finish failed.
- Reports arriving after the finish and before the CLI exits count.
- In a round its host ended, the findings reported before the ending are posted
  and its verdicts applied. What a round whose host died reported is not posted
  (§ 3 The round host).

A failed round stays failed. It hands no threads back, and it closes the episode
only where it spent the last of the round cap or the token bound (§ 3
Terminology, § 8 The review budget).

**Stopping the reviewer stops every process it started**, the history tools'
`git` included.

**Each round records its tokens and cost as its CLI reports them.** The models a
round names are the ones its run reported, in the order it first named each.

### The `pi` adapter

The adapter `reviewer` chooses by default.

**A configured model is `provider/id`, exactly as `pi --list-models` lists it**,
such as `openai/gpt-5-mini`. A bare id listed under one provider is refused, and
the reason gives its full name. A `pi` that cannot list its models fails the
round at setup.

**A `pi` round's cost is the sum of its assistant messages' usage.** It is a
floor, "at least", where:

- the run did not end on a message's usage;
- the time bound stopped the reviewer;
- the report file could not be read to its end.

**A run where no message ended normally and no finish was recorded completed no
message.** The round's reason is the errored message's error text, and the
reviewer is not run a second time.

**A report file with a line that cannot be read fails the round**, and the
reports already read stand.

### The Copilot adapter

The adapter `"reviewer": "copilot"` chooses.

**With no `model` configured, the user's default is `COPILOT_MODEL`** in squiz's
environment, or else `model` in the user's Copilot `settings.json`. With neither,
the round runs on whatever Copilot falls back to.

**A Copilot run auto-updates nothing and sends no client telemetry**, so it
reaches only Copilot's own host and its model's.

**A Copilot round's cost comes from its usage line**, and only where Copilot
exited 0 by itself with token counts. It is never a floor:

| Figure | Read as |
|---|---|
| Tokens | Input plus output, over every model |
| AI credits | `totalNanoAiu`, at 10⁹ to a credit |

Any other Copilot round records no cost and names no model.

**The reporting server goes on answering while a history tool runs.** It is the
MCP server the adapter ships to serve the reporting calls and the history tools. A
`notifications/cancelled` naming a running history tool stops its `git`, and
that call is not answered. The server exits when its standard input closes, and
on `SIGTERM` and `SIGHUP`.

