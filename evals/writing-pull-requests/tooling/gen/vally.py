"""Generate each case's Vally eval spec.

  python3 -I vally.py <evals/writing-pull-requests> [case,...]

Reads the case's description, prompt, branch and commits from gen/<case>.yaml,
and the questions from judges/: the generic ones every case gets, then the
case's own criteria. Writes <case>/eval.yaml. The judges get the request and
the branch's diff in their prompt, since a repo snapshot carries no history.
With no cases named, generates every gen/*.yaml.
"""
import glob, json, os, shlex, shutil, subprocess, sys, tempfile

JUDGES = ['gpt-6.2-astra']  # add models here for a majority across them
QUESTIONS = ['contradicts-the-change', 'claims-unshown', 'no-effect-unchecked',
             'leaves-inconsistent-unnamed', 'mechanism-not-behaviour', 'working-not-result',
             'transcribed-figure', 'unverified-as-risk', 'obvious-filler', 'missed-worst-case']
HEADINGS = ['Intent', 'What changed', 'What did not change', 'Risks', 'Verification', 'Notes']
FIXTURE = '-c user.name=fixture -c user.email=fixture@example.com'
CLOSES = r'\b(?:[Cc]loses|[Ff]ixes|[Rr]esolves) #\d'

T = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
E = sys.argv[1]
cases = sys.argv[2].split(',') if len(sys.argv) > 2 else sorted(
    os.path.basename(p)[:-5] for p in glob.glob(f'{T}/gen/*.yaml'))
q = json.dumps  # a JSON string is a valid YAML double-quoted scalar


def load(path):
    js = 'console.log(JSON.stringify(Bun.YAML.parse(await Bun.file(process.argv[1]).text())))'
    return json.loads(subprocess.check_output(['bun', '-e', js, path]))


def net_diff(case, has_fix):
    """The branch's diff against main once every commit is applied."""
    with tempfile.TemporaryDirectory() as d:
        w = f'{d}/w'
        shutil.copytree(f'{E}/{case}/workspace', w)
        git = lambda *a, **k: subprocess.run(['git', '-C', w, *a], check=True, capture_output=True, text=True, **k)
        git('init', '-q')
        git('add', '-A')
        git(*FIXTURE.split(), 'commit', '-q', '-m', 'base')
        for p in ['change.patch'] + (['fix.patch'] if has_fix else []):
            git('apply', os.path.abspath(f'{E}/{case}/{p}'))
        git('add', '-A')
        return git('diff', '--cached').stdout


def block_scalar(text, indent):
    pad = ' ' * indent
    return '|\n' + '\n'.join(pad + l if l else '' for l in text.rstrip('\n').split('\n'))


def structural(output, tables_ok):
    """(name, pattern, negate): checks on the PR file's shape."""
    out = [
        ('title-on-first-line', r'^# \S', False),
        ('headings-from-the-template', r'(?m)^## (?!(?:' + '|'.join(HEADINGS) + r')\s*$)', True),
        # Any heading after one the template puts later.
        ('headings-in-order', '|'.join(
            rf'^## {later}\s*$[\s\S]*^## {earlier}\s*$'
            for i, earlier in enumerate(HEADINGS) for later in HEADINGS[i + 1:]).join(['(?m)', '']), True),
        # A closing keyword before the first heading, or under any heading but
        # Intent. (?<![\s\S]) is the start of the file.
        ('closes-in-intent', r'(?m)(?:(?<![\s\S])|^## (?!Intent\s*$)[^\n]*\n)(?:(?!## )[^\n]*\n)*?[^\n]*' + CLOSES, True),
    ]
    if not tables_ok:
        # A GFM header row, then a delimiter row; outer pipes are optional.
        out.append(('no-table', r'(?m)^ {0,3}[^\n]*\|[^\n]*\n {0,3}(?=[^\n]*\|)\|?[ \t]*:?-+:?[ \t]*(?:\|[ \t]*:?-+:?[ \t]*)*\|?[ \t]*$', True))
    return out


for case in cases:
    g = load(f'{T}/gen/{case}.yaml')
    output = g.get('output', 'pr/new.md')
    prompt = g['prompt'].rstrip('\n') + '\n'
    has_fix = os.path.exists(f'{E}/{case}/fix.patch')
    diff = net_diff(case, has_fix)

    setup = (f"git init -q -b main && git add -A -- . ':!change.patch' ':!fix.patch' && "
             f"git {FIXTURE} commit -q -m 'Initial commit' && git checkout -q -b {shlex.quote(g['branch'])} && "
             f"git apply change.patch && rm change.patch && git add -A -- . ':!fix.patch' && "
             f"git {FIXTURE} commit -q -m {shlex.quote(g['commit'])}")
    if has_fix:
        setup += (f" && git apply fix.patch && rm fix.patch && git add -A && "
                  f"git {FIXTURE} commit -q -m {shlex.quote(g['fix_commit'])}")
    files = ['{ src: workspace, dest: . }', '{ src: change.patch, dest: change.patch }']
    if has_fix:
        files.append('{ src: fix.patch, dest: fix.patch }')

    checks = structural(output, g.get('tables_ok', False))
    criteria = [(n, open(f'{T}/judges/{n}.txt').read().strip()) for n in QUESTIONS]
    criteria += [(c['name'], c['description'].strip()) for c in g.get('criteria', [])]
    n_regex, n_llm = len(checks), len(criteria)
    panel = (open(f'{T}/judges/_panel.txt').read()
             .replace('{request}', prompt).replace('{output}', output).replace('{diff}', diff.rstrip('\n')))

    out = [f'# Expected: {" ".join(g["expected_outcome"].split())}',
           f'name: writing-pull-requests-{case}', f'description: {q(" ".join(g["description"].split()))}',
           'defaults:', '  runs: 3', '  timeout: 20m', '  judge_timeout: 10m', '  executor: copilot-sdk', '  model: claude-opus-5.5',
           # Weights are per grader type; these give every scored grader an
           # equal share. Skill use is an indicator.
           'scoring:', '  threshold: 0.8', '  weights:', '    skill-invocation: 0',
           f'    file-matches: {n_regex / (n_regex + n_llm):g}',
           f'    panel: {n_llm / (n_regex + n_llm):g}',
           # At eval level, not on the stimulus, so an experiment variant can
           # replace the skills: a stimulus's environment wins over a variant's.
           'agent_environment:',
           '  skills: [../../../skills/writing-pull-requests]',
           f'  files: [{", ".join(files)}]',
           f'  commands: [{q(setup)}]',
           'stimuli:', f'  - name: {case}', f'    prompt: {block_scalar(prompt, 6)}',
           '    graders:',
           '      - name: skill-loaded', '        type: skill-invocation',
           '        config: { required: [writing-pull-requests] }']
    for name, pat, negate in checks:
        out += [f'      - name: {name}', '        type: file-matches',
                f'        config: {{ path: {output}, pattern: {q(pat)}, negate: {str(negate).lower()} }}']
    out += ['      - name: judges', '        type: panel', '        config:',
            f'          models: [{", ".join(JUDGES)}]', '          aggregation: majority',
            '          scoring: binary', '          evidence: [{ source: repo, max_file_bytes: 200000 }, { source: trajectory }]',
            f'          prompt: {block_scalar(panel, 12)}', '          criteria:']
    out += [f'            - {{ name: {n}, description: {q(d)} }}' for n, d in criteria]
    # Vally reads ${name} as a parameter; $${ is its escape for a literal ${.
    open(f'{E}/{case}/eval.yaml', 'w').write(('\n'.join(out) + '\n').replace('${', '$${'))
print('generated', len(cases))
