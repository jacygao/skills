"""Check the judges against the expected verdicts, with vally oracle.

  python3 validate.py <dir holding <case>/eval.yaml> <case,...> [sample,...]

For each case, grades each sample (default: ref,orig) in validate/<case>/ as if
the agent had written it, with only the case's judges panel, and compares each
question's verdict with validate/<case>/expected.tsv. A ? cell is not scored.
"""
import csv, json, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

E, cases = sys.argv[1], sys.argv[2].split(',')
samples = (sys.argv[3] if len(sys.argv) > 3 else 'ref,orig').split(',')
V = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'validate')
vally = os.environ.get('VALLY', 'vally')


def oracle(case):
    """The eval spec with only the judges, and one stimulus per sample."""
    s = open(f'{E}/{case}/eval.yaml').read()
    i = s.index('\nstimuli:\n') + len('\nstimuli:\n')
    head, stim = re.sub(r'scoring:\n(?:  .*\n)+', '', s[:i]), s[i:]
    g = stim.index('    graders:\n') + len('    graders:\n')
    stim = stim[:g] + stim[stim.index('      - name: judges\n'):]
    spec = head + ''.join(stim.replace(
        f'  - name: {case}\n',
        f'  - name: {smp}\n    golden_command: "mkdir -p issues && cp {os.path.abspath(V)}/{case}/{smp}.md issues/new.md"\n', 1
    ).replace('      - name: judges\n', f'      - name: judges-{smp}\n')  # grader names are unique per file
        for smp in samples)
    path = f'{E}/{case}/.oracle.eval.yaml'
    open(path, 'w').write(spec)
    out = subprocess.run([vally, 'oracle', '-e', path, '--output', 'jsonl'], capture_output=True, text=True,
                         env={**os.environ, 'VALLY_TELEMETRY_OPTOUT': '1'})
    os.remove(path)
    if not out.stdout.strip():
        print(f'{case}: {out.stderr[-500:]}', file=sys.stderr)
    got = {}
    for line in out.stdout.splitlines():
        r = json.loads(line)
        details = (r.get('gradeResult') or {}).get('details', [])
        if not details:
            print(f'{case} {r.get("stimulus")}: {r.get("error") or out.stderr[-300:]}', file=sys.stderr)
            continue
        for c in details[0]['metadata']['criteria']:
            got[r['stimulus'], c['name']] = 'P' if c['passed'] else 'F'
    return case, got


with ThreadPoolExecutor(len(cases)) as pool:
    results = list(pool.map(oracle, cases))
ok = bad = 0
for case, got in results:
    rows = list(csv.reader(open(f'{V}/{case}/expected.tsv'), delimiter='\t'))
    expected = {r[0]: dict(zip(rows[0][1:], r[1:])) for r in rows[1:]}
    for (smp, name), g in sorted(got.items()):
        exp = expected[smp].get(name, '?')
        mark = '' if exp == '?' else ('ok' if exp == g else 'MISMATCH')
        ok += mark == 'ok'
        bad += mark == 'MISMATCH'
        print(f'{case:16s} {smp:5s} {name:30s} expected {exp} got {g}  {mark}')
print(f'scored cells: {ok} match, {bad} mismatch')
