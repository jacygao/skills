import { handoffFor } from "./handoff.js";

export const FIXER_TOOLS = ["Read", "Edit", "Bash(git:*)", "Bash(npm:*)"];

export function fixerPrompt(round) {
  return [
    "You are the fixer. Work each finding below, push, and stop.",
    "Never run `squiz review` yourself.",
    handoffFor(round),
  ].join("\n\n");
}

export function fixerArgs(model) {
  const args = ["--model", model];
  for (const tool of FIXER_TOOLS) args.push("--allow-tool", tool);
  return args;
}
