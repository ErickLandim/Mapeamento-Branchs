"""Validates every scenario in scenarios/scenarios.json.

  python scripts/validate.py            static script (bcovscan) vs expected.json
  python scripts/validate.py --delphi   also: Delphi pipeline (bcov.exe + IDE agent),
                                        expected.json check, static x runtime compare and
                                        instrumenter parity (Go x Delphi output identical)

Exit code 0 only when every check passes.
"""
import json, os, subprocess, sys, filecmp, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
EXE = '.exe' if os.name == 'nt' else ''
SCAN = ROOT / 'tools' / 'bcovscan' / ('bcovscan' + EXE)
BCOV = ROOT / 'bcov' / 'bin' / 'bcov.exe'
OUT = ROOT / '.bcov' / 'validate'


def run(cmd, **kw):
    print('  $', ' '.join(str(c) for c in cmd), flush=True)
    r = subprocess.run([str(c) for c in cmd], capture_output=True, text=True, encoding='utf-8', errors='replace', **kw)
    return r.returncode, r.stdout + r.stderr


def tail(text, n=25):
    return '\n'.join(text.strip().splitlines()[-n:])


def main():
    delphi = '--delphi' in sys.argv
    if not SCAN.exists():
        code, out = run(['go', 'build', '-o', SCAN.name, '.'], cwd=ROOT / 'tools' / 'bcovscan')
        if code:
            print(out)
            return 1
    cfg = json.loads((ROOT / 'scenarios' / 'scenarios.json').read_text(encoding='utf-8'))
    results = []
    for sc in cfg['scenarios']:
        name = sc['name']
        root = ROOT / sc['root']
        expected = ROOT / 'scenarios' / name / 'expected.json'
        print(f'\n=== {name} ===')
        # 1. static script
        sout = OUT / name / 'static'
        args = [SCAN, 'scan', '--root', root, '--out', sout]
        for s in sc['src']:
            args += ['--src', s]
        for t in sc['tests']:
            args += ['--tests', t]
        code, out = run(args)
        ok = code == 0
        if ok:
            code, out = run([SCAN, 'check', '--report', sout / 'coverage.json', '--expected', expected])
            ok = code == 0
        print(tail(out))
        results.append((name, 'script x esperado', ok))
        if not delphi:
            continue
        # 2. instrumenter parity (Go x Delphi)
        gi, di = OUT / name / 'go-instr', OUT / name / 'delphi-instr'
        a1 = [SCAN, 'instrument', '--root', root, '--out', gi]
        a2 = [BCOV, 'instrument', '--root', root, '--out', di]
        for s in sc['src']:
            a1 += ['--src', s]
            a2 += ['--src', s]
        c1, o1 = run(a1)
        c2, o2 = run(a2)
        same = c1 == 0 and c2 == 0
        if same:
            for f in gi.rglob('*.pas'):
                g = di / f.relative_to(gi)
                if not g.exists() or f.read_bytes() != g.read_bytes():
                    print('  parity: differs', f.relative_to(gi))
                    same = False
            m1 = json.loads((gi / 'bcov.map.json').read_text(encoding='utf-8-sig'))
            m2 = json.loads((di / 'bcov.map.json').read_text(encoding='utf-8-sig'))
            if m1 != m2:
                print('  parity: bcov.map.json differs')
                same = False
        else:
            print(tail(o1), tail(o2))
        results.append((name, 'paridade instrumentação Go x Delphi', same))
        # 3. real run through the IDE agent
        dout = OUT / name / 'delphi'
        args = [BCOV, 'run', '--root', root, '--out', dout]
        for s in sc['src']:
            args += ['--src', s]
        for p in sc['projects']:
            path, _, plat = p.partition('@')
            args += ['--project', str(root / path) + ('@' + plat if plat else '')]
        code, out = run(args)
        print(tail(out, 40))
        rep = dout / 'report' / 'coverage.json'
        ok = code == 0 and rep.exists()
        if ok:
            code, out = run([SCAN, 'check', '--report', rep, '--expected', expected])
            print(tail(out))
            ok = code == 0
        results.append((name, 'Delphi (BPL/runtime) x esperado', ok))
        if rep.exists():
            code, out = run([SCAN, 'compare', '--a', rep, '--b', sout / 'coverage.json'])
            print(tail(out))
            results.append((name, 'Delphi x script (itens idênticos)', code == 0))
    print('\n=== resumo ===')
    for name, what, ok in results:
        print(f'{"OK  " if ok else "FAIL"} {name}: {what}')
    return 0 if all(ok for _, _, ok in results) else 1


if __name__ == '__main__':
    sys.exit(main())
