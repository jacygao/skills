export interface Round {
  number: number;
  findings: { path: string; line: number; body: string }[];
}

export function handoffFor(round: Round): string {
  const items = round.findings.map((f) => `- ${f.path}:${f.line} ${f.body}`);
  return [
    `Round ${round.number} found ${round.findings.length} issue(s):`,
    ...items,
    "Once you have pushed your fixes, run `squiz review` again.",
  ].join("\n");
}
