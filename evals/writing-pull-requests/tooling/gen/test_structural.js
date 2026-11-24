// bun gen/test_structural.js <eval.yaml>: the structural patterns against bodies they must and must not match.
const spec = Bun.YAML.parse(await Bun.file(process.argv[2]).text());
const graders = Object.fromEntries(spec.stimuli[0].graders.filter(g => g.type === 'file-matches').map(g => [g.name, g.config.pattern]));
const re = p => { const m = p.match(/^\(\?([a-z]+)\)/); return m ? new RegExp(p.slice(m[0].length), m[1]) : new RegExp(p); };
const cases = [
  ['closes-in-intent', '# T\n\n## Intent\n\n- Why\n\nCloses #38\n\n## What changed\n\n- X\n', false],
  ['closes-in-intent', '# T\n\nCloses #38\n\n## Intent\n\n- Why\n', true],
  ['closes-in-intent', '# T\n\n## Intent\n\n- Why\n\n## Notes\n\nFixes #4\n', true],
  ['no-table', '# T\n\n| a | b |\n|---|---|\n| 1 | 2 |\n', true],
  ['no-table', '# T\n\nItem | Result\n--- | ---\nA | B\n', true],
  ['no-table', '# T\n\n  a | b\n  :-|-:\n', true],
  ['no-table', '# T\n\n- a | b\n- c\n\n---\n', false],
];
let bad = 0;
for (const [name, body, matches] of cases) {
  const got = re(graders[name]).test(body);
  if (got !== matches) { bad++; console.log(`FAIL ${name}: expected ${matches} on ${JSON.stringify(body)}`); }
}
console.log(bad ? `${bad} failed` : `${cases.length} passed`);
process.exit(bad ? 1 : 0);
