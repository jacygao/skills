# Working in this repository

The core of a notes app: plain ES modules on Node 24, with one dependency, `tinymark`, vendored in `node_modules`.

## Tests

**Load the `skills:writing-tests` skill before writing or changing any test.**
Every time, without being asked.

Tests use `node:test` and `node:assert/strict`. A module's tests are in
`test/<module>.test.js`. Run them with `node --test`.
