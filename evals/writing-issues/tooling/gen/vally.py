"""Generate each case's Vally eval spec.

  python3 -I vally.py <gen dir> <judges dir> <evals/writing-issues> <case,...>

Reads the case's description and prompt from <gen dir>/<case>.yaml, the
structural checks from graders.yaml, and the questions from the judges dir.
Writes <case>/eval.yaml. The questions are one Vally panel: each judge model
answers every question, with the repo the agent worked in as the sources, and
each question takes the majority verdict across the models.
"""
import json, re, sys

JUDGES = ['gpt-6.2-astra']  # add models here for a majority across them
QUESTIONS = ['title-two-facts', 'opening-internal-first', 'opening-unexplained-term',
             'alternatives-outside-options', 'offers-choice-spec-decides', 'settles-undecided',
             'blames-conforming-part', 'contradicts-sources', 'vague-outcome', 'bundled-criterion',
             'cause-in-what-happens', 'reproduce-not-runnable', 'missing-part']

G, J, E = sys.argv[1:4]
cases = sys.argv[4].split(',')
blocks = {re.match(r'  - name: (\S+)', b).group(1): b
          for b in re.split(r'\n(?=  - name: )', open(f'{G}/graders.yaml').read())[1:]}
q = json.dumps  # a JSON string is a valid YAML double-quoted scalar


def field(block, key):
    m = re.search(rf"^    {key}: '((?:[^']|'')*)'$|^    {key}: (\S+)$", block, re.M)
    return None if not m else (m.group(1).replace("''", "'") if m.group(1) is not None else m.group(2))


def block_scalar(text, indent):
    pad = ' ' * indent
    return '|\n' + '\n'.join(pad + l if l else '' for l in text.rstrip('\n').split('\n'))


for case in cases:
    d = f'{E}/{case}'
    head = open(f'{G}/{case}.yaml').read()
    prompt = '\n'.join(l[2:] for l in re.search(r'^prompt: \|\n((?:  .*\n|\n)+)', head, re.M).group(1).split('\n')).rstrip('\n') + '\n'
    desc = ' '.join(re.search(r'^description: >\n((?:  .*\n)+)', head, re.M).group(1).split())
    graders = [(n, field(b, 'type')) for n, b in blocks.items()] + [(n, 'llm') for n in QUESTIONS]
    n_regex = sum(t == 'regex' for _, t in graders)
    n_llm = sum(t == 'llm' for _, t in graders)
    panel = open(f'{J}/_panel.txt').read().replace('{request}', prompt)

    out = [f'name: writing-issues-{case}', f'description: {q(desc)}',
           'defaults:', '  runs: 3', '  timeout: 10m', '  executor: copilot-sdk', '  model: claude-opus-5.5',
           # Weights are per grader type; these give every scored grader an
           # equal share. Skill use is an indicator.
           'scoring:', '  threshold: 0.8', '  weights:', '    skill-invocation: 0',
           f'    file-matches: {n_regex / (n_regex + n_llm):g}',
           f'    panel: {n_llm / (n_regex + n_llm):g}',
           # At eval level, not on the stimulus, so an experiment variant can
           # replace the skills: a stimulus's environment wins over a variant's.
           'agent_environment:',
           '  skills: [../../../skills/writing-issues]',
           '  files: [{ src: fixture.sh, dest: fixture.sh }]',
           # The fixture commits its directory, so it must not be in it.
           '  commands: [\'f=$(mktemp) && mv fixture.sh "$f" && bash "$f" && rm -f "$f"\']',
           'stimuli:', f'  - name: {case}', f'    prompt: {block_scalar(prompt, 6)}',
           '    graders:']
    for name, typ in graders:
        if typ == 'tool_used':
            out += [f'      - name: {name}', '        type: skill-invocation',
                    '        config: { required: [writing-issues] }']
        elif typ == 'regex':
            b = blocks[name]
            pat = field(b, 'pattern')
            flags = field(b, 'flags')
            if flags:
                pat = f'(?{flags}){pat}'
            out += [f'      - name: {name}', '        type: file-matches',
                    f'        config: {{ path: issues/new.md, pattern: {q(pat)}, negate: {str(field(b, "match") == "not_contains").lower()} }}']
        elif typ != 'llm':
            sys.exit(f'{case}: no Vally grader for {name} ({typ})')
    out += ['      - name: judges', '        type: panel', '        config:',
            f'          models: [{", ".join(JUDGES)}]', '          aggregation: majority',
            '          scoring: binary', '          evidence: [{ source: repo }]',
            f'          prompt: {block_scalar(panel, 12)}', '          criteria:']
    out += [f'            - {{ name: {n}, description: {q(open(f"{J}/{n}.txt").read().strip())} }}'
            for n, t in graders if t == 'llm']
    open(f'{d}/eval.yaml', 'w').write('\n'.join(out) + '\n')
print('generated', len(cases))
