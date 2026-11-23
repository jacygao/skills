export const DEFAULT_MODEL = "gpt-6-astra";

// The flags every Copilot run squiz starts must carry.
export function reviewerArgs(model) {
  return [
    "--model", model,
    "--disable-builtin-mcps",
    "--no-auto-update",
    "--disable-client-telemetry",
    "--allow-tool", "Read",
  ];
}
