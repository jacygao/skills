import { readFileSync } from "node:fs";

export function doctor(path = ".squiz.json") {
  const config = JSON.parse(readFileSync(path, "utf8"));
  return `Reviewer ${config.reviewer} (${path})`;
}
