import { handoffFor, type Round } from "./handoff.js";

export const FIXER_TOOLS = ["Read", "Edit", "Bash(git:*)", "Bash(npm:*)"];

export function fixerPrompt(round: Round): string {
  return [
    "You are the fixer. Work each finding below, push, and stop.",
    "Never run `squiz review` yourself.",
    handoffFor(round),
  ].join("\n\n");
}

export function fixerArgs(model: string): string[] {
  const args = ["--model", model];
  for (const tool of FIXER_TOOLS) args.push("--allow-tool", tool);
  return args;
}
