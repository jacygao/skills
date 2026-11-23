export function handoffFor(round) {
  const items = round.findings.map((f) => `- ${f.path}:${f.line} ${f.body}`);
  return [
    `Round ${round.number} found ${round.findings.length} issue(s):`,
    ...items,
    "Once you have pushed your fixes, run `squiz review` again.",
  ].join("\n");
}
