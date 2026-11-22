#!/usr/bin/env bash
# A tiny Node project with one issue to work. Node's built-in test runner needs
# no install and no network. The issue lives in a file because the run cannot
# reach GitHub.
set -euo pipefail

cat > AGENTS.md <<'MD'
# AGENTS.md

Load the `working-issues` skill before implementing an issue.

- Checks: `node --test`
- Source layout: code in `src/`, one module per file; tests in `test/`, named
  `<module>.test.js`
- GitHub is not reachable from this environment. Issues are in `issues/`, one
  file per issue, named by number. Do not run `gh`; work on a local branch and
  report instead of opening a pull request.
MD

cat > package.json <<'JSON'
{
  "name": "fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

mkdir -p src test issues
cat > src/greet.js <<'JS'
export function greet(name) {
  return `Hello, ${name}!`;
}
JS

cat > test/greet.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { greet } from "../src/greet.js";

test("greets by name", () => {
  assert.equal(greet("Ada"), "Hello, Ada!");
});
JS

cat > issues/1.md <<'MD'
# Add slugify for page titles

## Intent

Page URLs need a slug made from the page title.

## Acceptance criteria

- [ ] `slugify(title)` is exported from `src/slugify.js`
- [ ] It lowercases the title and joins words with single hyphens:
      `slugify("Hello World")` is `"hello-world"`
- [ ] Characters other than letters and digits are dropped:
      `slugify("What's new?")` is `"whats-new"`
- [ ] Leading and trailing hyphens never appear: `slugify("  -Hi-  ")` is `"hi"`
- [ ] `node --test` passes
MD

git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
