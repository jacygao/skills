import { writeFileSync, mkdirSync } from "node:fs";
import { handoffFor, type Round } from "./handoff.js";

export function endHeadlessRound(round: Round): void {
  mkdirSync(".squiz", { recursive: true });
  writeFileSync(".squiz/handoff.md", handoffFor(round));
}
