---
name: writing-tests
description: How a test is chosen and written - test first, against the unit as a black box. Load BEFORE writing or changing any test.
user-invocable: true
---

# Writing tests

A test is a claim about what the code does, seen from outside. Write the one
that fails when that behaviour breaks.

## Red, green, refactor

- **Write the test first, and watch it fail for the reason it names.** A test
  that was never seen failing has not shown it can, and is deleted rather than
  kept.
- **Then write the code that makes it pass, and refactor with the test kept
  green.** A test written after the code is not one of these.
- **Asked to test code that already exists, break the behaviour each test
  names, watch the test fail, and put the code back.** A test that still
  passes with the behaviour broken tests something else.

## Test the unit as a black box

- **Choose each case from the unit's inputs and outputs**, or from a user's
  action and what they see, never from its branches.
- **Drive it through its public surface, and fake only what the test cannot
  run for real.** That is the network, the clock, or a platform API the test
  runtime lacks, such as the browser's storage under Node. Never fake a module
  of your own: fake the browser's `SpeechRecognition`, not the module of yours
  that wraps it, and fake `fetch`, not your client for the API.
- **Assert the result someone can observe.** Read the note back from the
  database rather than asserting the arguments of the call that wrote it.
- **Test this project's code, not a library's behaviour through it.** A case
  that shows a markdown parser makes `**x**` bold tests the parser.

## Not a test

Do not write, and delete where you find:

- **One written to reach a line.** Coverage is not a goal.
- **One that checks a constant, a literal, a config value or a data table**,
  such as that the sample decks number exactly three.
- **One that asserts an internal call, a mock's arguments or internal state**
  where an observable result exists.
- **One that asserts nothing**, such as `expect(true).toBe(true)`, or that
  tests a copy of the code defined inside the test.
