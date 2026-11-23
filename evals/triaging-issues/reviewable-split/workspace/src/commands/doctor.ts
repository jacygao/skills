import { readFileSync } from "node:fs";

export function doctor(): string {
  const config = JSON.parse(readFileSync(".squiz.json", "utf8"));
  return `Reviewer ${config.reviewer} (.squiz.json)`;
}
