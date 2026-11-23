import { test } from "node:test";
import assert from "node:assert/strict";
import { handoffFor } from "../src/host/handoff.js";

test("lists each finding by path and line", () => {
  const text = handoffFor({ number: 2, findings: [{ path: "a.js", line: 3, body: "off by one" }] });
  assert.match(text, /^Round 2 found 1 issue\(s\):\n- a\.js:3 off by one/);
});
