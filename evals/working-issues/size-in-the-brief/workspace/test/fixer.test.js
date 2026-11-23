import { test } from "node:test";
import assert from "node:assert/strict";
import { fixerArgs } from "../src/host/fixer.js";

test("runs the fixer on the given model", () => {
  assert.deepEqual(fixerArgs("m").slice(0, 2), ["--model", "m"]);
});
