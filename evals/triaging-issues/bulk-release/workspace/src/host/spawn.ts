import { spawn } from "node:child_process";

// Starts a Copilot run with the given arguments and prompt, detached.
export function startCopilot(args: string[], prompt: string): void {
  spawn("copilot", [...args, "--prompt", prompt], { detached: true, stdio: "ignore" }).unref();
}
